"""
Financial Analyst & Chat Query Controller.

Conforms to ARCHITECTURE.md Section 8 (app/api/v1/endpoints/analyst.py & chat.py).
Provides:
- POST /api/v1/analyst/query: Full query routing, retrieval tool execution, and grounded answer synthesis
- POST /api/v1/chat: Alias endpoint for chat interfaces
- GET  /api/v1/analyst/classify: Inspect Jev intent classification and generated metadata filter
- GET  /api/v1/analyst/routes: Catalog of available routing modes and UI prompt suggestions
"""

import time
from typing import Any, Dict, List, Optional
from fastapi import APIRouter, HTTPException, Query, status

from app.retrieval.classifier import QueryClassification, classify_query
from app.retrieval.retrieval import AnalystResponse, run_retrieval
from app.schemas.analyst import (
    AnalystQueryRequest,
    AnalystQueryResponse,
    AnalystRoutesResponse,
    RouteInfo,
)

router = APIRouter()


@router.post(
    "/analyst/query",
    response_model=AnalystQueryResponse,
    tags=["analyst"],
    summary="Execute Financial Analyst RAG Query",
    description="Routes query via TypeSafe Jev classifier to SQL KPI, Hybrid RAG, or Peer Comparison, synthesizing a grounded answer with inline citations.",
)
def query_analyst(payload: AnalystQueryRequest) -> AnalystQueryResponse:
    """Executes full intent classification, tool retrieval, and response synthesis."""
    if not payload.query or not payload.query.strip():
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Query string cannot be empty.",
        )

    start_time = time.perf_counter()
    query_text = payload.query.strip()
    if payload.ticker and payload.ticker.upper() not in query_text.upper():
        query_text = f"{query_text} (ticker: {payload.ticker.upper()})"

    try:
        analyst_res: AnalystResponse = run_retrieval(query=query_text, mock=payload.mock)
        elapsed = time.perf_counter() - start_time

        return AnalystQueryResponse(
            query=payload.query,
            route_used=analyst_res.route_used,
            answer=analyst_res.answer,
            citations=analyst_res.citations,
            ticker=analyst_res.ticker,
            financial_domain=analyst_res.financial_domain,
            raw_data=analyst_res.raw_data,
            duration_seconds=round(elapsed, 3),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analyst retrieval failed: {str(e)}",
        )


@router.post(
    "/chat",
    response_model=AnalystQueryResponse,
    tags=["chat", "analyst"],
    summary="Chat with Financial Analyst (Alias)",
    description="Identical to /analyst/query, provided for conversational UI integrations.",
)
def chat_with_analyst(payload: AnalystQueryRequest) -> AnalystQueryResponse:
    """Direct alias to query_analyst for chat client compatibility."""
    return query_analyst(payload)


@router.get(
    "/analyst/classify",
    tags=["analyst"],
    summary="Classify Financial Query Intent",
    description="Inspects Jev decision model classification, confidences, and metadata filter without executing full retrieval.",
)
def classify_intent(
    q: str = Query(..., min_length=2, description="Query string to evaluate"),
    mock: bool = Query(default=False, description="Run in deterministic offline mode"),
) -> Dict[str, Any]:
    """Returns Jev intent classification and compiled metadata filters."""
    classification: QueryClassification = classify_query(query=q, mock=mock)
    return {
        "query": classification.query,
        "query_type": classification.query_type,
        "financial_domain": classification.financial_domain,
        "ticker": classification.ticker,
        "confidences": classification.confidences,
        "metadata_filter": classification.to_metadata_filter(),
        "chroma_filter": classification.to_chroma_filter(),
    }


@router.get(
    "/analyst/routes",
    response_model=AnalystRoutesResponse,
    tags=["analyst"],
    summary="List Supported Analyst Routes & Example Prompts",
)
def list_analyst_routes() -> AnalystRoutesResponse:
    """Returns catalog of routing paths and starter prompt suggestions for clients."""
    return AnalystRoutesResponse(
        routes=[
            RouteInfo(
                route="sql_kpi",
                name="Exact GAAP Financials (SQL)",
                description="Queries the SQLite database for audited 18+ GAAP financial metrics for a specific quarter.",
                sample_queries=[
                    "What was Tesla Q2 2026 revenue and free cash flow?",
                    "Show Meta Q2 2026 operating margin and net income",
                    "What was Apple cash and marketable securities balance?",
                ],
            ),
            RouteInfo(
                route="hybrid_rag",
                name="Qualitative Filing Analysis (Hybrid RAG)",
                description="Fuses dense ChromaDB semantic search and sparse BM25 keyword matching over SEC filing text with grounded citations.",
                sample_queries=[
                    "Why did automotive gross margin decline sequentially in Q2 2026?",
                    "What did management say about AI infrastructure CapEx commitments?",
                    "Explain the primary drivers of Reality Labs operating losses.",
                ],
            ),
            RouteInfo(
                route="comparison",
                name="Multi-Quarter / Peer Benchmark",
                description="Compares metrics across multiple public companies or analyzes time-series trends over consecutive quarters.",
                sample_queries=[
                    "Compare Meta and Tesla operating margins over the last year",
                    "Compare free cash flow between Tesla and Apple",
                    "Analyze Meta revenue growth trend over the last 4 quarters",
                ],
            ),
        ]
    )
