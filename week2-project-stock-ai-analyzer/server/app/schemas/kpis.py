"""
Standardized Financial KPI Schemas and Pydantic DTOs.

Conforms to ARCHITECTURE.md Section 8 (app/schemas/kpis.py).
"""

from typing import List, Optional
from pydantic import BaseModel, Field


class FinancialReportKPIs(BaseModel):
    """
    Standardized GAAP financial KPIs extracted from corporate earnings releases
    and SEC 10-Q / 10-K filings.
    """
    ticker: str = Field(description="Stock ticker symbol in capital letters, e.g. META, TSLA, AAPL")
    fiscal_quarter: str = Field(description="Fiscal quarter, e.g. 'Q1', 'Q2', 'Q3', 'Q4', or 'FY'")
    fiscal_year: int = Field(description="Four-digit fiscal year, e.g. 2026")
    report_title: str = Field(description="Filing title or press release headline, e.g. 'Meta Q2 2026 Earnings Release'")
    currency: str = Field(default="USD", description="Currency reported, typically 'USD'")
    units: str = Field(default="millions", description="Reporting unit scale, e.g. 'millions', 'thousands', 'billions'")

    # 1. Income Statement (Profitability)
    revenue: Optional[float] = Field(default=None, description="Total revenue / net sales for the period")
    cost_of_revenue: Optional[float] = Field(default=None, description="Cost of revenue / cost of goods sold")
    gross_profit: Optional[float] = Field(default=None, description="Gross profit (Revenue minus Cost of revenue)")
    gross_margin: Optional[float] = Field(default=None, description="Gross profit margin as decimal between 0 and 1 (e.g. 0.82 for 82%)")
    research_and_development: Optional[float] = Field(default=None, description="Research and development (R&D) expense")
    selling_general_admin: Optional[float] = Field(default=None, description="Selling, general, and administrative (SG&A) expense")
    total_operating_expenses: Optional[float] = Field(default=None, description="Total operating expenses")
    operating_income: Optional[float] = Field(default=None, description="Operating income / Income from operations")
    operating_margin: Optional[float] = Field(default=None, description="Operating profit margin as decimal between 0 and 1")
    net_income: Optional[float] = Field(default=None, description="Net income / net earnings attributable to common stockholders")
    net_margin: Optional[float] = Field(default=None, description="Net profit margin as decimal between 0 and 1")
    diluted_eps: Optional[float] = Field(default=None, description="Diluted earnings per share (EPS) in dollars")

    # 2. Cash Flow Statement
    operating_cash_flow: Optional[float] = Field(default=None, description="Net cash provided by (used in) operating activities")
    capital_expenditures: Optional[float] = Field(default=None, description="Capital expenditures (CapEx / purchase of property and equipment)")
    free_cash_flow: Optional[float] = Field(default=None, description="Free cash flow (Operating cash flow minus Capital expenditures)")

    # 3. Balance Sheet
    cash_and_equivalents: Optional[float] = Field(default=None, description="Cash, cash equivalents, and marketable securities")
    total_assets: Optional[float] = Field(default=None, description="Total assets")
    long_term_debt: Optional[float] = Field(default=None, description="Long-term debt (excluding operating lease liabilities if separate)")
    total_liabilities: Optional[float] = Field(default=None, description="Total liabilities")
    shareholders_equity: Optional[float] = Field(default=None, description="Total stockholders' / shareholders' equity")

    # Source grounding
    source_pages: List[int] = Field(default_factory=list, description="List of page numbers from which these numbers were extracted")
