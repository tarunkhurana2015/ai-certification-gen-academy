"""
Unit Tests for BM25 Sparse Keyword Index.

Conforms to ARCHITECTURE.md 1:1 mirror testing standard:
tests/indexing/test_bm25_index.py <---> app/indexing/bm25_index.py

Runs pure in-memory unit tests with ZERO network calls and ZERO permanent disk side effects.
"""

import sys
import tempfile
from pathlib import Path
from typing import List

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.indexing.bm25_index import BM25KeywordIndex, financial_tokenize
from app.ingestion.chunkers.metadata_enricher import EnrichedChunk


def _create_sample_chunks() -> List[EnrichedChunk]:
    """Helper to generate in-memory synthetic chunks."""
    return [
        EnrichedChunk(
            chunk_id="TSLA_Q2_2026_p3_c0",
            text="Free cash flow = operating cash flow less capex; FCF was $1,340 million in Q2 2026.",
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            page_number=3,
            financial_domain="cash_flow",
            char_count=85,
            chunk_index_in_page=0,
            total_chunks_in_page=1,
        ),
        EnrichedChunk(
            chunk_id="TSLA_Q2_2026_p4_c0",
            text="Total automotive revenues were $19,878M with automotive gross margin of 18.5%.",
            ticker="TSLA",
            fiscal_quarter="Q2",
            fiscal_year=2026,
            page_number=4,
            financial_domain="profitability",
            char_count=78,
            chunk_index_in_page=0,
            total_chunks_in_page=1,
        ),
        EnrichedChunk(
            chunk_id="TSLA_Q1_2026_p5_c0",
            text="Q1 non-GAAP net income reached $1,200M with capital expenditures of $1,800M.",
            ticker="TSLA",
            fiscal_quarter="Q1",
            fiscal_year=2026,
            page_number=5,
            financial_domain="cash_flow",
            char_count=76,
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


def test_financial_tokenize():
    """Verifies tokenizer behavior across financial figures, percentages, and acronyms."""
    print("Testing financial_tokenize rules...")

    # Empty inputs
    assert financial_tokenize("") == []
    assert financial_tokenize(None) == []

    # Financial figures and variants
    tokens = financial_tokenize("Free cash flow was $1,340M (down from $1,898M), non-GAAP gross margin 18.5%.")
    assert "free" in tokens
    assert "cash" in tokens
    assert "flow" in tokens
    assert "$1,340" in tokens
    assert "1,340" in tokens
    assert "non-gaap" in tokens
    assert "18.5%" in tokens
    assert "18.5" in tokens

    # Case insensitivity
    assert "tsla" in financial_tokenize("TSLA reported strong earnings")

    print("✅ financial_tokenize rules verified.")


def test_bm25_initialization_and_deduplication():
    """Verifies initialization and duplicate chunk rejection."""
    print("Testing BM25 initialization and deduplication...")

    index = BM25KeywordIndex(k1=1.5, b=0.75)
    assert index.count() == 0

    # Add empty
    assert index.add_chunks([]) == 0

    # Add 4 chunks
    chunks = _create_sample_chunks()
    added = index.add_chunks(chunks)
    assert added == 4
    assert index.count() == 4

    # Add duplicates (must not re-add)
    dup_added = index.add_chunks(chunks)
    assert dup_added == 0
    assert index.count() == 4

    print("✅ BM25 initialization and deduplication verified.")


def test_bm25_search_exact_matches():
    """Verifies BM25 scoring for exact financial numbers, acronyms, and phrases."""
    print("Testing BM25 exact keyword retrieval...")

    index = BM25KeywordIndex()
    index.add_chunks(_create_sample_chunks())

    # 1. Exact dollar amount match: $1,340
    hits_fcf = index.search("$1,340 million", k=1)
    assert len(hits_fcf) == 1
    top_chunk, score = hits_fcf[0]
    assert top_chunk.chunk_id == "TSLA_Q2_2026_p3_c0"
    assert score > 0.0

    # 2. Exact percentage match: 18.5%
    hits_margin = index.search("gross margin 18.5%", k=1)
    assert len(hits_margin) == 1
    assert hits_margin[0][0].chunk_id == "TSLA_Q2_2026_p4_c0"

    # 3. Exact hyphenated acronym: non-GAAP
    hits_gaap = index.search("non-GAAP net income", k=1)
    assert len(hits_gaap) == 1
    assert hits_gaap[0][0].chunk_id == "TSLA_Q1_2026_p5_c0"

    # 4. Empty / non-matching queries
    assert index.search("", k=5) == []
    assert index.search("xyznonexistentterm", k=5) == []

    print("✅ BM25 exact keyword retrieval verified.")


def test_bm25_metadata_filtering():
    """Verifies metadata pre-filtering across tickers, quarters, and domains."""
    print("Testing BM25 metadata pre-filtering...")

    index = BM25KeywordIndex()
    index.add_chunks(_create_sample_chunks())

    # 1. Ticker filter: TSLA only
    tsla_hits = index.search("revenue", k=5, ticker="TSLA")
    assert len(tsla_hits) == 1
    assert tsla_hits[0][0].ticker == "TSLA"
    assert tsla_hits[0][0].chunk_id == "TSLA_Q2_2026_p4_c0"

    # 2. Ticker filter: META only
    meta_hits = index.search("revenue", k=5, ticker="META")
    assert len(meta_hits) == 1
    assert meta_hits[0][0].ticker == "META"
    assert "47,510M" in meta_hits[0][0].text

    # 3. Multi-field filter: TSLA + Q1 + cash_flow
    targeted = index.search(
        "capital expenditures",
        k=5,
        ticker="TSLA",
        fiscal_quarter="Q1",
        fiscal_year=2026,
        financial_domain="cash_flow",
    )
    assert len(targeted) == 1
    assert targeted[0][0].chunk_id == "TSLA_Q1_2026_p5_c0"

    print("✅ BM25 metadata pre-filtering verified.")


def test_bm25_delete_and_reset():
    """Verifies deletion by ticker and index resetting."""
    print("Testing BM25 delete_by_ticker and reset...")

    index = BM25KeywordIndex()
    index.add_chunks(_create_sample_chunks())
    assert index.count() == 4

    # Delete TSLA chunks (3 chunks)
    removed = index.delete_by_ticker("TSLA")
    assert removed == 3
    assert index.count() == 1

    # Only META remains
    meta_hits = index.search("revenue", k=5)
    assert len(meta_hits) == 1
    assert meta_hits[0][0].ticker == "META"

    # Reset
    index.reset()
    assert index.count() == 0
    assert index.search("revenue", k=5) == []

    print("✅ BM25 delete_by_ticker and reset verified.")


def test_bm25_serialization_roundtrip():
    """Verifies saving to disk and reloading state."""
    print("Testing BM25 serialization roundtrip...")

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir) / "test_bm25.pkl"

        # Index and save
        index1 = BM25KeywordIndex(persist_dir=Path(tmp_dir))
        index1.add_chunks(_create_sample_chunks())
        index1.save(file_path=tmp_path)
        assert tmp_path.exists()

        # Load into clean index
        index2 = BM25KeywordIndex(persist_dir=Path(tmp_dir))
        success = index2.load(file_path=tmp_path)
        assert success is True
        assert index2.count() == 4

        # Verify search works identically
        hits1 = index1.search("18.5%", k=1)
        hits2 = index2.search("18.5%", k=1)
        assert hits1[0][0].chunk_id == hits2[0][0].chunk_id
        assert abs(hits1[0][1] - hits2[0][1]) < 1e-5

    print("✅ BM25 serialization roundtrip verified.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING BM25 SPARSE KEYWORD INDEX TESTS")
    print("=" * 60)

    test_financial_tokenize()
    test_bm25_initialization_and_deduplication()
    test_bm25_search_exact_matches()
    test_bm25_metadata_filtering()
    test_bm25_delete_and_reset()
    test_bm25_serialization_roundtrip()

    print("\n" + "=" * 60)
    print("ALL BM25 KEYWORD INDEX TESTS PASSED! ✅")
    print("=" * 60 + "\n")
