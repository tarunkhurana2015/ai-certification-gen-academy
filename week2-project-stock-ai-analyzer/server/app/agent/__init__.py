"""Financial Analyst Agent package."""

from app.agent.analyst import (
    AnalystResponse,
    run_analyst,
    save_analyst_artifact,
)
from app.agent.generation import (
    synthesize_comparison,
    synthesize_hybrid_rag,
    synthesize_sql_kpi,
)
from app.agent.tools import (
    ANALYST_TOOLS,
    compare_tickers,
    get_kpis,
    get_time_series,
    save_tools_artifact,
    search_filings,
)

__all__ = [
    "ANALYST_TOOLS",
    "get_kpis",
    "search_filings",
    "compare_tickers",
    "get_time_series",
    "save_tools_artifact",
    "synthesize_sql_kpi",
    "synthesize_hybrid_rag",
    "synthesize_comparison",
    "AnalystResponse",
    "run_analyst",
    "save_analyst_artifact",
]
