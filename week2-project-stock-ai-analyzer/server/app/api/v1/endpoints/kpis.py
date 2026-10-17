"""
Deterministic Financial KPI Query Controller.

Conforms to ARCHITECTURE.md Section 8 (app/api/v1/endpoints/kpis.py).
Provides:
- GET /api/v1/kpi/{ticker}: Single quarter or multi-quarter time series
- GET /api/v1/kpi/{ticker}/latest: Most recent reported quarterly KPIs
- GET /api/v1/kpi/compare: Side-by-side peer company comparison
- GET /api/v1/kpi/document/{document_id}: Retrieve KPIs by parent Document ID
"""

from typing import Any, Dict, List, Optional, Union
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.db.session import get_db_session
from app.db.repositories import kpi_repo
from app.schemas.kpis import (
    FinancialReportKPIs,
    KpiComparisonResponse,
    KpiTimeSeriesResponse,
    format_kpi_for_client,
)

router = APIRouter()


@router.get(
    "/kpi/compare",
    response_model=KpiComparisonResponse,
    tags=["kpis"],
    summary="Compare financial KPIs for multiple peer companies in the same fiscal quarter",
)
def compare_peer_companies(
    tickers: List[str] = Query(..., description="List of stock tickers (e.g. ['TSLA', 'META'])"),
    quarter: str = Query(..., description="Fiscal quarter (e.g. 'Q2')"),
    year: int = Query(..., description="Fiscal year (e.g. 2026)"),
    db: Session = Depends(get_db_session),
) -> KpiComparisonResponse:
    """
    Returns side-by-side audited financial KPIs for peer benchmarking.
    Outputs both flat standardized models and client-formatted QuarterlyKpis entities.
    """
    records = kpi_repo.get_multi_company_comparison(
        session=db,
        tickers=tickers,
        fiscal_year=year,
        fiscal_quarter=quarter,
    )
    if not records:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No financial records found for tickers {tickers} in {quarter} {year}.",
        )

    flat_kpis = [FinancialReportKPIs(**r.to_dict()) for r in records]
    client_reports = [format_kpi_for_client(r) for r in records]

    return KpiComparisonResponse(
        fiscal_quarter=quarter.upper(),
        fiscal_year=year,
        total_companies=len(records),
        kpis=flat_kpis,
        client_reports=client_reports,
    )


@router.get(
    "/kpi/{ticker}/latest",
    response_model=Dict[str, Any],
    tags=["kpis"],
    summary="Retrieve the most recent reported quarterly KPIs for a company",
)
def get_latest_kpis_for_ticker(
    ticker: str,
    db: Session = Depends(get_db_session),
) -> Dict[str, Any]:
    """Retrieves the latest available fiscal quarter record for the specified ticker."""
    records = kpi_repo.list_all_kpis(session=db, ticker=ticker)
    if not records:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No financial records found for ticker '{ticker.upper()}'.",
        )

    latest = records[0]  # list_all_kpis is sorted year DESC, quarter DESC
    return {
        "ticker": latest.ticker,
        "fiscal_quarter": latest.fiscal_quarter,
        "fiscal_year": latest.fiscal_year,
        "kpi": latest.to_dict(),
        "client_report": format_kpi_for_client(latest),
    }


@router.get(
    "/kpi/document/{document_id}",
    response_model=Dict[str, Any],
    tags=["kpis"],
    summary="Retrieve financial KPIs associated with a parent Document ID",
)
def get_kpis_by_document(
    document_id: str,
    db: Session = Depends(get_db_session),
) -> Dict[str, Any]:
    """Retrieves the audited financial KPIs extracted from a specific document."""
    record = kpi_repo.get_kpis_by_document_id(session=db, document_id=document_id)
    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No KPI records found for document '{document_id}'.",
        )
    return {
        "document_id": document_id,
        "ticker": record.ticker,
        "fiscal_quarter": record.fiscal_quarter,
        "fiscal_year": record.fiscal_year,
        "kpi": record.to_dict(),
        "client_report": format_kpi_for_client(record),
    }


@router.get(
    "/kpi/{ticker}",
    response_model=Union[Dict[str, Any], KpiTimeSeriesResponse],
    tags=["kpis"],
    summary="Retrieve single quarter KPI or multi-quarter chronological time series",
)
def get_company_kpis(
    ticker: str,
    quarter: Optional[str] = Query(None, description="Optional fiscal quarter (e.g. 'Q2')"),
    year: Optional[int] = Query(None, description="Optional fiscal year (e.g. 2026)"),
    limit: int = Query(8, ge=1, le=20, description="Max historical quarters to return"),
    db: Session = Depends(get_db_session),
) -> Any:
    """
    If quarter and year are provided, returns the exact single quarter record.
    If quarter and year are omitted, returns chronological quarterly time series for charts.
    """
    clean_ticker = ticker.upper().strip()

    # Exact Single Quarter Query
    if quarter is not None and year is not None:
        record = kpi_repo.get_kpis_by_quarter(
            session=db,
            ticker=clean_ticker,
            fiscal_year=year,
            fiscal_quarter=quarter,
        )
        if not record:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"No financial record found for {clean_ticker} {quarter.upper()} {year}.",
            )
        return {
            "ticker": record.ticker,
            "fiscal_quarter": record.fiscal_quarter,
            "fiscal_year": record.fiscal_year,
            "kpi": record.to_dict(),
            "client_report": format_kpi_for_client(record),
        }

    # Time Series Query
    records = kpi_repo.get_kpi_time_series(session=db, ticker=clean_ticker, limit=limit)
    if not records:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No financial time series found for ticker '{clean_ticker}'.",
        )

    flat_kpis = [FinancialReportKPIs(**r.to_dict()) for r in records]
    client_reports = [format_kpi_for_client(r) for r in records]

    return KpiTimeSeriesResponse(
        ticker=clean_ticker,
        total_quarters=len(records),
        kpis=flat_kpis,
        client_reports=client_reports,
    )
