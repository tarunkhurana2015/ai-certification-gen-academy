"""
PDF Text & Page Extractor Module.

Conforms to ARCHITECTURE.md Section 8 (app/ingestion/parsers/pdf_extractor.py).
Reads PDF documents page-by-page and extracts clean text with page alignment.
"""

import os
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional
from pypdf import PdfReader

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))


@dataclass(frozen=True)
class ExtractedPage:
    """Represents a single page extracted from a PDF document."""
    page_number: int       # 1-indexed human-readable page number
    text: str              # Cleaned text extracted from the page
    char_count: int        # Total character count
    is_blank: bool         # True if page has zero or whitespace-only text


@dataclass(frozen=True)
class PDFExtractionResult:
    """Contains the overall extraction output for an entire PDF."""
    file_name: str
    total_pages: int
    total_characters: int
    blank_page_count: int
    pages: List[ExtractedPage]
    metadata: Dict[str, Any]

    @property
    def blank_pages_count(self) -> int:
        return self.blank_page_count


def extract_text_by_pages(pdf_path: str | Path) -> PDFExtractionResult:
    """
    Extracts text page-by-page from a PDF file using pypdf.
    Maintains 1-indexed page alignment for grounded citations.
    """
    path = Path(pdf_path)
    if not path.is_file():
        raise FileNotFoundError(f"PDF file does not exist: {pdf_path}")

    try:
        reader = PdfReader(str(path))
    except Exception as e:
        raise ValueError(f"Failed to read PDF structure: {str(e)}") from e

    pages: List[ExtractedPage] = []
    total_chars = 0
    blank_count = 0

    for idx, page in enumerate(reader.pages):
        page_number = idx + 1
        try:
            raw_text = page.extract_text() or ""
        except Exception:
            raw_text = ""

        cleaned_text = raw_text.strip()
        char_count = len(cleaned_text)
        is_blank = (char_count == 0)

        if is_blank:
            blank_count += 1
        else:
            total_chars += char_count

        pages.append(
            ExtractedPage(
                page_number=page_number,
                text=cleaned_text,
                char_count=char_count,
                is_blank=is_blank,
            )
        )

    doc_metadata: Dict[str, Any] = {}
    if reader.metadata:
        for k, v in reader.metadata.items():
            if v:
                clean_k = str(k).lstrip("/").lower()
                doc_metadata[clean_k] = str(v)

    return PDFExtractionResult(
        file_name=path.name,
        total_pages=len(reader.pages),
        total_characters=total_chars,
        blank_page_count=blank_count,
        pages=pages,
        metadata=doc_metadata,
    )


if __name__ == "__main__":
    import json
    from datetime import datetime

    test_pdf = Path(sys.argv[1]) if len(sys.argv) > 1 else _SERVER_ROOT / "tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf"
    if not test_pdf.exists():
        print(f"❌ PDF not found at {test_pdf}")
        sys.exit(1)

    print(f"🚀 Extracting: {test_pdf.name}...")
    res = extract_text_by_pages(test_pdf)
    print(f"✅ Success! Extracted {res.total_pages} pages ({res.total_characters:,} characters).")

    artifact_dir = _SERVER_ROOT / ".artifact"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    base_slug = test_pdf.stem.lower().replace("-", "_").replace(".", "_")
    artifact_data = {
        "timestamp": datetime.now().isoformat(),
        "file_name": res.file_name,
        "total_pages": res.total_pages,
        "total_characters": res.total_characters,
        "blank_pages_count": res.blank_pages_count,
        "metadata": res.metadata,
        "pages": [asdict(p) for p in res.pages],
    }

    json_path = artifact_dir / f"01_extracted_{base_slug}.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(artifact_data, f, indent=2)

    md_path = artifact_dir / f"01_extracted_{base_slug}.md"
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(f"# 📑 Extracted PDF Pages Artifact: `{res.file_name}`\n\n")
        f.write(f"- **Timestamp**: `{artifact_data['timestamp']}`\n")
        f.write(f"- **Total Pages**: `{res.total_pages}`\n")
        f.write(f"- **Total Characters**: `{res.total_characters:,}`\n")
        f.write(f"- **Blank Pages Count**: `{res.blank_pages_count}`\n\n")
        for p in res.pages:
            f.write(f"## Page {p.page_number} ({p.char_count} chars)\n")
            f.write("```text\n" + (p.text[:400] + "..." if len(p.text) > 400 else p.text) + "\n```\n\n")

    print(f"📄 Saved Artifacts:\n  • {json_path}\n  • {md_path}")
