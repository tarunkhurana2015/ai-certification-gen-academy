"""
Unit tests for Financial Retrieval Tools.
Tests deterministic SQL KPI lookup, Hybrid RAG search, peer comparison, and time-series tools.
Runs 100% in-memory without external network dependencies.
"""

import os
import sys
import tempfile
from pathlib import Path

# Disable LangSmith tracing to guarantee zero network calls
os.environ["LANGCHAIN_TRACING_V2"] = "false"

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from langchain_core.documents import Document

from app.ingestion.indexing.bm25_index import BM25Index
from app.retrieval.hybrid_engine import HybridEngine
from app.retrieval.tools import (
    ANALYST_TOOLS,
    compare_tickers,
    get_kpis,
    get_time_series,
    save_tools_artifact,
    search_filings,
)


def test_analyst_tools_bundle():
    """Validates that ANALYST_TOOLS contains all 4 expected tools."""
    tool_names = [t.name for t in ANALYST_TOOLS]
    assert "get_kpis" in tool_names
    assert "search_filings" in tool_names
    assert "compare_tickers" in tool_names
    assert "get_time_series" in tool_names
    assert len(ANALYST_TOOLS) == 4


def test_get_kpis_tool():
    """Validates deterministic retrieval of exact GAAP KPIs for TSLA."""
    res = get_kpis.invoke({"ticker": "TSLA", "fiscal_quarter": "Q2", "fiscal_year": 2026})
    assert res.get("ticker") == "TSLA"
    assert res.get("fiscal_quarter") == "Q2"
    assert res.get("fiscal_year") == 2026
    assert "revenue" in res
    assert "gross_margin" in res
    assert "operating_income" in res
    assert "free_cash_flow" in res


def test_get_kpis_missing_ticker():
    """Validates helpful error response when ticker is not in database."""
    res = get_kpis.invoke({"ticker": "NONEXISTENT", "fiscal_quarter": "Q1", "fiscal_year": 2026})
    assert "error" in res
    assert "NONEXISTENT" in res["error"]


def test_get_kpis_default_latest():
    """Validates retrieval of latest reported quarter when quarter/year omitted."""
    res = get_kpis.invoke({"ticker": "TSLA"})
    assert res.get("ticker") == "TSLA"
    assert "revenue" in res


def test_search_filings_tool():
    """Validates hybrid filing search and audit citation formatting."""
    res = search_filings.invoke({"query": "gross margin decline", "ticker": "TSLA", "k": 3})
    assert isinstance(res, list)
    if res:
        first = res[0]
        assert "citation" in first
        assert "Page -" in first["citation"]
        assert "Section -" in first["citation"]
        assert "text" in first
        assert first.get("ticker") == "TSLA"


def test_compare_tickers_tool():
    """Validates cross-company peer comparison."""
    res = compare_tickers.invoke({
        "tickers": ["META", "TSLA"],
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
    })
    assert "companies" in res
    assert "META" in res["companies"]
    assert "TSLA" in res["companies"]
    assert res["companies"]["META"]["revenue"] is not None
    assert res["companies"]["TSLA"]["revenue"] is not None


def test_compare_tickers_empty():
    """Validates error message when no valid tickers are passed."""
    res = compare_tickers.invoke({"tickers": []})
    assert "error" in res


def test_get_time_series_tool():
    """Validates chronological time-series retrieval for trend charts."""
    res = get_time_series.invoke({"ticker": "TSLA", "limit": 4})
    assert isinstance(res, list)
    if len(res) > 1:
        # Check chronological ordering (earliest first)
        for i in range(len(res) - 1):
            t1 = (res[i]["fiscal_year"], res[i]["fiscal_quarter"])
            t2 = (res[i + 1]["fiscal_year"], res[i + 1]["fiscal_quarter"])
            assert t1 <= t2


def test_save_tools_artifact():
    """Validates markdown artifact generation."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        art_path = Path(tmp_dir) / "test_artifact.md"
        saved = save_tools_artifact(
            kpi_sample={"ticker": "TSLA", "revenue": 25500.0, "gross_margin": 0.17},
            rag_sample=[{"citation": "[Page - 4, Section - Profitability]", "chunk_id": "c1", "text": "sample"}],
            compare_sample={"fiscal_period": "Q2 2026", "companies": {"TSLA": {"revenue": 25500.0}}},
            output_path=art_path,
        )
        assert saved.exists()
        content = saved.read_text(encoding="utf-8")
        assert "Financial Analyst Tools Artifact (`agent_01`)" in content
        assert "TSLA" in content
        assert "[Page - 4, Section - Profitability]" in content


def test_modular_tool_imports():
    """Validates that tools can be imported directly from app.retrieval.tools."""
    from app.retrieval.tools.sql_tool import get_kpis as sql_get_kpis, get_time_series as sql_get_time_series
    from app.retrieval.tools.rag_tool import search_filings as rag_search_filings, get_default_engine
    from app.retrieval.tools.comparison_tool import compare_tickers as comp_tool
    from app.retrieval.tools.comparasion_tool import compare_tickers as comp_alias_tool

    assert sql_get_kpis.name == "get_kpis"
    assert sql_get_time_series.name == "get_time_series"
    assert rag_search_filings.name == "search_filings"
    assert comp_tool.name == "compare_tickers"
    assert comp_alias_tool.name == "compare_tickers"
    assert callable(get_default_engine)


if __name__ == "__main__":
    print("\nRunning test_tools.py...")
    test_analyst_tools_bundle()
    print("  ✓ test_analyst_tools_bundle passed")

    test_modular_tool_imports()
    print("  ✓ test_modular_tool_imports passed")

    test_get_kpis_tool()
    print("  ✓ test_get_kpis_tool passed")

    test_get_kpis_missing_ticker()
    print("  ✓ test_get_kpis_missing_ticker passed")

    test_get_kpis_default_latest()
    print("  ✓ test_get_kpis_default_latest passed")

    test_search_filings_tool()
    print("  ✓ test_search_filings_tool passed")

    test_compare_tickers_tool()
    print("  ✓ test_compare_tickers_tool passed")

    test_compare_tickers_empty()
    print("  ✓ test_compare_tickers_empty passed")

    test_get_time_series_tool()
    print("  ✓ test_get_time_series_tool passed")

    test_save_tools_artifact()
    print("  ✓ test_save_tools_artifact passed")

    print("\nAll 10 retrieval tools unit tests passed successfully!\n")
