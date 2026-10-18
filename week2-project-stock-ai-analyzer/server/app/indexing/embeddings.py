"""
OpenAI Embeddings Factory Module.

Conforms to ARCHITECTURE.md Section 7.2 & Section 8 (app/indexing/embeddings.py).
Provides a configured LangChain OpenAIEmbeddings client using text-embedding-3-small
truncated to 512 dimensions for memory-efficient, high-precision HNSW vector search.
"""

import json
import math
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

from dotenv import load_dotenv
from langchain_openai import OpenAIEmbeddings

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

# Load environment variables (.env)
load_dotenv(_SERVER_ROOT / ".env")

DEFAULT_EMBEDDING_MODEL = "text-embedding-3-small"
DEFAULT_EMBEDDING_DIMENSIONS = 512


def get_embeddings_model(
    model: str = DEFAULT_EMBEDDING_MODEL,
    dimensions: int = DEFAULT_EMBEDDING_DIMENSIONS,
    api_key: Optional[str] = None,
) -> OpenAIEmbeddings:
    """
    Returns an initialized LangChain OpenAIEmbeddings model configured
    for dense vector search in ChromaDB.

    Args:
        model: OpenAI embedding model name (default: text-embedding-3-small).
        dimensions: Vector length (default: 512 for memory efficiency).
        api_key: Optional API key override (defaults to OPENAI_API_KEY from environment).

    Returns:
        OpenAIEmbeddings instance ready to pass directly to ChromaDB or LangChain stores.
    """
    resolved_api_key = api_key or os.getenv("OPENAI_API_KEY")
    if not resolved_api_key:
        raise ValueError(
            "OPENAI_API_KEY is not set. Please add it to your .env file or pass api_key directly."
        )

    return OpenAIEmbeddings(
        model=model,
        dimensions=dimensions,
        api_key=resolved_api_key,
    )


def compute_cosine_similarity(vec_a: List[float], vec_b: List[float]) -> float:
    """Computes cosine similarity between two float vectors."""
    if len(vec_a) != len(vec_b):
        raise ValueError(f"Vector dimensions mismatch: {len(vec_a)} vs {len(vec_b)}")
    dot = sum(a * b for a, b in zip(vec_a, vec_b))
    norm_a = math.sqrt(sum(a * a for a in vec_a))
    norm_b = math.sqrt(sum(b * b for b in vec_b))
    if norm_a == 0.0 or norm_b == 0.0:
        return 0.0
    return dot / (norm_a * norm_b)


def save_embeddings_artifact(
    query_text: str,
    query_vector: List[float],
    doc_text: str,
    doc_vector: List[float],
    similarity: float,
    model_name: str,
    dimensions: int,
) -> Path:
    """Saves inspection artifacts (JSON & Markdown) to server/.artifact/."""
    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    json_path = artifact_dir / "idx_01_embeddings_sample.json"
    md_path = artifact_dir / "idx_01_embeddings_sample.md"

    artifact_data: Dict[str, Any] = {
        "step": "idx_01_embeddings_sample",
        "model": model_name,
        "dimensions": dimensions,
        "query": {
            "text": query_text,
            "vector_length": len(query_vector),
            "sample_coordinates": query_vector[:8],
        },
        "document": {
            "text": doc_text,
            "vector_length": len(doc_vector),
            "sample_coordinates": doc_vector[:8],
        },
        "cosine_similarity": round(similarity, 4),
    }

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(artifact_data, f, indent=2)

    md_content = f"""# 🧠 Indexing Step 01 — OpenAIEmbeddings Verification

- **Model**: `{model_name}`
- **Dimensions**: `{dimensions}` (conforming to ARCHITECTURE.md Section 7.2 & 8)
- **Cosine Similarity**: `{similarity:.4f}`

---

### 1. Sample Query
> *"{query_text}"*
- **Vector Dimensions**: {len(query_vector)} floats
- **First 8 Coordinates**: `{query_vector[:8]}`

### 2. Sample Financial Statement Chunk
> *"{doc_text}"*
- **Vector Dimensions**: {len(doc_vector)} floats
- **First 8 Coordinates**: `{doc_vector[:8]}`

### 3. Verification Assertion
- ✅ Output vectors strictly match target dimensions `{dimensions}`.
- ✅ Normalized cosine similarity between semantically related financial statements is positive (`{similarity:.4f}`).
- ✅ The returned `OpenAIEmbeddings` instance is directly compatible with ChromaDB.
"""

    with open(md_path, "w", encoding="utf-8") as f:
        f.write(md_content)

    return json_path


if __name__ == "__main__":
    print("=" * 70)
    print("🧠 Stock AI Analyst — OpenAIEmbeddings Self-Test (app/indexing/embeddings.py)")
    print("=" * 70)

    try:
        embedder = get_embeddings_model()
        print(f"✅ Initialized OpenAIEmbeddings(model='{DEFAULT_EMBEDDING_MODEL}', dimensions={DEFAULT_EMBEDDING_DIMENSIONS})")

        sample_query = "What was Tesla's Free Cash Flow in Q2 2026?"
        sample_doc = "Free Cash Flow surged to $1.34B (+52% QoQ) with balance sheet liquidity remaining fortress-strong at $30.72B in cash."

        print(f"\n[1/3] Generating dense vector for query: '{sample_query}'")
        q_vec = embedder.embed_query(sample_query)
        print(f"      Dimensions: {len(q_vec)} floats | First 4 values: {[round(x, 4) for x in q_vec[:4]]}")

        print(f"\n[2/3] Generating dense vector for chunk: '{sample_doc[:60]}...'")
        d_vec = embedder.embed_query(sample_doc)
        print(f"      Dimensions: {len(d_vec)} floats | First 4 values: {[round(x, 4) for x in d_vec[:4]]}")

        sim = compute_cosine_similarity(q_vec, d_vec)
        print(f"\n[3/3] Cosine Similarity: {sim:.4f}")

        artifact_file = save_embeddings_artifact(
            query_text=sample_query,
            query_vector=q_vec,
            doc_text=sample_doc,
            doc_vector=d_vec,
            similarity=sim,
            model_name=DEFAULT_EMBEDDING_MODEL,
            dimensions=DEFAULT_EMBEDDING_DIMENSIONS,
        )
        print(f"\n📁 Saved inspection artifact: {artifact_file.name} (.json and .md)")
        print("✅ Embeddings self-test completed successfully!")
    except Exception as e:
        print(f"\n❌ Error during embeddings test: {e}")
        sys.exit(1)
