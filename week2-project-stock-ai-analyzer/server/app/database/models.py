"""
SQLAlchemy 2.0 ORM Models for Deterministic Financial Analysis.

Models:
- DocumentModel: Metadata, SHA-256 deduplication fingerprint, and file tracking.
- FinancialKPIModel: 18+ standardized GAAP financial metrics across Income,
  Balance Sheet, and Cash Flow statements.
- IngestionTaskModel: Async background job status tracking and progress state machine.
"""

import sys
import uuid
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.database.session import Base, engine, init_db


def generate_uuid() -> str:
    """Generate a standard UUID4 string."""
    return str(uuid.uuid4())


class DocumentModel(Base):
    """
    Stores document metadata and SHA-256 fingerprint for instantaneous deduplication.
    Raw PDF binaries are stored on disk; only structured metadata lives in the database.
    """
    __tablename__ = "documents"
    __table_args__ = {"extend_existing": True}

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_uuid)
    ticker: Mapped[str] = mapped_column(String(10), nullable=False, index=True)
    fiscal_quarter: Mapped[str] = mapped_column(String(5), nullable=False)  # 'Q1', 'Q2', 'Q3', 'Q4', 'FY'
    fiscal_year: Mapped[int] = mapped_column(Integer, nullable=False, index=True)
    report_title: Mapped[str] = mapped_column(String(255), nullable=False)
    sha256_hash: Mapped[str] = mapped_column(String(64), nullable=False, unique=True, index=True)
    file_path: Mapped[str] = mapped_column(String(500), nullable=False)
    page_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
    )

    # Cascades: Deleting a document automatically removes its extracted KPIs
    kpis: Mapped[List["FinancialKPIModel"]] = relationship(
        "FinancialKPIModel",
        back_populates="document",
        cascade="all, delete-orphan",
    )
    tasks: Mapped[List["IngestionTaskModel"]] = relationship(
        "IngestionTaskModel",
        back_populates="document",
    )

    def __repr__(self) -> str:
        return f"<Document {self.ticker} {self.fiscal_quarter} {self.fiscal_year} (id={self.id[:8]})>"


class FinancialKPIModel(Base):
    """
    Stores 18+ standardized GAAP financial metrics extracted from the filing.
    Used for 100% deterministic mathematical queries, chart time-series, and exact comparisons.
    """
    __tablename__ = "financial_kpis"

    # Enforce only ONE official entry per ticker per fiscal period
    __table_args__ = (
        UniqueConstraint("ticker", "fiscal_year", "fiscal_quarter", name="uq_ticker_period"),
        {"extend_existing": True},
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_uuid)
    document_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("documents.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    ticker: Mapped[str] = mapped_column(String(10), nullable=False, index=True)
    fiscal_quarter: Mapped[str] = mapped_column(String(5), nullable=False)
    fiscal_year: Mapped[int] = mapped_column(Integer, nullable=False, index=True)

    # ---------------------------------------------------------
    # 1. Income Statement Metrics (Profitability)
    # ---------------------------------------------------------
    revenue: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    cost_of_revenue: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    gross_profit: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    gross_margin: Mapped[Optional[float]] = mapped_column(Float, nullable=True)  # e.g. 0.82 for 82%
    research_and_development: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    selling_general_admin: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    total_operating_expenses: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    operating_income: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    operating_margin: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    net_income: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    net_margin: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    diluted_eps: Mapped[Optional[float]] = mapped_column(Float, nullable=True)

    # ---------------------------------------------------------
    # 2. Cash Flow Statement Metrics
    # ---------------------------------------------------------
    operating_cash_flow: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    capital_expenditures: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    free_cash_flow: Mapped[Optional[float]] = mapped_column(Float, nullable=True)  # OCF - CapEx

    # ---------------------------------------------------------
    # 3. Balance Sheet Metrics (Financial Health)
    # ---------------------------------------------------------
    cash_and_equivalents: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    total_assets: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    long_term_debt: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    total_liabilities: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    shareholders_equity: Mapped[Optional[float]] = mapped_column(Float, nullable=True)

    # ---------------------------------------------------------
    # 4. Units & Audit Lineage (Grounding)
    # ---------------------------------------------------------
    currency: Mapped[str] = mapped_column(String(10), default="USD", nullable=False)
    units: Mapped[str] = mapped_column(String(20), default="millions", nullable=False)  # 'millions', 'thousands', 'billions'
    is_audited: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    source_pages: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)  # JSON e.g. "[5, 6, 7]"

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
    )

    # Relationship back to Document
    document: Mapped["DocumentModel"] = relationship("DocumentModel", back_populates="kpis")

    def to_dict(self) -> Dict[str, Any]:
        """Convert KPI model into a complete serializable dictionary."""
        return {
            "id": self.id,
            "document_id": self.document_id,
            "ticker": self.ticker,
            "fiscal_quarter": self.fiscal_quarter,
            "fiscal_year": self.fiscal_year,
            "currency": self.currency,
            "units": self.units,
            # Income
            "revenue": self.revenue,
            "cost_of_revenue": self.cost_of_revenue,
            "gross_profit": self.gross_profit,
            "gross_margin": self.gross_margin,
            "research_and_development": self.research_and_development,
            "selling_general_admin": self.selling_general_admin,
            "total_operating_expenses": self.total_operating_expenses,
            "operating_income": self.operating_income,
            "operating_margin": self.operating_margin,
            "net_income": self.net_income,
            "net_margin": self.net_margin,
            "diluted_eps": self.diluted_eps,
            # Cash Flow
            "operating_cash_flow": self.operating_cash_flow,
            "capital_expenditures": self.capital_expenditures,
            "free_cash_flow": self.free_cash_flow,
            # Balance Sheet
            "cash_and_equivalents": self.cash_and_equivalents,
            "total_assets": self.total_assets,
            "long_term_debt": self.long_term_debt,
            "total_liabilities": self.total_liabilities,
            "shareholders_equity": self.shareholders_equity,
            # Lineage
            "is_audited": self.is_audited,
            "source_pages": self.source_pages,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }

    def __repr__(self) -> str:
        return f"<FinancialKPI {self.ticker} {self.fiscal_quarter} {self.fiscal_year}: Rev={self.revenue}, NetInc={self.net_income}>"


class IngestionTaskModel(Base):
    """
    Tracks asynchronous document processing tasks.
    Enables frontend progress bars and status updates during PDF ingestion.
    """
    __tablename__ = "ingestion_tasks"
    __table_args__ = {"extend_existing": True}

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=generate_uuid)
    document_id: Mapped[Optional[str]] = mapped_column(
        String(36),
        ForeignKey("documents.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    ticker: Mapped[Optional[str]] = mapped_column(String(10), nullable=True)
    status: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
        default="PENDING",
    )  # 'PENDING', 'VALIDATING', 'EXTRACTING', 'CLASSIFYING', 'CHUNKING', 'INDEXING', 'COMPLETED', 'FAILED'
    progress_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    message: Mapped[str] = mapped_column(String(255), nullable=False, default="Task initiated")
    error_details: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
    )

    document: Mapped[Optional["DocumentModel"]] = relationship("DocumentModel", back_populates="tasks")

    def __repr__(self) -> str:
        return f"<IngestionTask {self.id[:8]}: {self.status} ({self.progress_percent}%)>"


if __name__ == "__main__":
    import json
    from datetime import datetime
    from sqlalchemy.orm import Session
    from app.database.session import SessionLocal

    print("🚀 Initializing Tables from Models...")
    init_db(engine)

    # Verify tables registered
    registered_tables = list(Base.metadata.tables.keys())
    print(f"✅ Registered Tables: {registered_tables}")

    # Test an insert and cascade delete verification
    session: Session = SessionLocal()
    test_sha = "mock_sha256_" + uuid.uuid4().hex[:16]
    try:
        # Create a sample document
        doc = DocumentModel(
            ticker="DEMO",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            report_title="Demo Corporation Q2 2026 Earnings",
            sha256_hash=test_sha,
            file_path="uploads/demo.pdf",
            page_count=5,
        )
        session.add(doc)
        session.flush()

        # Add KPI
        kpi = FinancialKPIModel(
            document_id=doc.id,
            ticker="DEMO",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            revenue=45000.0,
            gross_profit=36000.0,
            gross_margin=0.80,
            operating_income=18000.0,
            operating_margin=0.40,
            net_income=15000.0,
            diluted_eps=5.80,
            operating_cash_flow=20000.0,
            capital_expenditures=8000.0,
            free_cash_flow=12000.0,
            cash_and_equivalents=55000.0,
            total_assets=120000.0,
            long_term_debt=18000.0,
            total_liabilities=30000.0,
            shareholders_equity=90000.0,
            currency="USD",
            units="millions",
            source_pages="[1, 2, 3]",
        )
        session.add(kpi)

        # Add Task
        task = IngestionTaskModel(
            document_id=doc.id,
            ticker="DEMO",
            status="COMPLETED",
            progress_percent=100,
            message="Ingestion complete",
        )
        session.add(task)
        session.commit()

        print(f"✅ Inserted test records successfully. Document ID: {doc.id}")

        # Test Cascade Delete
        doc_id = doc.id
        session.delete(doc)
        session.commit()

        # Verify child KPI was deleted automatically by cascade
        orphaned_kpi = session.query(FinancialKPIModel).filter_by(document_id=doc_id).first()
        assert orphaned_kpi is None, "Child KPI should have been cascade deleted!"
        print("✅ Cascade Delete verified: Deleting parent Document automatically deleted child KPIs.")

    finally:
        session.close()

    # Export Artifact to .artifact/ (Only when run directly as CLI)
    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    schema_info = {}
    for table_name, table in Base.metadata.tables.items():
        schema_info[table_name] = {
            "columns": [
                {
                    "name": col.name,
                    "type": str(col.type),
                    "primary_key": col.primary_key,
                    "nullable": col.nullable,
                    "foreign_keys": [str(fk.target_fullname) for fk in col.foreign_keys],
                }
                for col in table.columns
            ],
            "column_count": len(table.columns),
        }

    artifact_data = {
        "timestamp": datetime.now().isoformat(),
        "tables": schema_info,
        "cascade_delete_verified": True,
        "status": "ready",
    }

    json_path = artifact_dir / "05_database_models.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(artifact_data, f, indent=2)

    md_path = artifact_dir / "05_database_models.md"
    with open(md_path, "w", encoding="utf-8") as f:
        f.write("# 🗄️ Database ORM Models & Schema Artifact\n\n")
        f.write(f"- **Timestamp**: `{artifact_data['timestamp']}`\n")
        f.write(f"- **Registered Tables**: `{list(schema_info.keys())}`\n")
        f.write(f"- **Cascade Delete Verified**: `{artifact_data['cascade_delete_verified']}`\n\n")
        for tname, tdetails in schema_info.items():
            f.write(f"### Table: `{tname}` ({tdetails['column_count']} columns)\n\n")
            f.write("| Column | Type | Primary Key | Nullable | Foreign Key |\n")
            f.write("| :--- | :--- | :--- | :--- | :--- |\n")
            for col in tdetails["columns"]:
                f.write(f"| `{col['name']}` | `{col['type']}` | {col['primary_key']} | {col['nullable']} | {col['foreign_keys'] or '-'} |\n")
            f.write("\n")

    print(f"📄 Saved Artifacts:\n  • {json_path}\n  • {md_path}")
