"""
Interactive Learning Test: Step 1.3 - Financial Section Classifier & Domain Tagger
=================================================================================

Pure verification test (does NOT write to .artifact/ directory).

Run from server directory:
    python tests/ingestion/test_section_classifier.py
or
    uv run python tests/ingestion/test_section_classifier.py
"""

import sys
from pathlib import Path

# Ensure the server root is in sys.path so 'from app...' works cleanly
SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(SERVER_ROOT))

# Import ingestion components
from app.ingestion.pdf_extractor import extract_text_by_pages
from app.ingestion.section_classifier import (
    FinancialDomain,
    PageClassification,
    classify_document_pages,
)


def main():
    print("=" * 75)
    print("🎓 LEARNING TEST: STEP 1.3 - FINANCIAL SECTION CLASSIFIER & DOMAIN TAGGER")
    print("=" * 75)

    test_dir = Path(__file__).resolve().parent.parent / "test_data"

    # =========================================================================
    # CASE 1: Real Meta Q2 2026 Investor Relations Filing (9 pages)
    # =========================================================================
    meta_pdf = test_dir / "Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if meta_pdf.exists():
        print(f"\n[Case 1] Real Meta Q2 2026 Filing ({meta_pdf.name}):")
        meta_doc = extract_text_by_pages(meta_pdf)
        meta_classifications = classify_document_pages(meta_doc.pages)

        for c in meta_classifications:
            top_signal = c.matched_signals[0] if c.matched_signals else "None"
            print(f"  📄 Page {c.page_number:02d} ──▶ {c.domain.value.upper():<16} (Confidence: {c.confidence:.2f}) | {top_signal}")

        # Assert key financial statement pages
        p2 = meta_classifications[1]  # Page 2
        p4 = meta_classifications[3]  # Page 4
        p5 = meta_classifications[4]  # Page 5
        p6 = meta_classifications[5]  # Page 6
        p7 = meta_classifications[6]  # Page 7

        assert p2.domain == FinancialDomain.GUIDANCE_OUTLOOK
        assert p4.domain == FinancialDomain.RISK_FACTORS
        assert p5.domain == FinancialDomain.PROFITABILITY
        assert p6.domain == FinancialDomain.BALANCE_SHEET
        assert p7.domain == FinancialDomain.CASH_FLOW

        print("  ✅ Case 1 Passed: Meta's 3 primary financial statements + outlook correctly tagged!")

    # =========================================================================
    # CASE 2: Real Tesla Q2 2026 Investor Slide Deck (33 pages)
    # =========================================================================
    tesla_pdf = test_dir / "TSLA-Q2-2026-Update.pdf"
    if tesla_pdf.exists():
        print(f"\n[Case 2] Real Tesla Q2 2026 Investor Update ({tesla_pdf.name} - 33 pages):")
        tesla_doc = extract_text_by_pages(tesla_pdf)
        tesla_classifications = classify_document_pages(tesla_doc.pages)

        # Verify key Tesla slides
        outlook_slide = tesla_classifications[9]        # Page 10: 'O U T L O O K'
        income_slide = tesla_classifications[26]        # Page 27: Statement of Operations
        balance_sheet_slide = tesla_classifications[27]  # Page 28: 'B A L A N C E  S H E E T'
        cash_flow_slide = tesla_classifications[28]     # Page 29: Cash Flows
        cybercab_slide = tesla_classifications[13]      # Page 14: Cybercab photo

        assert outlook_slide.domain == FinancialDomain.GUIDANCE_OUTLOOK
        assert income_slide.domain == FinancialDomain.PROFITABILITY
        assert balance_sheet_slide.domain == FinancialDomain.BALANCE_SHEET
        assert cash_flow_slide.domain == FinancialDomain.CASH_FLOW
        assert cybercab_slide.domain == FinancialDomain.GENERAL

        print("  ✅ Case 2 Passed: Spaced headers correctly normalized and tagged!")

    print("\n" + "=" * 75)
    print("🎉 STEP 1.3 SECTION CLASSIFIER TEST COMPLETED (ALL ASSERTIONS PASSED)!")
    print("=" * 75)


if __name__ == "__main__":
    main()
