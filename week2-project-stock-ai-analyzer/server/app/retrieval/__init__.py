"""
Retrieval Package.

Simple Hybrid RAG retrieval engine powered by LangChain EnsembleRetriever.
Directly matches week2-rag/3_hybrid_rag.ipynb.
"""

from app.retrieval.hybrid_engine import HybridEngine, create_ensemble_retriever

__all__ = ["HybridEngine", "create_ensemble_retriever"]
