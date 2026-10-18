"""
Unit Tests for OpenAI Embeddings Factory Module.

Conforms to ARCHITECTURE.md Section 8 (tests/indexing/test_embeddings.py).
Tests get_embeddings_model initialization, dimension configuration,
cosine similarity computation, and mock vector generation with zero disk side effects.
"""

import math
import os
import sys
from pathlib import Path
from unittest.mock import MagicMock, patch

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.indexing.embeddings import (
    DEFAULT_EMBEDDING_DIMENSIONS,
    DEFAULT_EMBEDDING_MODEL,
    compute_cosine_similarity,
    get_embeddings_model,
)


def test_get_embeddings_model_defaults():
    """Verify default embedding model and dimensions match architecture spec."""
    print("Testing get_embeddings_model defaults...")
    model = get_embeddings_model(api_key="sk-test-key-12345")
    assert model.model == DEFAULT_EMBEDDING_MODEL
    assert model.dimensions == DEFAULT_EMBEDDING_DIMENSIONS
    assert model.dimensions == 512
    print("✅ Model defaults to text-embedding-3-small and 512 dimensions.")


def test_get_embeddings_model_custom_dimensions():
    """Verify custom dimensionality is properly configured."""
    print("Testing get_embeddings_model with custom dimensions...")
    model = get_embeddings_model(dimensions=256, api_key="sk-test-key-12345")
    assert model.dimensions == 256
    print("✅ Custom dimensions (256) accepted properly.")


def test_get_embeddings_model_missing_key():
    """Verify ValueError is raised when no API key is provided or present in environment."""
    print("Testing missing API key raises ValueError...")
    with patch.dict(os.environ, {}, clear=True):
        os.environ.pop("OPENAI_API_KEY", None)
        try:
            get_embeddings_model(api_key=None)
            assert False, "Should have raised ValueError"
        except ValueError as e:
            assert "OPENAI_API_KEY is not set" in str(e)
    print("✅ Missing API key error handled cleanly.")


def test_compute_cosine_similarity():
    """Verify mathematical properties of cosine similarity."""
    print("Testing cosine similarity calculation...")
    # 1. Identical vectors -> 1.0
    v1 = [1.0, 2.0, 3.0]
    v2 = [1.0, 2.0, 3.0]
    sim = compute_cosine_similarity(v1, v2)
    assert math.isclose(sim, 1.0, rel_tol=1e-5)

    # 2. Orthogonal vectors -> 0.0
    v_orth1 = [1.0, 0.0]
    v_orth2 = [0.0, 1.0]
    sim_orth = compute_cosine_similarity(v_orth1, v_orth2)
    assert math.isclose(sim_orth, 0.0, abs_tol=1e-5)

    # 3. Opposite vectors -> -1.0
    v_opp1 = [1.0, 0.0]
    v_opp2 = [-1.0, 0.0]
    sim_opp = compute_cosine_similarity(v_opp1, v_opp2)
    assert math.isclose(sim_opp, -1.0, rel_tol=1e-5)

    # 4. Zero vector -> 0.0 without divide by zero
    v_zero = [0.0, 0.0]
    assert compute_cosine_similarity(v_zero, v1[:2]) == 0.0

    # 5. Dimension mismatch raises ValueError
    try:
        compute_cosine_similarity([1.0, 2.0], [1.0, 2.0, 3.0])
        assert False, "Should have raised ValueError"
    except ValueError as e:
        assert "mismatch" in str(e)

    print("✅ Cosine similarity math properties verified.")


@patch("app.indexing.embeddings.OpenAIEmbeddings")
def test_mock_embed_query_and_documents(mock_embeddings_class):
    """Verify embed_query and embed_documents work through the instantiated model."""
    print("Testing embed_query and embed_documents with mock vectors...")
    mock_instance = MagicMock()
    mock_instance.embed_query.return_value = [0.1] * 512
    mock_instance.embed_documents.return_value = [[0.1] * 512, [0.2] * 512]
    mock_embeddings_class.return_value = mock_instance

    embedder = get_embeddings_model(api_key="sk-mock-key")
    query_vec = embedder.embed_query("Tesla Q2 Free Cash Flow")
    assert len(query_vec) == 512

    docs_vec = embedder.embed_documents(["Chunk 1 text", "Chunk 2 text"])
    assert len(docs_vec) == 2
    assert len(docs_vec[0]) == 512
    assert len(docs_vec[1]) == 512
    print("✅ Embed query and embed documents mocked vectors verified.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("RUNNING OPENAI EMBEDDINGS FACTORY TESTS")
    print("=" * 60)

    test_get_embeddings_model_defaults()
    test_get_embeddings_model_custom_dimensions()
    test_get_embeddings_model_missing_key()
    test_compute_cosine_similarity()
    test_mock_embed_query_and_documents()

    print("\n" + "=" * 60)
    print("ALL OPENAI EMBEDDINGS TESTS PASSED! ✅")
    print("=" * 60)
