"""
Unit Tests for Structured Financial KPI Extractor (Step 2.4.1).

Validates:
1. Pydantic schema validation for FinancialReportKPIs.
2. Mathematical reconciliation (negative CapEx sign correction, FCF calculation).
3. Automatic margin ratio derivations (Gross Margin, Operating Margin, Net Margin).
4. Page filtering logic: Only passes financial statement pages (PROFITABILITY, BALANCE_SHEET, CASH_FLOW).
5. End-to-end extraction pipeline with a mocked LLM.

NOTE: Tests must NEVER write artifacts. Pure assertions only.
"""

import sys
from pathlib import Path
from unittest.mock import MagicMock

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.schemas.common import FinancialDomain
from app.schemas.kpis import FinancialReportKPIs
from app.db.models import FinancialKPIModel
from app.db.repositories.document_repo import save_document
from app.db.repositories.kpi_repo import get_kpis_by_quarter
from app.db.session import init_db
from app.ingestion.parsers import ExtractedPage, PageClassification
from app.ingestion.extractor import (
    build_extraction_prompt,
    extract_financial_kpis,
    filter_financial_statement_pages,
    save_extracted_kpis_to_db,
    validate_and_reconcile_kpis,
)
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool


def test_schema_instantiation_and_defaults():
    """Verify schema defaults and serialization."""
    print("Testing FinancialReportKPIs schema instantiation...")
    kpi = FinancialReportKPIs(
        ticker="meta",
        fiscal_quarter="q2",
        fiscal_year=2026,
        report_title="Meta Q2 2026",
        revenue=39071.0,
        net_income=13465.0,
    )
    assert kpi.currency == "USD"
    assert kpi.units == "millions"
    assert kpi.revenue == 39071.0
    d = kpi.model_dump()
    assert isinstance(d, dict)
    assert d["revenue"] == 39071.0
    print("✅ Schema instantiation and defaults verified.")


def test_reconciliation_negative_capex_and_fcf():
    """Verify negative CapEx is made positive and Free Cash Flow is computed."""
    print("Testing negative CapEx sign correction and FCF derivation...")
    raw = FinancialReportKPIs(
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Meta Q2 2026",
        revenue=39071.0,
        operating_cash_flow=19370.0,
        capital_expenditures=-8473.0,  # Negative CapEx reported in cash flow statement
        free_cash_flow=None,           # Let reconciler compute
    )
    reconciled = validate_and_reconcile_kpis(raw)

    # 1. CapEx must be positive magnitude
    assert reconciled.capital_expenditures == 8473.0, f"Expected 8473.0, got {reconciled.capital_expenditures}"

    # 2. Free cash flow must be 19370.0 - 8473.0 = 10897.0
    assert reconciled.free_cash_flow == 10897.0, f"Expected 10897.0, got {reconciled.free_cash_flow}"
    print("✅ Negative CapEx sign corrected and Free Cash Flow verified.")


def test_reconciliation_margin_derivations():
    """Verify Gross Margin, Operating Margin, and Net Margin are auto-derived."""
    print("Testing margin ratio derivations...")
    raw = FinancialReportKPIs(
        ticker="TSLA",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Tesla Q2 2026",
        revenue=25500.0,
        gross_profit=4590.0,
        operating_income=1605.0,
        net_income=1400.0,
        gross_margin=None,
        operating_margin=None,
        net_margin=None,
    )
    reconciled = validate_and_reconcile_kpis(raw)

    # Gross margin = 4590 / 25500 = 0.18 (18%)
    assert reconciled.gross_margin == 0.18, f"Expected 0.18, got {reconciled.gross_margin}"

    # Operating margin = 1605 / 25500 ≈ 0.0629 (6.3%)
    assert abs(reconciled.operating_margin - 0.0629) < 0.001

    # Net margin = 1400 / 25500 ≈ 0.0549 (5.5%)
    assert abs(reconciled.net_margin - 0.0549) < 0.001
    print("✅ Margin derivations (Gross, Operating, Net) verified.")


def test_filter_financial_statement_pages():
    """Verify only statement pages are retained, filtering out general/risk pages."""
    print("Testing financial statement page filtering...")
    pages = [
        ExtractedPage(page_number=1, text="Executive Summary", char_count=20, is_blank=False),
        ExtractedPage(page_number=2, text="Photo of Cybercab", char_count=20, is_blank=False),
        ExtractedPage(page_number=3, text="Condensed Consolidated Balance Sheet", char_count=50, is_blank=False),
        ExtractedPage(page_number=4, text="Statements of Operations / Income", char_count=50, is_blank=False),
        ExtractedPage(page_number=5, text="Statements of Cash Flows", char_count=50, is_blank=False),
        ExtractedPage(page_number=6, text="Risk Factors and Safe Harbor", char_count=30, is_blank=False),
    ]

    classifications = [
        PageClassification(page_number=1, domain=FinancialDomain.GENERAL, confidence=0.5, matched_signals=[]),
        PageClassification(page_number=2, domain=FinancialDomain.GENERAL, confidence=0.5, matched_signals=[]),
        PageClassification(page_number=3, domain=FinancialDomain.BALANCE_SHEET, confidence=0.9, matched_signals=[]),
        PageClassification(page_number=4, domain=FinancialDomain.PROFITABILITY, confidence=0.95, matched_signals=[]),
        PageClassification(page_number=5, domain=FinancialDomain.CASH_FLOW, confidence=0.9, matched_signals=[]),
        PageClassification(page_number=6, domain=FinancialDomain.RISK_FACTORS, confidence=0.8, matched_signals=[]),
    ]

    filtered = filter_financial_statement_pages(pages, classifications)
    assert len(filtered) == 3
    selected_page_numbers = [p.page_number for p in filtered]
    assert selected_page_numbers == [3, 4, 5], f"Expected [3, 4, 5], got {selected_page_numbers}"
    print("✅ Financial statement page filtering verified (only pages 3, 4, 5 selected).")


def test_mock_llm_extraction_pipeline():
    """Verify extract_financial_kpis with a mocked structured LLM."""
    print("Testing extraction pipeline with mocked LLM...")
    mock_llm = MagicMock()
    mock_structured = MagicMock()
    mock_llm.with_structured_output.return_value = mock_structured

    # Mock LLM return value
    mock_structured.invoke.return_value = FinancialReportKPIs(
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Meta Q2 2026 Financial Results",
        revenue=39071.0,
        gross_profit=32071.0,
        operating_cash_flow=19370.0,
        capital_expenditures=8473.0,
        source_pages=[5, 6, 7],
    )

    pages = [
        ExtractedPage(page_number=5, text="Statements of Income", char_count=20, is_blank=False),
        ExtractedPage(page_number=6, text="Balance Sheet", char_count=20, is_blank=False),
        ExtractedPage(page_number=7, text="Statements of Cash Flows", char_count=20, is_blank=False),
    ]
    classifications = [
        PageClassification(page_number=5, domain=FinancialDomain.PROFITABILITY, confidence=1.0, matched_signals=[]),
        PageClassification(page_number=6, domain=FinancialDomain.BALANCE_SHEET, confidence=1.0, matched_signals=[]),
        PageClassification(page_number=7, domain=FinancialDomain.CASH_FLOW, confidence=1.0, matched_signals=[]),
    ]

    result = extract_financial_kpis(
        extracted_pages=pages,
        classifications=classifications,
        llm=mock_llm,
        ticker_hint="META",
        quarter_hint="Q2",
        year_hint=2026,
    )

    assert result.ticker == "META"
    assert result.revenue == 39071.0
    # Auto-derived FCF
    assert result.free_cash_flow == 10897.0
    # Auto-derived Gross Margin
    assert result.gross_margin == 0.8208
    assert result.source_pages == [5, 6, 7]
    print("✅ End-to-end extraction pipeline with mocked LLM verified.")


def test_save_extracted_kpis_to_db():
    """Verify persisting FinancialReportKPIs to SQLite database (Step 2.4.2)."""
    print("Testing saving extracted KPIs to SQLite database...")
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    init_db(engine)
    TestingSession = sessionmaker(bind=engine)
    session = TestingSession()

    try:
        # 1. Create parent document
        doc = save_document(session, {
            "ticker": "META",
            "fiscal_quarter": "Q2",
            "fiscal_year": 2026,
            "report_title": "Meta Q2 2026 Financial Results",
            "sha256_hash": "mock_hash_meta_q2_2026",
            "file_path": "uploads/Meta_Q2_2026.pdf",
            "page_count": 9,
        })
        assert doc.id is not None

        # 2. Prepare validated Pydantic KPIs
        kpis = FinancialReportKPIs(
            ticker="META",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Meta Q2 2026 Financial Results",
            revenue=39071.0,
            gross_profit=32071.0,
            gross_margin=0.8208,
            operating_income=14847.0,
            operating_margin=0.38,
            net_income=13465.0,
            net_margin=0.3446,
            diluted_eps=5.16,
            operating_cash_flow=19370.0,
            capital_expenditures=8473.0,
            free_cash_flow=10897.0,
            cash_and_equivalents=58080.0,
            total_assets=242270.0,
            long_term_debt=28387.0,
            total_liabilities=86940.0,
            shareholders_equity=155330.0,
            source_pages=[5, 6, 7],
        )

        # 3. Persist to DB
        saved_kpi = save_extracted_kpis_to_db(session, doc.id, kpis)

        # 4. Assert ORM model fields
        assert saved_kpi.id is not None
        assert saved_kpi.document_id == doc.id
        assert saved_kpi.ticker == "META"
        assert saved_kpi.fiscal_year == 2026
        assert saved_kpi.fiscal_quarter == "Q2"
        assert saved_kpi.revenue == 39071.0
        assert saved_kpi.gross_margin == 0.8208
        assert saved_kpi.free_cash_flow == 10897.0
        assert saved_kpi.source_pages == "[5, 6, 7]"

        # 5. Query back via repository query
        queried = get_kpis_by_quarter(session, "META", 2026, "Q2")
        assert queried is not None
        assert queried.id == saved_kpi.id
        assert queried.net_income == 13465.0
        print("✅ Persistence of FinancialReportKPIs to SQLite verified.")
    finally:
        session.close()


def test_save_extracted_kpis_idempotency():
    """Verify that multiple saves for the same fiscal quarter update rather than duplicate."""
    print("Testing idempotent updating of KPIs in SQLite...")
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    init_db(engine)
    TestingSession = sessionmaker(bind=engine)
    session = TestingSession()

    try:
        doc = save_document(session, {
            "ticker": "TSLA",
            "fiscal_quarter": "Q2",
            "fiscal_year": 2026,
            "report_title": "Tesla Q2 2026 Update",
            "sha256_hash": "mock_hash_tsla_q2_2026",
            "file_path": "uploads/TSLA_Q2_2026.pdf",
            "page_count": 33,
        })

        initial_kpis = FinancialReportKPIs(
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Tesla Q2 2026 Update",
            revenue=25500.0,
            net_income=1400.0,
            source_pages=[10, 11],
        )
        save_extracted_kpis_to_db(session, doc.id, initial_kpis)

        # Second save (e.g., revised earnings report with updated revenue)
        revised_kpis = FinancialReportKPIs(
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Tesla Q2 2026 Update (Revised)",
            revenue=25580.0,
            net_income=1450.0,
            source_pages=[10, 11],
        )
        save_extracted_kpis_to_db(session, doc.id, revised_kpis)

        # Verify only 1 record exists
        all_records = list(session.scalars(select(FinancialKPIModel)).all())
        assert len(all_records) == 1, f"Expected 1 record, found {len(all_records)}"

        # Verify record has revised figures
        updated = get_kpis_by_quarter(session, "TSLA", 2026, "Q2")
        assert updated.revenue == 25580.0
        assert updated.net_income == 1450.0
        print("✅ Idempotent KPI upsert verified (updated existing record without duplicates).")
    finally:
        session.close()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING KPI EXTRACTOR UNIT TESTS (Steps 2.4.1 & 2.4.2)")
    print("=" * 60)

    test_schema_instantiation_and_defaults()
    test_reconciliation_negative_capex_and_fcf()
    test_reconciliation_margin_derivations()
    test_filter_financial_statement_pages()
    test_mock_llm_extraction_pipeline()
    test_save_extracted_kpis_to_db()
    test_save_extracted_kpis_idempotency()

    print("\n" + "=" * 60)
    print("ALL STEPS 2.4.1 & 2.4.2 EXTRACTOR TESTS PASSED SUCCESSFULLY! ✅")
    print("=" * 60)
