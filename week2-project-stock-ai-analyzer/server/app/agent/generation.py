"""
Financial Response Generation Module - Phase 5.2.

Provides dedicated response generation and synthesis functions:
1. synthesize_sql_kpi: Formats exact audited GAAP numbers into professional equity analyst summaries.
2. synthesize_hybrid_rag: Synthesizes retrieved filing sections with grounded inline [Page - X, Section - Y] citations.
3. synthesize_comparison: Builds side-by-side comparative markdown tables and executive takeaways across peer companies.
"""

import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

from dotenv import load_dotenv

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

load_dotenv()


def _get_llm():
    """Lazily instantiate ChatOpenAI if API key exists."""
    if not os.getenv("OPENAI_API_KEY"):
        return None
    try:
        from langchain_openai import ChatOpenAI

        return ChatOpenAI(model="gpt-4o-mini", temperature=0.0)
    except Exception:
        return None


def synthesize_sql_kpi(query: str, ticker: str, kpis: Dict[str, Any], mock: bool = False) -> str:
    """Synthesizes exact quantitative figures into an audited analyst response."""
    if "error" in kpis:
        return f"**Data Notice**: {kpis['error']}"

    quarter = kpis.get("fiscal_quarter", "Q2")
    year = kpis.get("fiscal_year", 2026)
    rev = kpis.get("revenue")
    gross_prof = kpis.get("gross_profit")
    gross_mgn = kpis.get("gross_margin")
    op_inc = kpis.get("operating_income")
    op_mgn = kpis.get("operating_margin")
    net_inc = kpis.get("net_income")
    fcf = kpis.get("free_cash_flow")
    cash = kpis.get("cash_and_equivalents")
    debt = kpis.get("long_term_debt")

    llm = None if mock else _get_llm()
    if llm:
        try:
            from langchain_core.messages import HumanMessage, SystemMessage

            prompt = (
                f"User Question: {query}\n\n"
                f"Audited Financial Data for {ticker} ({quarter} {year}):\n"
                f"- Total Revenue: ${rev:,.1f}M\n"
                f"- Gross Profit: ${gross_prof:,.1f}M (Gross Margin: {gross_mgn*100:.1f}%)\n"
                f"- Operating Income: ${op_inc:,.1f}M (Operating Margin: {op_mgn*100:.1f}%)\n"
                f"- Net Income: ${net_inc:,.1f}M\n"
                f"- Free Cash Flow: ${fcf:,.1f}M\n"
                f"- Cash & Equivalents: ${cash:,.1f}M\n"
                f"- Long-Term Debt: ${debt:,.1f}M\n\n"
                f"Provide a concise, professional financial summary answering the user's question directly. "
                f"Use ONLY the exact figures provided above."
            )
            resp = llm.invoke(
                [
                    SystemMessage(
                        content="You are a Wall Street equity research analyst. Answer using ONLY the exact audited figures provided."
                    ),
                    HumanMessage(content=prompt),
                ]
            )
            return resp.content
        except Exception:
            pass  # Fall back to deterministic template below

    # Deterministic fallback formatting
    lines = [
        f"### {ticker} {quarter} {year} Financial Performance (Audited SQLite Record)",
        "",
        f"- **Total Revenue**: ${rev:,.1f}M",
        f"- **Gross Profit**: ${gross_prof:,.1f}M (Gross Margin: {gross_mgn*100:.1f}%)" if gross_prof else "",
        f"- **Operating Income**: ${op_inc:,.1f}M (Operating Margin: {op_mgn*100:.1f}%)" if op_inc else "",
        f"- **Net Income**: ${net_inc:,.1f}M" if net_inc is not None else "",
        f"- **Free Cash Flow**: ${fcf:,.1f}M" if fcf is not None else "",
        f"- **Cash & Equivalents**: ${cash:,.1f}M" if cash is not None else "",
    ]
    return "\n".join([line for line in lines if line])


def synthesize_hybrid_rag(query: str, chunks: List[Dict[str, Any]], mock: bool = False) -> str:
    """Synthesizes narrative filing excerpts with [Page - X, Section - Y] citations."""
    if not chunks:
        return "No relevant narrative sections were found in the filed earnings reports for this query."

    llm = None if mock else _get_llm()
    if llm:
        try:
            from langchain_core.messages import HumanMessage, SystemMessage

            excerpts = []
            for c in chunks:
                citation = c.get("citation", "[Page - 1, Section - General]")
                text = c.get("text", "")
                excerpts.append(f"Source {citation}:\n{text}")

            context_str = "\n\n---\n\n".join(excerpts)
            prompt = (
                f"User Question: {query}\n\n"
                f"Filing Excerpts:\n{context_str}\n\n"
                f"Instructions:\n"
                f"1. Answer the question thoroughly based ONLY on the excerpts provided.\n"
                f"2. Every key factual claim MUST cite its source using the exact format `[Page - X, Section - Y]` inline.\n"
                f"3. Maintain an objective, Wall Street equity analyst tone."
            )
            resp = llm.invoke(
                [
                    SystemMessage(
                        content="You are a Wall Street equity analyst. Every factual claim MUST be grounded with inline [Page - X, Section - Y] citations."
                    ),
                    HumanMessage(content=prompt),
                ]
            )
            return resp.content
        except Exception:
            pass  # Fall back to template below

    # Deterministic fallback formatting
    lines = [
        "Based on SEC filing narrative and earnings disclosures:",
        "",
    ]
    for c in chunks:
        citation = c.get("citation", "[Page - 1, Section - General]")
        snippet = c.get("text", "")[:280].replace("\n", " ").strip()
        lines.append(f"- {snippet}... {citation}")
        lines.append("")

    return "\n".join(lines)


def synthesize_comparison(query: str, comp_data: Dict[str, Any], mock: bool = False) -> str:
    """Synthesizes cross-company peer comparison into a markdown table and analysis."""
    period = comp_data.get("fiscal_period", "Q2 2026")
    companies = comp_data.get("companies", {})
    if not companies:
        return f"No comparison data found for {period}."

    table_lines = [
        f"### Peer Comparison Summary ({period})",
        "",
        "| Metric | " + " | ".join([f"**{t}**" for t in companies.keys()]) + " |",
        "| :--- | " + " | ".join([":---" for _ in companies]) + " |",
    ]

    metrics = [
        ("Total Revenue", "revenue", lambda v: f"${v:,.1f}M" if v else "N/A"),
        ("Gross Margin", "gross_margin", lambda v: f"{v*100:.1f}%" if v else "N/A"),
        ("Operating Margin", "operating_margin", lambda v: f"{v*100:.1f}%" if v else "N/A"),
        ("Net Income", "net_income", lambda v: f"${v:,.1f}M" if v else "N/A"),
        ("Free Cash Flow", "free_cash_flow", lambda v: f"${v:,.1f}M" if v else "N/A"),
        ("Cash & Equiv", "cash_and_equivalents", lambda v: f"${v:,.1f}M" if v else "N/A"),
    ]

    for label, key, fmt in metrics:
        row = [f"**{label}**"]
        for t, data in companies.items():
            val = data.get(key)
            row.append(fmt(val))
        table_lines.append("| " + " | ".join(row) + " |")

    table_lines.append("")
    table_lines.append(
        f"*Data extracted from 10-Q / Exhibit 99.1 filings registered in SQLite for {', '.join(companies.keys())}.*"
    )
    return "\n".join(table_lines)


__all__ = [
    "synthesize_sql_kpi",
    "synthesize_hybrid_rag",
    "synthesize_comparison",
]
