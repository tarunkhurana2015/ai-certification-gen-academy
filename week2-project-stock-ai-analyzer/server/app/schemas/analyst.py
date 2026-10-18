"""
Financial Analyst & Chat API Schemas.

Pydantic models for:
- AnalystQueryRequest: Incoming user query with optional overrides
- AnalystQueryResponse: Full answer, citations, intent route, and raw data
- AnalystRoutesResponse: Catalog of available routing modes and prompt suggestions
"""

from typing import Any, Dict, List, Optional, Union
from pydantic import BaseModel, Field


class AnalystQueryRequest(BaseModel):
    """Request payload for financial query routing and answering."""

    query: str = Field(
        ...,
        min_length=2,
        description="Natural language financial question or comparison query",
        examples=["What was Tesla Q2 2026 revenue and free cash flow?"],
    )
    ticker: Optional[str] = Field(
        default=None,
        description="Optional ticker override (e.g. TSLA, META, AAPL)",
    )
    mock: bool = Field(
        default=False,
        description="Whether to run in deterministic offline mode (no external API calls)",
    )


class CitationItem(BaseModel):
    """Citation chip referencing ground truth source filings."""

    source: str = Field(description="Filing name or document identifier")
    page_number: Union[int, str] = Field(default=0, alias="page_number")
    section_name: str = Field(default="Report", description="GAAP section or financial statement")
    snippet: str = Field(default="", description="Relevant snippet from filing text")
    tag: str = Field(default="", description="Formatted inline citation chip [Page - X, Section - Y]")

    class Config:
        populate_by_name = True


class AnalystQueryResponse(BaseModel):
    """Comprehensive response from the Financial Retrieval & Generation pipeline."""

    query: str = Field(description="Original user question")
    route_used: str = Field(
        description="Selected routing mode: 'sql_kpi', 'hybrid_rag', or 'comparison'"
    )
    answer: str = Field(description="Synthesized markdown response with citation chips")
    citations: List[Dict[str, Any]] = Field(
        default_factory=list,
        description="Ground truth citations extracted from audited database or filings",
    )
    ticker: Optional[str] = Field(
        default=None,
        description="Detected or extracted company ticker symbol",
    )
    financial_domain: Optional[str] = Field(
        default=None,
        description="Classified financial domain (profitability, cash_flow, balance_sheet)",
    )
    raw_data: Optional[Dict[str, Any]] = Field(
        default=None,
        description="Raw structured data retrieved from SQL, Chroma, or BM25",
    )
    duration_seconds: float = Field(
        default=0.0,
        description="End-to-end processing latency in seconds",
    )


class RouteInfo(BaseModel):
    """Description and example queries for a specific analyst route."""

    route: str
    name: str
    description: str
    sample_queries: List[str]


class AnalystRoutesResponse(BaseModel):
    """Catalog of available routes for client suggestion chips."""

    routes: List[RouteInfo]
