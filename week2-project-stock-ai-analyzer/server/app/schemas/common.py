"""
Common Enumerations and Shared Type Contracts.

Conforms to ARCHITECTURE.md Section 8 (app/schemas/common.py).
"""

from enum import Enum


class FinancialDomain(str, Enum):
    """
    Standardized classification domains for corporate filings and earnings reports.
    Used for query routing, ChromaDB/BM25 metadata filtering, and targeted KPI extraction.
    """
    PROFITABILITY = "profitability"          # Income Statement / Operations
    BALANCE_SHEET = "balance_sheet"          # Statement of Financial Position
    CASH_FLOW = "cash_flow"                  # Statement of Cash Flows
    GUIDANCE_OUTLOOK = "guidance_outlook"    # CFO Commentary / Forward Estimates
    RISK_FACTORS = "risk_factors"            # Safe Harbor / Regulatory Disclosures
    GENERAL = "general"                      # Executive commentary, ESG, product marketing


class StatementType(str, Enum):
    """Primary US GAAP Financial Statements."""
    INCOME_STATEMENT = "income_statement"
    BALANCE_SHEET = "balance_sheet"
    CASH_FLOW = "cash_flow"
    NOTES_AND_DISCLOSURES = "notes_and_disclosures"


class ContentFormat(str, Enum):
    """Data presentation formats."""
    TABLE = "table"
    NARRATIVE = "narrative"
    MIXED = "mixed"
