"""
Tests for HybridEngine and EnsembleRetriever.
Matches the tests and examples from week2-rag/3_hybrid_rag.ipynb.
Runs 100% in-memory with EphemeralClient and FakeEmbeddings.
"""

import os
import sys
from pathlib import Path

# Disable LangSmith tracing during tests to avoid network timeouts
os.environ["LANGCHAIN_TRACING_V2"] = "false"

# Ensure server root is on sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

import chromadb
from langchain_classic.retrievers import EnsembleRetriever
from langchain_core.documents import Document
from langchain_core.embeddings.fake import FakeEmbeddings

from app.ingestion.indexing.bm25_index import BM25Index
from app.ingestion.indexing.vector_index import VectorIndex
from app.retrieval.hybrid_engine import HybridEngine, create_ensemble_retriever


def make_test_engine():
    fake_embeddings = FakeEmbeddings(size=512)
    client = chromadb.EphemeralClient()
    vector_index = VectorIndex(collection_name="test_col", embeddings=fake_embeddings, client=client)
    bm25_index = BM25Index(persist_path=None)

    docs = [
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
        Document(
            page_content="Free cash flow for Tesla was $2.74 billion, supported by energy storage growth.",
            metadata={"ticker": "TSLA", "fiscal_year": 2024, "fiscal_quarter": "Q3", "chunk_id": "tsla-002"},
        ),
    ]

    vector_index.add_documents(docs)
    bm25_index.add_documents(docs)

    return HybridEngine(vector_index=vector_index, bm25_index=bm25_index)


def test_create_ensemble_retriever():
    """Verify create_ensemble_retriever returns an EnsembleRetriever instance."""
    engine = make_test_engine()
    retriever = create_ensemble_retriever(
        vector_index=engine.vector_index,
        bm25_index=engine.bm25_index,
        ticker=None,
        k=3,
        weights=[0.5, 0.5],
    )
    assert isinstance(retriever, EnsembleRetriever)
    assert len(retriever.retrievers) == 2
    assert retriever.weights == [0.5, 0.5]


def test_hybrid_search():
    """Verify hybrid search executes and returns relevant documents."""
    engine = make_test_engine()
    results = engine.search("iPhone revenue", k=2)
    assert len(results) <= 2
    assert len(results) > 0
    assert any("iPhone" in doc.page_content or "revenue" in doc.page_content for doc in results)


def test_hybrid_search_with_ticker_filter():
    """Verify metadata filtering limits results to the specified ticker."""
    engine = make_test_engine()
    results = engine.search("revenue", ticker="TSLA", k=5)
    assert len(results) > 0
    for doc in results:
        assert doc.metadata["ticker"] == "TSLA"


def test_show_hybrid_structure():
    """Verify show_hybrid returns vector, bm25, and fused ensemble documents."""
    engine = make_test_engine()
    views = engine.show_hybrid("Free cash flow", ticker="TSLA", k=2)
    assert "vector" in views
    assert "bm25" in views
    assert "ensemble" in views
    assert len(views["vector"]) > 0
    assert len(views["bm25"]) > 0
    assert len(views["ensemble"]) > 0


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING HYBRID ENGINE (ENSEMBLE RETRIEVER) TESTS")
    print("=" * 60)

    print("\n1. Testing create_ensemble_retriever...")
    test_create_ensemble_retriever()
    print("   ✅ EnsembleRetriever creation verified")

    print("\n2. Testing hybrid search...")
    test_hybrid_search()
    print("   ✅ Hybrid search execution verified")

    print("\n3. Testing hybrid search with ticker filter...")
    test_hybrid_search_with_ticker_filter()
    print("   ✅ Ticker metadata filtering verified")

    print("\n4. Testing show_hybrid comparison view...")
    test_show_hybrid_structure()
    print("   ✅ Vector, BM25, and Ensemble combined view verified")

    print("\n" + "=" * 60)
    print("ALL HYBRID RETRIEVAL TESTS PASSED! ✅")
    print("=" * 60)
