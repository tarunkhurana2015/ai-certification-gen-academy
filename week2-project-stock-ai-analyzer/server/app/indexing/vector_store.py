"""
ChromaDB Vector Store Module.

Conforms to ARCHITECTURE.md Section 7.2 (ChromaDB Vector Store Schema) & Section 8 (app/indexing/vector_store.py).
Manages layout-aware chunk ingestion, HNSW cosine vector index, and metadata-filtered
semantic retrieval for financial earnings reports.
"""

import json
import logging
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import chromadb
from chromadb.api import ClientAPI
from dotenv import load_dotenv
from langchain_chroma import Chroma
from langchain_core.documents import Document
from langchain_core.embeddings import Embeddings

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

# Load environment variables (.env)
load_dotenv(_SERVER_ROOT / ".env")

from app.indexing.embeddings import get_embeddings_model
from app.ingestion.chunkers.metadata_enricher import EnrichedChunk

logger = logging.getLogger("stock_analyst.indexing.vector_store")

DEFAULT_COLLECTION_NAME = "earnings_chunks"
DEFAULT_PERSIST_DIR = _SERVER_ROOT / "data" / "chroma"


def build_chroma_filter(
    ticker: Optional[str] = None,
    fiscal_quarter: Optional[str] = None,
    fiscal_year: Optional[int] = None,
    financial_domain: Optional[str] = None,
) -> Optional[Dict[str, Any]]:
    """
    Constructs a Chroma-compliant metadata pre-filter clause.
    
    Chroma filter rules:
    - 0 conditions: None (no filter)
    - 1 condition: {"field": value}
    - 2+ conditions: {"$and": [{"field1": v1}, {"field2": v2}]}
    """
    conditions: List[Dict[str, Any]] = []
    if ticker:
        conditions.append({"ticker": ticker.upper().strip()})
    if fiscal_quarter:
        conditions.append({"fiscal_quarter": fiscal_quarter.upper().strip()})
    if fiscal_year is not None:
        conditions.append({"fiscal_year": int(fiscal_year)})
    if financial_domain:
        conditions.append({"financial_domain": financial_domain.lower().strip()})

    if not conditions:
        return None
    if len(conditions) == 1:
        return conditions[0]
    return {"$and": conditions}


class FinancialVectorStore:
    """
    Production-ready Vector Store wrapper backed by ChromaDB and OpenAI Embeddings.
    
    Provides:
    - Direct chunk ingestion from List[EnrichedChunk]
    - HNSW Cosine vector space indexing
    - Strict metadata pre-filtering by ticker, quarter, year, and financial domain
    - Support for ephemeral in-memory clients (zero disk side effects in tests)
    """

    def __init__(
        self,
        persist_dir: Optional[Path] = None,
        collection_name: str = DEFAULT_COLLECTION_NAME,
        embeddings: Optional[Embeddings] = None,
        client: Optional[ClientAPI] = None,
        collection_metadata: Optional[Dict[str, Any]] = None,
    ):
        """
        Initializes the ChromaDB vector store.

        Args:
            persist_dir: Path to directory for persistent SQLite/HNSW files.
            collection_name: Chroma collection name (default: 'earnings_chunks').
            embeddings: LangChain Embeddings instance (defaults to OpenAIEmbeddings 512-dim).
            client: Optional pre-configured ClientAPI (e.g. chromadb.EphemeralClient() for tests).
            collection_metadata: Collection configuration (defaults to cosine distance metric).
        """
        self.collection_name = collection_name
        self.persist_dir = persist_dir or DEFAULT_PERSIST_DIR
        self._embeddings = embeddings or get_embeddings_model()
        self._metadata = collection_metadata or {"hnsw:space": "cosine"}

        if client is not None:
            self._client = client
        else:
            self.persist_dir.mkdir(parents=True, exist_ok=True)
            self._client = chromadb.PersistentClient(path=str(self.persist_dir))

        self._vector_store = Chroma(
            client=self._client,
            collection_name=self.collection_name,
            embedding_function=self._embeddings,
            collection_metadata=self._metadata,
        )
        self._collection = self._client.get_or_create_collection(
            name=self.collection_name,
            metadata=self._metadata,
        )

    @property
    def collection(self):
        """Returns the underlying ChromaDB native collection."""
        return self._collection

    @property
    def vector_store(self) -> Chroma:
        """Returns the underlying LangChain Chroma instance."""
        return self._vector_store

    def add_chunks(self, chunks: List[EnrichedChunk]) -> int:
        """
        Ingests a list of EnrichedChunks directly into ChromaDB.
        
        Extracts chunk text, deterministic chunk_id, and metadata facets
        (ticker, fiscal_quarter, fiscal_year, financial_domain, page_number)
        and calls ChromaDB's batch indexing pipeline.

        Args:
            chunks: List of EnrichedChunk instances.

        Returns:
            Number of chunks successfully added.
        """
        if not chunks:
            return 0

        documents: List[Document] = []
        ids: List[str] = []

        for chunk in chunks:
            doc_metadata = {
                "chunk_id": chunk.chunk_id,
                "ticker": chunk.ticker,
                "fiscal_quarter": chunk.fiscal_quarter,
                "fiscal_year": chunk.fiscal_year,
                "page_number": chunk.page_number,
                "financial_domain": chunk.financial_domain,
                "char_count": chunk.char_count,
                "chunk_index_in_page": chunk.chunk_index_in_page,
                "total_chunks_in_page": chunk.total_chunks_in_page,
            }
            documents.append(
                Document(
                    page_content=chunk.text,
                    metadata=doc_metadata,
                )
            )
            ids.append(chunk.chunk_id)

        self._vector_store.add_documents(documents=documents, ids=ids)
        logger.info(f"Successfully added {len(chunks)} chunks to '{self.collection_name}'")
        return len(chunks)

    def similarity_search(
        self,
        query: str,
        k: int = 5,
        ticker: Optional[str] = None,
        fiscal_quarter: Optional[str] = None,
        fiscal_year: Optional[int] = None,
        financial_domain: Optional[str] = None,
    ) -> List[Document]:
        """
        Executes a dense semantic similarity search with optional metadata pre-filtering.

        Args:
            query: User's natural language question.
            k: Top-K chunks to retrieve.
            ticker: Stock ticker filter (e.g. 'TSLA').
            fiscal_quarter: Quarter filter (e.g. 'Q2').
            fiscal_year: Year filter (e.g. 2026).
            financial_domain: Domain filter (e.g. 'profitability', 'cash_flow').

        Returns:
            List of retrieved Document instances.
        """
        chroma_filter = build_chroma_filter(
            ticker=ticker,
            fiscal_quarter=fiscal_quarter,
            fiscal_year=fiscal_year,
            financial_domain=financial_domain,
        )
        return self._vector_store.similarity_search(
            query=query,
            k=k,
            filter=chroma_filter,
        )

    def similarity_search_with_scores(
        self,
        query: str,
        k: int = 5,
        ticker: Optional[str] = None,
        fiscal_quarter: Optional[str] = None,
        fiscal_year: Optional[int] = None,
        financial_domain: Optional[str] = None,
    ) -> List[Tuple[Document, float]]:
        """
        Executes semantic similarity search returning Document and relevance score tuples.
        """
        chroma_filter = build_chroma_filter(
            ticker=ticker,
            fiscal_quarter=fiscal_quarter,
            fiscal_year=fiscal_year,
            financial_domain=financial_domain,
        )
        return self._vector_store.similarity_search_with_relevance_scores(
            query=query,
            k=k,
            filter=chroma_filter,
        )

    def delete_by_ticker(self, ticker: str) -> None:
        """Deletes all chunks belonging to a specific ticker."""
        self._collection.delete(where={"ticker": ticker.upper().strip()})
        logger.info(f"Deleted chunks for ticker '{ticker.upper()}' from '{self.collection_name}'")

    def count(self) -> int:
        """Returns total number of chunks currently stored in the collection."""
        return self._collection.count()

    def reset(self) -> None:
        """Wipes all records from the collection."""
        self._client.delete_collection(name=self.collection_name)
        self._collection = self._client.get_or_create_collection(
            name=self.collection_name,
            metadata=self._metadata,
        )
        self._vector_store = Chroma(
            client=self._client,
            collection_name=self.collection_name,
            embedding_function=self._embeddings,
            collection_metadata=self._metadata,
        )

    def get_stats(self) -> Dict[str, Any]:
        """Returns diagnostic statistics for the vector store."""
        return {
            "collection_name": self.collection_name,
            "total_chunks": self.count(),
            "persist_directory": str(self.persist_dir) if self.persist_dir else "in-memory",
            "distance_metric": self._metadata.get("hnsw:space", "cosine"),
        }


# =====================================================================
# CLI Runner & Observable Inspection Artifact Generator
# =====================================================================

if __name__ == "__main__":
    from datetime import datetime
    from app.ingestion.chunkers.metadata_enricher import enrich_split

    print("\n" + "=" * 65)
    print("CHROMADB FINANCIAL VECTOR STORE SELF-TEST (Step 3.2)")
    print("=" * 65)

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    # 1. Load sample chunks from existing ingestion artifact or create fallback
    tsla_artifact_path = artifact_dir / "03b_enriched_chunks_tsla_q2_2026_update.json"
    chunks_to_index: List[EnrichedChunk] = []

    if tsla_artifact_path.exists():
        print(f"📖 Loading real chunks from: {tsla_artifact_path.name}")
        with open(tsla_artifact_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            raw_chunks = data.get("chunks", [])
            for c in raw_chunks:
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
                text="Free cash flow = operating cash flow less capex. Free cash flow was $1,340 million in Q2 2026.",
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

    # 2. Initialize FinancialVectorStore
    from langchain_core.embeddings import FakeEmbeddings
    try:
        store = FinancialVectorStore()
        # Test connection with a quick ping
        store._embeddings.embed_query("test")
        print(f"🗄️ Initialized Chroma collection '{store.collection_name}' with OpenAI text-embedding-3-small (512-dim)")
    except Exception as e:
        print(f"⚠️ OpenAI API connection failed ({e}). Using deterministic FakeEmbeddings(size=512) for offline verification.")
        store = FinancialVectorStore(embeddings=FakeEmbeddings(size=512))

    # 3. Ingest chunks
    print(f"📥 Ingesting {len(chunks_to_index)} chunks into ChromaDB...")
    added_count = store.add_chunks(chunks_to_index)
    total_stored = store.count()
    print(f"✅ Successfully ingested {added_count} chunks. Total in collection: {total_stored}")

    # 4. Perform filtered similarity searches
    test_queries = [
        {
            "query": "free cash flow and capital expenditures",
            "filter": {"ticker": "TSLA", "financial_domain": "cash_flow"},
        },
        {
            "query": "automotive gross margin and revenue highlights",
            "filter": {"ticker": "TSLA", "financial_domain": "profitability"},
        },
    ]

    search_results = []
    print("\n🔍 Running Semantic Searches with Metadata Pre-Filtering:")
    for tq in test_queries:
        query_text = tq["query"]
        q_filter = tq["filter"]
        print(f"\n  • Query: '{query_text}' | Filter: {q_filter}")

        hits = store.similarity_search_with_scores(
            query=query_text,
            k=2,
            ticker=q_filter.get("ticker"),
            financial_domain=q_filter.get("financial_domain"),
        )

        hit_data = []
        for doc, score in hits:
            preview = doc.page_content.replace("\n", " ")[:120]
            print(f"    [Score: {score:.4f}] [Page {doc.metadata.get('page_number')}] {preview}...")
            hit_data.append({
                "chunk_id": doc.metadata.get("chunk_id"),
                "relevance_score": round(score, 4),
                "page_number": doc.metadata.get("page_number"),
                "domain": doc.metadata.get("financial_domain"),
                "content_preview": doc.page_content[:200],
            })

        search_results.append({
            "query": query_text,
            "filter": q_filter,
            "hits": hit_data,
        })

    # 5. Export observable inspection artifacts
    artifact_payload = {
        "timestamp": datetime.now().isoformat(),
        "vector_store_stats": store.get_stats(),
        "ingested_chunks_count": added_count,
        "sample_searches": search_results,
    }

    json_artifact = artifact_dir / "idx_02_vector_store_sample.json"
    with open(json_artifact, "w", encoding="utf-8") as f:
        json.dump(artifact_payload, f, indent=2)

    md_artifact = artifact_dir / "idx_02_vector_store_sample.md"
    with open(md_artifact, "w", encoding="utf-8") as f:
        f.write("# ChromaDB Vector Store Sample Artifact (`idx_02`)\n\n")
        f.write(f"- **Generated At**: `{artifact_payload['timestamp']}`\n")
        f.write(f"- **Collection Name**: `{store.collection_name}`\n")
        f.write(f"- **Total Chunks Indexed**: `{total_stored}`\n")
        f.write(f"- **Distance Metric**: `{store.get_stats()['distance_metric']}`\n")
        f.write(f"- **Storage Path**: `{store.persist_dir}`\n\n")
        f.write("## 🔍 Sample Filtered Searches\n\n")
        for sr in search_results:
            f.write(f"### Query: *\"{sr['query']}\"*\n")
            f.write(f"- **Filter**: `{sr['filter']}`\n")
            f.write("| Score | Chunk ID | Page | Domain | Preview |\n")
            f.write("| :--- | :--- | :--- | :--- | :--- |\n")
            for h in sr["hits"]:
                preview = h["content_preview"].replace("\n", " ")
                f.write(f"| {h['relevance_score']} | `{h['chunk_id']}` | {h['page_number']} | `{h['domain']}` | {preview[:80]}... |\n")
            f.write("\n")

    print(f"\n📦 Artifacts created:")
    print(f"  • {json_artifact.relative_to(_SERVER_ROOT)}")
    print(f"  • {md_artifact.relative_to(_SERVER_ROOT)}")
    print("=" * 65 + "\n")
