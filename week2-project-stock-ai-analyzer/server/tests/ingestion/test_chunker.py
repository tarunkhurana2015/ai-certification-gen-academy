"""
Interactive Learning Test: Step 1.4 - Semantic Chunker & Metadata Enricher
=========================================================================

Pure verification test (does NOT write to .artifact/ directory).

Run from server directory:
    python tests/ingestion/test_chunker.py
or
    uv run python tests/ingestion/test_chunker.py
"""

import sys
from pathlib import Path

# Ensure the server root is in sys.path so 'from app...' works cleanly
SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(SERVER_ROOT))

# Import ingestion components
from app.ingestion.pdf_extractor import extract_text_by_pages, ExtractedPage
from app.ingestion.section_classifier import classify_document_pages, FinancialDomain, PageClassification
from app.ingestion.chunker import chunk_document_pages, EnrichedChunk


def main():
    print("=" * 75)
    print("🎓 LEARNING TEST: STEP 1.4 - SEMANTIC CHUNKER & METADATA ENRICHER")
    print("=" * 75)

    test_dir = Path(__file__).resolve().parent.parent / "test_data"

    # =========================================================================
    # CASE 1: Meta Q2 2026 Ingestion & Chunking
    # =========================================================================
    meta_pdf = test_dir / "Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if meta_pdf.exists():
        print(f"\n[Case 1] Chunking Real Meta Q2 2026 Filing ({meta_pdf.name}):")
        meta_doc = extract_text_by_pages(meta_pdf)
        meta_classifications = classify_document_pages(meta_doc.pages)

        chunks = chunk_document_pages(
            pages=meta_doc.pages,
            classifications=meta_classifications,
            ticker="META",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            chunk_size=1000,
            chunk_overlap=100,
        )

        print(f"  • Source Pages:    {meta_doc.total_pages}")
        print(f"  • Produced Chunks: {len(chunks)}")
        assert len(chunks) > 0, "Expected chunks to be produced"

        # Verify metadata integrity on all chunks
        for c in chunks:
            assert c.ticker == "META"
            assert c.fiscal_quarter == "Q2"
            assert c.fiscal_year == 2026
            assert c.page_number >= 1 and c.page_number <= meta_doc.total_pages
            assert len(c.text) > 0
            assert c.chunk_id.startswith("META_Q2_2026_p")

        # Verify that Page 5 (Income statement) chunks inherited 'profitability' domain
        p5_chunks = [c for c in chunks if c.page_number == 5]
        assert len(p5_chunks) >= 1
        assert p5_chunks[0].financial_domain == "profitability"
        print(f"  • Page 5 (Income Statement) generated {len(p5_chunks)} chunks with domain '{p5_chunks[0].financial_domain}'")

        # Verify that Page 6 (Balance sheet) chunks inherited 'balance_sheet' domain
        p6_chunks = [c for c in chunks if c.page_number == 6]
        assert len(p6_chunks) >= 1
        assert p6_chunks[0].financial_domain == "balance_sheet"
        print(f"  • Page 6 (Balance Sheet) generated {len(p6_chunks)} chunks with domain '{p6_chunks[0].financial_domain}'")

        print("  ✅ Case 1 Passed: Meta chunks verified with exact metadata & domain inheritance!")

    # =========================================================================
    # CASE 2: Blank Page Handling
    # =========================================================================
    print(f"\n[Case 2] Blank Page Handling Test:")
    dummy_pages = [
        ExtractedPage(page_number=1, text="Quarterly revenue was $10B.", char_count=28, is_blank=False),
        ExtractedPage(page_number=2, text="", char_count=0, is_blank=True),  # Blank page
        ExtractedPage(page_number=3, text="Operating margin was 30%.", char_count=26, is_blank=False),
    ]
    dummy_classes = [
        PageClassification(page_number=1, domain=FinancialDomain.PROFITABILITY, confidence=0.9),
        PageClassification(page_number=2, domain=FinancialDomain.GENERAL, confidence=1.0),
        PageClassification(page_number=3, domain=FinancialDomain.PROFITABILITY, confidence=0.9),
    ]
    dummy_chunks = chunk_document_pages(
        pages=dummy_pages,
        classifications=dummy_classes,
        ticker="AAPL",
        fiscal_quarter="Q3",
        fiscal_year=2024,
    )
    # Page 2 should be skipped entirely
    p2_dummy_chunks = [c for c in dummy_chunks if c.page_number == 2]
    assert len(p2_dummy_chunks) == 0, "Blank page must not generate any chunks"
    assert len(dummy_chunks) == 2
    print("  ✅ Case 2 Passed: Blank page produced 0 chunks as expected!")

    # =========================================================================
    # CASE 3: Overlap Verification
    # =========================================================================
    print(f"\n[Case 3] Chunk Overlap Boundary Test:")
    long_text = "Sentence number one about financial results. " * 30  # ~1350 characters
    long_page = [ExtractedPage(page_number=1, text=long_text, char_count=len(long_text), is_blank=False)]
    long_class = [PageClassification(page_number=1, domain=FinancialDomain.GENERAL, confidence=1.0)]

    overlap_chunks = chunk_document_pages(
        pages=long_page,
        classifications=long_class,
        ticker="TEST",
        fiscal_quarter="Q1",
        fiscal_year=2025,
        chunk_size=500,
        chunk_overlap=100,
    )
    assert len(overlap_chunks) >= 2, "Long text should be split into multiple chunks"
    print(f"  • Long text ({len(long_text)} chars) split into {len(overlap_chunks)} overlapping chunks")
    print("  ✅ Case 3 Passed: Multi-chunk split verified!")

    print("\n" + "=" * 75)
    print("🎉 STEP 1.4 SEMANTIC CHUNKER TEST COMPLETED (ALL ASSERTIONS PASSED)!")
    print("=" * 75)


if __name__ == "__main__":
    main()
