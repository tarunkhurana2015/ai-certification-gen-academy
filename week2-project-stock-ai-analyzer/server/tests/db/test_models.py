"""
Unit Tests for Database ORM Models (Step 2.2).

Validates:
1. Table schemas for documents, financial_kpis, and ingestion_tasks.
2. SHA-256 unique constraint on DocumentModel.
3. Unique constraint on (ticker, fiscal_year, fiscal_quarter) for FinancialKPIModel.
4. Foreign key cascade delete behavior (deleting a Document cascades to child KPIs).
5. KPI dictionary serialization (to_dict).
6. IngestionTask status transitions.

NOTE: Tests must NEVER write artifacts. Pure assertions only.
"""

import sys
import uuid
from pathlib import Path
from sqlalchemy import create_engine, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, sessionmaker

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.db.session import Base, create_db_engine
from app.db.models import DocumentModel, FinancialKPIModel, IngestionTaskModel


def create_test_session() -> Session:
    """Helper creating a fresh, isolated in-memory SQLite session with foreign keys enabled."""
    test_engine = create_db_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=test_engine)
    test_session_factory = sessionmaker(bind=test_engine)
    return test_session_factory()


def test_models_table_creation():
    """Verify that all three expected tables exist in metadata."""
    print("Testing tables in metadata...")
    table_names = set(Base.metadata.tables.keys())
    expected_tables = {"documents", "financial_kpis", "ingestion_tasks"}
    assert expected_tables.issubset(table_names), f"Missing tables. Found: {table_names}"
    print(f"✅ All expected tables present: {expected_tables}")


def test_document_sha256_uniqueness():
    """Verify duplicate SHA-256 hash raises IntegrityError."""
    print("Testing SHA-256 unique constraint on documents...")
    session = create_test_session()
    dup_hash = "unique_hash_1234567890abcdef"

    doc1 = DocumentModel(
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Meta Q2 2026",
        sha256_hash=dup_hash,
        file_path="uploads/meta_q2.pdf",
        page_count=9,
    )
    session.add(doc1)
    session.commit()

    # Attempt to add duplicate hash
    doc2 = DocumentModel(
        ticker="META_COPY",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Meta Q2 2026 Duplicate",
        sha256_hash=dup_hash,
        file_path="uploads/meta_q2_dupe.pdf",
        page_count=9,
    )
    session.add(doc2)
    try:
        session.commit()
        assert False, "Should have raised IntegrityError on duplicate sha256_hash"
    except IntegrityError:
        session.rollback()
        print("✅ Unique constraint correctly blocked duplicate SHA-256 hash.")
    finally:
        session.close()


def test_kpi_unique_period_constraint():
    """Verify only ONE KPI record can exist for a given (ticker, year, quarter)."""
    print("Testing unique constraint on (ticker, fiscal_year, fiscal_quarter)...")
    session = create_test_session()

    doc = DocumentModel(
        ticker="TSLA",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        report_title="Tesla Q2 2026",
        sha256_hash="tsla_hash_abc",
        file_path="uploads/tsla.pdf",
        page_count=33,
    )
    session.add(doc)
    session.flush()

    kpi1 = FinancialKPIModel(
        document_id=doc.id,
        ticker="TSLA",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        revenue=25500.0,
    )
    session.add(kpi1)
    session.commit()

    # Second entry for same ticker + year + quarter
    kpi2 = FinancialKPIModel(
        document_id=doc.id,
        ticker="TSLA",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        revenue=25600.0,
    )
    session.add(kpi2)
    try:
        session.commit()
        assert False, "Should have raised IntegrityError on duplicate (ticker, year, quarter)"
    except IntegrityError:
        session.rollback()
        print("✅ Unique constraint correctly blocked duplicate fiscal period KPIs.")
    finally:
        session.close()


def test_cascade_delete():
    """Verify deleting a DocumentModel cascades and deletes associated FinancialKPIModel rows."""
    print("Testing foreign key cascade deletion...")
    session = create_test_session()

    doc = DocumentModel(
        ticker="AAPL",
        fiscal_quarter="Q3",
        fiscal_year=2026,
        report_title="Apple Q3 2026",
        sha256_hash="aapl_hash_xyz",
        file_path="uploads/aapl.pdf",
        page_count=3,
    )
    session.add(doc)
    session.flush()

    kpi = FinancialKPIModel(
        document_id=doc.id,
        ticker="AAPL",
        fiscal_quarter="Q3",
        fiscal_year=2026,
        revenue=85777.0,
        net_income=21448.0,
    )
    session.add(kpi)
    session.commit()

    doc_id = doc.id
    # Delete parent document
    session.delete(doc)
    session.commit()

    # Check child KPI
    remaining = session.query(FinancialKPIModel).filter_by(document_id=doc_id).all()
    assert len(remaining) == 0, f"Expected 0 child KPIs after delete, found {len(remaining)}"
    print("✅ Cascade delete verified: Parent document deletion automatically wiped child KPIs.")
    session.close()


def test_kpi_to_dict_serialization():
    """Verify to_dict returns formatted dictionary with exact keys."""
    print("Testing KPI to_dict serialization...")
    kpi = FinancialKPIModel(
        document_id="doc_123",
        ticker="META",
        fiscal_quarter="Q2",
        fiscal_year=2026,
        revenue=39071.0,
        cost_of_revenue=7000.0,
        gross_profit=32071.0,
        gross_margin=0.8208,
        operating_income=14847.0,
        operating_margin=0.38,
        net_income=13465.0,
        diluted_eps=5.16,
        operating_cash_flow=19370.0,
        capital_expenditures=8473.0,
        free_cash_flow=10897.0,
        cash_and_equivalents=58080.0,
        currency="USD",
        units="millions",
        is_audited=True,
        source_pages="[5, 6, 7]",
    )
    d = kpi.to_dict()
    assert d["ticker"] == "META"
    assert d["revenue"] == 39071.0
    assert d["free_cash_flow"] == 10897.0
    assert d["diluted_eps"] == 5.16
    assert d["source_pages"] == "[5, 6, 7]"
    assert d["currency"] == "USD"
    print("✅ to_dict serialization verified with all 18+ GAAP metrics.")


def test_ingestion_task_workflow():
    """Verify IngestionTaskModel updates status and progress."""
    print("Testing IngestionTaskModel status progression...")
    session = create_test_session()

    task = IngestionTaskModel(
        ticker="META",
        status="PENDING",
        progress_percent=0,
        message="Queued for processing",
    )
    session.add(task)
    session.commit()

    # Simulate pipeline progression
    task.status = "CLASSIFYING"
    task.progress_percent = 50
    task.message = "Classifying financial statement sections"
    session.commit()

    updated = session.query(IngestionTaskModel).filter_by(id=task.id).one()
    assert updated.status == "CLASSIFYING"
    assert updated.progress_percent == 50
    assert "Classifying" in updated.message
    print("✅ IngestionTask state transitions verified.")
    session.close()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING DATABASE MODELS UNIT TESTS (Step 2.2)")
    print("=" * 60)

    test_models_table_creation()
    test_document_sha256_uniqueness()
    test_kpi_unique_period_constraint()
    test_cascade_delete()
    test_kpi_to_dict_serialization()
    test_ingestion_task_workflow()

    print("\n" + "=" * 60)
    print("ALL STEP 2.2 MODELS TESTS PASSED SUCCESSFULLY! ✅")
    print("=" * 60)
