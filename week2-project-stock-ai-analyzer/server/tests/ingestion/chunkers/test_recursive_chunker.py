"""
Unit Tests for Recursive Text Chunker.

Conforms to ARCHITECTURE.md Section 8 (tests/ingestion/chunkers/test_recursive_chunker.py).
Tests:
1. Text splitter initialization and configuration.
2. Short text splitting (single chunk).
3. Long text recursive character splitting with overlap.
4. Handling of empty or whitespace-only inputs.
"""

import sys
from pathlib import Path

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.ingestion.chunkers.recursive_chunker import (
    create_financial_text_splitter,
    split_page_text,
)


def test_create_financial_text_splitter():
    """Verify splitter parameters."""
    print("Testing create_financial_text_splitter initialization...")
    splitter = create_financial_text_splitter(chunk_size=800, chunk_overlap=80)
    assert splitter._chunk_size == 800
    assert splitter._chunk_overlap == 80
    assert "\n\n" in splitter._separators
    print("✅ Splitter initialization verified.")


def test_split_empty_or_whitespace():
    """Verify empty or blank inputs return empty list."""
    print("Testing empty and whitespace inputs...")
    assert split_page_text("") == []
    assert split_page_text("   \n\n  \t  ") == []
    assert split_page_text(None) == []
    print("✅ Empty inputs return empty list.")


def test_split_short_text():
    """Verify short text under chunk size produces exactly one chunk."""
    print("Testing short text splitting...")
    text = "Condensed Consolidated Statements of Income. Revenue: $47,510 million."
    splits = split_page_text(text, chunk_size=1000, chunk_overlap=100)
    assert len(splits) == 1
    assert splits[0] == text
    print("✅ Short text produces exactly 1 split.")


def test_split_long_text_with_overlap():
    """Verify text exceeding chunk_size is split with overlap."""
    print("Testing long text splitting with overlap...")
    paragraph = "Operating cash flow for the quarter reached record levels. " * 30  # ~1740 chars
    splits = split_page_text(paragraph, chunk_size=500, chunk_overlap=100)
    assert len(splits) >= 3, f"Expected at least 3 splits, got {len(splits)}"

    for s in splits:
        assert len(s) <= 500, f"Split exceeded chunk_size: {len(s)}"
        assert len(s) > 0
    print(f"✅ Long text ({len(paragraph)} chars) produced {len(splits)} chunks respecting chunk_size.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING RECURSIVE CHUNKER UNIT TESTS")
    print("=" * 60)

    test_create_financial_text_splitter()
    test_split_empty_or_whitespace()
    test_split_short_text()
    test_split_long_text_with_overlap()

    print("\n" + "=" * 60)
    print("ALL RECURSIVE CHUNKER TESTS PASSED! ✅")
    print("=" * 60)
