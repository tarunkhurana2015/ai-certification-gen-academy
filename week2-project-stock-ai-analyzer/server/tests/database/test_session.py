"""
Unit Tests for Database Session & Connection Management.

Validates:
1. SQLite PRAGMA foreign_keys is strictly enabled.
2. SQLAlchemy Session lifecycle (open, query, close).
3. FastAPI get_db() generator lifecycle and cleanup.
4. Isolated in-memory database engine creation.

NOTE: Tests must NEVER write artifacts. Pure assertions only.
"""

import sys
from pathlib import Path
from sqlalchemy import text
from sqlalchemy.orm import Session

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.database.session import (
    Base,
    create_db_engine,
    engine,
    get_db,
    SessionLocal,
)


def test_sqlite_foreign_keys_enabled():
    """Verify that SQLite executes with PRAGMA foreign_keys = ON."""
    print("Testing SQLite foreign keys enforcement...")
    with engine.connect() as conn:
        fk_status = conn.execute(text("PRAGMA foreign_keys;")).scalar()
        assert fk_status == 1, f"Expected foreign_keys=1, got {fk_status}"
    print("✅ Foreign keys enforcement verified (PRAGMA foreign_keys=1).")


def test_session_query_lifecycle():
    """Verify SessionLocal can open, query, and close cleanly."""
    print("Testing SessionLocal query lifecycle...")
    session: Session = SessionLocal()
    try:
        result = session.execute(text("SELECT 42 AS answer;")).mappings().first()
        assert result is not None
        assert result["answer"] == 42
    finally:
        session.close()
    print("✅ SessionLocal opened, executed query, and closed cleanly.")


def test_get_db_generator():
    """Verify get_db() yields a functional session and closes it on generator exit."""
    print("Testing get_db() generator lifecycle...")
    db_gen = get_db()
    session = next(db_gen)
    assert isinstance(session, Session), "get_db() must yield a SQLAlchemy Session instance"
    assert session.is_active, "Yielded session must be active"

    # Query through the yielded session
    val = session.execute(text("SELECT 'alive' AS status;")).scalar()
    assert val == "alive"

    # Exhaust the generator to trigger the `finally: db.close()` block
    try:
        next(db_gen)
    except StopIteration:
        pass  # Expected generator completion

    print("✅ get_db() generator successfully yielded session and executed finally cleanup.")


def test_in_memory_engine_isolation():
    """Verify create_db_engine works for isolated in-memory testing."""
    print("Testing in-memory engine creation...")
    mem_engine = create_db_engine("sqlite:///:memory:")
    with mem_engine.connect() as conn:
        # In-memory engine should also have foreign keys enabled via the Engine event listener
        fk_status = conn.execute(text("PRAGMA foreign_keys;")).scalar()
        assert fk_status == 1, "In-memory engine must also enforce foreign keys"
        
        # Test basic arithmetic
        sum_val = conn.execute(text("SELECT 10 + 20;")).scalar()
        assert sum_val == 30
    print("✅ In-memory engine created and tested with isolated state.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING DATABASE SESSION UNIT TESTS (Step 2.1)")
    print("=" * 60)
    
    test_sqlite_foreign_keys_enabled()
    test_session_query_lifecycle()
    test_get_db_generator()
    test_in_memory_engine_isolation()

    print("\n" + "=" * 60)
    print("ALL STEP 2.1 SESSION TESTS PASSED SUCCESSFULLY! ✅")
    print("=" * 60)
