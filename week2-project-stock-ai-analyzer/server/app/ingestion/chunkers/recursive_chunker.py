"""
Recursive Text Chunker Module.

Conforms to ARCHITECTURE.md Section 8 (app/ingestion/chunkers/recursive_chunker.py).
Provides layout-agnostic recursive character splitting configured with:
- 1,000 character chunk size
- 100 character overlap
- Hierarchy of financial text separators: ["\\n\\n", "\\n", ". ", " ", ""]
"""

import sys
from pathlib import Path
from typing import List
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))


def create_financial_text_splitter(
    chunk_size: int = 1000,
    chunk_overlap: int = 100,
) -> RecursiveCharacterTextSplitter:
    """
    Creates a LangChain RecursiveCharacterTextSplitter configured for SEC filings
    and quarterly earnings releases.
    """
    return RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        separators=["\n\n", "\n", ". ", " ", ""],
        length_function=len,
        is_separator_regex=False,
    )


def split_page_text(
    text: str,
    chunk_size: int = 1000,
    chunk_overlap: int = 100,
) -> List[str]:
    """
    Splits a single page's text into raw character-bounded chunks.
    Filters out empty or whitespace-only splits.
    """
    if not text or not text.strip():
        return []

    splitter = create_financial_text_splitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
    )
    raw_splits = splitter.split_text(text)
    return [s.strip() for s in raw_splits if s and s.strip()]


if __name__ == "__main__":
    sample_text = (
        "Operating Activities: Cash provided by operating activities was $19,370 million.\n\n"
        "Investing Activities: Purchases of property and equipment were $8,473 million.\n\n"
        "Financing Activities: Repurchases of Class A common stock were $1,450 million."
    )
    splits = split_page_text(sample_text, chunk_size=100, chunk_overlap=20)
    print(f"🚀 Sample Recursive Split into {len(splits)} chunks:")
    for i, s in enumerate(splits):
        print(f"  [{i}]: {s[:50]}... ({len(s)} chars)")
