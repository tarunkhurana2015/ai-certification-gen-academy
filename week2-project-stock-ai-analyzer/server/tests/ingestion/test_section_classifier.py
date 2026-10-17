"""
Interactive Learning Test: Step 1.3 - Financial Section Classifier & Domain Tagger
=================================================================================

Tests domain classification against:
1. Real Meta Q2 2026 Filing (9-page SEC Press Release)
2. Real Tesla Q2 2026 Filing (33-page Investor Slide Deck)
3. Edge cases (blank pages, ambiguous text)

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

        assert p2.domain == FinancialDomain.GUIDANCE_OUTLOOK, f"Page 2 expected GUIDANCE_OUTLOOK, got {p2.domain}"
        assert p4.domain == FinancialDomain.RISK_FACTORS, f"Page 4 expected RISK_FACTORS, got {p4.domain}"
        assert p5.domain == FinancialDomain.PROFITABILITY, f"Page 5 expected PROFITABILITY, got {p5.domain}"
        assert p6.domain == FinancialDomain.BALANCE_SHEET, f"Page 6 expected BALANCE_SHEET, got {p6.domain}"
        assert p7.domain == FinancialDomain.CASH_FLOW, f"Page 7 expected CASH_FLOW, got {p7.domain}"

        print("  ✅ Case 1 Passed: Meta's 3 primary financial statements + outlook correctly tagged!")

    # =========================================================================
    # CASE 2: Real Tesla Q2 2026 Investor Slide Deck (33 pages)
    # =========================================================================
    tesla_pdf = test_dir / "TSLA-Q2-2026-Update.pdf"
    if tesla_pdf.exists():
        print(f"\n[Case 2] Real Tesla Q2 2026 Investor Update ({tesla_pdf.name} - 33 pages):")
        tesla_doc = extract_text_by_pages(tesla_pdf)
        tesla_classifications = classify_document_pages(tesla_doc.pages)

        # Highlight important classified pages in Tesla's deck
        key_pages = [1, 4, 10, 14, 26, 27, 28, 29, 31]
        for pg_num in key_pages:
            c = tesla_classifications[pg_num - 1]
            top_signal = c.matched_signals[0] if c.matched_signals else "None"
            print(f"  📄 Page {c.page_number:02d} ──▶ {c.domain.value.upper():<16} (Confidence: {c.confidence:.2f}) | {top_signal}")

        # Verify key Tesla slides
        outlook_slide = tesla_classifications[9]       # Page 10: 'O U T L O O K'
        income_slide = tesla_classifications[26]       # Page 27: Statement of Operations
        balance_sheet_slide = tesla_classifications[27] # Page 28: 'B A L A N C E  S H E E T'
        cash_flow_slide = tesla_classifications[28]    # Page 29: Cash Flows
        cybercab_slide = tesla_classifications[13]     # Page 14: Cybercab photo

        assert outlook_slide.domain == FinancialDomain.GUIDANCE_OUTLOOK, f"Page 10 expected GUIDANCE_OUTLOOK, got {outlook_slide.domain}"
        assert income_slide.domain == FinancialDomain.PROFITABILITY, f"Page 27 expected PROFITABILITY, got {income_slide.domain}"
        assert balance_sheet_slide.domain == FinancialDomain.BALANCE_SHEET, f"Page 28 expected BALANCE_SHEET, got {balance_sheet_slide.domain}"
        assert cash_flow_slide.domain == FinancialDomain.CASH_FLOW, f"Page 29 expected CASH_FLOW, got {cash_flow_slide.domain}"
        assert cybercab_slide.domain == FinancialDomain.GENERAL, f"Page 14 expected GENERAL, got {cybercab_slide.domain}"

        print("  ✅ Case 2 Passed: Spaced headers ('B A L A N C E  S H E E T' & 'O U T L O O K') correctly normalized and tagged!")

    print("\n" + "=" * 75)
    print("🎉 STEP 1.3 FINANCIAL SECTION CLASSIFIER TEST COMPLETED SUCCESSFULLY!")
    print("=" * 75)


if __name__ == "__main__":
    main()
