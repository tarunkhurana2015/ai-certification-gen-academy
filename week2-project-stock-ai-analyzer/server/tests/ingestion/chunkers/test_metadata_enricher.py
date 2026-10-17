"""
Unit Tests for Metadata Enricher Module.

Conforms to ARCHITECTURE.md Section 8 (tests/ingestion/chunkers/test_metadata_enricher.py).
Tests:
1. enrich_split formatting, deterministic ID generation, and metadata fields.
2. chunk_document_pages across real Meta Q2 2026 report with domain classification.
3. Blank page skipping logic.
"""

import sys
from pathlib import Path

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
from app.ingestion.chunkers.metadata_enricher import (
    EnrichedChunk,
    chunk_document_pages,
    enrich_split,
)


def test_enrich_split_fields():
    """Verify single split enrichment and deterministic ID format."""
    print("Testing enrich_split metadata decoration...")
    chunk = enrich_split(
        text="  Total Revenue: $47,510M  ",
        ticker="meta",
        fiscal_quarter="q2",
        fiscal_year=2026,
        page_number=5,
        domain="profitability",
        chunk_index_in_page=0,
        total_chunks_in_page=2,
    )

    assert chunk.chunk_id == "META_Q2_2026_p5_c0"
    assert chunk.text == "Total Revenue: $47,510M"
    assert chunk.ticker == "META"
    assert chunk.fiscal_quarter == "Q2"
    assert chunk.fiscal_year == 2026
    assert chunk.page_number == 5
    assert chunk.financial_domain == "profitability"
    assert chunk.char_count == len("Total Revenue: $47,510M")
    assert chunk.chunk_index_in_page == 0
    assert chunk.total_chunks_in_page == 2
    print("✅ enrich_split verified with deterministic ID and clean fields.")


def test_chunk_document_pages_with_meta_pdf():
    """Verify chunking and domain inheritance on real Meta filing."""
    print("Testing chunk_document_pages with Meta Q2 2026 filing...")
    test_pdf = _SERVER_ROOT / "tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if not test_pdf.exists():
        print(f"⚠️ Skipping real PDF test (file not found: {test_pdf})")
        return

    doc = extract_text_by_pages(test_pdf)
    classes = classify_document_pages(doc.pages)
    chunks = chunk_document_pages(
        pages=doc.pages,
        classifications=classes,
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        chunk_size=1000,
        chunk_overlap=100,
    )

    assert len(chunks) > 0
    print(f"  • Generated {len(chunks)} chunks across {doc.total_pages} pages")

    # Verify every chunk has proper facets
    for c in chunks:
        assert c.ticker == "META"
        assert c.fiscal_quarter == "Q2"
        assert c.fiscal_year == 2026
        assert 1 <= c.page_number <= doc.total_pages
        assert c.chunk_id.startswith(f"META_Q2_2026_p{c.page_number}_c")

    # Verify statement domain inheritance
    p5_chunks = [c for c in chunks if c.page_number == 5]
    assert len(p5_chunks) >= 1
    assert p5_chunks[0].financial_domain == "profitability"

    p6_chunks = [c for c in chunks if c.page_number == 6]
    assert len(p6_chunks) >= 1
    assert p6_chunks[0].financial_domain == "balance_sheet"
    print("✅ Real PDF chunking and domain inheritance verified.")


def test_blank_page_handling():
    """Verify that blank pages produce 0 chunks."""
    print("Testing blank page handling...")
    pages = [
        ExtractedPage(page_number=1, text="Quarterly revenue was $10B.", char_count=28, is_blank=False),
        ExtractedPage(page_number=2, text="", char_count=0, is_blank=True),
        ExtractedPage(page_number=3, text="Operating margin was 30%.", char_count=26, is_blank=False),
    ]
    classes = [
        PageClassification(page_number=1, domain=FinancialDomain.PROFITABILITY, confidence=1.0, matched_signals=[]),
        PageClassification(page_number=2, domain=FinancialDomain.GENERAL, confidence=1.0, matched_signals=[]),
        PageClassification(page_number=3, domain=FinancialDomain.PROFITABILITY, confidence=1.0, matched_signals=[]),
    ]

    chunks = chunk_document_pages(
        pages=pages,
        classifications=classes,
        ticker="TEST",
        fiscal_quarter="Q1",
        fiscal_year=2026,
    )

    assert len(chunks) == 2
    p2_chunks = [c for c in chunks if c.page_number == 2]
    assert len(p2_chunks) == 0, "Blank page must not generate any chunks"
    print("✅ Blank page skipping verified.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING METADATA ENRICHER UNIT TESTS")
    print("=" * 60)

    test_enrich_split_fields()
    test_chunk_document_pages_with_meta_pdf()
    test_blank_page_handling()

    print("\n" + "=" * 60)
    print("ALL METADATA ENRICHER TESTS PASSED! ✅")
    print("=" * 60)
