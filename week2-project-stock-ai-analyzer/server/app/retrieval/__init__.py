"""
Retrieval Package.

Contains:
- hybrid_engine: HybridEngine, create_ensemble_retriever
- retrieval: run_analyst, run_retrieval, AnalystResponse, RetrievalResponse, save_analyst_artifact
- tools: get_kpis, search_filings, compare_tickers, get_time_series, ANALYST_TOOLS
"""

from app.retrieval.classifier import (
    QueryClassification,
    classify_query,
    get_jev_questions,
)
from app.retrieval.hybrid_engine import HybridEngine, create_ensemble_retriever
from app.retrieval.retrieval import (
    AnalystResponse,
    RetrievalResponse,
    run_analyst,
    run_retrieval,
    save_analyst_artifact,
    save_retrieval_artifact,
)
from app.retrieval.tools import (
    ANALYST_TOOLS,
    compare_tickers,
    get_kpis,
    get_time_series,
    save_tools_artifact,
    search_filings,
)

__all__ = [
    "QueryClassification",
    "classify_query",
    "get_jev_questions",
    "HybridEngine",
    "create_ensemble_retriever",
    "AnalystResponse",
    "RetrievalResponse",
    "run_analyst",
    "run_retrieval",
    "save_analyst_artifact",
    "save_retrieval_artifact",
    "get_kpis",
    "search_filings",
    "compare_tickers",
    "get_time_series",
    "ANALYST_TOOLS",
    "save_tools_artifact",
]
