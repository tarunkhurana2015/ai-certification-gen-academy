"""
Ingestion Pipeline Module:
- Validation & deduplication hashing (validator.py)
- Layout & text extraction (pdf_extractor.py)
- Financial section tagging (section_classifier.py)
- Semantic chunking & enrichment (chunker.py)
"""

from app.ingestion.validator import PDFValidationResult, validate_and_hash_pdf

__all__ = ["PDFValidationResult", "validate_and_hash_pdf"]
