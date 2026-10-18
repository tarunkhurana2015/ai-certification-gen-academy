"""
Financial Retrieval Router & Synthesizer - Phase 5.2.

Fast intent-based router:
1. Classifies query using Jev (TypeSafeClassifier) from Phase 4.
2. Routes directly to the specialized retrieval tool (SQL KPI, Hybrid RAG, or Peer Comparison) from app.retrieval.tools.
3. Delegates grounded response synthesis to app.generation with [Page - X, Section - Y] citations.
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

from dotenv import load_dotenv
from pydantic import BaseModel, Field

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.retrieval.classifier import QueryClassification, classify_query
from app.generation import (
    synthesize_comparison,
    synthesize_hybrid_rag,
    synthesize_sql_kpi,
)
from app.retrieval.tools import compare_tickers, get_kpis, search_filings

load_dotenv()

DEFAULT_ARTIFACT_PATH = (
    Path(__file__).resolve().parent.parent.parent / ".artifact" / "agent_02_analyst_query_sample.md"
)


class AnalystResponse(BaseModel):
    """Structured response from the Financial Retrieval / Analyst Router."""

    query: str
    route_used: str  # "sql_kpi", "hybrid_rag", "comparison"
    answer: str
    citations: List[Dict[str, Any]] = Field(default_factory=list)
    ticker: Optional[str] = None
    financial_domain: Optional[str] = None
    raw_data: Optional[Dict[str, Any]] = None


RetrievalResponse = AnalystResponse


# ============================================================================
# Main Router & Entrypoint
# ============================================================================


def run_analyst(query: str, mock: bool = False) -> AnalystResponse:
    """
    Fast Intent Router and Synthesizer.

    1. Runs Jev classifier (TypeSafe decision model).
    2. Routes directly to the specialized retrieval tool (SQL KPI, Hybrid RAG, or Peer Comparison).
    3. Synthesizes a grounded response with audit citations via app.generation.
    """
    # Step 1: Intent & metadata classification via Jev
    classification: QueryClassification = classify_query(query, mock=mock)
    route = classification.query_type
    ticker = classification.ticker
    domain = classification.financial_domain

    citations: List[Dict[str, Any]] = []
    raw_data: Dict[str, Any] = {}

    # Step 2: Route execution & synthesis
    if route == "sql_kpi":
        target_ticker = ticker or "TSLA"
        kpis = get_kpis.invoke({"ticker": target_ticker})
        answer = synthesize_sql_kpi(query=query, ticker=target_ticker, kpis=kpis, mock=mock)
        raw_data = kpis
        if "source_pages" in kpis and kpis["source_pages"]:
            try:
                pages = json.loads(kpis["source_pages"]) if isinstance(kpis["source_pages"], str) else kpis["source_pages"]
                for p in pages:
                    citations.append(
                        {
                            "source": "sqlite://financial_kpis",
                            "ticker": target_ticker,
                            "page_number": p,
                            "section_name": "Financial Statements",
                            "financial_domain": "Financial Statements",
                            "citation": f"[Page - {p}, Section - Financial Statements]",
                            "tag": f"[Page - {p}, Section - Financial Statements]",
                        }
                    )
            except Exception:
                pass
        if not citations and kpis and "revenue" in kpis:
            citations.append(
                {
                    "source": "sqlite://financial_kpis",
                    "ticker": target_ticker,
                    "page_number": 1,
                    "section_name": "Financial Statements",
                    "financial_domain": "Financial Statements",
                    "citation": f"[{target_ticker} Audited Financials]",
                    "tag": f"[{target_ticker} Audited Financials]",
                }
            )
        # Smart fallback to Hybrid RAG if SQL financial table does not contain the metric asked
        missing_indicators = ["does not include", "cannot provide", "not available", "data notice"]
        if any(ind in answer.lower() for ind in missing_indicators):
            chunks = search_filings.invoke(
                {
                    "query": query,
                    "ticker": target_ticker,
                    "financial_domain": domain,
                    "k": 3,
                }
            )
            if chunks:
                answer = synthesize_hybrid_rag(query=query, chunks=chunks, mock=mock)
                route = "hybrid_rag"
                citations = []
                for c in chunks:
                    citations.append(
                        {
                            "source": f"{c.get('ticker', 'SEC')} 10-Q",
                            "ticker": c.get("ticker", ""),
                            "page_number": c.get("page_number", 1),
                            "section_name": str(c.get("financial_domain", "Filing")).title(),
                            "financial_domain": c.get("financial_domain", "general"),
                            "snippet": c.get("text", "")[:200],
                            "citation": c.get("citation", f"[Page - {c.get('page_number', 1)}]"),
                            "tag": c.get("citation", f"[Page - {c.get('page_number', 1)}]"),
                        }
                    )
                raw_data = {"retrieved_chunks_count": len(chunks), "fallback_from": "sql_kpi"}

    elif route == "hybrid_rag":
        target_ticker = ticker if ticker and ticker not in ("none", "multiple") else None
        chunks = search_filings.invoke(
            {
                "query": query,
                "ticker": target_ticker,
                "financial_domain": domain,
                "k": 3,
            }
        )
        answer = synthesize_hybrid_rag(query=query, chunks=chunks, mock=mock)
        for c in chunks:
            citations.append(
                {
                    "source": f"{c.get('ticker', 'SEC')} 10-Q",
                    "ticker": c.get("ticker", ""),
                    "page_number": c.get("page_number", 1),
                    "section_name": str(c.get("financial_domain", "Filing")).title(),
                    "financial_domain": c.get("financial_domain", "general"),
                    "snippet": c.get("text", "")[:200],
                    "citation": c.get("citation", f"[Page - {c.get('page_number', 1)}]"),
                    "tag": c.get("citation", f"[Page - {c.get('page_number', 1)}]"),
                }
            )
        raw_data = {"retrieved_chunks_count": len(chunks)}

    elif route == "comparison":
        tickers = ["META", "TSLA"] if (not ticker or ticker == "multiple") else [ticker]
        comp_res = compare_tickers.invoke(
            {
                "tickers": tickers,
                "fiscal_quarter": "Q2",
                "fiscal_year": 2026,
            }
        )
        answer = synthesize_comparison(query=query, comp_data=comp_res, mock=mock)
        raw_data = comp_res
        if "companies" in comp_res:
            for tick, kpi_dict in comp_res["companies"].items():
                sp = kpi_dict.get("source_pages")
                added_for_tick = False
                if sp:
                    try:
                        pages = json.loads(sp) if isinstance(sp, str) else sp
                        for p in pages:
                            citations.append(
                                {
                                    "source": f"{tick} 10-Q",
                                    "ticker": tick,
                                    "page_number": p,
                                    "section_name": "Financial Statements",
                                    "financial_domain": "Financial Statements",
                                    "citation": f"[{tick} Page - {p}, Section - Financial Statements]",
                                    "tag": f"[{tick} Page - {p}, Section - Financial Statements]",
                                }
                            )
                            added_for_tick = True
                    except Exception:
                        pass
                if not added_for_tick:
                    citations.append(
                        {
                            "source": f"sqlite://financial_kpis/{tick}",
                            "ticker": tick,
                            "page_number": 0,
                            "section_name": "Audited KPIs",
                            "financial_domain": "Financial Statements",
                            "citation": f"[{tick} Audited Financials]",
                            "tag": f"[{tick} Audited Financials]",
                        }
                    )

    else:
        # Fallback to Hybrid RAG
        route = "hybrid_rag"
        chunks = search_filings.invoke({"query": query, "k": 3})
        answer = synthesize_hybrid_rag(query=query, chunks=chunks, mock=mock)
        for c in chunks:
            citations.append(
                {
                    "source": f"{c.get('ticker', 'SEC')} 10-Q",
                    "ticker": c.get("ticker", ""),
                    "page_number": c.get("page_number", 1),
                    "section_name": str(c.get("financial_domain", "Filing")).title(),
                    "financial_domain": c.get("financial_domain", "general"),
                    "snippet": c.get("text", "")[:200],
                    "citation": c.get("citation", f"[Page - {c.get('page_number', 1)}]"),
                    "tag": c.get("citation", f"[Page - {c.get('page_number', 1)}]"),
                }
            )
        raw_data = {"retrieved_chunks_count": len(chunks)}

    return AnalystResponse(
        query=query,
        route_used=route,
        answer=answer,
        citations=citations,
        ticker=ticker,
        financial_domain=domain,
        raw_data=raw_data,
    )


run_retrieval = run_analyst


# ============================================================================
# Artifact Generation
# ============================================================================


def save_analyst_artifact(
    responses: List[AnalystResponse],
    output_path: Optional[Path] = None,
) -> Path:
    """Saves analyst execution queries and responses to markdown artifact."""
    target_path = output_path or DEFAULT_ARTIFACT_PATH
    target_path.parent.mkdir(parents=True, exist_ok=True)

    lines = [
        "# 📊 Financial Analyst Intent Router Artifact (`agent_02`)",
        "",
        f"- **Generated At**: `{datetime.now().isoformat()}`",
        f"- **Architecture**: Option 2 (Fast Intent Router & Modular Generation under app/retrieval)",
        f"- **Decision Model**: TypeSafe Jev (`TypeSafeClassifier`)",
        f"- **Total Queries Processed**: `{len(responses)}`",
        "",
    ]

    for i, resp in enumerate(responses, 1):
        lines.extend(
            [
                f"## Query {i}: \"{resp.query}\"",
                "",
                f"- **Route Used**: `{resp.route_used.upper()}`",
                f"- **Detected Ticker**: `{resp.ticker or 'None'}`",
                f"- **Financial Domain**: `{resp.financial_domain or 'None'}`",
                f"- **Total Citations**: `{len(resp.citations)}`",
                "",
                "### Synthesized Answer:",
                "",
                resp.answer,
                "",
            ]
        )
        if resp.citations:
            lines.append("### Grounded Evidence Citations:")
            for c in resp.citations[:3]:
                cit_label = c.get("citation", "[Page - 1]")
                chunk_id = c.get("chunk_id", "N/A")
                lines.append(f"- **{cit_label}** (`{chunk_id}`)")
            lines.append("")

        lines.append("---")
        lines.append("")

    content = "\n".join(lines)
    with open(target_path, "w", encoding="utf-8") as f:
        f.write(content)

    return target_path


save_retrieval_artifact = save_analyst_artifact


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Financial Retrieval Router CLI")
    parser.add_argument("query", nargs="?", default=None, help="User financial question")
    parser.add_argument("--mock", action="store_true", help="Run offline without external API calls")
    args = parser.parse_args()

    sample_queries = (
        [args.query]
        if args.query
        else [
            "What was Tesla Q2 2026 revenue and free cash flow?",
            "Why did automotive gross margin decline sequentially in Q2 2026?",
            "Compare Meta and Tesla operating margins over the last year",
        ]
    )

    results = []
    print("\n--- Running Financial Retrieval Router ---")
    for q in sample_queries:
        r = run_analyst(q, mock=args.mock)
        results.append(r)
        print(f"\n[Query]: {r.query}")
        print(f"[Route]: {r.route_used.upper()} | Ticker: {r.ticker} | Domain: {r.financial_domain}")
        print(f"[Answer]:\n{r.answer[:300]}...\n")

    art = save_analyst_artifact(results)
    print(f"Saved analyst artifact to {art}\n")


__all__ = [
    "AnalystResponse",
    "RetrievalResponse",
    "run_analyst",
    "run_retrieval",
    "save_analyst_artifact",
    "save_retrieval_artifact",
]
