"""
Standardized Financial KPI Schemas and Pydantic DTOs.

Conforms to ARCHITECTURE.md Section 8 (app/schemas/kpis.py).
"""

from typing import Any, Dict, List, Optional, Union
import json
from pydantic import BaseModel, Field, field_validator


class FinancialReportKPIs(BaseModel):
    """
    Standardized GAAP financial KPIs extracted from corporate earnings releases
    and SEC 10-Q / 10-K filings.
    """
    ticker: str = Field(description="Stock ticker symbol in capital letters, e.g. META, TSLA, AAPL")
    fiscal_quarter: str = Field(description="Fiscal quarter, e.g. 'Q1', 'Q2', 'Q3', 'Q4', or 'FY'")
    fiscal_year: int = Field(description="Four-digit fiscal year, e.g. 2026")
    report_title: str = Field(default="", description="Filing title or press release headline, e.g. 'Meta Q2 2026 Earnings Release'")
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

    @field_validator("source_pages", mode="before")
    @classmethod
    def parse_source_pages(cls, v: Any) -> List[int]:
        if isinstance(v, str):
            try:
                parsed = json.loads(v)
                return [int(x) for x in parsed] if isinstance(parsed, list) else []
            except Exception:
                return []
        if isinstance(v, (list, tuple)):
            return [int(x) for x in v]
        return []



class KpiTimeSeriesResponse(BaseModel):
    """Time-series response containing chronological quarterly KPI records."""
    ticker: str = Field(description="Stock ticker symbol")
    total_quarters: int = Field(description="Number of quarters returned")
    kpis: List[FinancialReportKPIs] = Field(description="Standardized flat KPI models")
    client_reports: List[Dict[str, Any]] = Field(
        default_factory=list,
        description="Nested quarterly KPI models matching Flutter client entity structure"
    )


class KpiComparisonResponse(BaseModel):
    """Peer comparison response for multiple companies in the same fiscal period."""
    fiscal_quarter: str = Field(description="Fiscal quarter compared (e.g., Q2)")
    fiscal_year: int = Field(description="Fiscal year compared (e.g., 2026)")
    total_companies: int = Field(description="Number of companies compared")
    kpis: List[FinancialReportKPIs] = Field(description="Standardized flat KPI models")
    client_reports: List[Dict[str, Any]] = Field(
        default_factory=list,
        description="Nested quarterly KPI models matching Flutter client entity structure"
    )


def format_kpi_for_client(
    kpi_obj: Any,
    document_id: Optional[str] = None,
    company_name: Optional[str] = None,
    report_date: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Transforms a FinancialKPI ORM model or FinancialReportKPIs DTO
    into the exact nested JSON structure expected by the Flutter client's
    QuarterlyKpis.fromJson() entity parser.
    """
    # Normalize input into dictionary
    if hasattr(kpi_obj, "to_dict"):
        data = kpi_obj.to_dict()
    elif hasattr(kpi_obj, "model_dump"):
        data = kpi_obj.model_dump()
    elif isinstance(kpi_obj, dict):
        data = kpi_obj
    else:
        raise ValueError(f"Cannot format unsupported KPI object: {type(kpi_obj)}")

    doc_id = document_id or data.get("document_id") or f"doc_{data.get('ticker', 'unknown').lower()}_{data.get('fiscal_year', 2026)}_{data.get('fiscal_quarter', 'q2').lower()}"
    ticker = data.get("ticker", "UNKNOWN").upper()
    quarter = data.get("fiscal_quarter", "Q2")
    year = int(data.get("fiscal_year", 2026))

    # Name mapping for famous tickers
    names = {
        "TSLA": "Tesla, Inc.",
        "META": "Meta Platforms, Inc.",
        "AAPL": "Apple Inc.",
        "GOOGL": "Alphabet Inc.",
        "MSFT": "Microsoft Corporation",
        "AMZN": "Amazon.com, Inc.",
        "NVDA": "NVIDIA Corporation",
    }
    c_name = company_name or names.get(ticker, f"{ticker} Inc.")

    # Income
    rev = float(data.get("revenue") or 0.0)
    gp = float(data.get("gross_profit") or 0.0)
    gm = float(data.get("gross_margin") or (gp / rev if rev else 0.0))
    op_inc = float(data.get("operating_income") or 0.0)
    op_margin = float(data.get("operating_margin") or (op_inc / rev if rev else 0.0))
    net_inc = float(data.get("net_income") or 0.0)
    net_margin = float(data.get("net_margin") or (net_inc / rev if rev else 0.0))
    eps = float(data.get("diluted_eps") or 0.0)

    # Cash Flow
    ocf = float(data.get("operating_cash_flow") or 0.0)
    capex = float(data.get("capital_expenditures") or 0.0)
    fcf = float(data.get("free_cash_flow") or (ocf - capex))
    fcf_conv = round((fcf / net_inc) * 100, 2) if net_inc > 0 else None

    # Balance Sheet
    cash = float(data.get("cash_and_equivalents") or 0.0)
    assets = float(data.get("total_assets") or 0.0)
    debt = float(data.get("long_term_debt") or 0.0)
    liab = float(data.get("total_liabilities") or 0.0)
    equity = float(data.get("shareholders_equity") or 0.0)
    net_cash = cash - debt
    debt_to_equity = round(debt / equity, 3) if equity > 0 else None

    # Bullet summaries
    bullets = [
        f"Total revenue for {quarter} {year} reported at ${rev:,.1f}M with gross margin of {gm * 100:.2f}%.",
        f"Operating income generated was ${op_inc:,.1f}M (operating margin {op_margin * 100:.2f}%).",
        f"Free Cash Flow produced was ${fcf:,.1f}M, supported by ${cash:,.1f}M in cash and equivalents.",
    ]

    return {
        "document_id": doc_id,
        "ticker": ticker,
        "company_name": c_name,
        "fiscal_year": year,
        "fiscal_quarter": quarter,
        "report_date": report_date or f"{year}-06-30",
        "summary": bullets,
        "profitability": {
            "total_revenue_millions": rev,
            "revenue_growth_yoy_pct": None,
            "gross_profit_millions": gp,
            "gross_margin_pct": round(gm * 100, 2),
            "operating_income_millions": op_inc,
            "operating_margin_pct": round(op_margin * 100, 2),
            "net_income_millions": net_inc,
            "net_margin_pct": round(net_margin * 100, 2),
            "eps_diluted_gaap": eps,
            "eps_diluted_nongaap": eps,
        },
        "cash_flow": {
            "operating_cash_flow_millions": ocf,
            "capital_expenditures_millions": capex,
            "free_cash_flow_millions": fcf,
            "fcf_conversion_rate_pct": fcf_conv,
        },
        "balance_sheet": {
            "cash_and_equivalents_millions": cash,
            "total_debt_millions": debt,
            "net_cash_millions": net_cash,
            "total_assets_millions": assets,
            "total_liabilities_millions": liab,
            "shareholders_equity_millions": equity,
            "debt_to_equity_ratio": debt_to_equity,
            "current_ratio": round(assets / liab, 2) if liab > 0 else None,
        },
    }

