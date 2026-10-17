"""
Ingestion Pipeline Orchestrator Module.

Conforms to ARCHITECTURE.md Section 5.4 & 8 (app/ingestion/pipeline.py).
Orchestrates the entire document processing lifecycle:
1. Validation & SHA-256 Hashing (validator.py)
2. Instant 0.1ms Deduplication Check in SQLite (document_repo.py)
3. Page-by-page Layout Text Extraction (pdf_extractor.py)
4. GAAP Section Classification & Domain Tagging (section_classifier.py)
5. Structured GAAP KPI Extraction via LLM (kpi_extractor.py) - Dynamic ticker & period discovery
6. Recursive Chunking & Metadata Enrichment (metadata_enricher.py & recursive_chunker.py)
7. Deterministic SQLite Persistence (kpi_repo.py)
8. Real-time IngestionTask status lifecycle tracking and comprehensive artifact generation
"""

import argparse
import json
import os
import sys
import time
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Union

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.db.session import SessionLocal, init_db, engine
from app.db.models import DocumentModel, IngestionTaskModel
from app.db.repositories.document_repo import (
    create_task,
    get_document_by_hash,
    save_document,
    update_task_status,
)
from app.db.repositories.kpi_repo import get_kpis_by_document_id, get_kpis_by_quarter
from app.ingestion.chunkers.metadata_enricher import chunk_document_pages, EnrichedChunk
from app.ingestion.chunkers.recursive_chunker import split_page_text
from app.ingestion.extractor.kpi_extractor import (
    extract_financial_kpis,
    save_extracted_kpis_to_db,
)
from app.ingestion.parsers.pdf_extractor import (
    PDFExtractionResult,
    ExtractedPage,
    extract_text_by_pages,
)
from app.ingestion.parsers.section_classifier import (
    PageClassification,
    classify_document_pages,
)
from app.ingestion.validator import PDFValidationResult, validate_and_hash_pdf
from app.schemas.kpis import FinancialReportKPIs


@dataclass
class IngestionResult:
    """Standardized result returned by the Ingestion Pipeline."""
    task_id: str
    status: str  # "COMPLETED" | "FAILED"
    document_id: Optional[str]
    ticker: str
    fiscal_quarter: str
    fiscal_year: int
    report_title: str
    sha256_hash: str
    file_path: str
    page_count: int
    is_duplicate: bool
    kpis: Optional[Dict[str, Any]]
    duration_seconds: float = 0.0
    error_message: Optional[str] = None


class IngestionPipeline:
    """
    Central coordinator for the Document Ingestion Pipeline.
    Thread-safe and decoupled for both CLI runners and background workers.
    """

    def __init__(
        self,
        session_factory: Callable = SessionLocal,
        llm: Optional[Any] = None,
        progress_callback: Optional[Callable[[str, int, str], None]] = None,
    ):
        self.session_factory = session_factory
        self.llm = llm
        self.progress_callback = progress_callback

    def _notify(
        self,
        session,
        task_id: str,
        status: str,
        progress_percent: int,
        message: str,
        document_id: Optional[str] = None,
        error_details: Optional[str] = None,
    ):
        """Updates the SQLite task row and triggers any external listener."""
        update_task_status(
            session=session,
            task_id=task_id,
            status=status,
            progress_percent=progress_percent,
            message=message,
            document_id=document_id,
            error_details=error_details,
        )
        if self.progress_callback:
            try:
                self.progress_callback(status, progress_percent, message)
            except Exception:
                pass

    def run(
        self,
        file_path: Union[str, Path],
        ticker: Optional[str] = None,
        fiscal_quarter: Optional[str] = None,
        fiscal_year: Optional[int] = None,
        task_id: Optional[str] = None,
        force_reprocess: bool = False,
        save_artifacts: bool = False,
    ) -> IngestionResult:
        """
        Executes the end-to-end ingestion pipeline.
        
        - If ticker/quarter/year are omitted, they are dynamically extracted from filing content by LLM.
        - If document already exists, executes 0.1ms instant deduplication (unless force_reprocess=True).
        - When save_artifacts=True, generates inspection artifacts for all pipeline substeps.
        """
        start_time = time.time()
        path = Path(file_path).resolve()
        session = self.session_factory()

        # Clean optional user hints (if explicitly provided)
        resolved_ticker = ticker.upper().strip() if ticker else None
        resolved_quarter = fiscal_quarter.upper().strip() if fiscal_quarter else None
        resolved_year = int(fiscal_year) if fiscal_year else None

        # Step 0: Ensure active tracking task exists in SQLite
        if not task_id:
            task = create_task(session, ticker=resolved_ticker)
            active_task_id = task.id
        else:
            active_task_id = task_id

        try:
            # -------------------------------------------------------------
            # Step 1: Validate PDF Format & Compute SHA-256 (15%)
            # -------------------------------------------------------------
            self._notify(
                session,
                active_task_id,
                status="VALIDATING",
                progress_percent=15,
                message=f"Validating file header and computing SHA-256 checksum for {path.name}...",
            )
            val_res = validate_and_hash_pdf(path)
            if not val_res.is_valid:
                error_msg = f"PDF Validation Error: {val_res.error_message}"
                self._notify(
                    session,
                    active_task_id,
                    status="FAILED",
                    progress_percent=100,
                    message="Validation failed",
                    error_details=error_msg,
                )
                return IngestionResult(
                    task_id=active_task_id,
                    status="FAILED",
                    document_id=None,
                    ticker=resolved_ticker or "UNKNOWN",
                    fiscal_quarter=resolved_quarter or "UNKNOWN",
                    fiscal_year=resolved_year or 0,
                    report_title=path.stem,
                    sha256_hash=val_res.sha256_hash or "",
                    file_path=str(path),
                    page_count=0,
                    is_duplicate=False,
                    kpis=None,
                    duration_seconds=round(time.time() - start_time, 3),
                    error_message=error_msg,
                )

            # -------------------------------------------------------------
            # Step 2: Instant 0.1ms Deduplication Check in SQLite (25%)
            # -------------------------------------------------------------
            self._notify(
                session,
                active_task_id,
                status="DEDUPLICATING",
                progress_percent=25,
                message="Checking database for existing document fingerprint...",
            )
            existing_doc = get_document_by_hash(session, val_res.sha256_hash)
            if existing_doc and not force_reprocess:
                existing_kpi = get_kpis_by_document_id(session, existing_doc.id)
                if not existing_kpi:
                    existing_kpi = get_kpis_by_quarter(
                        session,
                        existing_doc.ticker,
                        existing_doc.fiscal_year,
                        existing_doc.fiscal_quarter,
                    )

                if existing_kpi:
                    self._notify(
                        session,
                        active_task_id,
                        status="COMPLETED",
                        progress_percent=100,
                        message=f"Instant deduplication: Document '{existing_doc.report_title}' already fully ingested in SQLite (use --force to re-process).",
                        document_id=existing_doc.id,
                    )
                    res = IngestionResult(
                        task_id=active_task_id,
                        status="COMPLETED",
                        document_id=existing_doc.id,
                        ticker=existing_doc.ticker,
                        fiscal_quarter=existing_doc.fiscal_quarter,
                        fiscal_year=existing_doc.fiscal_year,
                        report_title=existing_doc.report_title,
                        sha256_hash=existing_doc.sha256_hash,
                        file_path=existing_doc.file_path,
                        page_count=existing_doc.page_count,
                        is_duplicate=True,
                        kpis=existing_kpi.to_dict(),
                        duration_seconds=round(time.time() - start_time, 3),
                    )
                    if save_artifacts:
                        self._save_pipeline_artifact(path, res)
                    return res

            # -------------------------------------------------------------
            # Step 3: Layout & Page Text Extraction (40%)
            # -------------------------------------------------------------
            self._notify(
                session,
                active_task_id,
                status="EXTRACTING",
                progress_percent=40,
                message="Extracting page-by-page text hierarchy...",
            )
            extraction_res = extract_text_by_pages(path)

            # -------------------------------------------------------------
            # Step 4: GAAP Section Classification (55%)
            # -------------------------------------------------------------
            self._notify(
                session,
                active_task_id,
                status="CLASSIFYING",
                progress_percent=55,
                message="Classifying financial statement sections and tagging GAAP domains...",
            )
            classifications = classify_document_pages(extraction_res.pages)

            # -------------------------------------------------------------
            # Step 5: Structured GAAP KPI Extraction via LLM (70%)
            # -------------------------------------------------------------
            self._notify(
                session,
                active_task_id,
                status="EXTRACTING_KPIS",
                progress_percent=70,
                message="Auditing statements and dynamically extracting 18+ GAAP KPIs with math validation...",
            )
            extracted_kpis: FinancialReportKPIs = extract_financial_kpis(
                extracted_pages=extraction_res.pages,
                classifications=classifications,
                llm=self.llm,
                ticker_hint=resolved_ticker,
                quarter_hint=resolved_quarter,
                year_hint=resolved_year,
            )

            # Authoritative extracted metadata directly from filing
            canonical_ticker = extracted_kpis.ticker.upper().strip()
            canonical_quarter = extracted_kpis.fiscal_quarter.upper().strip()
            canonical_year = int(extracted_kpis.fiscal_year)
            canonical_title = extracted_kpis.report_title or path.stem

            # -------------------------------------------------------------
            # Step 6: Recursive Chunking & Metadata Enrichment (85%)
            # -------------------------------------------------------------
            self._notify(
                session,
                active_task_id,
                status="CHUNKING",
                progress_percent=85,
                message="Splitting text and attaching metadata facets (ticker, quarter, year, domain)...",
            )
            chunks, pages_splits = self._chunk_and_collect_splits(
                pages=extraction_res.pages,
                classifications=classifications,
                ticker=canonical_ticker,
                fiscal_quarter=canonical_quarter,
                fiscal_year=canonical_year,
            )

            # -------------------------------------------------------------
            # Step 7: Deterministic SQLite Persistence (95%)
            # -------------------------------------------------------------
            self._notify(
                session,
                active_task_id,
                status="PERSISTING",
                progress_percent=95,
                message="Persisting document record and audited KPIs into SQLite database...",
            )
            if existing_doc:
                doc = existing_doc
                doc.ticker = canonical_ticker
                doc.fiscal_quarter = canonical_quarter
                doc.fiscal_year = canonical_year
                doc.report_title = canonical_title
                doc.page_count = extraction_res.total_pages
                session.commit()
            else:
                doc = save_document(session, {
                    "ticker": canonical_ticker,
                    "fiscal_quarter": canonical_quarter,
                    "fiscal_year": canonical_year,
                    "report_title": canonical_title,
                    "sha256_hash": val_res.sha256_hash,
                    "file_path": str(path),
                    "page_count": extraction_res.total_pages,
                })

            persisted_kpi = save_extracted_kpis_to_db(session, doc.id, extracted_kpis)

            # -------------------------------------------------------------
            # Step 8: Completion (100%)
            # -------------------------------------------------------------
            self._notify(
                session,
                active_task_id,
                status="COMPLETED",
                progress_percent=100,
                message=f"Successfully ingested {doc.ticker} {doc.fiscal_quarter} {doc.fiscal_year} into SQLite database.",
                document_id=doc.id,
            )

            duration = round(time.time() - start_time, 3)
            result = IngestionResult(
                task_id=active_task_id,
                status="COMPLETED",
                document_id=doc.id,
                ticker=doc.ticker,
                fiscal_quarter=doc.fiscal_quarter,
                fiscal_year=doc.fiscal_year,
                report_title=doc.report_title,
                sha256_hash=doc.sha256_hash,
                file_path=doc.file_path,
                page_count=doc.page_count,
                is_duplicate=False,
                kpis=persisted_kpi.to_dict(),
                duration_seconds=duration,
            )

            if save_artifacts:
                self._save_all_substep_artifacts(
                    path=path,
                    extraction_res=extraction_res,
                    classifications=classifications,
                    pages_splits=pages_splits,
                    chunks=chunks,
                    extracted_kpis=extracted_kpis,
                    doc=doc,
                    persisted_kpi=persisted_kpi,
                    result=result,
                    val_res=val_res,
                )

            return result

        except Exception as e:
            error_msg = f"Unexpected error in IngestionPipeline: {str(e)}"
            self._notify(
                session,
                active_task_id,
                status="FAILED",
                progress_percent=100,
                message="Ingestion process encountered an error",
                error_details=error_msg,
            )
            return IngestionResult(
                task_id=active_task_id,
                status="FAILED",
                document_id=None,
                ticker=resolved_ticker or "UNKNOWN",
                fiscal_quarter=resolved_quarter or "UNKNOWN",
                fiscal_year=resolved_year or 0,
                report_title=path.stem,
                sha256_hash=val_res.sha256_hash if 'val_res' in locals() and val_res.sha256_hash else "",
                file_path=str(path),
                page_count=0,
                is_duplicate=False,
                kpis=None,
                duration_seconds=round(time.time() - start_time, 3),
                error_message=error_msg,
            )
        finally:
            session.close()

    def _chunk_and_collect_splits(
        self,
        pages: List[ExtractedPage],
        classifications: List[PageClassification],
        ticker: str,
        fiscal_quarter: str,
        fiscal_year: int,
    ):
        """Runs page-level recursive chunking while collecting raw splits and enriched chunks."""
        from app.schemas.common import FinancialDomain
        from app.ingestion.chunkers.metadata_enricher import enrich_split

        class_map = {c.page_number: c.domain.value for c in classifications}
        all_chunks: List[EnrichedChunk] = []
        pages_splits: List[Dict[str, Any]] = []

        for page in pages:
            if page.is_blank or not page.text.strip():
                continue

            splits = split_page_text(text=page.text, chunk_size=1000, chunk_overlap=100)
            if not splits:
                continue

            pages_splits.append({
                "page_number": page.page_number,
                "split_count": len(splits),
                "char_count": page.char_count,
                "splits": [
                    {"split_index": idx, "char_count": len(s), "text": s}
                    for idx, s in enumerate(splits)
                ],
            })

            domain_str = class_map.get(page.page_number, FinancialDomain.GENERAL.value)
            for c_idx, split_text in enumerate(splits):
                chunk = enrich_split(
                    text=split_text,
                    ticker=ticker,
                    fiscal_quarter=fiscal_quarter,
                    fiscal_year=fiscal_year,
                    page_number=page.page_number,
                    domain=domain_str,
                    chunk_index_in_page=c_idx,
                    total_chunks_in_page=len(splits),
                )
                all_chunks.append(chunk)

        return all_chunks, pages_splits

    def _save_pipeline_artifact(self, path: Path, result: IngestionResult):
        """Saves the 06_pipeline_ingest artifact."""
        artifact_dir = _SERVER_ROOT / ".artifact"
        artifact_dir.mkdir(parents=True, exist_ok=True)
        base_slug = path.stem.lower().replace("-", "_").replace(".", "_")

        json_path = artifact_dir / f"06_pipeline_ingest_{base_slug}.json"
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(asdict(result), f, indent=2)

        md_path = artifact_dir / f"06_pipeline_ingest_{base_slug}.md"
        with open(md_path, "w", encoding="utf-8") as f:
            f.write(f"# 🚀 End-to-End Ingestion Pipeline Artifact: `{path.name}`\n\n")
            f.write(f"- **Execution Status**: `{result.status}`\n")
            f.write(f"- **Execution Time**: `{result.duration_seconds}s`\n")
            f.write(f"- **Task ID**: `{result.task_id}`\n")
            f.write(f"- **Document ID**: `{result.document_id}`\n")
            f.write(f"- **SHA-256 Hash**: `{result.sha256_hash}`\n")
            f.write(f"- **Instant Deduplication Triggered**: `{result.is_duplicate}`\n")
            f.write(f"- **Ticker / Period**: `{result.ticker}` — `{result.fiscal_quarter} {result.fiscal_year}`\n\n")

            if result.kpis:
                k = result.kpis
                f.write("## Persisted Financial KPIs in SQLite\n\n")
                f.write("| Line Item | Value | Margin |\n")
                f.write("| :--- | :--- | :--- |\n")
                f.write(f"| **Revenue** | `${k.get('revenue', 0):,.1f}M` | - |\n")
                f.write(f"| **Gross Profit** | `${k.get('gross_profit', 0):,.1f}M` | `{k.get('gross_margin', 0):.1%}` |\n")
                f.write(f"| **Operating Income** | `${k.get('operating_income', 0):,.1f}M` | `{k.get('operating_margin', 0):.1%}` |\n")
                f.write(f"| **Net Income** | `${k.get('net_income', 0):,.1f}M` | `{k.get('net_margin', 0):.1%}` |\n")
                f.write(f"| **Operating Cash Flow** | `${k.get('operating_cash_flow', 0):,.1f}M` | - |\n")
                f.write(f"| **Capital Expenditures** | `${k.get('capital_expenditures', 0):,.1f}M` | - |\n")
                f.write(f"| **Free Cash Flow** | **`${k.get('free_cash_flow', 0):,.1f}M`** | - |\n")
                f.write(f"| **Cash & Equivalents** | `${k.get('cash_and_equivalents', 0):,.1f}M` | - |\n")
                f.write(f"| **Total Debt** | `${k.get('long_term_debt', 0):,.1f}M` | - |\n")
                f.write(f"| **Shareholders' Equity** | `${k.get('shareholders_equity', 0):,.1f}M` | - |\n\n")
                f.write(f"**Audit Citation Pages**: `{k.get('source_pages')}`\n")

    def _save_all_substep_artifacts(
        self,
        path: Path,
        extraction_res: PDFExtractionResult,
        classifications: List[PageClassification],
        pages_splits: List[Dict[str, Any]],
        chunks: List[EnrichedChunk],
        extracted_kpis: FinancialReportKPIs,
        doc: DocumentModel,
        persisted_kpi: Any,
        result: IngestionResult,
        val_res: PDFValidationResult,
    ):
        """Generates inspectable JSON & MD artifacts for every pipeline substep."""
        artifact_dir = _SERVER_ROOT / ".artifact"
        artifact_dir.mkdir(parents=True, exist_ok=True)
        base_slug = path.stem.lower().replace("-", "_").replace(".", "_")

        # 1. Page-by-Page Extraction Artifacts (01_extracted_*)
        extract_data = {
            "timestamp": datetime.now().isoformat(),
            "file_name": extraction_res.file_name,
            "total_pages": extraction_res.total_pages,
            "total_characters": extraction_res.total_characters,
            "blank_pages_count": extraction_res.blank_pages_count,
            "metadata": extraction_res.metadata,
            "pages": [asdict(p) for p in extraction_res.pages],
        }
        with open(artifact_dir / f"01_extracted_{base_slug}.json", "w", encoding="utf-8") as f:
            json.dump(extract_data, f, indent=2)
        with open(artifact_dir / f"01_extracted_{base_slug}.md", "w", encoding="utf-8") as f:
            f.write(f"# 📑 Extracted PDF Pages Artifact: `{extraction_res.file_name}`\n\n")
            f.write(f"- **Timestamp**: `{extract_data['timestamp']}`\n")
            f.write(f"- **Total Pages**: `{extraction_res.total_pages}`\n")
            f.write(f"- **Total Characters**: `{extraction_res.total_characters:,}`\n")
            f.write(f"- **Blank Pages Count**: `{extraction_res.blank_pages_count}`\n\n")
            for p in extraction_res.pages:
                f.write(f"## Page {p.page_number} ({p.char_count} chars)\n")
                snippet = p.text[:400] + "..." if len(p.text) > 400 else p.text
                f.write(f"```text\n{snippet}\n```\n\n")

        # 2. Section Classifications Artifacts (02_classified_*)
        class_data = {
            "timestamp": datetime.now().isoformat(),
            "file_name": path.name,
            "total_pages": len(classifications),
            "classifications": [
                {
                    "page_number": c.page_number,
                    "domain": c.domain.value,
                    "confidence": c.confidence,
                    "matched_signals": c.matched_signals,
                }
                for c in classifications
            ],
        }
        with open(artifact_dir / f"02_classified_{base_slug}.json", "w", encoding="utf-8") as f:
            json.dump(class_data, f, indent=2)
        with open(artifact_dir / f"02_classified_{base_slug}.md", "w", encoding="utf-8") as f:
            f.write(f"# 🏷️ Classified Sections Artifact: `{path.name}`\n\n")
            f.write(f"- **Timestamp**: `{class_data['timestamp']}`\n")
            f.write(f"- **Total Pages**: `{len(classifications)}`\n\n")
            f.write("| Page | Financial Domain | Confidence | Matched Signals |\n")
            f.write("| :--- | :--- | :--- | :--- |\n")
            for c in classifications:
                signals = "<br/>".join(c.matched_signals)
                f.write(f"| {c.page_number} | **`{c.domain.value}`** | `{c.confidence:.2f}` | {signals} |\n")

        # 3. Recursive Splits Artifacts (03a_recursive_splits_*)
        splits_data = {
            "timestamp": datetime.now().isoformat(),
            "pdf_name": path.name,
            "total_pages": extraction_res.total_pages,
            "non_blank_pages": len(pages_splits),
            "chunk_size": 1000,
            "chunk_overlap": 100,
            "total_splits": sum(p["split_count"] for p in pages_splits),
            "pages": pages_splits,
        }
        with open(artifact_dir / f"03a_recursive_splits_{base_slug}.json", "w", encoding="utf-8") as f:
            json.dump(splits_data, f, indent=2)
        with open(artifact_dir / f"03a_recursive_splits_{base_slug}.md", "w", encoding="utf-8") as f:
            f.write(f"# ✂️ Recursive Text Splits Artifact: `{path.name}`\n\n")
            f.write(f"- **Timestamp**: `{splits_data['timestamp']}`\n")
            f.write(f"- **Total Source Pages**: `{extraction_res.total_pages}`\n")
            f.write(f"- **Non-Blank Pages Split**: `{len(pages_splits)}`\n")
            f.write(f"- **Total Raw Splits Produced**: `{splits_data['total_splits']}`\n\n")
            for p in pages_splits:
                f.write(f"### 📄 Page {p['page_number']} ({p['split_count']} splits, {p['char_count']:,} chars)\n\n")
                for s in p["splits"]:
                    f.write(f"#### Split {s['split_index'] + 1}/{p['split_count']} ({s['char_count']} chars)\n\n")
                    f.write(f"```text\n{s['text']}\n```\n\n")

        # 4. Enriched Semantic Chunks Artifacts (03b_enriched_chunks_*)
        enriched_data = {
            "timestamp": datetime.now().isoformat(),
            "pdf_name": path.name,
            "ticker": doc.ticker,
            "fiscal_quarter": doc.fiscal_quarter,
            "fiscal_year": doc.fiscal_year,
            "total_pages": extraction_res.total_pages,
            "total_chunks": len(chunks),
            "chunks": [asdict(c) for c in chunks],
        }
        with open(artifact_dir / f"03b_enriched_chunks_{base_slug}.json", "w", encoding="utf-8") as f:
            json.dump(enriched_data, f, indent=2)
        with open(artifact_dir / f"03b_enriched_chunks_{base_slug}.md", "w", encoding="utf-8") as f:
            f.write(f"# 🧩 Semantic Chunks & Facets Artifact: `{path.name}`\n\n")
            f.write(f"- **Timestamp**: `{enriched_data['timestamp']}`\n")
            f.write(f"- **Ticker / Period**: `{doc.ticker}` (`{doc.fiscal_quarter} {doc.fiscal_year}`)\n")
            f.write(f"- **Total Source Pages**: `{extraction_res.total_pages}`\n")
            f.write(f"- **Total Chunks Produced**: `{len(chunks)}`\n\n")
            for c in chunks:
                f.write(f"### Chunk `{c.chunk_id}`\n")
                f.write(f"- **Domain**: `{c.financial_domain}` | **Page**: `{c.page_number}` | **Length**: `{c.char_count}` chars\n\n")
                f.write(f"```text\n{c.text}\n```\n\n")

        # 5. Extracted GAAP KPIs Artifacts (04_extracted_kpis_*)
        kpi_dict = extracted_kpis.model_dump()
        with open(artifact_dir / f"04_extracted_kpis_{base_slug}.json", "w", encoding="utf-8") as f:
            json.dump({
                "timestamp": datetime.now().isoformat(),
                "pdf_name": path.name,
                "extracted_kpis": kpi_dict,
                "status": "extracted_and_math_validated",
            }, f, indent=2)
        with open(artifact_dir / f"04_extracted_kpis_{base_slug}.md", "w", encoding="utf-8") as f:
            f.write(f"# 📊 Extracted Financial KPIs Artifact: `{path.name}`\n\n")
            f.write(f"- **Company / Ticker**: `{extracted_kpis.ticker}`\n")
            f.write(f"- **Fiscal Period**: `{extracted_kpis.fiscal_quarter} {extracted_kpis.fiscal_year}`\n")
            f.write(f"- **Report Title**: `{extracted_kpis.report_title}`\n\n")
            f.write("```json\n" + json.dumps(kpi_dict, indent=2) + "\n```\n")

        # 6. Persisted SQLite KPIs Artifacts (05_persisted_kpis_*)
        persisted_dict = persisted_kpi.to_dict()
        with open(artifact_dir / f"05_persisted_kpis_{base_slug}.json", "w", encoding="utf-8") as f:
            json.dump({
                "timestamp": datetime.now().isoformat(),
                "pdf_name": path.name,
                "document_id": doc.id,
                "kpi_record_id": persisted_kpi.id,
                "persisted_kpis": persisted_dict,
                "status": "persisted_in_sqlite",
            }, f, indent=2)
        with open(artifact_dir / f"05_persisted_kpis_{base_slug}.md", "w", encoding="utf-8") as f:
            f.write(f"# 🗄️ Persisted SQLite Financial KPIs Artifact: `{path.name}`\n\n")
            f.write(f"- **Document ID**: `{doc.id}`\n")
            f.write(f"- **Ticker / Period**: `{persisted_kpi.ticker}` — `{persisted_kpi.fiscal_quarter} {persisted_kpi.fiscal_year}`\n")
            f.write(f"- **Audit Lineage**: Source Pages `{persisted_kpi.source_pages}`\n\n")
            f.write("```json\n" + json.dumps(persisted_dict, indent=2) + "\n```\n")

        # 7. Pipeline Execution Artifacts (06_pipeline_ingest_*)
        self._save_pipeline_artifact(path, result)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run the end-to-end Ingestion Pipeline on a PDF filing.")
    parser.add_argument("pdf_path", nargs="?", default=None, help="Path to PDF filing")
    parser.add_argument("--ticker", type=str, default=None, help="Optional ticker symbol hint (e.g., META, TSLA)")
    parser.add_argument("--quarter", type=str, default=None, help="Optional fiscal quarter hint (e.g., Q2)")
    parser.add_argument("--year", type=int, default=None, help="Optional fiscal year hint (e.g., 2026)")
    parser.add_argument("--force", action="store_true", help="Bypass deduplication and re-process filing end-to-end, regenerating all substep artifacts")
    args = parser.parse_args()

    test_pdf = Path(args.pdf_path) if args.pdf_path else _SERVER_ROOT / "tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if not test_pdf.exists():
        print(f"❌ PDF not found at {test_pdf}")
        sys.exit(1)

    init_db(engine)

    def log_progress(status: str, percent: int, msg: str):
        print(f"  [{percent:>3}%] {status:<15} ──▶ {msg}")

    print("\n" + "=" * 70)
    print(f"🚀 RUNNING END-TO-END INGESTION PIPELINE: {test_pdf.name}")
    print("=" * 70)

    pipeline = IngestionPipeline(progress_callback=log_progress)
    result = pipeline.run(
        file_path=test_pdf,
        ticker=args.ticker,
        fiscal_quarter=args.quarter,
        fiscal_year=args.year,
        force_reprocess=args.force,
        save_artifacts=True,
    )

    print("\n" + "=" * 70)
    print(f"🏁 PIPELINE EXECUTION {result.status} IN {result.duration_seconds}s")
    print("=" * 70)
    print(f"• Task ID:       {result.task_id}")
    print(f"• Document ID:   {result.document_id}")
    print(f"• Ticker/Period: {result.ticker} {result.fiscal_quarter} {result.fiscal_year}")
    print(f"• Duplicate:     {result.is_duplicate}")
    if result.kpis:
        print(f"• Revenue:       ${result.kpis.get('revenue', 0):,.1f}M")
        print(f"• Net Income:    ${result.kpis.get('net_income', 0):,.1f}M")
        print(f"• Free Cash Flow:${result.kpis.get('free_cash_flow', 0):,.1f}M")
        print(f"• Lineage Pages: {result.kpis.get('source_pages')}")

    base_slug = test_pdf.stem.lower().replace("-", "_").replace(".", "_")
    artifact_dir = _SERVER_ROOT / ".artifact"
    print(f"\n📄 Saved Pipeline Artifacts in server/.artifact/:")
    if result.is_duplicate and not args.force:
        print(f"  • 06_pipeline_ingest_{base_slug}.json & .md")
        print(f"  💡 Note: Document already fully ingested in SQLite. Substeps 3-7 skipped by instant 0.1ms deduplication.")
        print(f"     Pass '--force' to re-process filing end-to-end and generate all substep artifacts (01, 02, 03a, 03b, 04, 05).")
    else:
        print(f"  • 01_extracted_{base_slug}.json & .md (Page layouts)")
        print(f"  • 02_classified_{base_slug}.json & .md (GAAP section tags)")
        print(f"  • 03a_recursive_splits_{base_slug}.json & .md (Recursive text splits)")
        print(f"  • 03b_enriched_chunks_{base_slug}.json & .md (Enriched semantic chunks)")
        print(f"  • 04_extracted_kpis_{base_slug}.json & .md (Structured GAAP KPIs)")
        print(f"  • 05_persisted_kpis_{base_slug}.json & .md (SQLite persisted records)")
        print(f"  • 06_pipeline_ingest_{base_slug}.json & .md (Pipeline run summary)")
