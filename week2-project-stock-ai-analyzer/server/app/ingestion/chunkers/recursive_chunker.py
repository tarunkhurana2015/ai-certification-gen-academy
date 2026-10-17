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
    import argparse
    import json
    from datetime import datetime
    from app.ingestion.parsers.pdf_extractor import extract_text_by_pages

    parser = argparse.ArgumentParser(description="Split PDF text recursively into character-bounded chunks.")
    parser.add_argument("pdf_path", nargs="?", default=None, help="Path to PDF filing")
    parser.add_argument("--chunk-size", type=int, default=1000, help="Max chunk size in characters (default: 1000)")
    parser.add_argument("--chunk-overlap", type=int, default=100, help="Overlap size in characters (default: 100)")
    args = parser.parse_args()

    test_pdf = Path(args.pdf_path) if args.pdf_path else _SERVER_ROOT / "tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if not test_pdf.exists():
        print(f"❌ PDF not found at {test_pdf}")
        sys.exit(1)

    print(f"🚀 Running Recursive Text Chunker on: {test_pdf.name}")
    print(f"⚙️ Configuration: chunk_size={args.chunk_size}, chunk_overlap={args.chunk_overlap}")

    extraction_res = extract_text_by_pages(test_pdf)
    print(f"📄 Extracted {extraction_res.total_pages} pages ({extraction_res.total_characters:,} characters)")

    pages_splits = []
    total_splits_count = 0

    for page in extraction_res.pages:
        if page.is_blank or not page.text.strip():
            continue

        raw_splits = split_page_text(
            text=page.text,
            chunk_size=args.chunk_size,
            chunk_overlap=args.chunk_overlap,
        )
        total_splits_count += len(raw_splits)
        pages_splits.append({
            "page_number": page.page_number,
            "char_count": page.char_count,
            "split_count": len(raw_splits),
            "splits": [
                {
                    "split_index": idx,
                    "char_count": len(s),
                    "text": s,
                }
                for idx, s in enumerate(raw_splits)
            ]
        })

    print(f"✅ Generated {total_splits_count} raw splits across {len(pages_splits)} non-blank pages!")

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    base_slug = test_pdf.stem.lower().replace("-", "_").replace(".", "_")
    artifact_data = {
        "timestamp": datetime.now().isoformat(),
        "pdf_name": test_pdf.name,
        "total_pages": extraction_res.total_pages,
        "non_blank_pages": len(pages_splits),
        "chunk_size": args.chunk_size,
        "chunk_overlap": args.chunk_overlap,
        "total_splits": total_splits_count,
        "pages": pages_splits,
    }

    json_path = artifact_dir / f"03a_recursive_splits_{base_slug}.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(artifact_data, f, indent=2)

    md_path = artifact_dir / f"03a_recursive_splits_{base_slug}.md"
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(f"# ✂️ Recursive Text Splits Artifact: `{test_pdf.name}`\n\n")
        f.write(f"- **Timestamp**: `{artifact_data['timestamp']}`\n")
        f.write(f"- **Source File**: `{test_pdf.name}`\n")
        f.write(f"- **Total Source Pages**: `{extraction_res.total_pages}`\n")
        f.write(f"- **Non-Blank Pages Split**: `{len(pages_splits)}`\n")
        f.write(f"- **Total Raw Splits Produced**: `{total_splits_count}`\n")
        f.write(f"- **Chunk Size / Overlap**: `{args.chunk_size}` / `{args.chunk_overlap}` chars\n\n")

        f.write("## Page-by-Page Splits Breakdown\n\n")
        for p in pages_splits:
            f.write(f"### 📄 Page {p['page_number']} ({p['split_count']} splits, {p['char_count']:,} characters)\n\n")
            for s in p["splits"]:
                f.write(f"#### Split {s['split_index'] + 1}/{p['split_count']} ({s['char_count']} chars)\n\n")
                f.write("```text\n" + s["text"] + "\n```\n\n")

    print(f"\n📄 Saved Artifacts:\n  • {json_path}\n  • {md_path}")
