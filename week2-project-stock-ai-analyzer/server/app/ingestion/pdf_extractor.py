"""
PDF Text and Page Extractor
============================
Component: Step 1.2 in PDF Ingestion Pipeline

Purpose:
1. Extract raw text from a PDF document on a page-by-page basis.
2. Preserve 1-indexed page numbers for every extracted chunk, ensuring
   downstream RAG answers can provide verified, clickable page citations
   (e.g., 'Gross margin was 45.4% [Page 14]').
3. Collect document-level metadata (total pages, character count, title).

Why page-by-page extraction?
----------------------------
In financial auditing and regulatory compliance, an AI analyst must NEVER
make untraceable assertions. By tagging every text segment with its source page
number upfront, the entire pipeline (chunking -> vector index -> LLM synthesis)
maintains strict chain-of-custody citations back to the exact page of the filing.
"""

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Union
from pypdf import PdfReader


@dataclass(frozen=True)
class ExtractedPage:
    """
    Text and metadata for an individual PDF page.

    Attributes:
        page_number: 1-indexed page number (Page 1 is the cover/first page).
        text: Extracted text content, stripped of leading/trailing whitespace.
        char_count: Length of the extracted text string.
        is_blank: True if no readable text could be extracted (e.g. scanned image).
    """
    page_number: int
    text: str
    char_count: int
    is_blank: bool


@dataclass
class PDFExtractionResult:
    """
    Complete outcome of extracting a multi-page PDF document.

    Attributes:
        file_path: Absolute path to the PDF on disk.
        total_pages: Total number of pages in the PDF.
        total_characters: Sum of all characters across all readable pages.
        pages: List of individual ExtractedPage objects.
        metadata: Raw PDF document info dictionary (Title, Author, Producer, etc.).
        blank_page_count: Count of pages with zero extractable text.
    """
    file_path: str
    total_pages: int
    total_characters: int
    pages: List[ExtractedPage]
    metadata: Dict[str, Any] = field(default_factory=dict)
    blank_page_count: int = 0


def extract_text_by_pages(file_path: Union[str, Path]) -> PDFExtractionResult:
    """
    Reads a PDF document and extracts text page-by-page with strict page numbering.

    Args:
        file_path: Local path to the PDF document.

    Returns:
        PDFExtractionResult containing all extracted pages and document metadata.

    Raises:
        FileNotFoundError: If the specified file does not exist.
        ValueError: If the file is encrypted with an unknown password or corrupted.
    """
    path_obj = Path(file_path)
    if not path_obj.exists():
        raise FileNotFoundError(f"PDF file not found at: '{file_path}'")

    # Initialize PyPDF reader
    reader = PdfReader(str(path_obj.resolve()))

    # Check for password encryption
    if reader.is_encrypted:
        try:
            # Attempt decryption with an empty password (many public PDFs use default encryption)
            reader.decrypt("")
        except Exception as exc:
            raise ValueError(f"PDF is encrypted and requires a password to open: {exc}")

    total_pages = len(reader.pages)
    extracted_pages: List[ExtractedPage] = []
    total_chars = 0
    blank_pages = 0

    # Extract text from each page sequentially (1-indexed)
    for index, page in enumerate(reader.pages, start=1):
        try:
            raw_text = page.extract_text() or ""
        except Exception:
            # If a specific page has encoding or font corruption, avoid crashing the whole document
            raw_text = ""

        clean_text = raw_text.strip()
        char_count = len(clean_text)
        is_blank = (char_count == 0)

        if is_blank:
            blank_pages += 1
        else:
            total_chars += char_count

        extracted_pages.append(
            ExtractedPage(
                page_number=index,
                text=clean_text,
                char_count=char_count,
                is_blank=is_blank,
            )
        )

    # Clean PDF metadata dictionary (converting keys like '/Title' to 'Title')
    cleaned_metadata: Dict[str, Any] = {}
    if reader.metadata:
        for k, v in reader.metadata.items():
            clean_key = k.lstrip("/") if isinstance(k, str) else str(k)
            cleaned_metadata[clean_key] = str(v) if v is not None else ""

    return PDFExtractionResult(
        file_path=str(path_obj.resolve()),
        total_pages=total_pages,
        total_characters=total_chars,
        pages=extracted_pages,
        metadata=cleaned_metadata,
        blank_page_count=blank_pages,
    )
