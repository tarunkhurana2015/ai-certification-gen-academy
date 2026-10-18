"""
Unit Tests for ChromaDB FinancialVectorStore.

Conforms to ARCHITECTURE.md 1:1 mirror testing standard:
tests/indexing/test_vector_store.py <---> app/indexing/vector_store.py

All tests run in-memory using chromadb.EphemeralClient() and FakeEmbeddings(size=512)
with ZERO network calls and ZERO disk side effects.
"""

import sys
from pathlib import Path
from typing import List

import chromadb
from langchain_core.embeddings import FakeEmbeddings

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.indexing.vector_store import FinancialVectorStore, build_chroma_filter
from app.ingestion.chunkers.metadata_enricher import EnrichedChunk


def _create_sample_chunks() -> List[EnrichedChunk]:
    """Helper to generate in-memory synthetic chunks."""
    return [
        EnrichedChunk(
            chunk_id="TSLA_Q2_2026_p3_c0",
            text="Free cash flow = operating cash flow less capex. FCF was $1,340M in Q2 2026.",
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            page_number=3,
            financial_domain="cash_flow",
            char_count=78,
            chunk_index_in_page=0,
            total_chunks_in_page=1,
        ),
        EnrichedChunk(
            chunk_id="TSLA_Q2_2026_p4_c0",
            text="Automotive revenues were $19,878M with automotive gross margin of 18.5%.",
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            page_number=4,
            financial_domain="profitability",
            char_count=73,
            chunk_index_in_page=0,
            total_chunks_in_page=1,
        ),
        EnrichedChunk(
            chunk_id="TSLA_Q1_2026_p5_c0",
            text="Q1 Free cash flow was $1,010M with CapEx of $1,200M.",
            ticker="TSLA",
            fiscal_quarter="Q1",
            fiscal_year=2026,
            page_number=5,
            financial_domain="cash_flow",
            char_count=52,
            chunk_index_in_page=0,
            total_chunks_in_page=1,
        ),
        EnrichedChunk(
            chunk_id="META_Q2_2026_p5_c0",
            text="Meta Q2 total revenue was $47,510M representing 22% year-over-year growth.",
            ticker="META",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            page_number=5,
            financial_domain="profitability",
            char_count=74,
            chunk_index_in_page=0,
            total_chunks_in_page=1,
        ),
    ]


def test_build_chroma_filter():
    """Verifies Chroma metadata filter construction rules."""
    print("Testing build_chroma_filter rules...")

    # 1. Zero conditions -> None
    assert build_chroma_filter() is None

    # 2. Single condition -> Simple dict
    f1 = build_chroma_filter(ticker="tsla")
    assert f1 == {"ticker": "TSLA"}

    # 3. Multiple conditions -> $and list
    f2 = build_chroma_filter(ticker="TSLA", fiscal_quarter="q2", fiscal_year=2026)
    assert f2 == {
        "$and": [
            {"ticker": "TSLA"},
            {"fiscal_quarter": "Q2"},
            {"fiscal_year": 2026},
        ]
    }

    # 4. Domain condition
    f3 = build_chroma_filter(financial_domain="CASH_FLOW")
    assert f3 == {"financial_domain": "cash_flow"}

    print("✅ build_chroma_filter rules verified.")


def test_vector_store_initialization():
    """Verifies FinancialVectorStore initializes in-memory with EphemeralClient."""
    print("Testing FinancialVectorStore in-memory initialization...")

    client = chromadb.EphemeralClient()
    fake_embeddings = FakeEmbeddings(size=512)

    store = FinancialVectorStore(
        client=client,
        collection_name="test_collection",
        embeddings=fake_embeddings,
    )

    assert store.collection_name == "test_collection"
    assert store.count() == 0
    stats = store.get_stats()
    assert stats["distance_metric"] == "cosine"
    assert stats["total_chunks"] == 0

    print("✅ In-memory initialization and metadata verified.")


def test_add_chunks():
    """Verifies chunk ingestion into ChromaDB."""
    print("Testing add_chunks with EnrichedChunks...")

    client = chromadb.EphemeralClient()
    fake_embeddings = FakeEmbeddings(size=512)
    store = FinancialVectorStore(
        client=client,
        collection_name="test_add_chunks",
        embeddings=fake_embeddings,
    )

    # Empty chunks -> returns 0
    assert store.add_chunks([]) == 0
    assert store.count() == 0

    # Add 4 chunks
    chunks = _create_sample_chunks()
    added = store.add_chunks(chunks)
    assert added == 4
    assert store.count() == 4

    print("✅ Chunk addition and count tracking verified.")


def test_similarity_search_and_filtering():
    """Verifies dense similarity search and metadata pre-filtering."""
    print("Testing similarity_search with metadata pre-filtering...")

    client = chromadb.EphemeralClient()
    fake_embeddings = FakeEmbeddings(size=512)
    store = FinancialVectorStore(
        client=client,
        collection_name="test_search",
        embeddings=fake_embeddings,
    )

    store.add_chunks(_create_sample_chunks())

    # 1. Unfiltered search -> returns up to k
    all_results = store.similarity_search("revenue and cash flow", k=4)
    assert len(all_results) == 4

    # 2. Strict Ticker Filter (TSLA only)
    tsla_results = store.similarity_search("financial performance", k=4, ticker="TSLA")
    assert len(tsla_results) == 3
    for doc in tsla_results:
        assert doc.metadata["ticker"] == "TSLA"

    # 3. Strict Ticker Filter (META only)
    meta_results = store.similarity_search("financial performance", k=4, ticker="META")
    assert len(meta_results) == 1
    assert meta_results[0].metadata["ticker"] == "META"
    assert "47,510M" in meta_results[0].page_content

    # 4. Multi-attribute filter: TSLA + Q2 + cash_flow
    targeted = store.similarity_search(
        "free cash flow",
        k=4,
        ticker="TSLA",
        fiscal_quarter="Q2",
        financial_domain="cash_flow",
    )
    assert len(targeted) == 1
    assert targeted[0].metadata["chunk_id"] == "TSLA_Q2_2026_p3_c0"
    assert targeted[0].metadata["page_number"] == 3

    # 5. Search with relevance scores
    scored = store.similarity_search_with_scores("Free cash flow", k=1, ticker="TSLA")
    assert len(scored) == 1
    doc, score = scored[0]
    assert isinstance(score, float)
    assert doc.metadata["ticker"] == "TSLA"

    print("✅ Similarity search and multi-dimensional filters verified.")


def test_delete_and_reset():
    """Verifies deletion by ticker and complete collection reset."""
    print("Testing delete_by_ticker and reset operations...")

    client = chromadb.EphemeralClient()
    fake_embeddings = FakeEmbeddings(size=512)
    store = FinancialVectorStore(
        client=client,
        collection_name="test_lifecycle",
        embeddings=fake_embeddings,
    )

    store.add_chunks(_create_sample_chunks())
    assert store.count() == 4

    # Delete TSLA chunks (3 chunks)
    store.delete_by_ticker("TSLA")
    assert store.count() == 1

    # Remaining chunk must be META
    remaining = store.similarity_search("revenue", k=2)
    assert len(remaining) == 1
    assert remaining[0].metadata["ticker"] == "META"

    # Reset collection -> 0 chunks
    store.reset()
    assert store.count() == 0

    print("✅ Deletion by ticker and reset operations verified.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING CHROMADB FINANCIAL VECTOR STORE TESTS")
    print("=" * 60)

    test_build_chroma_filter()
    test_vector_store_initialization()
    test_add_chunks()
    test_similarity_search_and_filtering()
    test_delete_and_reset()

    print("\n" + "=" * 60)
    print("ALL VECTOR STORE TESTS PASSED! ✅")
    print("=" * 60 + "\n")
