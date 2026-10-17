"""
Ingestion Request and Response Schemas.

Conforms to ARCHITECTURE.md Section 8 (app/schemas/ingestion.py).
"""

from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field

from app.schemas.kpis import FinancialReportKPIs


class IngestionUploadRequest(BaseModel):
    """Optional metadata overrides passed during document upload."""
    ticker: Optional[str] = Field(default=None, description="Stock ticker override (e.g., TSLA, META)")
    fiscal_quarter: Optional[str] = Field(default=None, description="Fiscal quarter override (e.g., Q1, Q2)")
    fiscal_year: Optional[int] = Field(default=None, description="Fiscal year override (e.g., 2026)")
    force_reprocess: bool = Field(default=False, description="Bypass 0.1ms instant deduplication cache")


class IngestionResponse(BaseModel):
    """Standardized response returned after ingestion pipeline execution."""
    task_id: str = Field(description="Unique ingestion task UUID")
    document_id: Optional[str] = Field(default=None, description="Persisted document UUID in SQLite")
    status: str = Field(description="Pipeline status: COMPLETED, FAILED, or DUPLICATE")
    message: str = Field(description="Human-readable summary message")
    is_duplicate: bool = Field(default=False, description="Whether instant 0.1ms deduplication was triggered")
    sha256_hash: Optional[str] = Field(default=None, description="SHA-256 fingerprint of the uploaded file")
    ticker: Optional[str] = Field(default=None, description="Extracted or resolved ticker symbol")
    fiscal_quarter: Optional[str] = Field(default=None, description="Fiscal quarter (e.g., Q2)")
    fiscal_year: Optional[int] = Field(default=None, description="Fiscal year (e.g., 2026)")
    duration_seconds: float = Field(default=0.0, description="Pipeline execution wall-clock time in seconds")
    kpis: Optional[FinancialReportKPIs] = Field(default=None, description="Structured GAAP KPIs extracted")
    client_kpis: Optional[Dict[str, Any]] = Field(default=None, description="Pre-formatted DTO matching Flutter client QuarterlyKpis entity")
