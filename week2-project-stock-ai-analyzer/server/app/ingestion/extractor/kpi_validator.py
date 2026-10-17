"""
Financial Math Validator & Reconciliation Module.

Conforms to ARCHITECTURE.md Section 8 (app/ingestion/extractor/kpi_validator.py).
Applies deterministic mathematical checks to financial statements:
1. CapEx sign correction: Converts negative CapEx outflows into positive absolute values.
2. Free Cash Flow calculation: Guarantees FCF = Operating Cash Flow - CapEx.
3. Margin derivations: Auto-derives Gross Margin, Operating Margin, and Net Margin if omitted.
"""

from typing import Optional
from app.schemas.kpis import FinancialReportKPIs


def validate_and_reconcile_kpis(kpis: FinancialReportKPIs) -> FinancialReportKPIs:
    """
    Deterministic mathematical reconciliation and sanity checking:
    1. Ensures CapEx is a positive magnitude (accounting statements often list CapEx as negative cash outflow).
    2. Auto-calculates Free Cash Flow = OCF - CapEx if not explicitly set.
    3. Auto-calculates Gross Margin, Operating Margin, Net Margin if missing.
    4. Ensures ticker and quarter formatting.
    """
    kpis.ticker = kpis.ticker.upper().strip()
    kpis.fiscal_quarter = kpis.fiscal_quarter.upper().strip()

    # 1. CapEx sign reconciliation: In Cash Flow statements, CapEx is often reported in parentheses (negative)
    if kpis.capital_expenditures is not None and kpis.capital_expenditures < 0:
        kpis.capital_expenditures = abs(kpis.capital_expenditures)

    # 2. Free Cash Flow calculation
    if kpis.free_cash_flow is None:
        if kpis.operating_cash_flow is not None and kpis.capital_expenditures is not None:
            kpis.free_cash_flow = round(kpis.operating_cash_flow - kpis.capital_expenditures, 2)

    # 3. Gross Margin calculation
    if kpis.gross_margin is None and kpis.gross_profit is not None and kpis.revenue and kpis.revenue > 0:
        kpis.gross_margin = round(kpis.gross_profit / kpis.revenue, 4)

    # 4. Operating Margin calculation
    if kpis.operating_margin is None and kpis.operating_income is not None and kpis.revenue and kpis.revenue > 0:
        kpis.operating_margin = round(kpis.operating_income / kpis.revenue, 4)

    # 5. Net Margin calculation
    if kpis.net_margin is None and kpis.net_income is not None and kpis.revenue and kpis.revenue > 0:
        kpis.net_margin = round(kpis.net_income / kpis.revenue, 4)

    return kpis
