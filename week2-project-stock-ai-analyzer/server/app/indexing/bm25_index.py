"""
BM25 Sparse Lexical Keyword Index Module.

Conforms to ARCHITECTURE.md Section 4.5, Section 7.2 & Section 8 (app/indexing/bm25_index.py).
Provides an in-memory BM25Okapi inverted index with specialized financial tokenization,
exact ticker/number/acronym matching, metadata pre-filtering, and persistent disk caching.
"""

import json
import logging
import os
import pickle
import re
import sys
from dataclasses import asdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

from rank_bm25 import BM25Okapi

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.ingestion.chunkers.metadata_enricher import EnrichedChunk

logger = logging.getLogger("stock_analyst.indexing.bm25_index")

DEFAULT_BM25_DIR = _SERVER_ROOT / "data" / "bm25"
DEFAULT_BM25_FILE = DEFAULT_BM25_DIR / "bm25_index.pkl"


def financial_tokenize(text: str) -> List[str]:
    """
    Specialized tokenizer for financial documents and earnings reports.
    
    Preserves:
    - Financial figures with commas/decimals: '$1,340', '1,340', '18.5%'
    - Financial acronyms & hyphenated terms: 'GAAP', 'Non-GAAP', 'CapEx', '10-Q'
    - Ticker symbols and accounting words: 'TSLA', 'EBITDA', 'Revenues'
    
    Returns:
        List of lowercase, normalized tokens.
    """
    if not text:
        return []

    # Pattern matches:
    # 1. Currency & percentages: $1,340.50, 18.5%, $50M
    # 2. Hyphenated accounting terms: non-gaap, year-over-year
    # 3. Standard alphanumeric tokens: TSLA, revenue, ebitda
    pattern = r"\$?\d+(?:,\d+)*(?:\.\d+)?%?|[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*"
    raw_tokens = re.findall(pattern, text.lower())

    tokens: List[str] = []
    for token in raw_tokens:
        tokens.append(token)
        # Emit clean numeric variants without currency symbols or % for exact number matching
        if token.startswith("$") and len(token) > 1:
            tokens.append(token[1:])
        if token.endswith("%") and len(token) > 1:
            tokens.append(token[:-1])
        # Simple plural normalization for financial terms (e.g. revenues -> revenue)
        if token.endswith("s") and len(token) > 3 and not token.endswith("ss"):
            tokens.append(token[:-1])

    return tokens


class BM25KeywordIndex:
    """
    High-performance in-memory BM25Okapi sparse keyword index.
    
    Complementary to dense vector search:
    - Catches exact dollar amounts, GAAP line items, footnote references, and tickers.
    - Supports strict metadata filtering by ticker, quarter, year, and financial domain.
    - Zero external API dependencies, runs completely offline in <5ms.
    - Supports serialization to and deserialization from disk.
    """

    def __init__(
        self,
        persist_dir: Optional[Path] = None,
        k1: float = 1.5,
        b: float = 0.75,
    ):
        """
        Initializes the BM25 keyword index.

        Args:
            persist_dir: Path to directory where serialized index is stored.
            k1: BM25 term frequency saturation parameter (default: 1.5).
            b: BM25 document length normalization parameter (default: 0.75).
        """
        self.persist_dir = persist_dir or DEFAULT_BM25_DIR
        self.k1 = k1
        self.b = b

        self._chunks: List[EnrichedChunk] = []
        self._chunk_ids: Set[str] = set()
        self._corpus_tokens: List[List[str]] = []
        self._bm25: Optional[BM25Okapi] = None

    @property
    def chunks(self) -> List[EnrichedChunk]:
        """Returns the list of stored chunks."""
        return self._chunks

    def count(self) -> int:
        """Returns total number of chunks currently indexed."""
        return len(self._chunks)

    def _build_bm25_model(self) -> Optional[BM25Okapi]:
        """Instantiates BM25Okapi and enforces a positive IDF floor on all corpus terms."""
        if not self._corpus_tokens:
            return None
        model = BM25Okapi(self._corpus_tokens, k1=self.k1, b=self.b)
        for term, idf_val in model.idf.items():
            if idf_val <= 0:
                model.idf[term] = 0.05
        return model

    def add_chunks(self, chunks: List[EnrichedChunk]) -> int:
        """
        Ingests a list of EnrichedChunks into the sparse inverted index.
        
        Tokenizes text using financial_tokenize, deduplicates chunk IDs,
        and reconstructs the BM25Okapi frequency table.

        Args:
            chunks: List of EnrichedChunk instances.

        Returns:
            Count of newly added chunks.
        """
        if not chunks:
            return 0

        new_chunks = 0
        for chunk in chunks:
            if chunk.chunk_id in self._chunk_ids:
                continue

            self._chunks.append(chunk)
            self._chunk_ids.add(chunk.chunk_id)
            tokens = financial_tokenize(chunk.text)
            self._corpus_tokens.append(tokens)
            new_chunks += 1

        if new_chunks > 0 and self._corpus_tokens:
            self._bm25 = self._build_bm25_model()
            logger.info(f"Rebuilt BM25 index with {len(self._chunks)} total chunks.")

        return new_chunks

    def search(
        self,
        query: str,
        k: int = 5,
        ticker: Optional[str] = None,
        fiscal_quarter: Optional[str] = None,
        fiscal_year: Optional[int] = None,
        financial_domain: Optional[str] = None,
        min_score: float = 0.0,
    ) -> List[Tuple[EnrichedChunk, float]]:
        """
        Performs BM25 keyword retrieval with strict metadata pre-filtering.

        Args:
            query: Natural language or exact keyword search string.
            k: Top-K candidates to return.
            ticker: Optional ticker pre-filter (e.g. 'TSLA').
            fiscal_quarter: Optional quarter pre-filter (e.g. 'Q2').
            fiscal_year: Optional year pre-filter (e.g. 2026).
            financial_domain: Optional domain filter (e.g. 'cash_flow', 'profitability').
            min_score: Minimum BM25 score threshold (default: 0.0).

        Returns:
            List of (EnrichedChunk, score) tuples sorted by score descending.
        """
        if not self._chunks or self._bm25 is None or not query.strip():
            return []

        query_tokens = financial_tokenize(query)
        if not query_tokens:
            return []

        # Vectorized BM25 scoring across all corpus chunks
        scores = self._bm25.get_scores(query_tokens)

        norm_ticker = ticker.upper().strip() if ticker else None
        norm_quarter = fiscal_quarter.upper().strip() if fiscal_quarter else None
        norm_domain = financial_domain.lower().strip() if financial_domain else None

        candidates: List[Tuple[EnrichedChunk, float]] = []

        for idx, raw_score in enumerate(scores):
            score = float(raw_score)
            if score <= min_score:
                continue

            chunk = self._chunks[idx]

            # Apply metadata filters
            if norm_ticker and chunk.ticker != norm_ticker:
                continue
            if norm_quarter and chunk.fiscal_quarter != norm_quarter:
                continue
            if fiscal_year is not None and chunk.fiscal_year != int(fiscal_year):
                continue
            if norm_domain and chunk.financial_domain != norm_domain:
                continue

            candidates.append((chunk, score))

        # Sort descending by score
        candidates.sort(key=lambda x: x[1], reverse=True)
        return candidates[:k]

    def delete_by_ticker(self, ticker: str) -> int:
        """
        Deletes all chunks belonging to a specific ticker and rebuilds the BM25 index.

        Args:
            ticker: Stock ticker to delete.

        Returns:
            Number of removed chunks.
        """
        norm_ticker = ticker.upper().strip()
        retained_chunks: List[EnrichedChunk] = []
        retained_tokens: List[List[str]] = []
        retained_ids: Set[str] = set()
        removed = 0

        for chunk, tokens in zip(self._chunks, self._corpus_tokens):
            if chunk.ticker == norm_ticker:
                removed += 1
            else:
                retained_chunks.append(chunk)
                retained_tokens.append(tokens)
                retained_ids.add(chunk.chunk_id)

        self._chunks = retained_chunks
        self._corpus_tokens = retained_tokens
        self._chunk_ids = retained_ids
        self._bm25 = self._build_bm25_model()

        logger.info(f"Deleted {removed} chunks for ticker '{norm_ticker}' from BM25 index.")
        return removed

    def save(self, file_path: Optional[Path] = None) -> Path:
        """Serializes the index and chunks to disk using pickle."""
        target_path = file_path or (self.persist_dir / "bm25_index.pkl")
        target_path.parent.mkdir(parents=True, exist_ok=True)

        payload = {
            "version": "1.0",
            "k1": self.k1,
            "b": self.b,
            "chunks": self._chunks,
            "corpus_tokens": self._corpus_tokens,
        }

        with open(target_path, "wb") as f:
            pickle.dump(payload, f)

        logger.info(f"Saved BM25 index with {len(self._chunks)} chunks to {target_path}")
        return target_path

    def load(self, file_path: Optional[Path] = None) -> bool:
        """Loads and rebuilds the BM25 index from a serialized file on disk."""
        target_path = file_path or (self.persist_dir / "bm25_index.pkl")
        if not target_path.exists():
            logger.warning(f"BM25 index file not found at: {target_path}")
            return False

        with open(target_path, "rb") as f:
            payload = pickle.load(f)

        self.k1 = payload.get("k1", 1.5)
        self.b = payload.get("b", 0.75)
        self._chunks = payload.get("chunks", [])
        self._corpus_tokens = payload.get("corpus_tokens", [])
        self._chunk_ids = {c.chunk_id for c in self._chunks}
        self._bm25 = self._build_bm25_model()

        logger.info(f"Loaded {len(self._chunks)} chunks from {target_path}")
        return True

    def reset(self) -> None:
        """Clears all in-memory chunks and reset the BM25 index."""
        self._chunks = []
        self._chunk_ids = set()
        self._corpus_tokens = []
        self._bm25 = None

    def get_stats(self) -> Dict[str, Any]:
        """Returns diagnostic statistics for the BM25 index."""
        tickers = sorted(list({c.ticker for c in self._chunks}))
        domains = sorted(list({c.financial_domain for c in self._chunks}))
        return {
            "total_chunks": len(self._chunks),
            "k1": self.k1,
            "b": self.b,
            "tickers": tickers,
            "domains": domains,
            "persist_directory": str(self.persist_dir),
        }


# =====================================================================
# CLI Runner & Observable Inspection Artifact Generator
# =====================================================================

if __name__ == "__main__":
    from datetime import datetime
    from app.ingestion.chunkers.metadata_enricher import enrich_split

    print("\n" + "=" * 65)
    print("BM25 SPARSE KEYWORD INDEX SELF-TEST (Step 3.3)")
    print("=" * 65)

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    # 1. Load real chunks from existing ingestion artifact or create fallback
    tsla_artifact_path = artifact_dir / "03b_enriched_chunks_tsla_q2_2026_update.json"
    chunks_to_index: List[EnrichedChunk] = []

    if tsla_artifact_path.exists():
        print(f"📖 Loading real chunks from: {tsla_artifact_path.name}")
        with open(tsla_artifact_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            for c in data.get("chunks", []):
                chunks_to_index.append(
                    EnrichedChunk(
                        chunk_id=c["chunk_id"],
                        text=c["text"],
                        ticker=c["ticker"],
                        fiscal_quarter=c["fiscal_quarter"],
                        fiscal_year=c["fiscal_year"],
                        page_number=c["page_number"],
                        financial_domain=c["financial_domain"],
                        char_count=c["char_count"],
                        chunk_index_in_page=c["chunk_index_in_page"],
                        total_chunks_in_page=c["total_chunks_in_page"],
                    )
                )
        print(f"✅ Loaded {len(chunks_to_index)} real enriched chunks.")
    else:
        print("⚠️ Artifact not found, creating synthetic sample chunks...")
        chunks_to_index = [
            enrich_split(
                text="Free cash flow = operating cash flow less capex; Free cash flow was $1,340 million in Q2 2026.",
                ticker="TSLA",
                fiscal_quarter="Q2",
                fiscal_year=2026,
                page_number=3,
                domain="cash_flow",
                chunk_index_in_page=0,
                total_chunks_in_page=1,
            ),
            enrich_split(
                text="Total automotive revenues grew 2% year-over-year to $19,878 million. Automotive gross margin was 18.5%.",
                ticker="TSLA",
                fiscal_quarter="Q2",
                fiscal_year=2026,
                page_number=4,
                domain="profitability",
                chunk_index_in_page=0,
                total_chunks_in_page=1,
            ),
        ]

    # 2. Initialize BM25 Keyword Index
    bm25_index = BM25KeywordIndex()
    print(f"🗂️ Initialized BM25Okapi Index (k1={bm25_index.k1}, b={bm25_index.b})")

    # 3. Add chunks
    print(f"📥 Tokenizing and indexing {len(chunks_to_index)} chunks...")
    added = bm25_index.add_chunks(chunks_to_index)
    print(f"✅ Successfully indexed {added} chunks. Total in index: {bm25_index.count()}")

    # 4. Save index to disk
    saved_file = bm25_index.save()
    print(f"💾 Serialized index saved to: {saved_file.relative_to(_SERVER_ROOT)}")

    # 5. Execute exact keyword queries with metadata pre-filtering
    test_queries = [
        {
            "query": "Free cash flow $1,340M",
            "filter": {"ticker": "TSLA", "financial_domain": "cash_flow"},
        },
        {
            "query": "automotive gross margin 18.5%",
            "filter": {"ticker": "TSLA", "financial_domain": "profitability"},
        },
        {
            "query": "GAAP operating income $0.4B",
            "filter": {"ticker": "TSLA"},
        },
    ]

    search_results = []
    print("\n🔍 Running Exact BM25 Keyword Searches:")
    for tq in test_queries:
        query_text = tq["query"]
        q_filter = tq["filter"]
        print(f"\n  • Query: '{query_text}' | Filter: {q_filter}")

        hits = bm25_index.search(
            query=query_text,
            k=2,
            ticker=q_filter.get("ticker"),
            financial_domain=q_filter.get("financial_domain"),
        )

        hit_data = []
        for chunk, score in hits:
            preview = chunk.text.replace("\n", " ")[:120]
            print(f"    [BM25 Score: {score:.4f}] [Page {chunk.page_number}] {preview}...")
            hit_data.append({
                "chunk_id": chunk.chunk_id,
                "bm25_score": round(score, 4),
                "page_number": chunk.page_number,
                "domain": chunk.financial_domain,
                "content_preview": chunk.text[:200],
            })

        search_results.append({
            "query": query_text,
            "filter": q_filter,
            "hits": hit_data,
        })

    # 6. Export observable inspection artifacts
    artifact_payload = {
        "timestamp": datetime.now().isoformat(),
        "bm25_stats": bm25_index.get_stats(),
        "ingested_chunks_count": added,
        "sample_searches": search_results,
    }

    json_artifact = artifact_dir / "idx_03_bm25_sample.json"
    with open(json_artifact, "w", encoding="utf-8") as f:
        json.dump(artifact_payload, f, indent=2)

    md_artifact = artifact_dir / "idx_03_bm25_sample.md"
    with open(md_artifact, "w", encoding="utf-8") as f:
        f.write("# BM25 Sparse Keyword Index Sample Artifact (`idx_03`)\n\n")
        f.write(f"- **Generated At**: `{artifact_payload['timestamp']}`\n")
        f.write(f"- **Total Chunks Indexed**: `{bm25_index.count()}`\n")
        f.write(f"- **Parameters**: `k1={bm25_index.k1}, b={bm25_index.b}`\n")
        f.write(f"- **Serialized File**: `{saved_file.relative_to(_SERVER_ROOT)}`\n\n")
        f.write("## 🔍 Sample Keyword Searches\n\n")
        for sr in search_results:
            f.write(f"### Query: *\"{sr['query']}\"*\n")
            f.write(f"- **Filter**: `{sr['filter']}`\n")
            f.write("| BM25 Score | Chunk ID | Page | Domain | Preview |\n")
            f.write("| :--- | :--- | :--- | :--- | :--- |\n")
            for h in sr["hits"]:
                preview = h["content_preview"].replace("\n", " ")
                f.write(f"| {h['bm25_score']} | `{h['chunk_id']}` | {h['page_number']} | `{h['domain']}` | {preview[:80]}... |\n")
            f.write("\n")

    print(f"\n📦 Artifacts created:")
    print(f"  • {json_artifact.relative_to(_SERVER_ROOT)}")
    print(f"  • {md_artifact.relative_to(_SERVER_ROOT)}")
    print("=" * 65 + "\n")
