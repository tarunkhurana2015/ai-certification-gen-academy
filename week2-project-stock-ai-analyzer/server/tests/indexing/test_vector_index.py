"""
Tests for VectorIndex module.
Runs 100% in-memory using chromadb.EphemeralClient and FakeEmbeddings(size=512).
"""

import os
import sys
from pathlib import Path

# Disable LangSmith tracing in tests to avoid offline network retry timeouts
os.environ["LANGCHAIN_TRACING_V2"] = "false"

# Ensure server root is on sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

import chromadb
from langchain_core.documents import Document
from langchain_core.embeddings.fake import FakeEmbeddings

from app.ingestion.indexing.vector_index import VectorIndex, get_embeddings


def make_fake_embeddings():
    return FakeEmbeddings(size=512)


def make_memory_client():
    return chromadb.EphemeralClient()


def make_vector_index():
    return VectorIndex(
        collection_name="test_collection",
        embeddings=make_fake_embeddings(),
        client=make_memory_client(),
    )


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


def test_get_embeddings_configuration():
    """Verify get_embeddings creates standard text-embedding-3-small with 512 dims."""
    emb = get_embeddings(dimensions=512)
    assert emb.model == "text-embedding-3-small"
    assert emb.dimensions == 512


def test_add_documents_and_count():
    """Verify documents are indexed and count is accurate."""
    vector_index = make_vector_index()
    sample_documents = make_sample_documents()
    ids = vector_index.add_documents(sample_documents)
    assert len(ids) == 3
    assert vector_index.count() == 3


def test_similarity_search():
    """Verify similarity search returns matching Document objects."""
    vector_index = make_vector_index()
    sample_documents = make_sample_documents()
    vector_index.add_documents(sample_documents)
    results = vector_index.similarity_search("revenue", k=2)
    assert len(results) == 2
    assert isinstance(results[0], Document)


def test_similarity_search_with_filter():
    """Verify similarity search respects metadata filter."""
    vector_index = make_vector_index()
    sample_documents = make_sample_documents()
    vector_index.add_documents(sample_documents)
    results = vector_index.similarity_search("revenue", k=5, filter={"ticker": "TSLA"})
    assert len(results) == 1
    assert results[0].metadata["ticker"] == "TSLA"


def test_as_retriever():
    """Verify standard LangChain retriever interface."""
    vector_index = make_vector_index()
    sample_documents = make_sample_documents()
    vector_index.add_documents(sample_documents)
    retriever = vector_index.as_retriever(k=2)
    results = retriever.invoke("iPhone sales")
    assert len(results) == 2
    assert isinstance(results[0], Document)


def test_delete_by_ticker():
    """Verify documents for a specific ticker can be cleared."""
    vector_index = make_vector_index()
    sample_documents = make_sample_documents()
    vector_index.add_documents(sample_documents)
    assert vector_index.count() == 3

    vector_index.delete_by_ticker("AAPL")
    assert vector_index.count() == 1

    remaining = vector_index.similarity_search("revenue", k=5)
    assert len(remaining) == 1
    assert remaining[0].metadata["ticker"] == "TSLA"


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING VECTOR INDEX TESTS")
    print("=" * 60)

    print("\n1. Testing get_embeddings configuration...")
    test_get_embeddings_configuration()
    print("   ✅ Embeddings model=text-embedding-3-small, dimensions=512 verified")

    print("\n2. Testing add_documents and count...")
    test_add_documents_and_count()
    print("   ✅ add_documents and count() verified")

    print("\n3. Testing similarity_search...")
    test_similarity_search()
    print("   ✅ similarity_search() verified")

    print("\n4. Testing similarity_search with ticker filter...")
    test_similarity_search_with_filter()
    print("   ✅ Metadata filter verified")

    print("\n5. Testing as_retriever...")
    test_as_retriever()
    print("   ✅ as_retriever() interface verified")

    print("\n6. Testing delete_by_ticker...")
    test_delete_by_ticker()
    print("   ✅ delete_by_ticker() verified")

    print("\n" + "=" * 60)
    print("ALL VECTOR INDEX TESTS PASSED! ✅")
    print("=" * 60)
