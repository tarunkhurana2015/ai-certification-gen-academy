"""
Vector Index Module.

Simple vector store backed by ChromaDB and OpenAI Embeddings.
Directly matches the beginner-friendly pattern from week2-rag/1_rag_pipeline.ipynb.
"""

import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

import chromadb
from dotenv import load_dotenv
from langchain_chroma import Chroma
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

# Load .env for OPENAI_API_KEY
load_dotenv(_SERVER_ROOT / ".env")

DEFAULT_PERSIST_DIR = _SERVER_ROOT / "data" / "chroma"


def get_embeddings(dimensions: int = 512) -> OpenAIEmbeddings:
    """
    Initializes the standard OpenAI Embeddings model matching the course notebooks:
    embeddings = OpenAIEmbeddings(model="text-embedding-3-small", dimensions=512)
    """
    api_key = os.getenv("OPENAI_API_KEY")
    return OpenAIEmbeddings(
        model="text-embedding-3-small",
        dimensions=dimensions,
        openai_api_key=api_key,
    )


class VectorIndex:
    """
    Simple Vector Store wrapper around ChromaDB matching week2-rag/1_rag_pipeline.ipynb:
    1. Stores standard LangChain Documents with content and metadata.
    2. Exposes .add_documents(), .as_retriever(), and .similarity_search().
    """

    def __init__(
        self,
        collection_name: str = "earnings_chunks",
        persist_dir: Optional[Path] = None,
        embeddings: Optional[Any] = None,
        client: Optional[Any] = None,
    ):
        self.collection_name = collection_name
        self.persist_dir = persist_dir or DEFAULT_PERSIST_DIR
        self.embeddings = embeddings or get_embeddings(dimensions=512)

        if client is not None:
            self.client = client
        else:
            self.persist_dir.mkdir(parents=True, exist_ok=True)
            self.client = chromadb.PersistentClient(path=str(self.persist_dir))

        self.vector_store = Chroma(
            client=self.client,
            collection_name=self.collection_name,
            embedding_function=self.embeddings,
        )

    def add_documents(self, documents: List[Document], ids: Optional[List[str]] = None) -> List[str]:
        """
        Adds LangChain Documents directly to Chroma vector store:
        vector_store.add_documents(documents=split_docs)
        """
        if not documents:
            return []

        # If ids not explicitly passed, extract chunk_id from metadata if present
        if ids is None:
            extracted_ids = [doc.metadata.get("chunk_id") for doc in documents if doc.metadata.get("chunk_id")]
            if len(extracted_ids) == len(documents):
                ids = extracted_ids

        return self.vector_store.add_documents(documents=documents, ids=ids)

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

    def as_retriever(self, k: int = 5, filter: Optional[Dict[str, Any]] = None):
        """
        Returns a standard LangChain retriever matching week2-rag/1_rag_pipeline.ipynb:
        retriever = vector_store.as_retriever(search_kwargs={"k": 5})
        """
        search_kwargs: Dict[str, Any] = {"k": k}
        if filter:
            search_kwargs["filter"] = filter
        return self.vector_store.as_retriever(search_kwargs=search_kwargs)

    def similarity_search(
        self,
        query: str,
        k: int = 5,
        filter: Optional[Dict[str, Any]] = None,
    ) -> List[Document]:
        """
        Direct semantic similarity search:
        docs = vector_store.similarity_search(query, k=5)
        """
        return self.vector_store.similarity_search(query=query, k=k, filter=filter)

    def count(self) -> int:
        """Returns total number of chunks indexed in the collection."""
        return self.vector_store._collection.count()

    def delete_by_ticker(self, ticker: str) -> None:
        """Deletes all chunks belonging to a specific ticker."""
        self.vector_store._collection.delete(where={"ticker": ticker.upper().strip()})

    def save_artifact(self, ticker: Optional[str] = None, output_path: Optional[Path] = None) -> Path:
        """Generates a plain text/markdown artifact of the vector index."""
        return save_vector_artifact(self, ticker=ticker, output_path=output_path)


def save_vector_artifact(
    vector_index: VectorIndex,
    ticker: Optional[str] = None,
    output_path: Optional[Path] = None,
) -> Path:
    """
    Saves an inspectable markdown/text artifact for the vector store in server/.artifact/idx_02_vector_store_sample.md.
    """
    from datetime import datetime

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    path = output_path or (artifact_dir / "idx_02_vector_store_sample.md")

    count = vector_index.count()
    queries = [
        "free cash flow and capital expenditures",
        "automotive gross margin and revenue highlights",
    ]

    lines = [
        "# ChromaDB Vector Store Artifact (`idx_02`)\n",
        f"- **Generated At**: `{datetime.now().isoformat()}`",
        f"- **Collection Name**: `{vector_index.collection_name}`",
        f"- **Total Chunks Indexed**: `{count}`",
        "- **Embedding Model**: `text-embedding-3-small` (512 dimensions)",
        f"- **Storage Path**: `{vector_index.persist_dir}`\n",
        "## 🔍 Sample Filtered Searches\n",
    ]

    filter_kwargs = {"ticker": ticker.upper().strip()} if ticker else None
    for q in queries:
        lines.append(f'### Query: *"{q}"*')
        if filter_kwargs:
            lines.append(f"- **Filter**: `{filter_kwargs}`")
        try:
            results = vector_index.similarity_search(q, k=2, filter=filter_kwargs)
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
    print("RUNNING VECTOR STORE SELF-TEST & ARTIFACT GENERATION")
    print("=" * 60)

    import json
    from langchain_core.embeddings.fake import FakeEmbeddings

    use_mock = "--mock" in sys.argv
    if use_mock:
        print("Using FakeEmbeddings(size=512) for offline test run.")
        idx = VectorIndex(embeddings=FakeEmbeddings(size=512))
    else:
        idx = VectorIndex()

    sample_file = _SERVER_ROOT / ".artifact" / "03b_enriched_chunks_tsla_q2_2026_update.json"
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
    print(f"✅ Vector Store artifact written to: {art_path}")
    print(f"   Indexed count: {idx.count()}")
    print("=" * 60 + "\n")

