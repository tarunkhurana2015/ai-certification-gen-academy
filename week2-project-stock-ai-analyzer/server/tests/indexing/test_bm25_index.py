"""
Tests for BM25Index module.
Directly verifies BM25Retriever integration matching week2-rag/3_hybrid_rag.ipynb.
"""

import os
import sys
import tempfile
from pathlib import Path

# Disable LangSmith tracing in tests
os.environ["LANGCHAIN_TRACING_V2"] = "false"

# Ensure server root is on sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from langchain_core.documents import Document
from app.indexing.bm25_index import BM25Index


def make_sample_documents():
    return [
        Document(
            page_content="Apple reported Q4 revenue of $94.9 billion, up 6% year-over-year.",
            metadata={"ticker": "AAPL", "fiscal_year": 2024, "fiscal_quarter": "Q4", "chunk_id": "aapl-001"},
        ),
        Document(
            page_content="iPhone revenue was $46.2 billion with Services reaching all-time high.",
            metadata={"ticker": "AAPL", "fiscal_year": 2024, "fiscal_quarter": "Q4", "chunk_id": "aapl-002"},
        ),
        Document(
            page_content="Tesla reported Q3 automotive revenue of $20.0 billion, up 2% YoY.",
            metadata={"ticker": "TSLA", "fiscal_year": 2024, "fiscal_quarter": "Q3", "chunk_id": "tsla-001"},
        ),
    ]


def test_add_documents_and_count():
    """Verify documents are added and count is correct."""
    with tempfile.TemporaryDirectory() as tmpdir:
        persist_path = Path(tmpdir) / "bm25.json"
        index = BM25Index(persist_path=persist_path)
        docs = make_sample_documents()

        index.add_documents(docs)
        assert index.count() == 3


def test_keyword_search():
    """Verify exact keyword matching via BM25."""
    with tempfile.TemporaryDirectory() as tmpdir:
        persist_path = Path(tmpdir) / "bm25.json"
        index = BM25Index(persist_path=persist_path)
        index.add_documents(make_sample_documents())

        results = index.search("iPhone", k=1)
        assert len(results) == 1
        assert "iPhone" in results[0].page_content
        assert results[0].metadata["ticker"] == "AAPL"


def test_search_with_filter():
    """Verify search with metadata filter."""
    with tempfile.TemporaryDirectory() as tmpdir:
        persist_path = Path(tmpdir) / "bm25.json"
        index = BM25Index(persist_path=persist_path)
        index.add_documents(make_sample_documents())

        # Filter specifically for TSLA
        results = index.search("revenue", k=5, filter={"ticker": "TSLA"})
        assert len(results) == 1
        assert results[0].metadata["ticker"] == "TSLA"


def test_as_retriever():
    """Verify standard LangChain retriever interface."""
    with tempfile.TemporaryDirectory() as tmpdir:
        persist_path = Path(tmpdir) / "bm25.json"
        index = BM25Index(persist_path=persist_path)
        index.add_documents(make_sample_documents())

        retriever = index.as_retriever(k=2)
        results = retriever.invoke("automotive")
        assert len(results) >= 1
        assert "automotive" in results[0].page_content


def test_delete_by_ticker():
    """Verify deleting by ticker purges only matching documents."""
    with tempfile.TemporaryDirectory() as tmpdir:
        persist_path = Path(tmpdir) / "bm25.json"
        index = BM25Index(persist_path=persist_path)
        index.add_documents(make_sample_documents())
        assert index.count() == 3

        index.delete_by_ticker("AAPL")
        assert index.count() == 1

        remaining = index.search("revenue", k=5)
        assert len(remaining) == 1
        assert remaining[0].metadata["ticker"] == "TSLA"


def test_save_and_reload_persistence():
    """Verify documents persist and reload from JSON storage."""
    with tempfile.TemporaryDirectory() as tmpdir:
        persist_path = Path(tmpdir) / "bm25.json"
        index1 = BM25Index(persist_path=persist_path)
        index1.add_documents(make_sample_documents())
        assert persist_path.exists()

        # Reload in a fresh instance
        index2 = BM25Index(persist_path=persist_path)
        assert index2.count() == 3
        results = index2.search("iPhone", k=1)
        assert len(results) == 1
        assert "iPhone" in results[0].page_content


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING BM25 INDEX TESTS")
    print("=" * 60)

    print("\n1. Testing add_documents and count...")
    test_add_documents_and_count()
    print("   ✅ add_documents and count() verified")

    print("\n2. Testing keyword search...")
    test_keyword_search()
    print("   ✅ Exact keyword search verified")

    print("\n3. Testing search with metadata filter...")
    test_search_with_filter()
    print("   ✅ Metadata filter verified")

    print("\n4. Testing as_retriever...")
    test_as_retriever()
    print("   ✅ as_retriever() interface verified")

    print("\n5. Testing delete_by_ticker...")
    test_delete_by_ticker()
    print("   ✅ delete_by_ticker() verified")

    print("\n6. Testing save and reload persistence...")
    test_save_and_reload_persistence()
    print("   ✅ Persistence verified")

    print("\n" + "=" * 60)
    print("ALL BM25 INDEX TESTS PASSED! ✅")
    print("=" * 60)
