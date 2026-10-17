"""
Relational Data Tier Package (SQLite).

Conforms to ARCHITECTURE.md Section 8 (app/db/).
Exposes:
- Base, engine, SessionLocal, get_db, init_db
- Models: DocumentModel, FinancialKPIModel, IngestionTaskModel
- Repositories: document_repo, kpi_repo
"""

from app.db.session import (
    Base,
    DATABASE_URL,
    SessionLocal,
    create_db_engine,
    engine,
    get_db,
    init_db,
)


def __getattr__(name: str):
    """Lazy import ORM models and repositories to prevent circular imports."""
    if name in {"DocumentModel", "FinancialKPIModel", "IngestionTaskModel"}:
        import app.db.models as models
        return getattr(models, name)

    repo_exports = {
        "get_document_by_id",
        "get_document_by_hash",
        "save_document",
        "list_documents",
        "create_task",
        "update_task_status",
        "get_task",
        "get_kpis_by_quarter",
        "get_kpi_time_series",
        "get_multi_company_comparison",
        "upsert_kpi",
    }
    if name in repo_exports:
        import app.db.repositories as repositories
        return getattr(repositories, name)

    raise AttributeError(f"module '{__name__}' has no attribute '{name}'")


__all__ = [
    "Base",
    "DATABASE_URL",
    "SessionLocal",
    "create_db_engine",
    "engine",
    "get_db",
    "init_db",
    "DocumentModel",
    "FinancialKPIModel",
    "IngestionTaskModel",
    "get_document_by_id",
    "get_document_by_hash",
    "save_document",
    "list_documents",
    "create_task",
    "update_task_status",
    "get_task",
    "get_kpis_by_quarter",
    "get_kpi_time_series",
    "get_multi_company_comparison",
    "upsert_kpi",
]
