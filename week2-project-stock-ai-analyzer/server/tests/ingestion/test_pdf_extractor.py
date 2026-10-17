"""
Interactive Learning Test: Step 1.2 - PDF Text & Page Extractor
===============================================================

Pure verification test (does NOT write to .artifact/ directory).

Run from server directory:
    python tests/ingestion/test_pdf_extractor.py
or
    uv run python tests/ingestion/test_pdf_extractor.py
"""

import sys
from pathlib import Path
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

# Ensure the server root is in sys.path so 'from app...' works cleanly
SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(SERVER_ROOT))

# Import extractor component
from app.ingestion.pdf_extractor import extract_text_by_pages


def generate_mock_earnings_report(pdf_path: Path) -> Path:
    """Generates a realistic 3-page quarterly financial report PDF using ReportLab."""
    c = canvas.Canvas(str(pdf_path), pagesize=letter)

    # PAGE 1: Statements of Operations
    c.setFont("Helvetica-Bold", 16)
    c.drawString(54, 730, "Apple Inc. Q3 FY2024 Financial Results")
    c.setFont("Helvetica-Bold", 12)
    c.drawString(54, 700, "Consolidated Statements of Operations (Unaudited)")
    c.setFont("Helvetica", 10)
    c.drawString(54, 670, "Total Net Sales: $85,777 million")
    c.drawString(54, 650, "Cost of Sales: $46,099 million")
    c.drawString(54, 630, "Gross Margin: $39,678 million (46.3%)")
    c.drawString(54, 610, "Operating Income: $25,352 million")
    c.drawString(54, 590, "Net Income: $21,448 million")
    c.drawString(54, 570, "Diluted Earnings Per Share (EPS): $1.40")
    c.drawString(54, 540, "Quarter ended June 29, 2024 compared to quarter ended July 1, 2023.")
    c.showPage()

    # PAGE 2: Balance Sheets
    c.setFont("Helvetica-Bold", 14)
    c.drawString(54, 730, "Apple Inc. Condensed Consolidated Balance Sheets")
    c.setFont("Helvetica", 10)
    c.drawString(54, 700, "Cash and cash equivalents: $25,574 million")
    c.drawString(54, 680, "Marketable securities: $36,122 million")
    c.drawString(54, 660, "Inventories: $6,145 million")
    c.drawString(54, 640, "Total current assets: $134,836 million")
    c.drawString(54, 620, "Total assets: $337,411 million")
    c.drawString(54, 600, "Total liabilities: $270,724 million")
    c.drawString(54, 580, "Total shareholders' equity: $66,687 million")
    c.showPage()

    # PAGE 3: MD&A Commentary
    c.setFont("Helvetica-Bold", 14)
    c.drawString(54, 730, "Management's Discussion and Analysis of Financial Condition (MD&A)")
    c.setFont("Helvetica", 10)
    c.drawString(54, 700, "Products revenue was $61.6 billion, up 2 percent from the prior year quarter.")
    c.drawString(54, 680, "Services revenue reached an all-time record of $24.2 billion, up 14 percent.")
    c.drawString(54, 660, "Operating margin expanded to 29.5 percent driven by favorable Services mix.")
    c.drawString(54, 640, "The Company returned over $32 billion to shareholders including dividends.")
    c.showPage()

    c.save()
    return pdf_path


def generate_pdf_with_blank_page(pdf_path: Path) -> Path:
    """Generates a 2-page PDF where Page 2 has no text to test blank page detection."""
    c = canvas.Canvas(str(pdf_path), pagesize=letter)
    c.drawString(54, 700, "Page 1: Cover Page with text.")
    c.showPage()
    c.showPage()
    c.save()
    return pdf_path


def main():
    print("=" * 70)
    print("🎓 LEARNING TEST: STEP 1.2 - PDF TEXT & PAGE-BY-PAGE EXTRACTION")
    print("=" * 70)

    test_dir = Path(__file__).resolve().parent.parent / "test_data"
    test_dir.mkdir(exist_ok=True)

    # ---------------- Case 1: Multi-Page Generated Financial Report ----------------
    earnings_pdf = test_dir / "apple_q3_fy24_financials.pdf"
    generate_mock_earnings_report(earnings_pdf)
    print(f"\n[Case 1] Multi-Page Financial Report: {earnings_pdf.name}")

    result = extract_text_by_pages(earnings_pdf)
    print(f"  • Total Pages Extracted:    {result.total_pages}")
    print(f"  • Total Characters Counted: {result.total_characters}")
    print(f"  • Blank Pages Detected:     {result.blank_page_count}")

    assert result.total_pages == 3
    assert "Consolidated Statements of Operations" in result.pages[0].text
    print("  ✅ Case 1 Passed: Exact page alignment verified!")

    # ---------------- Case 2: Real Meta Q2 2026 Filing ----------------
    meta_pdf = test_dir / "Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if meta_pdf.exists():
        print(f"\n[Case 2] Real Investor Relations Filing: {meta_pdf.name}")
        meta_result = extract_text_by_pages(meta_pdf)
        print(f"  • Total Pages:              {meta_result.total_pages}")
        print(f"  • Total Characters:         {meta_result.total_characters}")
        assert meta_result.total_pages == 9
        print("  ✅ Case 2 Passed: Meta extracted successfully!")

    # ---------------- Case 3: Real Tesla Q2 2026 Filing ----------------
    tesla_pdf = test_dir / "TSLA-Q2-2026-Update.pdf"
    if tesla_pdf.exists():
        print(f"\n[Case 3] Real Tesla Q2 2026 Filing: {tesla_pdf.name}")
        tesla_result = extract_text_by_pages(tesla_pdf)
        print(f"  • Total Pages:              {tesla_result.total_pages}")
        print(f"  • Total Characters:         {tesla_result.total_characters}")
        assert tesla_result.total_pages == 33
        print("  ✅ Case 3 Passed: Tesla extracted successfully!")

    # ---------------- Case 4: Blank Page Detection ----------------
    blank_pdf = test_dir / "report_with_blank_page.pdf"
    generate_pdf_with_blank_page(blank_pdf)
    blank_result = extract_text_by_pages(blank_pdf)
    assert blank_result.blank_page_count == 1
    print("\n[Case 4] Blank Page Test:")
    print("  ✅ Case 4 Passed: Blank page detected without crashing!")

    print("\n" + "=" * 70)
    print("🎉 STEP 1.2 PDF EXTRACTION TEST COMPLETED (ALL ASSERTIONS PASSED)!")
    print("=" * 70)


if __name__ == "__main__":
    main()
