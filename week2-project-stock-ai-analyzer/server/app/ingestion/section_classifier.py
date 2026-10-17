"""
Financial Section Classifier & Domain Tagger
=============================================
Component: Step 1.3 in PDF Ingestion Pipeline

Purpose:
1. Scan page headings and GAAP accounting terms to classify each PDF page into a
   standard FinancialDomain enum:
   - PROFITABILITY (Statements of Operations, Income Statement, EPS)
   - BALANCE_SHEET (Assets, Liabilities, Shareholders' Equity)
   - CASH_FLOW (Operating Cash Flow, CapEx, Free Cash Flow)
   - GUIDANCE_OUTLOOK (CFO Outlook, Forward Guidance, Full-Year Targets)
   - RISK_FACTORS (Forward-Looking Disclosures, Item 1A Risks)
   - GENERAL (Cover, Highlights, Product photos, Executive commentary)

Why this matters:
-----------------
1. Saves 80% on LLM token costs by only passing financial statement pages
   (profitability, balance_sheet, cash_flow) to the structured KPI extractor.
2. Serves as hard metadata pre-filters in vector retrieval (Pinecone / ChromaDB),
   preventing cross-statement confusion during user queries.
"""

from dataclasses import dataclass, field
from enum import Enum
import re
from typing import Dict, List, Optional, Set, Tuple

from app.ingestion.pdf_extractor import ExtractedPage


class FinancialDomain(str, Enum):
    """
    Standardized taxonomy of financial domains matching SEC Regulation S-X.
    """
    PROFITABILITY = "profitability"
    BALANCE_SHEET = "balance_sheet"
    CASH_FLOW = "cash_flow"
    GUIDANCE_OUTLOOK = "guidance_outlook"
    RISK_FACTORS = "risk_factors"
    GENERAL = "general"


@dataclass(frozen=True)
class PageClassification:
    """
    Outcome of classifying an individual PDF page into a FinancialDomain.

    Attributes:
        page_number: 1-indexed page number from the source document.
        domain: Assigned FinancialDomain enum.
        confidence: Calibrated confidence score between 0.0 and 1.0.
        matched_signals: List of specific keywords/titles detected on the page.
    """
    page_number: int
    domain: FinancialDomain
    confidence: float
    matched_signals: List[str] = field(default_factory=list)


# -------------------------------------------------------------------------
# Typography Normalization
# -------------------------------------------------------------------------
def normalize_header_text(text: str) -> str:
    """
    Normalizes typography to handle stylistic choices across corporate designers.
    Specifically collapses letter-spaced headers such as:
      'B A L A N C E   S H E E T'  -->  'BALANCESHEET'
      'O U T L O O K'              -->  'OUTLOOK'
    """
    # Collapse single-letter spacing (e.g. 'B A L A N C E' -> 'BALANCE')
    collapsed = re.sub(r"(\b[A-Za-z])\s+(?=[A-Za-z]\b)", r"\1", text)
    # Lowercase and remove punctuation
    cleaned = re.sub(r"[^a-zA-Z0-9\s]", " ", collapsed).lower()
    # Normalize multiple whitespace to single space
    return " ".join(cleaned.split())


# -------------------------------------------------------------------------
# Universal GAAP Anchor Dictionaries
# -------------------------------------------------------------------------
DOMAIN_TITLE_PATTERNS: Dict[FinancialDomain, List[str]] = {
    FinancialDomain.PROFITABILITY: [
        "statements of income",
        "statement of income",
        "statements of operations",
        "statement of operations",
        "income statement",
        "statements of earnings",
        "statement of earnings",
        "consolidated statements of income",
        "condensed consolidated statements of income",
        "condensed consolidated statements of operations",
        "revenues",
    ],
    FinancialDomain.BALANCE_SHEET: [
        "balance sheet",
        "balance sheets",
        "balancesheet",
        "balancesheets",
        "statements of financial position",
        "statement of financial position",
        "condensed consolidated balance sheets",
        "consolidated balance sheets",
    ],
    FinancialDomain.CASH_FLOW: [
        "statements of cash flows",
        "statement of cash flows",
        "cash flows from operating activities",
        "condensed consolidated statements of cash flows",
        "consolidated statements of cash flows",
        "reconciliation of gaap to non gaap",
        "reconciliation of gaap to non gaap financial information",
        "non gaap financial measures",
    ],
    FinancialDomain.GUIDANCE_OUTLOOK: [
        "cfo outlook commentary",
        "outlook",
        "cfo outlook",
        "financial outlook",
        "guidance",
        "business outlook",
    ],
    FinancialDomain.RISK_FACTORS: [
        "forward looking statements",
        "forward looking statement",
        "risk factors",
        "item 1a risk factors",
        "safe harbor",
    ],
}

DOMAIN_BODY_KEYWORDS: Dict[FinancialDomain, List[str]] = {
    FinancialDomain.PROFITABILITY: [
        "cost of revenue",
        "cost of sales",
        "research and development",
        "marketing and sales",
        "general and administrative",
        "income from operations",
        "operating income",
        "net income",
        "diluted earnings per share",
        "diluted eps",
        "operating margin",
    ],
    FinancialDomain.BALANCE_SHEET: [
        "cash and cash equivalents",
        "marketable securities",
        "accounts receivable",
        "total current assets",
        "property and equipment",
        "total assets",
        "accounts payable",
        "current liabilities",
        "total current liabilities",
        "long term debt",
        "total liabilities",
        "stockholders equity",
        "shareholders equity",
        "retained earnings",
    ],
    FinancialDomain.CASH_FLOW: [
        "cash flows from operating activities",
        "cash flows from investing activities",
        "cash flows from financing activities",
        "net cash provided by operating activities",
        "purchases of property and equipment",
        "capital expenditures",
        "principal payments on finance leases",
        "free cash flow",
        "payments for dividends",
    ],
    FinancialDomain.GUIDANCE_OUTLOOK: [
        "we expect",
        "total revenue to be in the range",
        "guidance assumes",
        "full year",
        "expense outlook",
        "we anticipate",
        "outlook for",
    ],
    FinancialDomain.RISK_FACTORS: [
        "forward looking statements",
        "actual results may differ",
        "factors including",
        "regulatory matters",
        "material adverse effect",
        "scrutiny",
    ],
}


def classify_page(page: ExtractedPage) -> PageClassification:
    """
    Classifies a single extracted page into its FinancialDomain using
    normalized typography and weighted GAAP terminology scoring.

    Scoring Model:
    - Title match in header zone (top 5 lines): 3.0 points
    - Body keyword match: 1.0 point
    - Minimum threshold for non-general assignment: 2.5 points

    Args:
        page: ExtractedPage object containing page_number and raw text.

    Returns:
        PageClassification with assigned domain and confidence.
    """
    if page.is_blank or not page.text.strip():
        return PageClassification(
            page_number=page.page_number,
            domain=FinancialDomain.GENERAL,
            confidence=1.0,
            matched_signals=["blank_page"],
        )

    lines = [line.strip() for line in page.text.splitlines() if line.strip()]
    if not lines:
        return PageClassification(
            page_number=page.page_number,
            domain=FinancialDomain.GENERAL,
            confidence=1.0,
            matched_signals=["empty_lines"],
        )

    # 1. Header Zone: Check the first 5 lines for primary title matches
    header_zone = " ".join(lines[:5])
    normalized_header = normalize_header_text(header_zone)

    # 2. Body Zone: Full page text normalized
    normalized_full_body = normalize_header_text(page.text)

    domain_scores: Dict[FinancialDomain, float] = {d: 0.0 for d in FinancialDomain if d != FinancialDomain.GENERAL}
    domain_matches: Dict[FinancialDomain, List[str]] = {d: [] for d in FinancialDomain if d != FinancialDomain.GENERAL}

    # Evaluate Title Patterns (Weight = 3.0)
    for domain, titles in DOMAIN_TITLE_PATTERNS.items():
        for title in titles:
            if title in normalized_header:
                domain_scores[domain] += 3.0
                domain_matches[domain].append(f"Title: '{title}'")
                break  # Award title score once per domain

    # Evaluate Body Keywords (Weight = 1.0 each)
    for domain, keywords in DOMAIN_BODY_KEYWORDS.items():
        for kw in keywords:
            if kw in normalized_full_body:
                domain_scores[domain] += 1.0
                domain_matches[domain].append(f"Body: '{kw}'")

    # Find the top-scoring domain
    best_domain = FinancialDomain.GENERAL
    best_score = 0.0
    matched_signals: List[str] = []

    for domain, score in domain_scores.items():
        if score > best_score:
            best_score = score
            best_domain = domain
            matched_signals = domain_matches[domain]

    # Threshold check: requires at least 2.5 points to avoid false positives
    MIN_CONFIDENCE_THRESHOLD = 2.5
    if best_score < MIN_CONFIDENCE_THRESHOLD:
        return PageClassification(
            page_number=page.page_number,
            domain=FinancialDomain.GENERAL,
            confidence=0.5,
            matched_signals=["below_threshold"],
        )

    # Calibrate confidence score between 0.6 and 1.0
    confidence = min(1.0, 0.5 + (best_score / 10.0))

    return PageClassification(
        page_number=page.page_number,
        domain=best_domain,
        confidence=round(confidence, 2),
        matched_signals=matched_signals,
    )


def classify_document_pages(pages: List[ExtractedPage]) -> List[PageClassification]:
    """
    Classifies an entire multi-page document page-by-page.

    Args:
        pages: List of ExtractedPage objects.

    Returns:
        List of PageClassification objects aligned with each page.
    """
    return [classify_page(page) for page in pages]
