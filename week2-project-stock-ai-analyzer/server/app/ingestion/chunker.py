"""
Semantic Chunker & Metadata Enricher
=====================================
Component: Step 1.4 in PDF Ingestion Pipeline

Purpose:
1. Split long PDF pages into optimal semantic chunks (~1,000 chars with 100 overlap)
   using LangChain's RecursiveCharacterTextSplitter.
2. Attach rich, typed metadata (ticker, quarter, year, page_number, financial_domain)
   to every chunk.
3. Form deterministic chunk IDs (e.g., 'META_Q2_2026_p5_c0') for traceable retrieval
   and verified LLM page-level citations.

Why chunking with overlap?
--------------------------
1. Splitting on paragraphs (\n\n) and line breaks (\n) prevents splitting financial
   table rows and sentences mid-word.
2. The 100-character overlap ensures that context bridging across chunk boundaries
   is never severed during semantic vector search.
"""

from dataclasses import dataclass, asdict
from pathlib import Path
import re
import sys
from typing import Dict, List, Optional, Union

# Ensure server root is on path when invoked directly
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from langchain_text_splitters import RecursiveCharacterTextSplitter

from app.ingestion.pdf_extractor import ExtractedPage
from app.ingestion.section_classifier import FinancialDomain, PageClassification


DEFAULT_CHUNK_SIZE = 1000
DEFAULT_CHUNK_OVERLAP = 100


@dataclass(frozen=True)
class EnrichedChunk:
    """
    A semantic chunk of financial text enriched with citation and domain metadata.

    Attributes:
        chunk_id: Deterministic unique ID (e.g. 'META_Q2_2026_p5_c0').
        ticker: Stock ticker symbol (e.g. 'META').
        fiscal_quarter: Quarter label (e.g. 'Q2').
        fiscal_year: Year integer (e.g. 2026).
        page_number: 1-indexed source PDF page number.
        financial_domain: Classified FinancialDomain value (e.g. 'profitability').
        text: Extracted text content of this chunk.
        char_count: Number of characters in the chunk.
        chunk_index_in_page: 0-indexed position within its parent page.
        global_chunk_index: 0-indexed position across the entire document.
    """
    chunk_id: str
    ticker: str
    fiscal_quarter: str
    fiscal_year: int
    page_number: int
    financial_domain: str
    text: str
    char_count: int
    chunk_index_in_page: int
    global_chunk_index: int


def chunk_document_pages(
    pages: List[ExtractedPage],
    classifications: List[PageClassification],
    ticker: str,
    fiscal_quarter: str,
    fiscal_year: int,
    chunk_size: int = DEFAULT_CHUNK_SIZE,
    chunk_overlap: int = DEFAULT_CHUNK_OVERLAP,
) -> List[EnrichedChunk]:
    """
    Splits document pages into overlapping semantic chunks and enriches each
    chunk with financial domain tags, source page numbers, and unique IDs.

    Args:
        pages: List of ExtractedPage objects from Step 1.2.
        classifications: List of PageClassification objects from Step 1.3.
        ticker: Uppercase ticker symbol (e.g. 'META').
        fiscal_quarter: Quarter identifier (e.g. 'Q2').
        fiscal_year: 4-digit fiscal year (e.g. 2026).
        chunk_size: Max character count per chunk (default: 1000).
        chunk_overlap: Character overlap between consecutive chunks (default: 100).

    Returns:
        List of EnrichedChunk objects ready for vector storage and BM25 indexing.
    """
    # Create mapping from page_number to financial_domain
    domain_by_page: Dict[int, str] = {
        c.page_number: c.domain.value for c in classifications
    }

    # Initialize LangChain recursive splitter
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        separators=["\n\n", "\n", ". ", " ", ""],
        length_function=len,
    )

    enriched_chunks: List[EnrichedChunk] = []
    global_idx = 0

    clean_ticker = ticker.upper().strip()
    clean_quarter = fiscal_quarter.upper().strip()

    for page in pages:
        # Skip blank pages
        if page.is_blank or not page.text.strip():
            continue

        domain = domain_by_page.get(page.page_number, FinancialDomain.GENERAL.value)
        raw_text_chunks = splitter.split_text(page.text)

        for page_chunk_idx, chunk_text in enumerate(raw_text_chunks):
            cleaned_text = chunk_text.strip()
            if not cleaned_text:
                continue

            chunk_id = f"{clean_ticker}_{clean_quarter}_{fiscal_year}_p{page.page_number}_c{page_chunk_idx}"

            chunk = EnrichedChunk(
                chunk_id=chunk_id,
                ticker=clean_ticker,
                fiscal_quarter=clean_quarter,
                fiscal_year=fiscal_year,
                page_number=page.page_number,
                financial_domain=domain,
                text=cleaned_text,
                char_count=len(cleaned_text),
                chunk_index_in_page=page_chunk_idx,
                global_chunk_index=global_idx,
            )
            enriched_chunks.append(chunk)
            global_idx += 1

    return enriched_chunks


if __name__ == "__main__":
    from app.ingestion.pdf_extractor import extract_text_by_pages
    from app.ingestion.section_classifier import classify_document_pages
    from app.ingestion.artifact_saver import save_artifact

    server_root = _SERVER_ROOT
    default_sample = server_root / "tests" / "test_data" / "Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    target_path = Path(sys.argv[1]) if len(sys.argv) > 1 else default_sample

    if not target_path.exists():
        print(f"❌ Sample PDF not found at: {target_path}")
        sys.exit(1)

    # Infer basic ticker and quarter from filename for CLI demonstration
    doc_name = target_path.name
    ticker = "TSLA" if "TSLA" in doc_name.upper() else "META"
    quarter = "Q2"
    year = 2026

    print("=" * 75)
    print(f"✂️  CHUNKING & METADATA ENRICHMENT: {doc_name}")
    print(f"   Ticker: {ticker} | Quarter: {quarter} | Year: {year}")
    print("=" * 75)

    doc = extract_text_by_pages(target_path)
    classifications = classify_document_pages(doc.pages)
    chunks = chunk_document_pages(
        pages=doc.pages,
        classifications=classifications,
        ticker=ticker,
        fiscal_quarter=quarter,
        fiscal_year=year,
    )

    print(f"  • Total Source Pages: {doc.total_pages}")
    print(f"  • Total Chunks:       {len(chunks)}")
    avg_len = sum(c.char_count for c in chunks) / len(chunks) if chunks else 0
    print(f"  • Average Chunk Size: {avg_len:.1f} characters")

    # Domain distribution summary
    domain_counts: Dict[str, int] = {}
    for c in chunks:
        domain_counts[c.financial_domain] = domain_counts.get(c.financial_domain, 0) + 1

    print("\n  Chunk Distribution by Financial Domain:")
    for dom, count in domain_counts.items():
        print(f"    • {dom.upper():<18}: {count} chunks")

    # Preview first 3 chunks
    print("\n  Sample Chunk Previews:")
    for c in chunks[:3]:
        print(f"    🏷️  [{c.chunk_id}] (Page {c.page_number}, {c.financial_domain}, {c.char_count} chars)")
        preview_text = c.text.replace("\n", " ")[:90]
        print(f"       \"{preview_text}...\"")

    doc_prefix = target_path.stem.lower().replace("-", "_")

    # Export JSON artifact
    json_payload = {
        "document_name": doc_name,
        "ticker": ticker,
        "fiscal_quarter": quarter,
        "fiscal_year": year,
        "total_pages": doc.total_pages,
        "total_chunks": len(chunks),
        "domain_distribution": domain_counts,
        "chunks": [asdict(c) for c in chunks],
    }
    json_path = save_artifact(f"03_chunks_{doc_prefix}.json", json_payload)

    # Export readable Markdown artifact
    md_lines = [
        f"# Semantic Chunks Artifact: {doc_name}",
        f"\n- **Ticker**: `{ticker}`",
        f"- **Period**: `{quarter} {year}`",
        f"- **Total Chunks**: **{len(chunks)}**",
        f"- **Average Size**: **{avg_len:.1f} chars**\n",
        "## Domain Distribution\n",
        "| Financial Domain | Chunk Count |",
        "| :--- | :--- |",
    ]
    for dom, count in domain_counts.items():
        md_lines.append(f"| `{dom}` | **{count}** |")

    md_lines.append("\n---\n## Chunk Registry\n")
    for c in chunks:
        md_lines.append(
            f"### 🏷️ `{c.chunk_id}` — Page {c.page_number} (`{c.financial_domain}`, {c.char_count} chars)\n"
        )
        md_lines.append("```text")
        md_lines.append(c.text)
        md_lines.append("```\n")

    md_path = save_artifact(f"03_chunks_{doc_prefix}.md", "\n".join(md_lines))

    print(f"\n🎉 Saved artifacts:")
    print(f"  • JSON: {json_path}")
    print(f"  • MD:   {md_path}")
    print("=" * 75)
