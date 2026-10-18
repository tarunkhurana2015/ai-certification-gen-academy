"""
Cross-Company Peer Comparison Tool.

Queries SQLite for side-by-side metric comparison across multiple tickers for the same quarter.
"""

import sys
from pathlib import Path
from typing import Any, Dict, List

from langchain_core.tools import tool

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.db.repositories.kpi_repo import get_multi_company_comparison
from app.db.session import SessionLocal


@tool
def compare_tickers(
    tickers: List[str],
    fiscal_quarter: str = "Q2",
    fiscal_year: int = 2026,
) -> Dict[str, Any]:
    """
    Compare key financial performance metrics (Revenue, Gross Margin, Operating Margin,
    Net Income, Free Cash Flow, Cash, Debt) across multiple peer companies for the same fiscal quarter.

    Use this tool whenever the user asks to compare two or more companies side-by-side.
    """
    clean_tickers = [t.upper().strip() for t in tickers if t and t.lower() not in ("none", "multiple")]
    if not clean_tickers:
        return {"error": "Please provide at least one valid company ticker to compare."}

    with SessionLocal() as session:
        records = get_multi_company_comparison(
            session=session,
            tickers=clean_tickers,
            fiscal_year=int(fiscal_year),
            fiscal_quarter=fiscal_quarter.upper().strip(),
        )

        comparison_data = {r.ticker: r.to_dict() for r in records}
        missing = [t for t in clean_tickers if t not in comparison_data]

        return {
            "fiscal_period": f"{fiscal_quarter.upper().strip()} {fiscal_year}",
            "companies": comparison_data,
            "missing_tickers": missing,
        }
