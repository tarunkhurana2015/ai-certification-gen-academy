"""
Unit tests for Jev Query Intent Classifier (Phase 4).
Matches week2-rag/2_metadata_filtering.ipynb.
Runs 100% in-memory without external network requirements.
"""

import os
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Dict

# Disable LangSmith tracing during tests to avoid network calls
os.environ["LANGCHAIN_TRACING_V2"] = "false"

# Ensure server root is on sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.classifier.jev_classifier import (
    QueryClassification,
    classify_query,
    get_jev_questions,
    save_artifact,
)


@dataclass
class DummyChoiceAnswer:
    choice: str
    confidence: float
    probabilities: Dict[str, float]


@dataclass
class DummyClassifierResponse:
    choices: Dict[str, DummyChoiceAnswer]


class MockTypeSafeClassifier:
    """Mock classifier mimicking TypeSafeClassifier.invoke() for unit tests."""

    def __init__(self, choices: Dict[str, DummyChoiceAnswer]):
        self._choices = choices

    def invoke(self, inputs: dict) -> DummyClassifierResponse:
        return DummyClassifierResponse(choices=self._choices)


def test_query_classification_model_filters():
    """Validates metadata and Chroma filter generation from QueryClassification."""
    # Case 1: Ticker only
    c1 = QueryClassification(
        query="What was Tesla revenue?",
        query_type="sql_kpi",
        ticker="TSLA",
        financial_domain=None,
    )
    assert c1.to_metadata_filter() == {"ticker": "TSLA"}
    assert c1.to_chroma_filter() == {"ticker": "TSLA"}

    # Case 2: Ticker and domain
    c2 = QueryClassification(
        query="Why did gross margin decline at Tesla?",
        query_type="hybrid_rag",
        ticker="TSLA",
        financial_domain="profitability",
    )
    assert c2.to_metadata_filter() == {"ticker": "TSLA", "financial_domain": "profitability"}
    chroma_filter = c2.to_chroma_filter()
    assert "$and" in chroma_filter
    assert len(chroma_filter["$and"]) == 2

    # Case 3: Multiple tickers or none
    c3 = QueryClassification(
        query="Compare Meta and Tesla",
        query_type="comparison",
        ticker="multiple",
        financial_domain=None,
    )
    assert c3.to_metadata_filter() == {}
    assert c3.to_chroma_filter() is None


def test_mock_classifier_sql_kpi():
    """Validates deterministic classification of exact KPI queries."""
    query = "What was Tesla Q2 2026 revenue and free cash flow?"
    result = classify_query(query, mock=True)
    assert result.query_type == "sql_kpi"
    assert result.ticker == "TSLA"
    assert result.financial_domain in ("profitability", "cash_flow")
    assert result.to_metadata_filter().get("ticker") == "TSLA"


def test_mock_classifier_hybrid_rag():
    """Validates deterministic classification of qualitative narrative queries."""
    query = "Why did automotive gross margin decline sequentially in Q2 2026?"
    result = classify_query(query, mock=True)
    assert result.query_type == "hybrid_rag"
    assert result.financial_domain == "profitability"
    assert result.ticker == "TSLA"
    assert result.to_metadata_filter() == {"ticker": "TSLA", "financial_domain": "profitability"}


def test_mock_classifier_comparison():
    """Validates deterministic classification of multi-company / peer comparison queries."""
    query = "Compare Meta and Tesla operating margins over the last year"
    result = classify_query(query, mock=True)
    assert result.query_type == "comparison"
    assert result.ticker == "multiple"
    assert result.financial_domain == "profitability"
    assert result.to_metadata_filter() == {"financial_domain": "profitability"}


def test_jev_questions_structure():
    """Validates that Jev questions define the 3 Choice questions with criteria."""
    questions = get_jev_questions()
    assert "query_type" in questions
    assert "financial_domain" in questions
    assert "ticker" in questions

    # Check criteria keys
    assert "sql_kpi" in questions["query_type"].criteria
    assert "hybrid_rag" in questions["query_type"].criteria
    assert "comparison" in questions["query_type"].criteria

    assert "profitability" in questions["financial_domain"].criteria
    assert "cash_flow" in questions["financial_domain"].criteria
    assert "none" in questions["financial_domain"].criteria

    assert "TSLA" in questions["ticker"].criteria
    assert "META" in questions["ticker"].criteria
    assert "multiple" in questions["ticker"].criteria
    assert "none" in questions["ticker"].criteria


def test_classify_query_with_mocked_jev():
    """Validates end-to-end classify_query unpacking using a mocked TypeSafeClassifier."""
    mock_choices = {
        "query_type": DummyChoiceAnswer(choice="sql_kpi", confidence=0.99, probabilities={"sql_kpi": 0.99}),
        "financial_domain": DummyChoiceAnswer(choice="cash_flow", confidence=0.95, probabilities={"cash_flow": 0.95}),
        "ticker": DummyChoiceAnswer(choice="TSLA", confidence=0.92, probabilities={"TSLA": 0.92}),
    }
    mock_classifier = MockTypeSafeClassifier(choices=mock_choices)

    # Note: set mock=False to exercise the Jev branch, with classifier injected
    os.environ["TYPESAFE_API_KEY"] = "dummy_key_for_test"
    result = classify_query(
        "What was Tesla free cash flow?",
        classifier=mock_classifier,
        mock=False,
    )

    assert result.query_type == "sql_kpi"
    assert result.financial_domain == "cash_flow"
    assert result.ticker == "TSLA"
    assert result.confidences["query_type"] == 0.99
    assert result.to_metadata_filter() == {"ticker": "TSLA", "financial_domain": "cash_flow"}


def test_classify_query_none_mapping():
    """Validates that 'none' answers are correctly mapped to None as in notebook line 608."""
    mock_choices = {
        "query_type": DummyChoiceAnswer(choice="hybrid_rag", confidence=0.91, probabilities={}),
        "financial_domain": DummyChoiceAnswer(choice="none", confidence=0.88, probabilities={}),
        "ticker": DummyChoiceAnswer(choice="none", confidence=0.85, probabilities={}),
    }
    mock_classifier = MockTypeSafeClassifier(choices=mock_choices)
    os.environ["TYPESAFE_API_KEY"] = "dummy_key_for_test"

    result = classify_query("Explain macro headwinds", classifier=mock_classifier, mock=False)
    assert result.query_type == "hybrid_rag"
    assert result.financial_domain is None
    assert result.ticker is None
    assert result.to_metadata_filter() == {}
    assert result.to_chroma_filter() is None


def test_save_artifact_roundtrip():
    """Validates markdown artifact generation."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        art_path = Path(tmp_dir) / "test_artifact.md"
        sample_results = [
            QueryClassification(
                query="What was Tesla Q2 revenue?",
                query_type="sql_kpi",
                ticker="TSLA",
                financial_domain="profitability",
                confidences={"query_type": 1.0, "financial_domain": 0.95, "ticker": 1.0},
            )
        ]
        saved = save_artifact(sample_results, output_path=art_path)
        assert saved.exists()
        content = saved.read_text(encoding="utf-8")
        assert "TypeSafe Query Intent Classifier Artifact (`idx_05`)" in content
        assert "What was Tesla Q2 revenue?" in content
        assert "SQL_KPI" in content
        assert "TSLA" in content


if __name__ == "__main__":
    print("\nRunning test_classifier.py...")
    test_query_classification_model_filters()
    print("  ✓ test_query_classification_model_filters passed")

    test_mock_classifier_sql_kpi()
    print("  ✓ test_mock_classifier_sql_kpi passed")

    test_mock_classifier_hybrid_rag()
    print("  ✓ test_mock_classifier_hybrid_rag passed")

    test_mock_classifier_comparison()
    print("  ✓ test_mock_classifier_comparison passed")

    test_jev_questions_structure()
    print("  ✓ test_jev_questions_structure passed")

    test_classify_query_with_mocked_jev()
    print("  ✓ test_classify_query_with_mocked_jev passed")

    test_classify_query_none_mapping()
    print("  ✓ test_classify_query_none_mapping passed")

    test_save_artifact_roundtrip()
    print("  ✓ test_save_artifact_roundtrip passed")

    print("\nAll 8 classifier unit tests passed successfully!\n")
