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
    import argparse
    import json

    parser = argparse.ArgumentParser(description="Compose grounded GAAP KPI extraction prompt.")
    parser.add_argument("--ticker", type=str, default="META", help="Stock ticker symbol (default: META)")
    parser.add_argument("--quarter", type=str, default="Q2", help="Fiscal quarter (default: Q2)")
    parser.add_argument("--year", type=int, default=2026, help="Fiscal year (default: 2026)")
    parser.add_argument("--text", type=str, default=None, help="Custom financial text (if omitted, uses default dummy pages)")
    parser.add_argument("--page", type=int, default=1, help="Page number for custom text (default: 1)")
    args = parser.parse_args()

    print("🚀 Composing GAAP KPI Extraction Prompt...")
    print(f"🎯 Target Hints: Ticker={args.ticker}, Quarter={args.quarter}, Year={args.year}")

    if args.text:
        sample_pages = [
            ExtractedPage(
                page_number=args.page,
                text=args.text,
                char_count=len(args.text),
                is_blank=False,
            )
        ]
        print(f"📄 Using custom CLI text for Page {args.page} ({len(args.text):,} characters)")
    else:
        sample_pages = [
            ExtractedPage(
                page_number=5,
                text=(
                    "Meta Platforms, Inc.\n"
                    "CONDENSED CONSOLIDATED STATEMENTS OF INCOME\n"
                    "(In millions, except per share amounts)\n"
                    "Three Months Ended June 30, 2026\n"
                    "--------------------------------------------------\n"
                    "Revenue: $47,510\n"
                    "Costs and expenses:\n"
                    "  Cost of revenue: $8,552\n"
                    "  Research and development: $12,380\n"
                    "  Marketing and sales: $3,210\n"
                    "  General and administrative: $3,520\n"
                    "Total costs and expenses: $27,662\n"
                    "Income from operations: $19,848\n"
                    "Net income: $15,848\n"
                    "Diluted earnings per share: $6.15\n"
                ),
                char_count=450,
                is_blank=False,
            ),
            ExtractedPage(
                page_number=6,
                text=(
                    "Meta Platforms, Inc.\n"
                    "CONDENSED CONSOLIDATED BALANCE SHEETS\n"
                    "(In millions)\n"
                    "June 30, 2026\n"
                    "--------------------------------------------------\n"
                    "Cash and cash equivalents: $41,200\n"
                    "Marketable securities: $23,500\n"
                    "Total assets: $258,400\n"
                    "Long-term debt: $28,400\n"
                    "Total liabilities: $84,200\n"
                    "Total stockholders' equity: $174,200\n"
                ),
                char_count=350,
                is_blank=False,
            ),
            ExtractedPage(
                page_number=7,
                text=(
                    "Meta Platforms, Inc.\n"
                    "CONDENSED CONSOLIDATED STATEMENTS OF CASH FLOWS\n"
                    "(In millions)\n"
                    "Three Months Ended June 30, 2026\n"
                    "--------------------------------------------------\n"
                    "Net cash provided by operating activities: $24,150\n"
                    "Purchases of property and equipment (CapEx): $8,470\n"
                    "Principal payments on finance leases: $410\n"
                    "Free cash flow: $15,680\n"
                ),
                char_count=380,
                is_blank=False,
            ),
        ]
        print(f"📄 Using {len(sample_pages)} default dummy financial statement pages (Income Statement, Balance Sheet, Cash Flow)")

    prompt = build_extraction_prompt(
        selected_pages=sample_pages,
        ticker_hint=args.ticker,
        quarter_hint=args.quarter,
        year_hint=args.year,
    )

    estimated_tokens = len(prompt) // 4
    print(f"✨ Successfully Composed Prompt: {len(prompt):,} characters (~{estimated_tokens:,} tokens)")
    print("-" * 60)
    print(prompt[:500] + "\n...[truncated for console display]...")
    print("-" * 60)

    # Save simple {"input": {}, "prompt": ""} artifact
    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    artifact_data = {
        "input": {
            "ticker": args.ticker,
            "quarter": args.quarter,
            "year": args.year,
            "pages": [
                {
                    "page_number": p.page_number,
                    "text": p.text,
                }
                for p in sample_pages
            ],
        },
        "prompt": prompt,
    }

    json_path = artifact_dir / "07a_sample_extraction_prompt.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(artifact_data, f, indent=2)

    md_path = artifact_dir / "07a_sample_extraction_prompt.md"
    with open(md_path, "w", encoding="utf-8") as f:
        f.write("# 📝 Composed LLM Extraction Prompt Artifact\n\n")
        f.write("## 1. Input Configuration\n\n")
        f.write(f"- **Ticker**: `{args.ticker}`\n")
        f.write(f"- **Quarter**: `{args.quarter}`\n")
        f.write(f"- **Year**: `{args.year}`\n")
        f.write(f"- **Pages Count**: `{len(sample_pages)}`\n\n")

        f.write("### Input Pages Content\n\n")
        for p in sample_pages:
            f.write(f"#### 📄 Page {p.page_number} ({len(p.text):,} chars)\n\n")
            f.write("```text\n" + p.text + "\n```\n\n")

        f.write("## 2. Full Composed Extraction Prompt\n\n")
        f.write("```text\n")
        f.write(prompt)
        f.write("\n```\n")

    print(f"\n📄 Saved Artifacts:\n  • {json_path}\n  • {md_path}")
