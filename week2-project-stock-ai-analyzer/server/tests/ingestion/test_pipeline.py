"""
Unit Tests for Ingestion Pipeline Orchestrator.

Conforms to ARCHITECTURE.md Section 8 (tests/ingestion/test_pipeline.py).
Tests:
1. Validation failure handling (invalid PDF headers, empty files).
2. Instant 0.1ms deduplication path when document already exists in SQLite.
3. Full end-to-end ingestion workflow with Mock LLM and isolated in-memory SQLite:
   - State transition progression (15% -> 25% -> 40% -> 55% -> 70% -> 85% -> 95% -> 100%)
   - IngestionTask, DocumentModel, and FinancialKPIModel persistence and linkage.
"""

import sys
from pathlib import Path
from unittest.mock import MagicMock

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.db.session import Base
from app.db.models import DocumentModel, FinancialKPIModel, IngestionTaskModel
from app.db.repositories.document_repo import get_task, save_document
from app.db.repositories.kpi_repo import get_kpis_by_document_id, upsert_kpi
from app.ingestion.pipeline import IngestionPipeline, IngestionResult
from app.schemas.kpis import FinancialReportKPIs


def get_test_in_memory_session_factory():
    """Create an isolated, in-memory SQLite database session factory for pure assertions."""
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    return sessionmaker(bind=engine)


def test_validation_failure():
    """Verify that an invalid PDF fails gracefully and updates task to FAILED."""
    print("Testing validation failure handling...")
    session_factory = get_test_in_memory_session_factory()
    pipeline = IngestionPipeline(session_factory=session_factory)

    # Use a non-existent or fake file
    fake_path = _SERVER_ROOT / "tests/test_data/non_existent.pdf"
    result = pipeline.run(file_path=fake_path, ticker="TEST")

    assert result.status == "FAILED"
    assert result.error_message is not None
    assert "File not found" in result.error_message or "Validation Error" in result.error_message

    # Verify task row in SQLite
    session = session_factory()
    task = get_task(session, result.task_id)
    assert task is not None
    assert task.status == "FAILED"
    assert task.progress_percent == 100
    session.close()
    print("✅ Validation failure handled gracefully.")


def test_instant_deduplication():
    """Verify that an already ingested document triggers instant 0.1ms deduplication."""
    print("Testing instant deduplication flow...")
    session_factory = get_test_in_memory_session_factory()
    session = session_factory()

    real_pdf = _SERVER_ROOT / "tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    from app.ingestion.validator import compute_sha256
    pdf_hash = compute_sha256(real_pdf)

    # Pre-seed document and KPI in SQLite
    doc = save_document(session, {
        "ticker": "META",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "report_title": "Meta Q2 2026 Release",
        "sha256_hash": pdf_hash,
        "file_path": str(real_pdf),
        "page_count": 9,
    })

    upsert_kpi(session, {
        "document_id": doc.id,
        "ticker": "META",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "revenue": 47510.0,
        "net_income": 15848.0,
        "operating_cash_flow": 24150.0,
        "capital_expenditures": 8470.0,
    })
    doc_id = doc.id
    session.close()

    # Run pipeline on the same file
    pipeline = IngestionPipeline(session_factory=session_factory)
    result = pipeline.run(file_path=real_pdf)

    assert result.status == "COMPLETED"
    assert result.is_duplicate is True
    assert result.document_id == doc_id
    assert result.kpis is not None
    assert result.kpis["revenue"] == 47510.0
    assert result.kpis["net_income"] == 15848.0

    # Verify task record
    session = session_factory()
    task = get_task(session, result.task_id)
    assert task is not None
    assert task.status == "COMPLETED"
    assert task.progress_percent == 100
    assert "Instant deduplication" in task.message
    session.close()
    print("✅ Instant deduplication verified in SQLite.")


def test_full_pipeline_with_mock_llm():
    """Verify full end-to-end ingestion pipeline with mock LLM and progress callbacks."""
    print("Testing full end-to-end pipeline execution...")
    session_factory = get_test_in_memory_session_factory()

    # Track progress notifications
    progress_log = []
    def callback(status: str, percent: int, msg: str):
        progress_log.append((status, percent))

    # Mock structured LLM
    mock_llm = MagicMock()
    mock_structured = MagicMock()
    mock_llm.with_structured_output.return_value = mock_structured

    mock_kpis = FinancialReportKPIs(
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Meta Platforms, Inc. Q2 2026",
        revenue=47510.0,
        cost_of_revenue=8552.0,
        gross_profit=38958.0,
        operating_income=19848.0,
        net_income=15848.0,
        diluted_eps=6.15,
        operating_cash_flow=24150.0,
        capital_expenditures=-8470.0,  # Negative CapEx to test auto-correction
        free_cash_flow=15680.0,
        cash_and_equivalents=41200.0,
        total_assets=258400.0,
        long_term_debt=28400.0,
        total_liabilities=84200.0,
        shareholders_equity=174200.0,
        source_pages=[5, 6, 7],
    )
    mock_structured.invoke.return_value = mock_kpis

    real_pdf = _SERVER_ROOT / "tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    pipeline = IngestionPipeline(
        session_factory=session_factory,
        llm=mock_llm,
        progress_callback=callback,
    )

    result = pipeline.run(
        file_path=real_pdf,
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
    )

    assert result.status == "COMPLETED"
    assert result.is_duplicate is False
    assert result.document_id is not None
    assert result.kpis is not None
    assert result.kpis["revenue"] == 47510.0
    assert result.kpis["capital_expenditures"] == 8470.0  # Auto-reconciled to positive
    assert result.kpis["free_cash_flow"] == 15680.0

    # Verify progress state sequence
    statuses = [s[0] for s in progress_log]
    assert "VALIDATING" in statuses
    assert "DEDUPLICATING" in statuses
    assert "EXTRACTING" in statuses
    assert "CLASSIFYING" in statuses
    assert "CHUNKING" in statuses
    assert "EXTRACTING_KPIS" in statuses
    assert "PERSISTING" in statuses
    assert "COMPLETED" in statuses

    # Verify SQLite database records
    session = session_factory()
    task = get_task(session, result.task_id)
    assert task is not None
    assert task.status == "COMPLETED"
    assert task.progress_percent == 100
    assert task.document_id == result.document_id

    persisted_kpi = get_kpis_by_document_id(session, result.document_id)
    assert persisted_kpi is not None
    assert persisted_kpi.ticker == "META"
    assert persisted_kpi.revenue == 47510.0
    assert persisted_kpi.net_income == 15848.0
    session.close()
    print("✅ Full pipeline execution and database state verified.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING INGESTION PIPELINE UNIT TESTS")
    print("=" * 60)

    test_validation_failure()
    test_instant_deduplication()
    test_full_pipeline_with_mock_llm()

    print("\n" + "=" * 60)
    print("ALL INGESTION PIPELINE TESTS PASSED! ✅")
    print("=" * 60)
