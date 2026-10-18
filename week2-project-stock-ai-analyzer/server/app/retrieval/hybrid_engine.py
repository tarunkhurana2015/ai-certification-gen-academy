"""
Hybrid Retrieval Engine Module.

Combines Semantic Dense Vector search (ChromaDB) and Lexical Sparse search (BM25)
using LangChain's EnsembleRetriever (weighted Reciprocal Rank Fusion / RRF).
Directly matches the beginner-friendly pattern from week2-rag/3_hybrid_rag.ipynb.
"""

import argparse
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

from langchain_classic.retrievers import EnsembleRetriever
from langchain_core.documents import Document

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.ingestion.indexing.bm25_index import BM25Index
from app.ingestion.indexing.vector_index import VectorIndex


def create_ensemble_retriever(
    vector_index: VectorIndex,
    bm25_index: BM25Index,
    ticker: Optional[str] = None,
    k: int = 5,
    weights: Optional[List[float]] = None,
) -> EnsembleRetriever:
    """
    Creates an EnsembleRetriever that fuses vector and BM25 retrievers, matching:
    ensemble_retriever = EnsembleRetriever(
        retrievers=[vector_retriever, bm25_retriever],
        weights=[0.5, 0.5],
    )
    """
    filter_dict = {"ticker": ticker.upper().strip()} if ticker else None
    vector_retriever = vector_index.as_retriever(k=k, filter=filter_dict)
    bm25_retriever = bm25_index.as_retriever(k=k, filter=filter_dict)

    return EnsembleRetriever(
        retrievers=[vector_retriever, bm25_retriever],
        weights=weights or [0.5, 0.5],
    )


class HybridEngine:
    """
    High-level Hybrid RAG Engine matching week2-rag/3_hybrid_rag.ipynb:
    1. Uses VectorIndex (dense OpenAI text-embedding-3-small + Chroma).
    2. Uses BM25Index (sparse lexical keyword search).
    3. Merges results using LangChain's EnsembleRetriever (RRF).
    """

    def __init__(
        self,
        vector_index: Optional[VectorIndex] = None,
        bm25_index: Optional[BM25Index] = None,
    ):
        self.vector_index = vector_index or VectorIndex()
        self.bm25_index = bm25_index or BM25Index()

    def get_retriever(
        self,
        ticker: Optional[str] = None,
        k: int = 5,
        weights: Optional[List[float]] = None,
    ) -> EnsembleRetriever:
        """Returns the fused EnsembleRetriever."""
        return create_ensemble_retriever(
            vector_index=self.vector_index,
            bm25_index=self.bm25_index,
            ticker=ticker,
            k=k,
            weights=weights,
        )

    def search(
        self,
        query: str,
        ticker: Optional[str] = None,
        k: int = 5,
        weights: Optional[List[float]] = None,
        save_artifact: bool = True,
    ) -> List[Document]:
        """
        Executes hybrid retrieval search query across vector and keyword indices.
        Returns top-k fused results and automatically records the artifact.
        """
        retriever = self.get_retriever(ticker=ticker, k=k, weights=weights)
        docs = retriever.invoke(query)[:k]
        if save_artifact:
            save_hybrid_artifact(query=query, results=docs, ticker=ticker)
        return docs

    def show_hybrid(
        self,
        query: str,
        ticker: Optional[str] = None,
        k: int = 3,
        weights: Optional[List[float]] = None,
        save_artifact: bool = True,
    ) -> Dict[str, List[Document]]:
        """
        Helper mirroring show_hybrid() from week2-rag/3_hybrid_rag.ipynb:
        Shows the individual vector results, BM25 results, and the fused ensemble results,
        and saves an inspectable markdown artifact.
        """
        filter_dict = {"ticker": ticker.upper().strip()} if ticker else None
        vector_docs = self.vector_index.similarity_search(query=query, k=k, filter=filter_dict)
        bm25_docs = self.bm25_index.search(query=query, k=k, filter=filter_dict)

        ensemble_retriever = self.get_retriever(ticker=ticker, k=k, weights=weights)
        fused_docs = ensemble_retriever.invoke(query)[:k]

        if save_artifact:
            save_hybrid_artifact(
                query=query,
                results=fused_docs,
                ticker=ticker,
                vector_results=vector_docs,
                bm25_results=bm25_docs,
            )

        return {
            "vector": vector_docs,
            "bm25": bm25_docs,
            "ensemble": fused_docs,
        }


def save_hybrid_artifact(
    query: str,
    results: List[Document],
    ticker: Optional[str] = None,
    output_path: Optional[Path] = None,
    vector_results: Optional[List[Document]] = None,
    bm25_results: Optional[List[Document]] = None,
) -> Path:
    """
    Saves a clean markdown/text artifact for hybrid retrieval in server/.artifact/idx_04_hybrid_retrieval_sample.md.
    """
    from datetime import datetime

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    path = output_path or (artifact_dir / "idx_04_hybrid_retrieval_sample.md")

    lines = [
        "# 🔍 Hybrid Retrieval Engine Artifact (`idx_04`)\n",
        f"- **Generated At**: `{datetime.now().isoformat()}`",
        f"- **Query**: `{query}`",
        f"- **Filter Ticker**: `{ticker.upper() if ticker else 'ALL'}`",
        f"- **Total Results Returned**: `{len(results)}`",
        "- **Retriever Type**: `EnsembleRetriever` (Weighted Reciprocal Rank Fusion)\n",
        "## 🏆 Fused Ranked Results (Ensemble)\n",
    ]

    for i, doc in enumerate(results, 1):
        m = doc.metadata
        cid = m.get("chunk_id", f"chunk_{i}")
        page = m.get("page_number", "-")
        domain = m.get("financial_domain", "general")
        doc_ticker = m.get("ticker", ticker or "N/A")
        lines.append(f"### Rank {i}: [{doc_ticker} · Page {page} · {domain.title()}] (`{cid}`)")
        lines.append("```text")
        lines.append(doc.page_content.strip())
        lines.append("```\n")

    if vector_results or bm25_results:
        lines.append("## 🔬 Component Retriever Breakdown\n")
        if vector_results:
            lines.append("### Vector (Semantic) Matches")
            for i, doc in enumerate(vector_results, 1):
                cid = doc.metadata.get("chunk_id", "N/A")
                preview = doc.page_content.replace("\n", " ")[:90] + "..."
                lines.append(f"- **[{i}]** `{cid}`: {preview}")
            lines.append("")
        if bm25_results:
            lines.append("### BM25 (Keyword) Matches")
            for i, doc in enumerate(bm25_results, 1):
                cid = doc.metadata.get("chunk_id", "N/A")
                preview = doc.page_content.replace("\n", " ")[:90] + "..."
                lines.append(f"- **[{i}]** `{cid}`: {preview}")
            lines.append("")

    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    return path


def main():
    parser = argparse.ArgumentParser(description="Hybrid RAG Search CLI")
    parser.add_argument("query", type=str, nargs="?", default="What was the Free Cash Flow in Q2 2026?", help="Search query (e.g. 'What was the Free Cash Flow?')")
    parser.add_argument("--ticker", type=str, default="TSLA", help="Optional stock ticker filter (e.g. TSLA)")
    parser.add_argument("--k", type=int, default=5, help="Number of chunks to retrieve")
    parser.add_argument("--mock", action="store_true", help="Use FakeEmbeddings for offline/sandboxed execution")
    args = parser.parse_args()

    if args.mock:
        from langchain_core.embeddings.fake import FakeEmbeddings
        v_idx = VectorIndex(embeddings=FakeEmbeddings(size=512))
        engine = HybridEngine(vector_index=v_idx)
    else:
        engine = HybridEngine()

    results = engine.show_hybrid(query=args.query, ticker=args.ticker, k=args.k, save_artifact=True)

    print(f"\nQUERY: {args.query}")
    if args.ticker:
        print(f"FILTER: ticker = {args.ticker.upper()}")

    print("\n--- VECTOR (Semantic) ---")
    for i, doc in enumerate(results["vector"], 1):
        chunk_id = doc.metadata.get("chunk_id", "N/A")
        print(f"[{i}] ({chunk_id}) {doc.page_content[:120]}...")

    print("\n--- BM25 (Keyword) ---")
    for i, doc in enumerate(results["bm25"], 1):
        chunk_id = doc.metadata.get("chunk_id", "N/A")
        print(f"[{i}] ({chunk_id}) {doc.page_content[:120]}...")

    print("\n--- ENSEMBLE (Fused RRF) ---")
    for i, doc in enumerate(results["ensemble"], 1):
        chunk_id = doc.metadata.get("chunk_id", "N/A")
        print(f"[{i}] ({chunk_id}) {doc.page_content[:120]}...")

    artifact_file = _SERVER_ROOT / ".artifact" / "idx_04_hybrid_retrieval_sample.md"
    print(f"\n✅ Artifact successfully written to: {artifact_file}\n")


if __name__ == "__main__":
    main()

