"""
Ingestion Pipeline Module:
- Validation & deduplication hashing (validator.py)
- Layout & text extraction (pdf_extractor.py)
- Financial section tagging (section_classifier.py)
- Semantic chunking & enrichment (chunker.py)
"""

from app.ingestion.validator import PDFValidationResult, validate_and_hash_pdf
from app.ingestion.pdf_extractor import (
    ExtractedPage,
    PDFExtractionResult,
    extract_text_by_pages,
)
from app.ingestion.section_classifier import (
    FinancialDomain,
    PageClassification,
    classify_page,
    classify_document_pages,
)

__all__ = [
    "PDFValidationResult",
    "validate_and_hash_pdf",
    "ExtractedPage",
    "PDFExtractionResult",
    "extract_text_by_pages",
    "FinancialDomain",
    "PageClassification",
    "classify_page",
    "classify_document_pages",
]
