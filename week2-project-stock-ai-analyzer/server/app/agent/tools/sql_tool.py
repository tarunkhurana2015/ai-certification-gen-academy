"""
Deterministic SQL KPI & Time-Series Tools.

Queries SQLite database for audited 18+ GAAP metrics (zero hallucination).
"""

import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

from langchain_core.tools import tool

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.db.repositories.kpi_repo import (
    get_kpi_time_series,
    get_kpis_by_quarter,
    list_all_kpis,
)
from app.db.session import SessionLocal


@tool
def get_kpis(
    ticker: str,
    fiscal_quarter: Optional[str] = None,
    fiscal_year: Optional[int] = None,
) -> Dict[str, Any]:
    """
    Retrieve exact, audited GAAP financial KPIs (Revenue, Gross Margin, Operating Income,
    Net Income, EPS, Free Cash Flow, Cash, Debt) from SQLite for a company and fiscal period.

    Use this tool whenever the user asks for exact numbers, financial statements,
    or quantitative balance sheet / cash flow metrics.
    """
    norm_ticker = ticker.upper().strip()

    with SessionLocal() as session:
        if fiscal_quarter and fiscal_year:
            record = get_kpis_by_quarter(
                session=session,
                ticker=norm_ticker,
                fiscal_year=int(fiscal_year),
                fiscal_quarter=fiscal_quarter.upper().strip(),
            )
        else:
            records = list_all_kpis(session=session, ticker=norm_ticker)
            record = records[0] if records else None

        if not record:
            period_str = f" for {fiscal_quarter} {fiscal_year}" if fiscal_quarter and fiscal_year else ""
            return {
                "error": f"No audited financial KPIs found in database for ticker {norm_ticker}{period_str}.",
                "ticker": norm_ticker,
            }

        return record.to_dict()


@tool
def get_time_series(
    ticker: str,
    limit: int = 8,
) -> List[Dict[str, Any]]:
    """
    Retrieve chronologically ordered historical quarterly metrics for a company
    to analyze trends over multiple quarters (e.g. revenue trajectory, margin compression/expansion).

    Use this tool whenever the user asks about trends, quarterly progression, or history.
    """
    norm_ticker = ticker.upper().strip()
    with SessionLocal() as session:
        records = get_kpi_time_series(session=session, ticker=norm_ticker, limit=limit)
        return [r.to_dict() for r in records]
