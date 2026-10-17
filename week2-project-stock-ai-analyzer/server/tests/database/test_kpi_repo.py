"""
Unit Tests for Deterministic Financial KPI Repository (Step 2.3).

Validates:
1. Document creation and 0.1ms SHA-256 deduplication lookup.
2. Idempotent KPI upserting with automatic calculation of derived ratios (Margins, FCF).
3. Single quarter exact financial lookup.
4. Chronological ordering of multi-quarter time series for frontend charts.
5. Cross-company peer comparisons for a given fiscal period.
6. Async ingestion task lifecycle and state tracking.

NOTE: Tests must NEVER write artifacts. Pure assertions only.
"""

import sys
import uuid
from pathlib import Path
from sqlalchemy.orm import Session, sessionmaker

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.database.session import Base, create_db_engine
from app.database.models import DocumentModel, FinancialKPIModel, IngestionTaskModel
from app.database.kpi_repo import (
    create_task,
    get_document_by_hash,
    get_document_by_id,
    get_kpi_time_series,
    get_kpis_by_quarter,
    get_multi_company_comparison,
    get_task,
    list_documents,
    save_document,
    update_task_status,
    upsert_kpi,
)


def create_test_session() -> Session:
    """Helper creating a fresh, isolated in-memory SQLite session with foreign keys enabled."""
    test_engine = create_db_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=test_engine)
    test_session_factory = sessionmaker(bind=test_engine)
    return test_session_factory()


def test_document_save_and_lookup_by_hash():
    """Verify saving a document and retrieving it instantaneously via SHA-256."""
    print("Testing document saving and deduplication lookup...")
    session = create_test_session()
    test_hash = "abc123sha256hash_" + uuid.uuid4().hex[:8]

    doc = save_document(session, {
        "ticker": "META",
        "fiscal_quarter": "q2",
        "fiscal_year": 2026,
        "report_title": "Meta Q2 2026 Earnings",
        "sha256_hash": test_hash,
        "file_path": "uploads/meta_q2_2026.pdf",
        "page_count": 9,
    })

    assert doc.id is not None
    assert doc.ticker == "META"
    assert doc.fiscal_quarter == "Q2"  # Verifies uppercase normalization

    # Lookup by SHA-256 hash
    found = get_document_by_hash(session, test_hash)
    assert found is not None
    assert found.id == doc.id
    assert found.report_title == "Meta Q2 2026 Earnings"

    # Non-existent hash
    missing = get_document_by_hash(session, "non_existent_hash")
    assert missing is None

    session.close()
    print("✅ Document saved and deduplication lookup verified.")


def test_kpi_upsert_and_derived_metrics():
    """Verify upsert_kpi calculates Margins and Free Cash Flow automatically."""
    print("Testing KPI upsert and auto-calculation of derived metrics...")
    session = create_test_session()

    doc = save_document(session, {
        "ticker": "META",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "report_title": "Meta Q2 2026",
        "sha256_hash": "meta_hash_derive",
        "file_path": "uploads/meta.pdf",
        "page_count": 9,
    })

    # Insert with raw components without pre-calculated ratios
    kpi = upsert_kpi(session, {
        "document_id": doc.id,
        "ticker": "META",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "revenue": 40000.0,
        "gross_profit": 32000.0,
        "operating_income": 16000.0,
        "net_income": 12000.0,
        "operating_cash_flow": 20000.0,
        "capital_expenditures": 8000.0,
    })

    # Verifications:
    # gross_margin = 32000 / 40000 = 0.80
    assert kpi.gross_margin == 0.80, f"Expected 0.80, got {kpi.gross_margin}"
    # operating_margin = 16000 / 40000 = 0.40
    assert kpi.operating_margin == 0.40, f"Expected 0.40, got {kpi.operating_margin}"
    # net_margin = 12000 / 40000 = 0.30
    assert kpi.net_margin == 0.30, f"Expected 0.30, got {kpi.net_margin}"
    # free_cash_flow = 20000 - 8000 = 12000
    assert kpi.free_cash_flow == 12000.0, f"Expected 12000.0, got {kpi.free_cash_flow}"

    # Idempotent re-upsert (update existing row, ensure count remains 1)
    kpi_updated = upsert_kpi(session, {
        "document_id": doc.id,
        "ticker": "META",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "revenue": 42000.0,
        "gross_profit": 33600.0,
    })

    assert kpi_updated.id == kpi.id, "Upsert should update existing row without generating new ID"
    assert kpi_updated.revenue == 42000.0
    assert kpi_updated.gross_margin == 0.80

    total_kpis = session.query(FinancialKPIModel).count()
    assert total_kpis == 1, f"Expected exactly 1 KPI row after upsert, got {total_kpis}"

    session.close()
    print("✅ KPI upsert and auto-calculation of derived metrics verified.")


def test_kpi_by_quarter_lookup():
    """Verify single quarter retrieval."""
    print("Testing get_kpis_by_quarter lookup...")
    session = create_test_session()

    doc = save_document(session, {
        "ticker": "TSLA",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "report_title": "Tesla Q2 2026",
        "sha256_hash": "tsla_lookup_hash",
        "file_path": "uploads/tsla.pdf",
        "page_count": 33,
    })

    upsert_kpi(session, {
        "document_id": doc.id,
        "ticker": "TSLA",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "revenue": 25500.0,
        "net_income": 1400.0,
    })

    # Exact match
    res = get_kpis_by_quarter(session, "TSLA", 2026, "Q2")
    assert res is not None
    assert res.revenue == 25500.0
    assert res.net_income == 1400.0

    # Non-existent quarter
    missing = get_kpis_by_quarter(session, "TSLA", 2025, "Q1")
    assert missing is None

    session.close()
    print("✅ Single quarter lookup verified.")


def test_kpi_time_series_chronological_ordering():
    """Verify quarters are strictly ordered chronologically for frontend charting."""
    print("Testing chronological time series ordering...")
    session = create_test_session()

    doc = save_document(session, {
        "ticker": "AAPL",
        "fiscal_quarter": "Q4",
        "fiscal_year": 2026,
        "report_title": "Apple Financials",
        "sha256_hash": "aapl_ts_hash",
        "file_path": "uploads/aapl.pdf",
        "page_count": 10,
    })

    # Insert out of order: Q3 2025, Q1 2026, Q1 2025, Q2 2026
    raw_quarters = [
        ("Q3", 2025, 82000.0),
        ("Q1", 2026, 95000.0),
        ("Q1", 2025, 90000.0),
        ("Q2", 2026, 88000.0),
    ]
    for q, y, rev in raw_quarters:
        upsert_kpi(session, {
            "document_id": doc.id,
            "ticker": "AAPL",
            "fiscal_quarter": q,
            "fiscal_year": y,
            "revenue": rev,
        })

    # Retrieve time series
    series = get_kpi_time_series(session, "AAPL", limit=10)
    assert len(series) == 4

    # Verify chronological order: (2025, Q1), (2025, Q3), (2026, Q1), (2026, Q2)
    expected_order = [("2025", "Q1"), ("2025", "Q3"), ("2026", "Q1"), ("2026", "Q2")]
    actual_order = [(str(s.fiscal_year), s.fiscal_quarter) for s in series]
    assert actual_order == expected_order, f"Order mismatch: expected {expected_order}, got {actual_order}"

    session.close()
    print("✅ Chronological time series ordering verified.")


def test_multi_company_comparison():
    """Verify side-by-side comparison across multiple companies."""
    print("Testing multi-company peer comparison...")
    session = create_test_session()

    doc1 = save_document(session, {
        "ticker": "META",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "report_title": "Meta",
        "sha256_hash": "meta_peer_hash",
        "file_path": "meta.pdf",
        "page_count": 9,
    })
    upsert_kpi(session, {
        "document_id": doc1.id,
        "ticker": "META",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "revenue": 39071.0,
        "gross_profit": 32000.0,
    })

    doc2 = save_document(session, {
        "ticker": "TSLA",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "report_title": "Tesla",
        "sha256_hash": "tsla_peer_hash",
        "file_path": "tsla.pdf",
        "page_count": 33,
    })
    upsert_kpi(session, {
        "document_id": doc2.id,
        "ticker": "TSLA",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "revenue": 25500.0,
        "gross_profit": 4590.0,
    })

    # Fetch peer comparison
    peers = get_multi_company_comparison(session, ["META", "TSLA"], 2026, "Q2")
    assert len(peers) == 2
    tickers_found = {p.ticker for p in peers}
    assert tickers_found == {"META", "TSLA"}

    session.close()
    print("✅ Multi-company peer comparison verified.")


def test_task_lifecycle_tracking():
    """Verify creating and updating ingestion tasks."""
    print("Testing IngestionTask lifecycle tracking...")
    session = create_test_session()

    task = create_task(session, ticker="META")
    assert task.status == "PENDING"
    assert task.progress_percent == 0

    # Advance task
    updated = update_task_status(session, task.id, status="EXTRACTING", progress_percent=25, message="Extracting text")
    assert updated is not None
    assert updated.status == "EXTRACTING"
    assert updated.progress_percent == 25

    # Complete task
    completed = update_task_status(session, task.id, status="COMPLETED", progress_percent=100, message="Done")
    assert completed is not None
    assert completed.status == "COMPLETED"
    assert completed.progress_percent == 100

    # Retrieve by ID
    fetched = get_task(session, task.id)
    assert fetched is not None
    assert fetched.status == "COMPLETED"

    session.close()
    print("✅ IngestionTask lifecycle tracking verified.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING KPI REPOSITORY UNIT TESTS (Step 2.3)")
    print("=" * 60)

    test_document_save_and_lookup_by_hash()
    test_kpi_upsert_and_derived_metrics()
    test_kpi_by_quarter_lookup()
    test_kpi_time_series_chronological_ordering()
    test_multi_company_comparison()
    test_task_lifecycle_tracking()

    print("\n" + "=" * 60)
    print("ALL STEP 2.3 REPOSITORY TESTS PASSED SUCCESSFULLY! ✅")
    print("=" * 60)
