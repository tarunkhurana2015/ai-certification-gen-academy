"""
Unit & Integration tests for /api/v1/documents and /api/v1/ingestion endpoints.

Tests:
- GET /api/v1/documents
- GET /api/v1/documents/{document_id}
- GET /api/v1/documents/tasks/{task_id}
- POST /api/v1/ingestion/upload (valid PDF, invalid extension rejection)
- POST /api/v1/documents/ingest (alias check)
- 404 Not Found handling

Uses in-memory SQLite via dependency overrides. Pure assertions, zero disk artifacts.
"""

import io
import sys
from pathlib import Path
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.db.models import Base, DocumentModel, IngestionTaskModel
from app.db.session import get_db_session
from app.main import app
from app.schemas.ingestion import IngestionResponse
from app.schemas.kpis import FinancialReportKPIs

# In-memory test SQLite engine with StaticPool
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
    """Seed test documents and tasks in memory."""
    db = TestingSessionLocal()
    try:
        db.query(IngestionTaskModel).delete()
        db.query(DocumentModel).delete()
        db.commit()

        doc = DocumentModel(
            id="doc_test_123",
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Tesla Q2 2026 Shareholder Update",
            sha256_hash="sha256_dummy_hash_test_123",
            file_path="mock/tsla.pdf",
            page_count=33,
        )
        db.add(doc)

        task = IngestionTaskModel(
            id="task_test_456",
            ticker="TSLA",
            document_id="doc_test_123",
            status="COMPLETED",
            progress_percent=100,
            message="Ingestion completed successfully",
        )
        db.add(task)
        db.commit()
    finally:
        db.close()


def test_list_documents():
    """Verify document catalog endpoint."""
    seed_test_database()
    response = client.get("/api/v1/documents")
    assert response.status_code == 200
    docs = response.json()
    assert len(docs) == 1
    assert docs[0]["id"] == "doc_test_123"
    assert docs[0]["ticker"] == "TSLA"
    print("✅ test_list_documents passed.")


def test_get_document_details():
    """Verify single document retrieval by UUID."""
    response = client.get("/api/v1/documents/doc_test_123")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == "doc_test_123"
    assert data["ticker"] == "TSLA"
    assert data["fiscal_quarter"] == "Q2"
    assert data["fiscal_year"] == 2026

    # 404 test
    res_404 = client.get("/api/v1/documents/non_existent_doc")
    assert res_404.status_code == 404
    print("✅ test_get_document_details passed.")


def test_get_task_status():
    """Verify task status polling endpoint."""
    response = client.get("/api/v1/documents/tasks/task_test_456")
    assert response.status_code == 200
    data = response.json()
    assert data["task_id"] == "task_test_456"
    assert data["status"] == "COMPLETED"
    assert data["progress_percent"] == 100

    # 404 test
    res_404 = client.get("/api/v1/documents/tasks/non_existent_task")
    assert res_404.status_code == 404
    print("✅ test_get_task_status passed.")


def test_upload_rejection_for_non_pdf():
    """Verify that non-PDF files are immediately rejected with 400."""
    fake_txt_file = io.BytesIO(b"This is a text file")
    files = {"file": ("malicious.txt", fake_txt_file, "text/plain")}
    response = client.post("/api/v1/ingestion/upload", files=files)
    assert response.status_code == 400
    assert "Only '.pdf' files are accepted" in response.json()["detail"]
    print("✅ test_upload_rejection_for_non_pdf passed.")


def test_upload_and_ingest_mocked():
    """Verify upload endpoint calls IngestionPipeline and returns IngestionResponse."""
    from app.ingestion.pipeline import IngestionResult

    dummy_pdf_bytes = b"%PDF-1.4 dummy valid PDF header and content\n%%EOF"
    fake_pdf = io.BytesIO(dummy_pdf_bytes)
    files = {"file": ("sample_report.pdf", fake_pdf, "application/pdf")}

    mock_result = IngestionResult(
        task_id="task_mock_789",
        document_id="doc_mock_789",
        status="COMPLETED",
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Meta Q2 2026 Results",
        sha256_hash="mock_hash_123",
        file_path="mock/meta.pdf",
        page_count=9,
        is_duplicate=False,
        duration_seconds=1.23,
        error_message=None,
        kpis=FinancialReportKPIs(
            ticker="META",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Meta Q2 2026 Results",
            revenue=47510.0,
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
            source_pages=[5, 6, 7],
        ).model_dump(),
    )

    with patch("app.api.v1.endpoints.documents.IngestionPipeline.run", return_value=mock_result):
        response = client.post(
            "/api/v1/ingestion/upload",
            files=files,
            data={"ticker": "META", "quarter": "Q2", "year": "2026"},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["task_id"] == "task_mock_789"
        assert data["ticker"] == "META"
        assert data["status"] == "COMPLETED"
        assert data["kpis"]["revenue"] == 47510.0
        assert data["client_kpis"] is not None
        assert data["client_kpis"]["profitability"]["total_revenue_millions"] == 47510.0
        assert data["client_kpis"]["company_name"] == "Meta Platforms, Inc."
    print("✅ test_upload_and_ingest_mocked passed.")


def test_documents_ingest_alias():
    """Verify /api/v1/documents/ingest works as an alias for /ingestion/upload."""
    from app.ingestion.pipeline import IngestionResult

    dummy_pdf_bytes = b"%PDF-1.4 dummy content\n%%EOF"
    fake_pdf = io.BytesIO(dummy_pdf_bytes)
    files = {"file": ("alias_test.pdf", fake_pdf, "application/pdf")}

    mock_result = IngestionResult(
        task_id="task_alias_1",
        document_id="doc_alias_1",
        status="COMPLETED",
        ticker="TSLA",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Tesla Q2 2026 Results",
        sha256_hash="mock_hash_alias",
        file_path="mock/tsla.pdf",
        page_count=33,
        is_duplicate=False,
        duration_seconds=0.5,
        error_message=None,
        kpis=None,
    )

    with patch("app.api.v1.endpoints.documents.IngestionPipeline.run", return_value=mock_result):
        response = client.post("/api/v1/documents/ingest", files=files)
        assert response.status_code == 200
        data = response.json()
        assert data["task_id"] == "task_alias_1"
        assert data["ticker"] == "TSLA"
    print("✅ test_documents_ingest_alias passed.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING DOCUMENTS & INGESTION API TESTS")
    print("=" * 60)
    test_list_documents()
    test_get_document_details()
    test_get_task_status()
    test_upload_rejection_for_non_pdf()
    test_upload_and_ingest_mocked()
    test_documents_ingest_alias()
    print("\n" + "=" * 60)
    print("ALL DOCUMENTS & INGESTION API TESTS PASSED! ✅")
    print("=" * 60 + "\n")
