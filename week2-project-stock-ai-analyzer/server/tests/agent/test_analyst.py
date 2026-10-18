"""
Unit tests for Financial Analyst Router & Synthesizer (Option 2).
Tests SQL KPI routing, Hybrid RAG routing, Peer Comparison routing, and citation grounding.
Runs 100% in-memory without external network dependencies.
"""

import os
import sys
import tempfile
from pathlib import Path

# Disable LangSmith tracing during tests to guarantee zero network calls
os.environ["LANGCHAIN_TRACING_V2"] = "false"

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.agent.analyst import (
    AnalystResponse,
    run_analyst,
    save_analyst_artifact,
)


def test_analyst_response_model():
    """Validates schema structure of AnalystResponse."""
    resp = AnalystResponse(
        query="What is Tesla revenue?",
        route_used="sql_kpi",
        answer="Tesla revenue was $28,236.0M.",
        citations=[{"page_number": 4, "citation": "[Page - 4, Section - Profitability]"}],
        ticker="TSLA",
        financial_domain="profitability",
    )
    assert resp.route_used == "sql_kpi"
    assert resp.ticker == "TSLA"
    assert len(resp.citations) == 1
    assert "28,236.0M" in resp.answer


def test_analyst_sql_route():
    """Validates that quantitative queries route to SQL KPI tool."""
    query = "What was Tesla Q2 2026 revenue and free cash flow?"
    resp = run_analyst(query, mock=True)

    assert resp.route_used == "sql_kpi"
    assert resp.ticker == "TSLA"
    assert "TSLA" in resp.answer
    assert "Revenue" in resp.answer
    assert resp.raw_data is not None


def test_analyst_hybrid_rag_route():
    """Validates that qualitative narrative queries route to Hybrid RAG tool."""
    query = "Why did automotive gross margin decline sequentially in Q2 2026?"
    resp = run_analyst(query, mock=True)

    assert resp.route_used == "hybrid_rag"
    assert resp.financial_domain == "profitability"
    assert resp.ticker == "TSLA"
    assert len(resp.citations) > 0
    # Every chunk citation must adhere to [Page - X, Section - Y] format
    for c in resp.citations:
        assert "citation" in c
        assert "Page -" in c["citation"]


def test_analyst_comparison_route():
    """Validates that cross-company comparison queries route to Comparison tool."""
    query = "Compare Meta and Tesla operating margins over the last year"
    resp = run_analyst(query, mock=True)

    assert resp.route_used == "comparison"
    assert resp.ticker == "multiple"
    assert "META" in resp.answer
    assert "TSLA" in resp.answer
    assert "|" in resp.answer  # Markdown table format


def test_save_analyst_artifact():
    """Validates markdown artifact generation."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        art_path = Path(tmp_dir) / "test_artifact.md"
        sample_responses = [
            AnalystResponse(
                query="What was Tesla revenue?",
                route_used="sql_kpi",
                answer="Tesla reported $28,236.0M in revenue.",
                citations=[{"citation": "[Page - 4]", "chunk_id": "c1"}],
                ticker="TSLA",
                financial_domain="profitability",
            )
        ]
        saved = save_analyst_artifact(sample_responses, output_path=art_path)
        assert saved.exists()
        content = saved.read_text(encoding="utf-8")
        assert "Financial Analyst Intent Router Artifact (`agent_02`)" in content
        assert "SQL_KPI" in content
        assert "Tesla reported $28,236.0M" in content


if __name__ == "__main__":
    print("\nRunning test_analyst.py...")
    test_analyst_response_model()
    print("  ✓ test_analyst_response_model passed")

    test_analyst_sql_route()
    print("  ✓ test_analyst_sql_route passed")

    test_analyst_hybrid_rag_route()
    print("  ✓ test_analyst_hybrid_rag_route passed")

    test_analyst_comparison_route()
    print("  ✓ test_analyst_comparison_route passed")

    test_save_analyst_artifact()
    print("  ✓ test_save_analyst_artifact passed")

    print("\nAll 5 analyst router unit tests passed successfully!\n")
