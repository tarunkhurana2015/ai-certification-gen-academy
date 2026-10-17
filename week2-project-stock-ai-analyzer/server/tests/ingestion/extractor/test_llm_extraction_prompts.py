"""
Unit Tests for LLM Extraction Prompts.

Conforms to ARCHITECTURE.md Section 8 (tests/ingestion/extractor/test_llm_extraction_prompts.py).
Tests:
1. System role and extraction rules presence.
2. Ticker, quarter, and year hints interpolation.
3. Multi-page formatting and boundary markers.
"""

import sys
from pathlib import Path

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.ingestion.parsers.pdf_extractor import ExtractedPage
from app.ingestion.extractor.llm_extraction_prompts import (
    KPI_AUDITOR_SYSTEM_ROLE,
    KPI_EXTRACTION_RULES,
    build_extraction_prompt,
)


def test_system_role_and_rules():
    """Verify system role and extraction rules constants."""
    print("Testing system role and extraction rules constants...")
    assert "Wall Street Senior Equity Research Analyst" in KPI_AUDITOR_SYSTEM_ROLE
    assert len(KPI_EXTRACTION_RULES) == 5
    assert any("decimal ratios" in r for r in KPI_EXTRACTION_RULES)
    assert any("CapEx" in r for r in KPI_EXTRACTION_RULES)
    print("✅ System role and extraction rules verified.")


def test_build_extraction_prompt_with_hints_and_pages():
    """Verify build_extraction_prompt interpolates hints and formats pages."""
    print("Testing build_extraction_prompt formatting...")
    pages = [
        ExtractedPage(page_number=5, text="Statements of Income\nRevenue: $60,801M", char_count=40, is_blank=False),
        ExtractedPage(page_number=6, text="Balance Sheet\nCash: $15,462M", char_count=30, is_blank=False),
    ]

    prompt = build_extraction_prompt(
        selected_pages=pages,
        ticker_hint="META",
        quarter_hint="Q2",
        year_hint=2026,
    )

    assert "Ticker=META" in prompt
    assert "Quarter=Q2" in prompt
    assert "Year=2026" in prompt
    assert "--- PAGE 5 ---" in prompt
    assert "Statements of Income" in prompt
    assert "--- PAGE 6 ---" in prompt
    assert "Balance Sheet" in prompt
    assert "Extract all available GAAP metrics into the requested JSON schema." in prompt
    print("✅ Prompt interpolation, page headers, and schema instruction verified.")


def test_build_extraction_prompt_without_hints():
    """Verify graceful handling when hints are None."""
    print("Testing prompt generation without optional hints...")
    pages = [
        ExtractedPage(page_number=1, text="Sample text", char_count=11, is_blank=False),
    ]
    prompt = build_extraction_prompt(pages)
    assert "Ticker=Unknown" in prompt
    assert "Quarter=Unknown" in prompt
    assert "Year=Unknown" in prompt
    assert "--- PAGE 1 ---" in prompt
    print("✅ Prompt generation without hints verified.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING LLM EXTRACTION PROMPTS UNIT TESTS")
    print("=" * 60)

    test_system_role_and_rules()
    test_build_extraction_prompt_with_hints_and_pages()
    test_build_extraction_prompt_without_hints()

    print("\n" + "=" * 60)
    print("ALL LLM EXTRACTION PROMPT TESTS PASSED! ✅")
    print("=" * 60)
