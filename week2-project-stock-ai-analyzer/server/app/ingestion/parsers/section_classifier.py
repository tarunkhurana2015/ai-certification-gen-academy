"""
Layout & Section Domain Classifier Module.

Conforms to ARCHITECTURE.md Section 8 (app/ingestion/parsers/section_classifier.py).
Tags each page with its primary financial domain using typography normalization,
SEC Regulation S-X anchor keywords, and weighted scoring.
"""

import re
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Dict, List, Set, Tuple

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.schemas.common import FinancialDomain
from app.ingestion.parsers.pdf_extractor import ExtractedPage, extract_text_by_pages


@dataclass(frozen=True)
class PageClassification:
    """The classified financial domain and confidence score for a page."""
    page_number: int
    domain: FinancialDomain
    confidence: float
    matched_signals: List[str] = field(default_factory=list)


# Universal GAAP keywords defined by SEC Regulation S-X
_DOMAIN_ANCHORS: Dict[FinancialDomain, Dict[str, Set[str]]] = {
    FinancialDomain.PROFITABILITY: {
        "headers": {
            "statement of operations",
            "statements of operations",
            "statement of income",
            "statements of income",
            "statement of earnings",
            "statements of earnings",
            "income statement",
            "income statements",
            "condensed consolidated statements of income",
            "condensed consolidated statements of operations",
            "statement of comprehensive income",
            "revenues",
            "financial summary",
        },
        "body": {
            "revenue",
            "total revenue",
            "cost of revenue",
            "gross profit",
            "gross margin",
            "operating income",
            "income from operations",
            "operating margin",
            "net income",
            "diluted eps",
            "earnings per share",
            "research and development",
            "general and administrative",
            "marketing expense",
        },
    },
    FinancialDomain.BALANCE_SHEET: {
        "headers": {
            "balance sheet",
            "balance sheets",
            "consolidated balance sheet",
            "consolidated balance sheets",
            "condensed consolidated balance sheets",
            "statement of financial position",
            "statements of financial position",
        },
        "body": {
            "current assets",
            "total assets",
            "cash and cash equivalents",
            "marketable securities",
            "accounts receivable",
            "current liabilities",
            "total liabilities",
            "long-term debt",
            "accounts payable",
            "stockholders equity",
            "shareholders equity",
            "retained earnings",
            "total liabilities and stockholders equity",
        },
    },
    FinancialDomain.CASH_FLOW: {
        "headers": {
            "statement of cash flows",
            "statements of cash flows",
            "condensed consolidated statements of cash flows",
            "cash flow statement",
            "cash flows",
            "free cash flow",
            "reconciliation of gaap to non gaap",
            "non gaap financial measures",
        },
        "body": {
            "operating activities",
            "investing activities",
            "financing activities",
            "cash provided by operating activities",
            "capital expenditures",
            "purchases of property and equipment",
            "free cash flow",
            "depreciation and amortization",
            "stock-based compensation",
        },
    },
    FinancialDomain.GUIDANCE_OUTLOOK: {
        "headers": {
            "cfo outlook commentary",
            "outlook",
            "guidance",
            "business outlook",
            "financial outlook",
            "forward looking guidance",
            "full year outlook",
            "quarter outlook",
        },
        "body": {
            "we expect",
            "we anticipate",
            "projected revenue",
            "guidance for the full year",
            "first quarter outlook",
            "second quarter outlook",
            "third quarter outlook",
            "fourth quarter outlook",
            "capital expenditures will be",
        },
    },
    FinancialDomain.RISK_FACTORS: {
        "headers": {
            "forward looking statements",
            "safe harbor",
            "cautionary note",
            "risk factors",
            "special note regarding forward looking",
        },
        "body": {
            "subject to risks and uncertainties",
            "actual results may differ",
            "differ materially",
            "safe harbor statement",
            "private securities litigation reform act",
            "assumes no obligation to update",
        },
    },
}


def normalize_header_text(line: str) -> str:
    """Normalizes spaced typography (e.g. 'B A L A N C E  S H E E T' -> 'BALANCESHEET')."""
    cleaned = re.sub(r"[^\w\s]", "", line.lower()).strip()
    collapsed = re.sub(r"(\b[a-z])\s+(?=[a-z]\b)", r"\1", cleaned)
    return collapsed


def classify_page(page: ExtractedPage) -> PageClassification:
    """Classifies an individual page into a FinancialDomain with calibrated confidence."""
    if page.is_blank:
        return PageClassification(
            page_number=page.page_number,
            domain=FinancialDomain.GENERAL,
            confidence=1.0,
            matched_signals=["blank_page"],
        )

    lines = [ln.strip() for ln in page.text.split("\n") if ln.strip()]
    top_5_lines = lines[:5]
    top_header_normalized = " ".join([normalize_header_text(ln) for ln in top_5_lines])
    body_normalized = re.sub(r"[^\w\s]", " ", page.text.lower())

    best_domain = FinancialDomain.GENERAL
    highest_score = 0
    signals_for_best: List[str] = []

    for domain, anchors in _DOMAIN_ANCHORS.items():
        score = 0
        current_signals: List[str] = []

        for h in anchors["headers"]:
            clean_h = re.sub(r"[^\w\s]", "", h)
            clean_h_collapsed = clean_h.replace(" ", "")
            if clean_h in top_header_normalized or clean_h_collapsed in top_header_normalized.replace(" ", ""):
                score += 5  # Strong header match
                current_signals.append(f"Title: '{h}'")
                break

        body_matches = 0
        for kw in anchors["body"]:
            clean_kw = f" {kw} "
            if clean_kw in f" {body_normalized} ":
                body_matches += 1
                if len(current_signals) < 4:
                    current_signals.append(f"Body: '{kw}'")

        score += min(body_matches, 6)

        if score > highest_score:
            highest_score = score
            best_domain = domain
            signals_for_best = current_signals

    if highest_score >= 5:
        confidence = 1.0
    elif highest_score >= 3:
        confidence = 0.8
    elif highest_score >= 2:
        confidence = 0.6
    else:
        best_domain = FinancialDomain.GENERAL
        confidence = 0.5
        signals_for_best = ["below_threshold"]

    return PageClassification(
        page_number=page.page_number,
        domain=best_domain,
        confidence=confidence,
        matched_signals=signals_for_best,
    )


def classify_document_pages(pages: List[ExtractedPage]) -> List[PageClassification]:
    """Classifies all pages in a document sequentially."""
    return [classify_page(page) for page in pages]


if __name__ == "__main__":
    import json
    from datetime import datetime

    test_pdf = Path(sys.argv[1]) if len(sys.argv) > 1 else _SERVER_ROOT / "tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if not test_pdf.exists():
        print(f"❌ PDF not found at {test_pdf}")
        sys.exit(1)

    print(f"🚀 Classifying sections for: {test_pdf.name}...")
    res = extract_text_by_pages(test_pdf)
    classifications = classify_document_pages(res.pages)

    print(f"\n📊 Classification Summary for {test_pdf.name}:")
    for c in classifications:
        print(f"  Page {c.page_number:02d} ──▶ {c.domain.value:<18} (Confidence: {c.confidence:.2f}) | {', '.join(c.matched_signals[:2])}")

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    base_slug = test_pdf.stem.lower().replace("-", "_").replace(".", "_")
    artifact_data = {
        "timestamp": datetime.now().isoformat(),
        "file_name": test_pdf.name,
        "total_pages": len(classifications),
        "classifications": [
            {
                "page_number": c.page_number,
                "domain": c.domain.value,
                "confidence": c.confidence,
                "matched_signals": c.matched_signals,
            }
            for c in classifications
        ],
    }

    json_path = artifact_dir / f"02_classified_{base_slug}.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(artifact_data, f, indent=2)

    md_path = artifact_dir / f"02_classified_{base_slug}.md"
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(f"# 🏷️ Classified Sections Artifact: `{test_pdf.name}`\n\n")
        f.write(f"- **Timestamp**: `{artifact_data['timestamp']}`\n")
        f.write(f"- **Total Pages**: `{len(classifications)}`\n\n")
        f.write("| Page | Financial Domain | Confidence | Matched Signals |\n")
        f.write("| :--- | :--- | :--- | :--- |\n")
        for c in classifications:
            signals = "<br/>".join(c.matched_signals)
            f.write(f"| {c.page_number} | **`{c.domain.value}`** | `{c.confidence:.2f}` | {signals} |\n")

    print(f"\n📄 Saved Artifacts:\n  • {json_path}\n  • {md_path}")
