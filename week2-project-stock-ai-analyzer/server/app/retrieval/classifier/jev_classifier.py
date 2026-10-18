"""
TypeSafe Query Intent Classifier (Jev) - Phase 4.

Directly patterned after week2-rag/2_metadata_filtering.ipynb (lines 562-612).
Uses TypeSafe's Jev decision model to classify financial queries into:
1. query_type: sql_kpi (deterministic database), hybrid_rag (qualitative narrative/reasons), comparison (multi-quarter/peers)
2. financial_domain: profitability, cash_flow, balance_sheet, guidance_outlook, or None
3. ticker: TSLA, META, AAPL, multiple, or None
"""

import os
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

from dotenv import load_dotenv
from pydantic import BaseModel, Field

# LangChain TypeSafe integration
try:
    from langchain_typesafe import Choice, TypeSafeClassifier
except ImportError:
    Choice = None  # type: ignore
    TypeSafeClassifier = None  # type: ignore

load_dotenv()

DEFAULT_ARTIFACT_PATH = (
    Path(__file__).resolve().parent.parent.parent.parent / ".artifact" / "idx_05_classifier_sample.md"
)


class QueryClassification(BaseModel):
    """Structured output of Jev classifier matching notebook's decision model."""

    query: str
    query_type: str  # "sql_kpi", "hybrid_rag", "comparison"
    financial_domain: Optional[str] = None  # "profitability", "cash_flow", etc., or None
    ticker: Optional[str] = None  # "TSLA", "META", "AAPL", "multiple", or None
    confidences: Dict[str, float] = Field(default_factory=dict)
    probabilities: Dict[str, Dict[str, float]] = Field(default_factory=dict)

    def to_metadata_filter(self) -> Dict[str, Any]:
        """Returns clean metadata filter for BM25 and Chroma retrieval."""
        filter_dict: Dict[str, Any] = {}
        if self.ticker and self.ticker not in ("multiple", "none"):
            filter_dict["ticker"] = self.ticker
        if self.financial_domain and self.financial_domain != "none":
            filter_dict["financial_domain"] = self.financial_domain
        return filter_dict

    def to_chroma_filter(self) -> Optional[Dict[str, Any]]:
        """Returns ChromaDB-compatible where filter."""
        flat = self.to_metadata_filter()
        if not flat:
            return None
        if len(flat) == 1:
            return flat
        return {"$and": [{k: v} for k, v in flat.items()]}


def get_jev_questions() -> Dict[str, Any]:
    """Defines Choice questions and criteria matching week2-rag/2_metadata_filtering.ipynb."""
    if Choice is None:
        raise ImportError("langchain-typesafe is not installed.")

    return {
        "query_type": Choice(
            instructions="What is the primary objective of this financial query?",
            criteria={
                "sql_kpi": "Asks for exact, audited financial metrics, numbers, or balance sheet / cash flow figures for a specific quarter",
                "hybrid_rag": "Asks for qualitative explanations, narrative context, business reasons, management commentary, or risks",
                "comparison": "Compares metrics between multiple companies or analyzes trends across multiple quarters",
            },
        ),
        "financial_domain": Choice(
            instructions="Which specific financial domain or statement is being asked about?",
            criteria={
                "profitability": "Revenues, gross margin, operating margin, net income, EPS, or profit margins",
                "cash_flow": "Operating cash flow, capital expenditures (CapEx), free cash flow, or working capital",
                "balance_sheet": "Cash and cash equivalents, total debt, assets, liabilities, or liquidity",
                "guidance_outlook": "Future outlook, delivery targets, growth projections, or strategic commentary",
                "none": "General financial questions or multiple domains spanned",
            },
        ),
        "ticker": Choice(
            instructions="Which public company ticker does the query refer to?",
            criteria={
                "TSLA": "Tesla, Inc. only (automotive, energy, Elon Musk, Cybercab, robotaxi)",
                "META": "Meta Platforms only (Facebook, Instagram, WhatsApp, Reality Labs, Zuckerberg)",
                "AAPL": "Apple Inc. only (iPhone, iPad, Mac, Services, Tim Cook)",
                "multiple": "Compares or mentions multiple companies (e.g. Meta vs Tesla)",
                "none": "No specific company ticker mentioned",
            },
        ),
    }


def _mock_classify(query: str) -> QueryClassification:
    """Deterministic, offline rule-based classifier for tests and restricted networks."""
    q_lower = query.lower()

    # 1. Query Type
    if any(k in q_lower for k in ["compare", "vs", "versus", "across", "peers", "trend"]):
        q_type = "comparison"
    elif any(
        k in q_lower
        for k in [
            "why",
            "reason",
            "explain",
            "driver",
            "commentary",
            "narrative",
            "risks",
            "outlook",
            "guidance",
        ]
    ):
        q_type = "hybrid_rag"
    else:
        q_type = "sql_kpi"

    # 2. Financial Domain
    if any(k in q_lower for k in ["free cash flow", "cash flow", "capex", "fcf", "operating cash"]):
        domain = "cash_flow"
    elif any(k in q_lower for k in ["revenue", "gross margin", "margin", "profit", "net income", "eps"]):
        domain = "profitability"
    elif any(k in q_lower for k in ["balance sheet", "debt", "cash and", "total debt", "liabilities", "assets"]):
        domain = "balance_sheet"
    elif any(k in q_lower for k in ["outlook", "guidance", "target", "projection"]):
        domain = "guidance_outlook"
    else:
        domain = None

    # 3. Ticker
    has_tsla = any(k in q_lower for k in ["tsla", "tesla", "cybercab", "robotaxi", "automotive"])
    has_meta = any(k in q_lower for k in ["meta", "facebook", "zuckerberg", "instagram"])
    has_aapl = any(k in q_lower for k in ["aapl", "apple", "iphone"])

    ticker_count = sum([bool(has_tsla), bool(has_meta), bool(has_aapl)])
    if ticker_count > 1:
        ticker = "multiple"
    elif has_tsla:
        ticker = "TSLA"
    elif has_meta:
        ticker = "META"
    elif has_aapl:
        ticker = "AAPL"
    else:
        ticker = None

    return QueryClassification(
        query=query,
        query_type=q_type,
        financial_domain=domain,
        ticker=ticker,
        confidences={"query_type": 1.0, "financial_domain": 1.0, "ticker": 1.0},
        probabilities={},
    )


def classify_query(
    query: str,
    classifier: Optional[Any] = None,
    mock: bool = False,
) -> QueryClassification:
    """
    Classifies a user query using Jev (TypeSafeClassifier) or mock fallback.

    Matches notebook lines 601-610:
    jev_answers = jev.invoke({"state": user_question, "questions": jev_questions}).choices
    """
    if mock or not os.getenv("TYPESAFE_API_KEY") or TypeSafeClassifier is None:
        return _mock_classify(query)

    jev = classifier or TypeSafeClassifier()
    questions = get_jev_questions()

    try:
        response = jev.invoke({"state": query, "questions": questions})
        choices = response.choices

        confidences = {k: v.confidence for k, v in choices.items()}
        probabilities = {k: getattr(v, "probabilities", {}) for k, v in choices.items()}

        # Map "none" back to None as in notebook line 608
        q_type = choices["query_type"].choice
        raw_domain = choices["financial_domain"].choice
        fin_domain = None if raw_domain == "none" else raw_domain

        raw_ticker = choices["ticker"].choice
        ticker = None if raw_ticker == "none" else raw_ticker

        return QueryClassification(
            query=query,
            query_type=q_type,
            financial_domain=fin_domain,
            ticker=ticker,
            confidences=confidences,
            probabilities=probabilities,
        )
    except Exception as e:
        print(f"[JevClassifier] Live call failed ({e}), falling back to deterministic mock.")
        return _mock_classify(query)


def save_artifact(
    classifications: List[QueryClassification],
    output_path: Optional[Path] = None,
) -> Path:
    """Saves classifier results and routing decisions to markdown artifact."""
    target_path = output_path or DEFAULT_ARTIFACT_PATH
    target_path.parent.mkdir(parents=True, exist_ok=True)

    lines = [
        "# 🎯 TypeSafe Query Intent Classifier Artifact (`idx_05`)",
        "",
        f"- **Generated At**: `{datetime.now().isoformat()}`",
        f"- **Classifier Model**: `TypeSafe Jev (Decision Model)`",
        f"- **Reference**: `week2-rag/2_metadata_filtering.ipynb`",
        f"- **Total Sample Queries Evaluated**: `{len(classifications)}`",
        "",
        "## 🧭 Query Routing & Filtering Decisions",
        "",
    ]

    for i, c in enumerate(classifications, 1):
        lines.append(f"### Query {i}: \"{c.query}\"")
        lines.append(f"- **Routed To**: `{c.query_type.upper()}`")
        lines.append(f"- **Detected Ticker**: `{c.ticker or 'None'}`")
        lines.append(f"- **Financial Domain**: `{c.financial_domain or 'None'}`")
        lines.append(f"- **Metadata Filter**: `{c.to_metadata_filter()}`")
        lines.append(f"- **Chroma Filter**: `{c.to_chroma_filter()}`")
        lines.append("- **Calibrated Confidences**:")
        for k, v in c.confidences.items():
            lines.append(f"  - `{k}`: {v:.2f}")
        lines.append("")

    content = "\n".join(lines)
    with open(target_path, "w", encoding="utf-8") as f:
        f.write(content)

    return target_path


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Jev Query Intent Classifier CLI")
    parser.add_argument("query", nargs="?", default=None, help="Query string to classify")
    parser.add_argument("--mock", action="store_true", help="Run offline with mock classifier")
    args = parser.parse_args()

    if args.query:
        sample_queries = [args.query]
    else:
        sample_queries = [
            "What was Tesla Q2 2026 revenue and free cash flow?",
            "Why did automotive gross margin decline sequentially in Q2 2026?",
            "Compare Meta and Tesla operating margins over the last year",
        ]

    results = [classify_query(q, mock=args.mock) for q in sample_queries]
    for r in results:
        print(f"Query: {r.query}")
        print(f" -> query_type      : {r.query_type} (conf {r.confidences.get('query_type', 1.0):.2f})")
        print(f" -> financial_domain: {r.financial_domain} (conf {r.confidences.get('financial_domain', 1.0):.2f})")
        print(f" -> ticker          : {r.ticker} (conf {r.confidences.get('ticker', 1.0):.2f})")
        print(f" -> metadata_filter : {r.to_metadata_filter()}\n")

    art_path = save_artifact(results)
    print(f"Saved artifact to {art_path}")
