"""
Hybrid RAG Filing Search Tool.

Fuses dense semantic vector search (ChromaDB) and sparse lexical search (BM25) over SEC filings.
"""

import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

from langchain_core.tools import tool

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.retrieval.hybrid_engine import HybridEngine

# Global lazy hybrid engine instance
_DEFAULT_ENGINE: Optional[HybridEngine] = None


def get_default_engine() -> HybridEngine:
    """Returns singleton HybridEngine instance for tool calls."""
    global _DEFAULT_ENGINE
    if _DEFAULT_ENGINE is None:
        _DEFAULT_ENGINE = HybridEngine()
    return _DEFAULT_ENGINE


@tool
def search_filings(
    query: str,
    ticker: Optional[str] = None,
    financial_domain: Optional[str] = None,
    k: int = 5,
) -> List[Dict[str, Any]]:
    """
    Run hybrid search (dense semantic vectors + sparse BM25 keywords) over SEC filings
    to retrieve qualitative explanations, narrative context, business drivers, risk factors,
    or management commentary with audit citations [Page - X, Section - Y].

    Use this tool whenever the user asks 'why', 'how', or asks for explanations,
    market commentary, strategic roadmaps, or risks.
    """
    clean_ticker = ticker.upper().strip() if ticker and ticker.lower() not in ("none", "multiple") else None
    clean_domain = financial_domain if financial_domain and financial_domain.lower() != "none" else None

    engine = get_default_engine()
    try:
        docs = engine.search(query=query, ticker=clean_ticker, k=k, save_artifact=False)
    except Exception as e:
        # Graceful fallback to sparse BM25 if external OpenAI embeddings connection is restricted
        print(f"[search_filings] Vector search fallback to BM25 ({e})")
        filter_dict = {}
        if clean_ticker:
            filter_dict["ticker"] = clean_ticker
        if clean_domain:
            filter_dict["financial_domain"] = clean_domain
        docs = engine.bm25_index.search(query=query, k=k, filter=filter_dict or None)
        if not docs and clean_domain and clean_ticker:
            # Fallback to ticker-only filter if strict financial domain produced zero hits
            docs = engine.bm25_index.search(query=query, k=k, filter={"ticker": clean_ticker})

    results = []
    for d in docs:
        meta = d.metadata or {}
        page = meta.get("page_number", 1)
        domain = meta.get("financial_domain", "general")
        doc_ticker = meta.get("ticker", clean_ticker or "UNKNOWN")
        results.append(
            {
                "chunk_id": meta.get("chunk_id", ""),
                "ticker": doc_ticker,
                "fiscal_quarter": meta.get("fiscal_quarter", ""),
                "fiscal_year": meta.get("fiscal_year", 0),
                "page_number": page,
                "financial_domain": domain,
                "citation": f"[Page - {page}, Section - {domain.title()}]",
                "text": d.page_content,
            }
        )

    return results
