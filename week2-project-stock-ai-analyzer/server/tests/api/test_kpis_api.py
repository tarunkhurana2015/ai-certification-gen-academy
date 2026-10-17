"""
Unit & Integration tests for /api/v1/kpi endpoints.

Tests:
- GET /api/v1/kpi/{ticker} (single quarter with ?quarter=Q2&year=2026)
- GET /api/v1/kpi/{ticker} (chronological time series)
- GET /api/v1/kpi/{ticker}/latest (latest quarter)
- GET /api/v1/kpi/compare?tickers=TSLA&tickers=META&quarter=Q2&year=2026 (peer comparison)
- GET /api/v1/kpi/document/{document_id}
- 404 Not Found handling
- Verification that client_reports directly match Flutter's QuarterlyKpis.fromJson contract

Uses in-memory SQLite via dependency overrides. Pure assertions, zero disk artifacts.
"""

import sys
from pathlib import Path
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.db.models import Base, DocumentModel, FinancialKPIModel
from app.db.session import get_db_session
from app.main import app

# In-memory test SQLite engine with StaticPool so all threads/sessions share the same DB
test_engine = create_engine(
    "sqlite:///:memory:",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)
Base.metadata.create_all(bind=test_engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db_session] = override_get_db
client = TestClient(app)


def seed_test_database():
    """Seed test documents and KPIs in memory."""
    db = TestingSessionLocal()
    try:
        # Clear existing
        db.query(FinancialKPIModel).delete()
        db.query(DocumentModel).delete()
        db.commit()

        # Seed Meta Document
        meta_doc = DocumentModel(
            id="doc_meta_2026_q2",
            ticker="META",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Meta Q2 2026 Financial Results",
            sha256_hash="hash_meta_q2_2026",
            file_path="mock/meta.pdf",
            page_count=9,
        )
        db.add(meta_doc)

        # Seed Meta Q2 KPI
        meta_kpi = FinancialKPIModel(
            document_id="doc_meta_2026_q2",
            ticker="META",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            revenue=47510.0,
            cost_of_revenue=8552.0,
            gross_profit=38958.0,
            gross_margin=0.82,
            operating_income=18150.0,
            operating_margin=0.382,
            net_income=15820.0,
            net_margin=0.333,
            diluted_eps=6.12,
            operating_cash_flow=21800.0,
            capital_expenditures=8200.0,
            free_cash_flow=13600.0,
            cash_and_equivalents=58100.0,
            total_assets=245000.0,
            total_liabilities=85000.0,
            shareholders_equity=160000.0,
            long_term_debt=18400.0,
            source_pages="[5, 6, 7]",
        )
        db.add(meta_kpi)

        # Seed Meta Q1 Document
        meta_q1_doc = DocumentModel(
            id="doc_meta_2026_q1",
            ticker="META",
            fiscal_quarter="Q1",
            fiscal_year=2026,
            report_title="Meta Q1 2026 Financial Results",
            sha256_hash="hash_meta_q1_2026",
            file_path="mock/meta_q1.pdf",
            page_count=8,
        )
        db.add(meta_q1_doc)

        # Seed Meta Q1 KPI for time series
        meta_q1_kpi = FinancialKPIModel(
            document_id="doc_meta_2026_q1",
            ticker="META",
            fiscal_quarter="Q1",
            fiscal_year=2026,
            revenue=42300.0,
            cost_of_revenue=8000.0,
            gross_profit=34300.0,
            gross_margin=0.811,
            operating_income=16100.0,
            operating_margin=0.381,
            net_income=13800.0,
            net_margin=0.326,
            diluted_eps=5.35,
            operating_cash_flow=19200.0,
            capital_expenditures=7500.0,
            free_cash_flow=11700.0,
            cash_and_equivalents=54000.0,
            total_assets=238000.0,
            total_liabilities=83000.0,
            shareholders_equity=155000.0,
            long_term_debt=18400.0,
            source_pages="[5, 6, 7]",
        )
        db.add(meta_q1_kpi)

        # Seed Tesla Document & KPI for peer comparison
        tsla_doc = DocumentModel(
            id="doc_tsla_2026_q2",
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Tesla Q2 2026 Shareholder Update",
            sha256_hash="hash_tsla_q2_2026",
            file_path="mock/tsla.pdf",
            page_count=33,
        )
        db.add(tsla_doc)

        tsla_kpi = FinancialKPIModel(
            document_id="doc_tsla_2026_q2",
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            revenue=28236.0,
            cost_of_revenue=23200.0,
            gross_profit=5036.0,
            gross_margin=0.178,
            operating_income=1605.0,
            operating_margin=0.057,
            net_income=1114.0,
            net_margin=0.039,
            diluted_eps=0.35,
            operating_cash_flow=1200.0,
            capital_expenditures=2292.0,
            free_cash_flow=-1092.0,
            cash_and_equivalents=30720.0,
            total_assets=110450.0,
            total_liabilities=44820.0,
            shareholders_equity=65630.0,
            long_term_debt=5350.0,
            source_pages="[4, 29]",
        )
        db.add(tsla_kpi)
        db.commit()
    finally:
        db.close()


def test_get_single_quarter_kpis():
    """Verify single quarter retrieval with query params."""
    seed_test_database()
    response = client.get("/api/v1/kpi/META?quarter=Q2&year=2026")
    assert response.status_code == 200
    data = response.json()
    assert data["ticker"] == "META"
    assert data["fiscal_quarter"] == "Q2"
    assert data["fiscal_year"] == 2026
    assert data["kpi"]["revenue"] == 47510.0
    assert data["kpi"]["free_cash_flow"] == 13600.0

    # Verify nested client_report structure
    client_rep = data["client_report"]
    assert client_rep["document_id"] == "doc_meta_2026_q2"
    assert client_rep["company_name"] == "Meta Platforms, Inc."
    assert client_rep["profitability"]["total_revenue_millions"] == 47510.0
    assert client_rep["profitability"]["gross_margin_pct"] == 82.0
    assert client_rep["cash_flow"]["free_cash_flow_millions"] == 13600.0
    assert client_rep["balance_sheet"]["cash_and_equivalents_millions"] == 58100.0
    print("✅ test_get_single_quarter_kpis passed.")


def test_get_time_series_kpis():
    """Verify multi-quarter time series retrieval."""
    response = client.get("/api/v1/kpi/META")
    assert response.status_code == 200
    data = response.json()
    assert data["ticker"] == "META"
    assert data["total_quarters"] == 2
    assert len(data["kpis"]) == 2
    assert len(data["client_reports"]) == 2
    # Check chronological ordering: Q1 2026 then Q2 2026
    assert data["kpis"][0]["fiscal_quarter"] == "Q1"
    assert data["kpis"][1]["fiscal_quarter"] == "Q2"
    print("✅ test_get_time_series_kpis passed.")


def test_get_latest_kpis():
    """Verify latest quarter convenience endpoint."""
    response = client.get("/api/v1/kpi/META/latest")
    assert response.status_code == 200
    data = response.json()
    assert data["ticker"] == "META"
    assert data["fiscal_quarter"] == "Q2"
    assert data["fiscal_year"] == 2026
    print("✅ test_get_latest_kpis passed.")


def test_compare_peer_companies():
    """Verify multi-ticker comparison endpoint."""
    response = client.get("/api/v1/kpi/compare?tickers=META&tickers=TSLA&quarter=Q2&year=2026")
    assert response.status_code == 200
    data = response.json()
    assert data["fiscal_quarter"] == "Q2"
    assert data["fiscal_year"] == 2026
    assert data["total_companies"] == 2
    tickers = {k["ticker"] for k in data["kpis"]}
    assert "META" in tickers
    assert "TSLA" in tickers
    print("✅ test_compare_peer_companies passed.")


def test_get_kpis_by_document():
    """Verify document ID lookup."""
    response = client.get("/api/v1/kpi/document/doc_meta_2026_q2")
    assert response.status_code == 200
    data = response.json()
    assert data["document_id"] == "doc_meta_2026_q2"
    assert data["ticker"] == "META"
    print("✅ test_get_kpis_by_document passed.")


def test_kpi_not_found():
    """Verify 404 responses on non-existent records."""
    response = client.get("/api/v1/kpi/NONEXISTENT")
    assert response.status_code == 404
    assert "No financial time series found" in response.json()["detail"]

    response_quarter = client.get("/api/v1/kpi/META?quarter=Q3&year=2099")
    assert response_quarter.status_code == 404
    assert "No financial record found" in response_quarter.json()["detail"]
    print("✅ test_kpi_not_found passed.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING KPI API TESTS")
    print("=" * 60)
    test_get_single_quarter_kpis()
    test_get_time_series_kpis()
    test_get_latest_kpis()
    test_compare_peer_companies()
    test_get_kpis_by_document()
    test_kpi_not_found()
    print("\n" + "=" * 60)
    print("ALL KPI API TESTS PASSED! ✅")
    print("=" * 60 + "\n")
