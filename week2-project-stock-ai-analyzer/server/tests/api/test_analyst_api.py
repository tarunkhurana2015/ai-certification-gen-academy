"""
Unit & Integration tests for /api/v1/analyst and /api/v1/chat endpoints.

Tests:
- POST /api/v1/analyst/query (SQL KPI route)
- POST /api/v1/analyst/query (Hybrid RAG route)
- POST /api/v1/analyst/query (Comparison route)
- POST /api/v1/chat (Chat endpoint alias)
- GET  /api/v1/analyst/classify (Intent inspection)
- GET  /api/v1/analyst/routes (Routes catalog & prompt suggestions)
- 422 Validation error handling for empty query

Uses in-memory SQLite via dependency overrides. Pure assertions, zero disk artifacts.
"""

import os
import sys
from pathlib import Path
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# Disable LangSmith tracing during test runs
os.environ["LANGCHAIN_TRACING_V2"] = "false"

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.db.models import Base, DocumentModel, FinancialKPIModel
from app.db.session import get_db_session
from app.main import app

# In-memory test SQLite engine
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
        db.query(FinancialKPIModel).delete()
        db.query(DocumentModel).delete()

        doc_tsla = DocumentModel(
            id="doc-tsla-test-1",
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Tesla Q2 2026 Update",
            sha256_hash="hash-tsla-test",
            file_path="/tmp/tsla.pdf",
            page_count=28,
        )
        kpi_tsla = FinancialKPIModel(
            id="kpi-tsla-test-1",
            document_id=doc_tsla.id,
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            revenue=25500.0,
            gross_profit=4590.0,
            gross_margin=0.18,
            operating_income=1605.0,
            operating_margin=0.063,
            net_income=1478.0,
            free_cash_flow=1400.0,
            cash_and_equivalents=29000.0,
            source_pages="[2, 3]",
        )

        doc_meta = DocumentModel(
            id="doc-meta-test-1",
            ticker="META",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Meta Q2 2026 Earnings",
            sha256_hash="hash-meta-test",
            file_path="/tmp/meta.pdf",
            page_count=32,
        )
        kpi_meta = FinancialKPIModel(
            id="kpi-meta-test-1",
            document_id=doc_meta.id,
            ticker="META",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            revenue=47510.0,
            gross_profit=38950.0,
            gross_margin=0.82,
            operating_income=14630.0,
            operating_margin=0.308,
            net_income=18320.0,
            free_cash_flow=13600.0,
            cash_and_equivalents=58200.0,
            source_pages="[5, 6]",
        )

        db.add_all([doc_tsla, kpi_tsla, doc_meta, kpi_meta])
        db.commit()
    finally:
        db.close()


def test_analyst_sql_query():
    """Validates POST /api/v1/analyst/query correctly routes to SQL KPI."""
    seed_test_database()
    res = client.post(
        "/api/v1/analyst/query",
        json={"query": "What was Tesla Q2 2026 revenue and free cash flow?", "mock": True},
    )
    assert res.status_code == 200
    data = res.json()
    assert data["route_used"] == "sql_kpi"
    assert data["ticker"] == "TSLA"
    assert "TSLA" in data["answer"]
    assert "citations" in data
    assert len(data["citations"]) > 0
    assert data["citations"][0]["source"] == "sqlite://financial_kpis"
    assert data["duration_seconds"] >= 0.0


def test_analyst_hybrid_rag_query():
    """Validates POST /api/v1/analyst/query correctly routes to Hybrid RAG."""
    seed_test_database()
    res = client.post(
        "/api/v1/analyst/query",
        json={
            "query": "Why did automotive gross margin decline sequentially in Q2 2026?",
            "mock": True,
        },
    )
    assert res.status_code == 200
    data = res.json()
    assert data["route_used"] == "hybrid_rag"
    assert data["ticker"] == "TSLA"
    assert data["financial_domain"] == "profitability"
    assert "answer" in data
    assert len(data["answer"]) > 10


def test_analyst_comparison_query():
    """Validates POST /api/v1/analyst/query correctly routes to Peer Comparison."""
    seed_test_database()
    res = client.post(
        "/api/v1/analyst/query",
        json={
            "query": "Compare Meta and Tesla operating margins over the last year",
            "mock": True,
        },
    )
    assert res.status_code == 200
    data = res.json()
    assert data["route_used"] == "comparison"
    assert data["ticker"] == "multiple"
    assert "Peer Comparison" in data["answer"]
    assert len(data["citations"]) >= 1


def test_chat_alias_endpoint():
    """Validates POST /api/v1/chat serves as an identical alias to /analyst/query."""
    seed_test_database()
    res = client.post(
        "/api/v1/chat",
        json={"query": "What was Tesla Q2 2026 revenue and free cash flow?", "mock": True},
    )
    assert res.status_code == 200
    data = res.json()
    assert data["route_used"] == "sql_kpi"
    assert data["ticker"] == "TSLA"
    assert len(data["citations"]) > 0


def test_analyst_classify_endpoint():
    """Validates GET /api/v1/analyst/classify inspects intent and metadata filter."""
    res = client.get("/api/v1/analyst/classify?q=What was Meta net income?&mock=true")
    assert res.status_code == 200
    data = res.json()
    assert data["query_type"] == "sql_kpi"
    assert data["ticker"] == "META"
    assert "metadata_filter" in data
    assert data["metadata_filter"].get("ticker") == "META"


def test_analyst_routes_catalog():
    """Validates GET /api/v1/analyst/routes returns route descriptions and examples."""
    res = client.get("/api/v1/analyst/routes")
    assert res.status_code == 200
    data = res.json()
    assert "routes" in data
    assert len(data["routes"]) == 3
    route_keys = [r["route"] for r in data["routes"]]
    assert "sql_kpi" in route_keys
    assert "hybrid_rag" in route_keys
    assert "comparison" in route_keys
    for r in data["routes"]:
        assert len(r["sample_queries"]) >= 2


def test_analyst_empty_query_validation():
    """Validates 422 Unprocessable Entity on empty query string."""
    res = client.post("/api/v1/analyst/query", json={"query": ""})
    assert res.status_code == 422


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING FINANCIAL ANALYST API TESTS")
    print("=" * 60)

    test_analyst_sql_query()
    print("✅ test_analyst_sql_query passed.")

    test_analyst_hybrid_rag_query()
    print("✅ test_analyst_hybrid_rag_query passed.")

    test_analyst_comparison_query()
    print("✅ test_analyst_comparison_query passed.")

    test_chat_alias_endpoint()
    print("✅ test_chat_alias_endpoint passed.")

    test_analyst_classify_endpoint()
    print("✅ test_analyst_classify_endpoint passed.")

    test_analyst_routes_catalog()
    print("✅ test_analyst_routes_catalog passed.")

    test_analyst_empty_query_validation()
    print("✅ test_analyst_empty_query_validation passed.")

    print("\n" + "=" * 60)
    print("ALL FINANCIAL ANALYST API TESTS PASSED! ✅")
    print("=" * 60 + "\n")
