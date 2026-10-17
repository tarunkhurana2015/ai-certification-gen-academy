"""
Unit tests for API Health and Root endpoints.

Tests:
- GET /health
- GET /api/v1/health
- GET /
"""

import sys
from pathlib import Path
from fastapi.testclient import TestClient

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.main import app

client = TestClient(app)


def test_root_index():
    """Verify root index welcome route."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "Welcome to Stock AI Financial Analyst API" in data["message"]
    assert data["docs_url"] == "/docs"
    assert data["v1_prefix"] == "/api/v1"
    print("✅ test_root_index passed.")


def test_top_level_health():
    """Verify top-level /health probe."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "stock-ai-analyzer-api"
    print("✅ test_top_level_health passed.")


def test_v1_health():
    """Verify /api/v1/health probe."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "stock-ai-analyzer-api"
    print("✅ test_v1_health passed.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING API HEALTH TESTS")
    print("=" * 60)
    test_root_index()
    test_top_level_health()
    test_v1_health()
    print("\n" + "=" * 60)
    print("ALL API HEALTH TESTS PASSED! ✅")
    print("=" * 60 + "\n")
