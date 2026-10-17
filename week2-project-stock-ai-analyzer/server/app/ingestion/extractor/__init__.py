"""
Extractor Package (Deterministic KPI Extraction - Branch A):
- kpi_extractor.py: extract_financial_kpis, filter_financial_statement_pages, save_extracted_kpis_to_db
- kpi_validator.py: validate_and_reconcile_kpis
- llm_extraction_prompts.py: build_extraction_prompt, KPI_AUDITOR_SYSTEM_ROLE, KPI_EXTRACTION_RULES
"""

from app.ingestion.extractor.kpi_extractor import (
    extract_financial_kpis,
    filter_financial_statement_pages,
    save_extracted_kpis_to_db,
)
from app.ingestion.extractor.kpi_validator import validate_and_reconcile_kpis
from app.ingestion.extractor.llm_extraction_prompts import (
    KPI_AUDITOR_SYSTEM_ROLE,
    KPI_EXTRACTION_RULES,
    build_extraction_prompt,
)

__all__ = [
    "extract_financial_kpis",
    "filter_financial_statement_pages",
    "save_extracted_kpis_to_db",
    "validate_and_reconcile_kpis",
    "build_extraction_prompt",
    "KPI_AUDITOR_SYSTEM_ROLE",
    "KPI_EXTRACTION_RULES",
]
