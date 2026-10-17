"""
Metadata Enrichment Module.

Conforms to ARCHITECTURE.md Section 8 (app/ingestion/chunkers/metadata_enricher.py).
Takes raw splits from recursive_chunker and decorates each chunk with multi-dimensional
financial facets:
- ticker, fiscal_quarter, fiscal_year
- page_number coordinates
- financial_domain classification ('profitability', 'balance_sheet', 'cash_flow', etc.)
- deterministic ID: {ticker}_{quarter}_{year}_p{page}_c{idx}
"""

import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.schemas.common import FinancialDomain
from app.ingestion.parsers.pdf_extractor import ExtractedPage, extract_text_by_pages
from app.ingestion.parsers.section_classifier import (
    PageClassification,
    classify_document_pages,
)
from app.ingestion.chunkers.recursive_chunker import split_page_text


@dataclass(frozen=True)
class EnrichedChunk:
    """Represents a semantic chunk enriched with multi-dimensional financial metadata."""
    chunk_id: str             # Deterministic ID: {ticker}_{quarter}_{year}_p{page}_c{idx}
    text: str                 # The chunk text
    ticker: str               # e.g., 'META'
    fiscal_quarter: str       # e.g., 'Q2'
    fiscal_year: int          # e.g., 2026
    page_number: int          # 1-indexed source page
    financial_domain: str     # 'profitability', 'balance_sheet', 'cash_flow', etc.
    char_count: int           # Length of the chunk text
    chunk_index_in_page: int  # 0-indexed chunk offset on this specific page
    total_chunks_in_page: int # Total chunks created from this page


def enrich_split(
    text: str,
    ticker: str,
    fiscal_quarter: str,
    fiscal_year: int,
    page_number: int,
    domain: str,
    chunk_index_in_page: int,
    total_chunks_in_page: int,
) -> EnrichedChunk:
    """Decorates a single text split with financial metadata and a deterministic ID."""
    clean_text = text.strip()
    chunk_id = f"{ticker.upper().strip()}_{fiscal_quarter.upper().strip()}_{fiscal_year}_p{page_number}_c{chunk_index_in_page}"
    return EnrichedChunk(
        chunk_id=chunk_id,
        text=clean_text,
        ticker=ticker.upper().strip(),
        fiscal_quarter=fiscal_quarter.upper().strip(),
        fiscal_year=fiscal_year,
        page_number=page_number,
        financial_domain=domain,
        char_count=len(clean_text),
        chunk_index_in_page=chunk_index_in_page,
        total_chunks_in_page=total_chunks_in_page,
    )


def chunk_document_pages(
    pages: List[ExtractedPage],
    classifications: List[PageClassification],
    ticker: str,
    fiscal_quarter: str,
    fiscal_year: int,
    chunk_size: int = 1000,
    chunk_overlap: int = 100,
) -> List[EnrichedChunk]:
    """
    Coordinates page-level recursive chunking and metadata enrichment.
    
    1. Skips blank or empty pages.
    2. Splits page text via recursive_chunker.split_page_text().
    3. Inherits classified financial_domain for that page.
    4. Stamps deterministic chunk IDs and pagination metadata.
    """
    class_map = {c.page_number: c.domain.value for c in classifications}
    all_chunks: List[EnrichedChunk] = []

    for page in pages:
        if page.is_blank or not page.text.strip():
            continue

        splits = split_page_text(
            text=page.text,
            chunk_size=chunk_size,
            chunk_overlap=chunk_overlap,
        )
        if not splits:
            continue

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

    return all_chunks


if __name__ == "__main__":
    import json
    from datetime import datetime

    test_pdf = Path(sys.argv[1]) if len(sys.argv) > 1 else _SERVER_ROOT / "tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if not test_pdf.exists():
        print(f"❌ PDF not found at {test_pdf}")
        sys.exit(1)

    print(f"🚀 Chunking and enriching: {test_pdf.name}...")
    res = extract_text_by_pages(test_pdf)
    classifications = classify_document_pages(res.pages)
    chunks = chunk_document_pages(
        pages=res.pages,
        classifications=classifications,
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
    )

    print(f"✅ Generated {len(chunks)} enriched semantic chunks across {res.total_pages} pages!")

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    base_slug = test_pdf.stem.lower().replace("-", "_").replace(".", "_")
    artifact_data = {
        "timestamp": datetime.now().isoformat(),
        "pdf_name": test_pdf.name,
        "ticker": "META",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "total_pages": res.total_pages,
        "total_chunks": len(chunks),
        "chunks": [asdict(c) for c in chunks],
    }

    json_path = artifact_dir / f"03_chunks_{base_slug}.json"
    json_b_path = artifact_dir / f"03b_enriched_chunks_{base_slug}.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(artifact_data, f, indent=2)
    with open(json_b_path, "w", encoding="utf-8") as f:
        json.dump(artifact_data, f, indent=2)

    md_content = f"# 🧩 Semantic Chunks & Facets Artifact: `{test_pdf.name}`\n\n"
    md_content += f"- **Timestamp**: `{artifact_data['timestamp']}`\n"
    md_content += f"- **Ticker / Period**: `META` (`Q2 2026`)\n"
    md_content += f"- **Total Source Pages**: `{res.total_pages}`\n"
    md_content += f"- **Total Chunks Produced**: `{len(chunks)}`\n\n"
    for c in chunks:
        md_content += f"### Chunk `{c.chunk_id}`\n"
        md_content += f"- **Domain**: `{c.financial_domain}` | **Page**: `{c.page_number}` | **Length**: `{c.char_count}` chars\n\n"
        md_content += "```text\n" + c.text + "\n```\n\n"

    md_path = artifact_dir / f"03_chunks_{base_slug}.md"
    md_b_path = artifact_dir / f"03b_enriched_chunks_{base_slug}.md"
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(md_content)
    with open(md_b_path, "w", encoding="utf-8") as f:
        f.write(md_content)

    print(f"📄 Saved Artifacts:\n  • {json_b_path}\n  • {md_b_path}\n  • {json_path}\n  • {md_path}")
