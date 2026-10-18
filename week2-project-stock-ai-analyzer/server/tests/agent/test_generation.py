"""
Unit tests for Financial Generation Module (Phase 5.2).
Tests synthesize_sql_kpi, synthesize_hybrid_rag, and synthesize_comparison.
Runs 100% in-memory without external network dependencies.
"""

import os
import sys
from pathlib import Path

# Disable LangSmith tracing during tests
os.environ["LANGCHAIN_TRACING_V2"] = "false"

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.agent.generation import (
    synthesize_comparison,
    synthesize_hybrid_rag,
    synthesize_sql_kpi,
)


def test_synthesize_sql_kpi_deterministic():
    """Validates deterministic formatting of audited GAAP KPIs."""
    kpis = {
        "ticker": "TSLA",
        "fiscal_quarter": "Q2",
        "fiscal_year": 2026,
        "revenue": 28236.0,
        "gross_profit": 5000.0,
        "gross_margin": 0.177,
        "operating_income": 2000.0,
        "operating_margin": 0.071,
        "net_income": 1500.0,
        "free_cash_flow": 1200.0,
        "cash_and_equivalents": 30000.0,
    }
    result = synthesize_sql_kpi(
        query="What was Tesla Q2 2026 revenue and free cash flow?",
        ticker="TSLA",
        kpis=kpis,
        mock=True,
    )
    assert "TSLA" in result
    assert "28,236.0M" in result
    assert "1,200.0M" in result
    assert "Audited SQLite Record" in result


def test_synthesize_sql_kpi_error():
    """Validates error message handling when KPI record missing."""
    kpis = {"error": "No audited financial KPIs found for FOO."}
    result = synthesize_sql_kpi(
        query="What was FOO revenue?",
        ticker="FOO",
        kpis=kpis,
        mock=True,
    )
    assert "**Data Notice**" in result
    assert "No audited financial KPIs found" in result


def test_synthesize_hybrid_rag_deterministic():
    """Validates deterministic formatting of narrative filing citations."""
    chunks = [
        {
            "citation": "[Page - 4, Section - Profitability]",
            "chunk_id": "chunk_101",
            "text": "Automotive gross margin declined due to reduced average selling price.",
        },
        {
            "citation": "[Page - 8, Section - Risk Factors]",
            "chunk_id": "chunk_102",
            "text": "Competition in the electric vehicle market intensified significantly.",
        },
    ]
    result = synthesize_hybrid_rag(
        query="Why did automotive gross margin decline?",
        chunks=chunks,
        mock=True,
    )
    assert "[Page - 4, Section - Profitability]" in result
    assert "[Page - 8, Section - Risk Factors]" in result
    assert "Automotive gross margin declined" in result


def test_synthesize_hybrid_rag_empty():
    """Validates fallback message when no chunks retrieved."""
    result = synthesize_hybrid_rag(
        query="Random unindexed question",
        chunks=[],
        mock=True,
    )
    assert "No relevant narrative sections were found" in result


def test_synthesize_comparison():
    """Validates peer comparison markdown table generation."""
    comp_data = {
        "fiscal_period": "Q2 2026",
        "companies": {
            "META": {
                "revenue": 39071.0,
                "gross_margin": 0.81,
                "operating_margin": 0.38,
                "net_income": 13465.0,
                "free_cash_flow": 13200.0,
                "cash_and_equivalents": 58000.0,
            },
            "TSLA": {
                "revenue": 28236.0,
                "gross_margin": 0.177,
                "operating_margin": 0.071,
                "net_income": 1500.0,
                "free_cash_flow": 1200.0,
                "cash_and_equivalents": 30000.0,
            },
        },
    }
    result = synthesize_comparison(
        query="Compare Meta and Tesla operating margins",
        comp_data=comp_data,
        mock=True,
    )
    assert "| Metric |" in result
    assert "**META**" in result
    assert "**TSLA**" in result
    assert "39,071.0M" in result
    assert "28,236.0M" in result
    assert "Peer Comparison Summary (Q2 2026)" in result


def test_synthesize_comparison_empty():
    """Validates comparison fallback when companies dict is empty."""
    result = synthesize_comparison(
        query="Compare nothing",
        comp_data={"fiscal_period": "Q2 2026", "companies": {}},
        mock=True,
    )
    assert "No comparison data found" in result


if __name__ == "__main__":
    print("\nRunning test_generation.py...")
    test_synthesize_sql_kpi_deterministic()
    print("  ✓ test_synthesize_sql_kpi_deterministic passed")

    test_synthesize_sql_kpi_error()
    print("  ✓ test_synthesize_sql_kpi_error passed")

    test_synthesize_hybrid_rag_deterministic()
    print("  ✓ test_synthesize_hybrid_rag_deterministic passed")

    test_synthesize_hybrid_rag_empty()
    print("  ✓ test_synthesize_hybrid_rag_empty passed")

    test_synthesize_comparison()
    print("  ✓ test_synthesize_comparison passed")

    test_synthesize_comparison_empty()
    print("  ✓ test_synthesize_comparison_empty passed")

    print("\nAll 6 generation unit tests passed successfully!\n")
