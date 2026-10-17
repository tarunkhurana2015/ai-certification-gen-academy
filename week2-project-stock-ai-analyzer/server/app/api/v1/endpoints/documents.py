"""
Document Ingestion & Management Controller.

Conforms to ARCHITECTURE.md Section 8 (app/api/v1/endpoints/documents.py).
Provides:
- POST /api/v1/ingestion/upload: Multipart PDF upload + end-to-end ingestion
- POST /api/v1/documents/ingest: Alias for pipeline triggering
- GET /api/v1/documents/{document_id}: Document metadata retrieval
- GET /api/v1/documents: Ingested document catalog
- GET /api/v1/documents/tasks/{task_id}: Async task status polling
"""

import shutil
import tempfile
from pathlib import Path
from typing import Any, Dict, List, Optional
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.db.session import get_db_session
from app.db.repositories import document_repo
from app.ingestion.pipeline import IngestionPipeline
from app.schemas.ingestion import IngestionResponse
from app.schemas.kpis import format_kpi_for_client

_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
router = APIRouter()


@router.post(
    "/ingestion/upload",
    response_model=IngestionResponse,
    status_code=status.HTTP_200_OK,
    tags=["ingestion"],
    summary="Upload and ingest a quarterly financial PDF report",
)
async def upload_and_ingest_document(
    file: UploadFile = File(..., description="SEC 10-Q / Shareholder Update PDF file"),
    ticker: Optional[str] = Form(None, description="Optional stock ticker override (e.g., TSLA, META)"),
    quarter: Optional[str] = Form(None, description="Optional fiscal quarter override (e.g., Q1, Q2)"),
    year: Optional[int] = Form(None, description="Optional fiscal year override (e.g., 2026)"),
    force: bool = Form(False, description="Bypass 0.1ms instant deduplication cache"),
    save_artifacts: bool = Form(True, description="Generate substep inspection artifacts in server/.artifact/"),
    db: Session = Depends(get_db_session),
) -> IngestionResponse:
    """
    Accepts an investor update or SEC filing PDF, executes the complete ingestion pipeline:
    1. Header byte validation & SHA-256 computation
    2. Instant 0.1ms SQLite deduplication check
    3. Page layout & text extraction
    4. Financial section classification (GAAP statement tagging)
    5. Dynamic LLM GAAP KPI extraction & math consistency audit
    6. Semantic chunking with enriched metadata facets
    7. SQLite persistence and lineage mapping
    """
    if not file.filename or not file.filename.lower().endswith(".pdf"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file extension: '{file.filename}'. Only '.pdf' files are accepted.",
        )

    # Save uploaded file to persistent raw uploads cache in server/data/uploads/
    upload_dir = _SERVER_ROOT / "data" / "uploads"
    upload_dir.mkdir(parents=True, exist_ok=True)
    target_file_path = upload_dir / file.filename

    with open(target_file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Run pipeline
    pipeline = IngestionPipeline(session_factory=lambda: db)
    result = pipeline.run(
        file_path=target_file_path,
        ticker=ticker,
        fiscal_quarter=quarter,
        fiscal_year=year,
        force_reprocess=force,
        save_artifacts=save_artifacts,
    )

    client_kpis = None
    if result.kpis:
        client_kpis = format_kpi_for_client(
            result.kpis,
            document_id=result.document_id,
        )

    return IngestionResponse(
        task_id=result.task_id,
        document_id=result.document_id,
        status=result.status,
        message=result.error_message or f"Successfully ingested {result.ticker} {result.fiscal_quarter} {result.fiscal_year}.",
        is_duplicate=result.is_duplicate,
        sha256_hash=result.sha256_hash,
        ticker=result.ticker,
        fiscal_quarter=result.fiscal_quarter,
        fiscal_year=result.fiscal_year,
        duration_seconds=result.duration_seconds,
        kpis=result.kpis,
        client_kpis=client_kpis,
    )


@router.post(
    "/documents/ingest",
    response_model=IngestionResponse,
    status_code=status.HTTP_200_OK,
    tags=["ingestion"],
    summary="Alias for /ingestion/upload",
)
async def documents_ingest_alias(
    file: UploadFile = File(...),
    ticker: Optional[str] = Form(None),
    quarter: Optional[str] = Form(None),
    year: Optional[int] = Form(None),
    force: bool = Form(False),
    save_artifacts: bool = Form(True),
    db: Session = Depends(get_db_session),
) -> IngestionResponse:
    """Alias for /ingestion/upload to conform to ARCHITECTURE.md endpoint specs."""
    return await upload_and_ingest_document(
        file=file,
        ticker=ticker,
        quarter=quarter,
        year=year,
        force=force,
        save_artifacts=save_artifacts,
        db=db,
    )


@router.get(
    "/documents/{document_id}",
    response_model=Dict[str, Any],
    tags=["documents"],
    summary="Retrieve document metadata by UUID",
)
def get_document_details(
    document_id: str,
    db: Session = Depends(get_db_session),
) -> Dict[str, Any]:
    """Retrieve indexed document record by primary key UUID."""
    doc = document_repo.get_document_by_id(db, document_id)
    if not doc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Document '{document_id}' not found.",
        )
    return {
        "id": doc.id,
        "ticker": doc.ticker,
        "fiscal_quarter": doc.fiscal_quarter,
        "fiscal_year": doc.fiscal_year,
        "report_title": doc.report_title,
        "sha256_hash": doc.sha256_hash,
        "page_count": doc.page_count,
        "created_at": doc.created_at.isoformat() if doc.created_at else None,
    }


@router.get(
    "/documents",
    response_model=List[Dict[str, Any]],
    tags=["documents"],
    summary="List all ingested corporate documents",
)
def list_ingested_documents(
    ticker: Optional[str] = None,
    db: Session = Depends(get_db_session),
) -> List[Dict[str, Any]]:
    """List documents in the catalog, optionally filtered by ticker."""
    docs = document_repo.list_documents(db, ticker=ticker)
    return [
        {
            "id": doc.id,
            "ticker": doc.ticker,
            "fiscal_quarter": doc.fiscal_quarter,
            "fiscal_year": doc.fiscal_year,
            "report_title": doc.report_title,
            "sha256_hash": doc.sha256_hash,
            "page_count": doc.page_count,
            "created_at": doc.created_at.isoformat() if doc.created_at else None,
        }
        for doc in docs
    ]


@router.get(
    "/documents/tasks/{task_id}",
    response_model=Dict[str, Any],
    tags=["documents"],
    summary="Poll ingestion task status and progress",
)
def get_task_status(
    task_id: str,
    db: Session = Depends(get_db_session),
) -> Dict[str, Any]:
    """Check task lifecycle and completion progress."""
    task = document_repo.get_task(db, task_id)
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Ingestion task '{task_id}' not found.",
        )
    return {
        "task_id": task.id,
        "status": task.status,
        "progress_percent": task.progress_percent,
        "message": task.message,
        "document_id": task.document_id,
        "error_details": task.error_details,
    }
