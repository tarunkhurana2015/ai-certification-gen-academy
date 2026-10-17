"""
LLM Extraction Prompts Module.

Conforms to ARCHITECTURE.md Section 8 (app/ingestion/extractor/llm_extraction_prompts.py).
Contains structured prompt templates and expert auditor instructions for extracting
18+ standardized US GAAP Financial KPIs from corporate earnings releases and SEC filings.
"""

import sys
from pathlib import Path
from typing import List, Optional

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.ingestion.parsers.pdf_extractor import ExtractedPage

KPI_AUDITOR_SYSTEM_ROLE = (
    "You are an expert Wall Street Senior Equity Research Analyst and SEC Filing Auditor.\n"
    "Your task is to extract the standardized US GAAP Financial KPIs for the CURRENT REPORTED QUARTER."
)

KPI_EXTRACTION_RULES = [
    "1. Extract the numbers for the PRIMARY LATEST QUARTER being reported (not the prior-year comparative column).",
    "2. Units: Carefully note whether figures are in 'millions', 'thousands', or 'billions' (usually stated at top of tables).",
    "3. Margins: Output margins as decimal ratios between 0.0 and 1.0 (e.g., 82.0% -> 0.82, 17.5% -> 0.175).",
    "4. CapEx: Look for 'Purchases of property and equipment' or 'Capital expenditures'. Report as a positive number.",
    "5. Source Pages: Include the exact 1-indexed page numbers where each figure was found.",
]


def build_extraction_prompt(
    selected_pages: List[ExtractedPage],
    ticker_hint: Optional[str] = None,
    quarter_hint: Optional[str] = None,
    year_hint: Optional[int] = None,
) -> str:
    """
    Builds a grounded, context-rich extraction prompt containing only the
    classified financial statement pages.
    """
    prompt_parts = [
        KPI_AUDITOR_SYSTEM_ROLE,
        "",
        "RULES FOR ACCURATE EXTRACTION:",
    ]
    prompt_parts.extend(KPI_EXTRACTION_RULES)
    prompt_parts.extend([
        "",
        f"Hints if available: Ticker={ticker_hint or 'Unknown'}, Quarter={quarter_hint or 'Unknown'}, Year={year_hint or 'Unknown'}",
        "",
        "FINANCIAL STATEMENT PAGES CONTENT:",
        "=" * 60,
    ])

    for p in selected_pages:
        prompt_parts.append(f"\n--- PAGE {p.page_number} ---")
        prompt_parts.append(p.text)

    prompt_parts.append("\n" + "=" * 60)
    prompt_parts.append("Extract all available GAAP metrics into the requested JSON schema.")
    return "\n".join(prompt_parts)


if __name__ == "__main__":
    dummy_page = ExtractedPage(
        page_number=5,
        text="Condensed Consolidated Statements of Income\nRevenue: $47,510M\nNet Income: $15,848M",
        char_count=85,
        is_blank=False,
    )
    prompt = build_extraction_prompt([dummy_page], ticker_hint="META", quarter_hint="Q2", year_hint=2026)
    print("🚀 Sample Generated Extraction Prompt:")
    print("-" * 60)
    print(prompt[:400] + "\n...[truncated]...")
