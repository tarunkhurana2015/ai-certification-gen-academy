"""
Database Session & Connection Management Module.

Conforms to ARCHITECTURE.md Section 8 (app/db/session.py).
Provides:
- SQLite Database Engine configuration with enforced foreign keys
- Modern DeclarativeBase for SQLAlchemy 2.0 ORM models
- SessionLocal factory for database transactions
- get_db() dependency generator for FastAPI endpoints
"""

import os
import sys
from pathlib import Path
from typing import Generator
from sqlalchemy import create_engine, event, text
from sqlalchemy.engine import Engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

# Default SQLite database location inside server/data/
_DEFAULT_DB_DIR = _SERVER_ROOT / "data"
_DEFAULT_DB_PATH = _DEFAULT_DB_DIR / "stock_analyst.db"
DEFAULT_DATABASE_URL = f"sqlite:///{_DEFAULT_DB_PATH}"

# Configurable via environment variable
DATABASE_URL = os.getenv("DATABASE_URL", DEFAULT_DATABASE_URL)


class Base(DeclarativeBase):
    """Modern SQLAlchemy 2.0 declarative base for all ORM models."""
    pass


@event.listens_for(Engine, "connect")
def _set_sqlite_pragma(dbapi_connection, connection_record):
    """
    Enforces SQLite foreign key constraints.
    By default, SQLite disables foreign key validation for backward compatibility.
    """
    if hasattr(dbapi_connection, "cursor"):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()


def create_db_engine(db_url: str = DATABASE_URL) -> Engine:
    """
    Creates and returns a SQLAlchemy Engine.
    For SQLite databases, disables thread-checking so connections can be shared
    across async FastAPI worker threads safely.
    """
    if db_url.startswith("sqlite"):
        if not db_url.startswith("sqlite:///:memory:") and "///" in db_url:
            raw_path = db_url.split("///", 1)[1]
            db_file = Path(raw_path)
            db_file.parent.mkdir(parents=True, exist_ok=True)

        return create_engine(
            db_url,
            connect_args={"check_same_thread": False},
            echo=False,
        )
    return create_engine(db_url, echo=False)


# Global singleton engine and sessionmaker
engine = create_db_engine(DATABASE_URL)
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


def get_db() -> Generator[Session, None, None]:
    """
    FastAPI dependency injection generator.
    Yields a scoped session for a request and guarantees it is closed
    even if an unhandled exception occurs.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Alias for dependency injection
get_db_session = get_db



def init_db(target_engine: Engine = engine) -> None:
    """
    Initializes database tables by creating all tables registered on Base.metadata.
    """
    Base.metadata.create_all(bind=target_engine)


if __name__ == "__main__":
    import json
    from datetime import datetime

    print("🚀 Initializing Database Engine & Verifying Connection...")
    init_db(engine)

    with engine.connect() as conn:
        fk_result = conn.execute(text("PRAGMA foreign_keys;")).scalar()
        version_result = conn.execute(text("SELECT sqlite_version();")).scalar()

    print(f"✅ SQLite Connected: version={version_result}, foreign_keys_enabled={bool(fk_result)}")
    print(f"📁 Database Location: {DATABASE_URL}")

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    artifact_data = {
        "timestamp": datetime.now().isoformat(),
        "database_url": DATABASE_URL,
        "sqlite_version": str(version_result),
        "foreign_keys_enabled": bool(fk_result),
        "models_registered": list(Base.metadata.tables.keys()),
        "status": "ready"
    }

    json_path = artifact_dir / "db_01_database_init.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(artifact_data, f, indent=2)

    md_path = artifact_dir / "db_01_database_init.md"
    with open(md_path, "w", encoding="utf-8") as f:
        f.write("# 🗄️ Database Engine Initialization Artifact\n\n")
        f.write(f"- **Timestamp**: `{artifact_data['timestamp']}`\n")
        f.write(f"- **Database URL**: `{artifact_data['database_url']}`\n")
        f.write(f"- **SQLite Version**: `{artifact_data['sqlite_version']}`\n")
        f.write(f"- **Foreign Keys Enabled**: `{artifact_data['foreign_keys_enabled']}`\n")
        f.write(f"- **Tables Registered**: `{len(artifact_data['models_registered'])}`\n\n")
        f.write("```json\n" + json.dumps(artifact_data, indent=2) + "\n```\n")

    print(f"📄 Saved Artifacts:\n  • {json_path}\n  • {md_path}")
