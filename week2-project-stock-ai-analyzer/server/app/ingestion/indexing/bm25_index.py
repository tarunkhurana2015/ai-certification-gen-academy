"""
BM25 Index Module.

Simple keyword (lexical) index backed by LangChain's BM25Retriever.
Directly matches the beginner-friendly pattern from week2-rag/3_hybrid_rag.ipynb.
"""

import json
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

from langchain_community.retrievers import BM25Retriever
from langchain_core.documents import Document

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

DEFAULT_BM25_PATH = _SERVER_ROOT / "data" / "bm25" / "documents.json"


class BM25Index:
    """
    Simple BM25 index with lightweight JSON persistence, matching
    week2-rag/3_hybrid_rag.ipynb:
    bm25_retriever = BM25Retriever.from_documents(docs)
    bm25_retriever.k = 3
    """

    def __init__(self, persist_path: Optional[Path] = None):
        self.persist_path = persist_path or DEFAULT_BM25_PATH
        self.documents: List[Document] = []
        self.retriever: Optional[BM25Retriever] = None
        self._load()

    def add_documents(self, documents: List[Document]) -> None:
        """Adds LangChain documents to the BM25 corpus and updates the retriever."""
        if not documents:
            return

        # Deduplicate by chunk_id
        existing_ids = {
            doc.metadata.get("chunk_id")
            for doc in self.documents
            if doc.metadata.get("chunk_id")
        }
        for doc in documents:
            chunk_id = doc.metadata.get("chunk_id")
            if not chunk_id or chunk_id not in existing_ids:
                self.documents.append(doc)
                if chunk_id:
                    existing_ids.add(chunk_id)

        self._rebuild()
        self._save()

    def add_chunks(self, chunks: List[Any]) -> int:
        """Converts EnrichedChunk objects to LangChain Documents and indexes them."""
        docs = []
        for c in chunks:
            if isinstance(c, Document):
                docs.append(c)
            elif hasattr(c, "text"):
                docs.append(
                    Document(
                        page_content=c.text,
                        metadata={
                            "chunk_id": getattr(c, "chunk_id", ""),
                            "ticker": getattr(c, "ticker", ""),
                            "fiscal_quarter": getattr(c, "fiscal_quarter", ""),
                            "fiscal_year": getattr(c, "fiscal_year", 0),
                            "page_number": getattr(c, "page_number", 1),
                            "financial_domain": getattr(c, "financial_domain", "general"),
                        },
                    )
                )
        self.add_documents(docs)
        return len(docs)

    def _rebuild(self) -> None:
        """Rebuilds the BM25Retriever from the current corpus."""
        if self.documents:
            self.retriever = BM25Retriever.from_documents(self.documents)
        else:
            self.retriever = None

    def as_retriever(self, k: int = 5, filter: Optional[Dict[str, Any]] = None) -> BM25Retriever:
        """
        Returns a standard LangChain BM25Retriever matching week2-rag/3_hybrid_rag.ipynb:
        bm25_retriever = BM25Retriever.from_documents(docs)
        bm25_retriever.k = 3
        """
        # If a metadata filter (e.g. ticker) is requested, filter documents first
        target_docs = self.documents
        if filter:
            target_docs = [
                d
                for d in self.documents
                if all(d.metadata.get(key) == val for key, val in filter.items())
            ]

        if not target_docs:
            # Fallback for empty corpus with non-empty token to avoid ZeroDivisionError in rank_bm25
            retriever = BM25Retriever.from_documents([Document(page_content="empty", metadata={})])
            retriever.k = k
            return retriever

        retriever = BM25Retriever.from_documents(target_docs)
        retriever.k = k
        return retriever

    def search(self, query: str, k: int = 5, filter: Optional[Dict[str, Any]] = None) -> List[Document]:
        """Runs lexical keyword search using BM25."""
        if not self.documents:
            return []
        if filter:
            matching = [
                d
                for d in self.documents
                if all(d.metadata.get(key) == val for key, val in filter.items())
            ]
            if not matching:
                return []
        retriever = self.as_retriever(k=k, filter=filter)
        return retriever.invoke(query)

    def count(self) -> int:
        """Returns total number of chunks in the BM25 index."""
        return len(self.documents)

    def delete_by_ticker(self, ticker: str) -> None:
        """Removes all documents belonging to the specified ticker."""
        norm_ticker = ticker.upper().strip()
        self.documents = [
            d
            for d in self.documents
            if d.metadata.get("ticker", "").upper().strip() != norm_ticker
        ]
        self._rebuild()
        self._save()

    def _save(self) -> None:
        """Persists documents corpus to a JSON file."""
        if not self.persist_path:
            return
        self.persist_path.parent.mkdir(parents=True, exist_ok=True)
        data = [
            {"page_content": doc.page_content, "metadata": doc.metadata}
            for doc in self.documents
        ]
        with open(self.persist_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)

    def _load(self) -> None:
        """Loads documents corpus from JSON file if it exists."""
        if not self.persist_path or not self.persist_path.exists():
            return
        try:
            with open(self.persist_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            self.documents = [
                Document(page_content=item["page_content"], metadata=item.get("metadata", {}))
                for item in data
            ]
            self._rebuild()
        except Exception:
            self.documents = []
            self.retriever = None

    def save_artifact(self, ticker: Optional[str] = None, output_path: Optional[Path] = None) -> Path:
        """Generates a plain text/markdown artifact of the BM25 index."""
        return save_bm25_artifact(self, ticker=ticker, output_path=output_path)


def save_bm25_artifact(
    bm25_index: BM25Index,
    ticker: Optional[str] = None,
    output_path: Optional[Path] = None,
) -> Path:
    """
    Saves an inspectable markdown/text artifact for the BM25 index in server/.artifact/idx_03_bm25_sample.md.
    """
    from datetime import datetime

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    path = output_path or (artifact_dir / "idx_03_bm25_sample.md")

    count = bm25_index.count()
    queries = [
        "Free cash flow",
        "automotive gross margin",
        "GAAP operating income",
    ]

    lines = [
        "# BM25 Sparse Keyword Index Artifact (`idx_03`)\n",
        f"- **Generated At**: `{datetime.now().isoformat()}`",
        f"- **Total Chunks Indexed**: `{count}`",
        "- **Retriever**: `langchain_community.retrievers.BM25Retriever`",
        f"- **Storage Path**: `{bm25_index.persist_path}`\n",
        "## 🔍 Sample Keyword Searches\n",
    ]

    filter_kwargs = {"ticker": ticker.upper().strip()} if ticker else None
    for q in queries:
        lines.append(f'### Query: *"{q}"*')
        if filter_kwargs:
            lines.append(f"- **Filter**: `{filter_kwargs}`")
        try:
            results = bm25_index.search(q, k=2, filter=filter_kwargs)
            if results:
                lines.append("| Rank | Chunk ID | Page | Domain | Preview |")
                lines.append("| :--- | :--- | :--- | :--- | :--- |")
                for r_idx, doc in enumerate(results, 1):
                    m = doc.metadata
                    cid = m.get("chunk_id", "N/A")
                    page = m.get("page_number", "-")
                    domain = m.get("financial_domain", "general")
                    preview = doc.page_content.replace("\n", " ")[:80] + "..."
                    lines.append(f"| {r_idx} | `{cid}` | {page} | `{domain}` | {preview} |")
            else:
                lines.append("*(No results matched)*")
        except Exception as e:
            lines.append(f"*(Query skipped: {e})*")
        lines.append("")

    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    return path


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING BM25 INDEX SELF-TEST & ARTIFACT GENERATION")
    print("=" * 60)

    sample_file = _SERVER_ROOT / ".artifact" / "03b_enriched_chunks_tsla_q2_2026_update.json"

    idx = BM25Index()
    if sample_file.exists():
        with open(sample_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        chunks = [
            Document(page_content=item["text"], metadata=item)
            for item in data.get("chunks", [])
        ]
        print(f"Loaded {len(chunks)} real sample chunks from {sample_file.name}")
        idx.delete_by_ticker("TSLA")
        idx.add_documents(chunks)

    art_path = idx.save_artifact(ticker="TSLA")
    print(f"✅ BM25 artifact written to: {art_path}")
    print(f"   Indexed count: {idx.count()}")
    print("=" * 60 + "\n")
