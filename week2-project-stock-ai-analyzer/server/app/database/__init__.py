"""
Database Module:
- SQLAlchemy 2.0 Base, Engine, and SessionLocal (session.py)
- ORM Models (models.py)
- KPI Database Repository (kpi_repo.py)
"""

from app.database.session import (
    Base,
    DATABASE_URL,
    SessionLocal,
    create_db_engine,
    engine,
    get_db,
    init_db,
)


def __getattr__(name: str):
    """
    Lazy import ORM models and repository functions to prevent circular import traps
    when running submodule scripts directly via CLI.
    """
    if name in {"DocumentModel", "FinancialKPIModel", "IngestionTaskModel"}:
        import app.database.models as models
        return getattr(models, name)

    repo_exports = {
        "get_document_by_id",
        "get_document_by_hash",
        "save_document",
        "list_documents",
        "get_kpis_by_quarter",
        "get_kpi_time_series",
        "get_multi_company_comparison",
        "upsert_kpi",
        "create_task",
        "update_task_status",
        "get_task",
    }
    if name in repo_exports:
        import app.database.kpi_repo as kpi_repo
        return getattr(kpi_repo, name)

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
    "get_kpis_by_quarter",
    "get_kpi_time_series",
    "get_multi_company_comparison",
    "upsert_kpi",
    "create_task",
    "update_task_status",
    "get_task",
]
