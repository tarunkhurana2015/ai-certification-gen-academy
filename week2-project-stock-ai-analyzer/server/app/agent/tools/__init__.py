"""
Financial Analyst Tools Package - Phase 5.1.

Exports:
- sql_tool: get_kpis, get_time_series
- rag_tool: search_filings, get_default_engine
- comparison_tool: compare_tickers
- ANALYST_TOOLS: standard bundle of all 4 tools
- save_tools_artifact: artifact exporter
"""

import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.agent.tools.comparison_tool import compare_tickers
from app.agent.tools.rag_tool import get_default_engine, search_filings
from app.agent.tools.sql_tool import get_kpis, get_time_series

DEFAULT_ARTIFACT_PATH = (
    Path(__file__).resolve().parent.parent.parent.parent / ".artifact" / "agent_01_tools_sample.md"
)

# Standard bundle of all analyst tools for LangGraph / ReAct agent
ANALYST_TOOLS = [get_kpis, search_filings, compare_tickers, get_time_series]


def save_tools_artifact(
    kpi_sample: Dict[str, Any],
    rag_sample: List[Dict[str, Any]],
    compare_sample: Dict[str, Any],
    output_path: Optional[Path] = None,
) -> Path:
    """Saves tool invocation verification report to markdown artifact."""
    target_path = output_path or DEFAULT_ARTIFACT_PATH
    target_path.parent.mkdir(parents=True, exist_ok=True)

    lines = [
        "# 🛠️ Financial Analyst Tools Artifact (`agent_01`)",
        "",
        f"- **Generated At**: `{datetime.now().isoformat()}`",
        f"- **Tool Suite**: Financial Analyst Tools (Modular Structure)",
        f"- **Available Tools**: `{', '.join([t.name for t in ANALYST_TOOLS])}`",
        "",
        "## 1. Deterministic SQL KPI Tool Sample (`get_kpis` via `tools/sql_tool.py`)",
        "",
        f"- **Ticker**: `{kpi_sample.get('ticker')}` ({kpi_sample.get('fiscal_quarter')} {kpi_sample.get('fiscal_year')})",
        f"- **Total Revenue**: `${kpi_sample.get('revenue', 0):,.1f}M`",
        f"- **Gross Profit**: `${kpi_sample.get('gross_profit', 0):,.1f}M` (Margin: `{kpi_sample.get('gross_margin', 0)*100:.1f}%`)",
        f"- **Operating Income**: `${kpi_sample.get('operating_income', 0):,.1f}M` (Margin: `{kpi_sample.get('operating_margin', 0)*100:.1f}%`)",
        f"- **Net Income**: `${kpi_sample.get('net_income', 0):,.1f}M`",
        f"- **Free Cash Flow**: `${kpi_sample.get('free_cash_flow', 0):,.1f}M`",
        f"- **Cash & Equivalents**: `${kpi_sample.get('cash_and_equivalents', 0):,.1f}M`",
        "",
        "## 2. Hybrid RAG Filing Search Tool Sample (`search_filings` via `tools/rag_tool.py`)",
        "",
        f"- **Total Chunks Retrieved**: `{len(rag_sample)}`",
    ]

    for i, chunk in enumerate(rag_sample[:2], 1):
        lines.append(f"### Chunk {i}: {chunk.get('citation')} (`{chunk.get('chunk_id')}`)")
        snippet = chunk.get("text", "")[:250].replace("\n", " ")
        lines.append(f"> {snippet}...")
        lines.append("")

    lines.extend(
        [
            "## 3. Peer Comparison Tool Sample (`compare_tickers` via `tools/comparison_tool.py`)",
            "",
            f"- **Fiscal Period**: `{compare_sample.get('fiscal_period')}`",
            f"- **Companies Compared**: `{', '.join(compare_sample.get('companies', {}).keys())}`",
            "",
            "| Company | Revenue | Operating Income | Free Cash Flow | Cash & Equiv |",
            "| :--- | :--- | :--- | :--- | :--- |",
        ]
    )

    for ticker, data in compare_sample.get("companies", {}).items():
        lines.append(
            f"| **{ticker}** | `${data.get('revenue', 0):,.1f}M` | `${data.get('operating_income', 0):,.1f}M` | `${data.get('free_cash_flow', 0):,.1f}M` | `${data.get('cash_and_equivalents', 0):,.1f}M` |"
        )

    lines.append("")
    content = "\n".join(lines)
    with open(target_path, "w", encoding="utf-8") as f:
        f.write(content)

    return target_path


if __name__ == "__main__":
    print("\n--- Running Financial Analyst Tools Self-Test ---")

    # 1. Test get_kpis
    kpi_res = get_kpis.invoke({"ticker": "TSLA", "fiscal_quarter": "Q2", "fiscal_year": 2026})
    print(f"1. get_kpis (TSLA Q2 2026): Revenue=${kpi_res.get('revenue')}M, FCF=${kpi_res.get('free_cash_flow')}M")

    # 2. Test search_filings
    rag_res = search_filings.invoke({"query": "gross margin automotive decline", "ticker": "TSLA", "k": 2})
    print(f"2. search_filings (TSLA): Retrieved {len(rag_res)} chunks with citations")
    for r in rag_res:
        print(f"   -> {r.get('citation')} (Chunk ID: {r.get('chunk_id')})")

    # 3. Test compare_tickers
    comp_res = compare_tickers.invoke({"tickers": ["META", "TSLA"], "fiscal_quarter": "Q2", "fiscal_year": 2026})
    print(f"3. compare_tickers: Compared {list(comp_res.get('companies', {}).keys())}")

    # 4. Save artifact
    art = save_tools_artifact(kpi_sample=kpi_res, rag_sample=rag_res, compare_sample=comp_res)
    print(f"Saved tools artifact to {art}\n")


__all__ = [
    "get_kpis",
    "get_time_series",
    "search_filings",
    "get_default_engine",
    "compare_tickers",
    "ANALYST_TOOLS",
    "save_tools_artifact",
]
