"""
Unit Tests for Schemas and DTOs.

Conforms to ARCHITECTURE.md Section 8 (tests/schemas/test_schemas.py).
Tests:
1. FinancialDomain enums and values.
2. StatementType and ContentFormat enums.
3. FinancialReportKPIs schema instantiation, defaults, and validation.
"""

import sys
from pathlib import Path

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.schemas.common import FinancialDomain, StatementType, ContentFormat
from app.schemas.kpis import FinancialReportKPIs


def test_enums():
    """Verify common schema enums."""
    print("Testing common enum definitions...")
    assert FinancialDomain.PROFITABILITY.value == "profitability"
    assert FinancialDomain.BALANCE_SHEET.value == "balance_sheet"
    assert FinancialDomain.CASH_FLOW.value == "cash_flow"
    assert FinancialDomain.GUIDANCE_OUTLOOK.value == "guidance_outlook"
    assert FinancialDomain.RISK_FACTORS.value == "risk_factors"
    assert FinancialDomain.GENERAL.value == "general"

    assert StatementType.INCOME_STATEMENT.value == "income_statement"
    assert ContentFormat.TABLE.value == "table"
    print("✅ Schema enums verified.")


def test_financial_kpis_dto():
    """Verify FinancialReportKPIs Pydantic validation."""
    print("Testing FinancialReportKPIs serialization...")
    kpi = FinancialReportKPIs(
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Meta Q2 2026 Earnings Release",
        revenue=60801.0,
        net_income=15848.0,
        gross_margin=0.812,
        source_pages=[1, 5, 6, 7],
    )
    assert kpi.currency == "USD"
    assert kpi.units == "millions"
    assert kpi.revenue == 60801.0
    d = kpi.model_dump()
    assert d["ticker"] == "META"
    assert d["source_pages"] == [1, 5, 6, 7]
    print("✅ FinancialReportKPIs validation verified.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING SCHEMAS UNIT TESTS")
    print("=" * 60)

    test_enums()
    test_financial_kpis_dto()

    print("\n" + "=" * 60)
    print("ALL SCHEMAS TESTS PASSED! ✅")
    print("=" * 60)
