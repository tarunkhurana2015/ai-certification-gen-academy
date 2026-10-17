"""
Ingestion Pipeline Package:
Conforms to ARCHITECTURE.md Section 8 (app/ingestion/).

Components:
- validator.py: File integrity and constant memory 64KB SHA-256 deduplication
- parsers/: Layout-aware page text extraction & financial domain classification
- chunkers/: Semantic chunking (1000 char / 100 overlap) and facet enrichment
- extractor/: Deterministic GAAP KPI extraction (Branch A) & math reconciliation
"""

from app.schemas.common import FinancialDomain
from app.schemas.kpis import FinancialReportKPIs
from app.ingestion.validator import PDFValidationResult, validate_and_hash_pdf
from app.ingestion.parsers import (
    ExtractedPage,
    PDFExtractionResult,
    PageClassification,
    classify_document_pages,
    classify_page,
    extract_text_by_pages,
)
from app.ingestion.chunkers import (
    EnrichedChunk,
    chunk_document_pages,
)
from app.ingestion.extractor import (
    build_extraction_prompt,
    extract_financial_kpis,
    filter_financial_statement_pages,
    save_extracted_kpis_to_db,
    validate_and_reconcile_kpis,
)

__all__ = [
    # Schemas
    "FinancialDomain",
    "FinancialReportKPIs",
    # Validator
    "PDFValidationResult",
    "validate_and_hash_pdf",
    # Parsers
    "ExtractedPage",
    "PDFExtractionResult",
    "PageClassification",
    "extract_text_by_pages",
    "classify_page",
    "classify_document_pages",
    # Chunkers
    "EnrichedChunk",
    "chunk_document_pages",
    # Extractor
    "extract_financial_kpis",
    "filter_financial_statement_pages",
    "build_extraction_prompt",
    "save_extracted_kpis_to_db",
    "validate_and_reconcile_kpis",
]
