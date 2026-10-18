"""
Unit tests for app.artifact_saver utility.
Runs 100% in-memory/tempfile without polluting test runs.
"""

import json
import os
import sys
import tempfile
from pathlib import Path

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.artifact_saver import get_artifact_dir, save_artifact
from app import get_artifact_dir as exported_get_dir
from app import save_artifact as exported_save_art


def test_get_artifact_dir():
    """Validates get_artifact_dir returns server root .artifact directory."""
    art_dir = get_artifact_dir()
    assert art_dir.exists()
    assert art_dir.name == ".artifact"
    assert art_dir.parent == _SERVER_ROOT


def test_app_init_re_exports():
    """Validates re-exports from app root package."""
    assert exported_get_dir is get_artifact_dir
    assert exported_save_art is save_artifact


def test_save_artifact_string():
    """Validates saving string content."""
    test_filename = "_test_string_artifact.txt"
    try:
        out_path = save_artifact(test_filename, "Hello Financial AI Analyst")
        assert out_path.exists()
        assert out_path.read_text(encoding="utf-8") == "Hello Financial AI Analyst"
    finally:
        p = get_artifact_dir() / test_filename
        if p.exists():
            p.unlink()


def test_save_artifact_json():
    """Validates saving dict / list structured JSON content."""
    test_filename = "_test_dict_artifact.json"
    data = {"ticker": "TSLA", "metrics": {"revenue": 25500000000, "fcf": 1340000000}}
    try:
        out_path = save_artifact(test_filename, data)
        assert out_path.exists()
        content = json.loads(out_path.read_text(encoding="utf-8"))
        assert content["ticker"] == "TSLA"
        assert content["metrics"]["revenue"] == 25500000000
    finally:
        p = get_artifact_dir() / test_filename
        if p.exists():
            p.unlink()


if __name__ == "__main__":
    print("\nRunning test_artifact_saver.py...")
    test_get_artifact_dir()
    print("  ✓ test_get_artifact_dir passed")

    test_app_init_re_exports()
    print("  ✓ test_app_init_re_exports passed")

    test_save_artifact_string()
    print("  ✓ test_save_artifact_string passed")

    test_save_artifact_json()
    print("  ✓ test_save_artifact_json passed")

    print("\nAll 4 artifact_saver unit tests passed successfully!\n")
