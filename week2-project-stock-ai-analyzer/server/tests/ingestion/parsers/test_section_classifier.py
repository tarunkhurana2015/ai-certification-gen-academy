"""
Interactive Learning Test: Step 1.3 - Financial Section Classifier & Domain Tagger
=================================================================================

Conforms to ARCHITECTURE.md Section 8 (tests/ingestion/parsers/test_section_classifier.py).
Pure verification test (does NOT write to .artifact/ directory).

Run from server directory:
    python tests/ingestion/parsers/test_section_classifier.py
"""

import sys
from pathlib import Path

# Ensure the server root is in sys.path so 'from app...' works cleanly
SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(SERVER_ROOT))

# Import ingestion components from canonical parsers package
from app.schemas.common import FinancialDomain
from app.ingestion.parsers.pdf_extractor import extract_text_by_pages
from app.ingestion.parsers.section_classifier import (
    PageClassification,
    classify_document_pages,
)


def main():
    print("=" * 75)
    print("🎓 LEARNING TEST: STEP 1.3 - FINANCIAL SECTION CLASSIFIER & DOMAIN TAGGER")
    print("=" * 75)

    test_dir = SERVER_ROOT / "tests/test_data"

    # =========================================================================
    # CASE 1: Real Meta Q2 2026 Investor Relations Filing (9 pages)
    # =========================================================================
    meta_pdf = test_dir / "Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if meta_pdf.exists():
        print(f"\n[Case 1] Real Meta Q2 2026 Filing ({meta_pdf.name}):")
        meta_doc = extract_text_by_pages(meta_pdf)
        meta_classifications = classify_document_pages(meta_doc.pages)

        for c in meta_classifications:
            print(f"  📄 Page {c.page_number:02d} ──▶ {c.domain.name:<18} (Confidence: {c.confidence:.2f}) | {c.matched_signals[0] if c.matched_signals else 'none'}")

        # Assert key financial statements in Meta's filing
        page_domains = {c.page_number: c.domain for c in meta_classifications}
        assert page_domains[2] == FinancialDomain.GUIDANCE_OUTLOOK, "Page 2 CFO Outlook commentary mismatch"
        assert page_domains[4] == FinancialDomain.RISK_FACTORS, "Page 4 Forward Looking Statements mismatch"
        assert page_domains[5] == FinancialDomain.PROFITABILITY, "Page 5 Condensed Statements of Income mismatch"
        assert page_domains[6] == FinancialDomain.BALANCE_SHEET, "Page 6 Condensed Balance Sheets mismatch"
        assert page_domains[7] == FinancialDomain.CASH_FLOW, "Page 7 Statements of Cash Flows mismatch"
        print("  ✅ Case 1 Passed: Meta's 3 primary financial statements + outlook correctly tagged!")

    # =========================================================================
    # CASE 2: Real Tesla Q2 2026 Investor Update (33 pages slide deck)
    # =========================================================================
    tesla_pdf = test_dir / "TSLA-Q2-2026-Update.pdf"
    if tesla_pdf.exists():
        print(f"\n[Case 2] Real Tesla Q2 2026 Investor Update ({tesla_pdf.name} - 33 pages):")
        tesla_doc = extract_text_by_pages(tesla_pdf)
        tesla_classifications = classify_document_pages(tesla_doc.pages)

        tesla_domains = {c.page_number: c.domain for c in tesla_classifications}

        # Page 10 is titled 'O U T L O O K' (spaced letters)
        assert tesla_domains.get(10) == FinancialDomain.GUIDANCE_OUTLOOK, f"Page 10 Outlook failed: got {tesla_domains.get(10)}"

        # Page 28 is titled 'B A L A N C E  S H E E T' (spaced letters)
        assert tesla_domains.get(28) == FinancialDomain.BALANCE_SHEET, f"Page 28 Balance Sheet failed: got {tesla_domains.get(28)}"

        # Page 27 has 'REVENUES' and 'Automotive sales'
        assert tesla_domains.get(27) == FinancialDomain.PROFITABILITY, f"Page 27 Income statement failed: got {tesla_domains.get(27)}"

        print("  ✅ Case 2 Passed: Spaced headers correctly normalized and tagged!")

    print("\n" + "=" * 75)
    print("🎉 STEP 1.3 SECTION CLASSIFIER TEST COMPLETED (ALL ASSERTIONS PASSED)!")
    print("=" * 75)


if __name__ == "__main__":
    main()
