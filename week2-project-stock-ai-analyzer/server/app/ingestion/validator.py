"""
PDF File Validator and Deduplication Hasher
============================================
Component: Step 1.1 in PDF Ingestion Pipeline

Purpose:
1. Verify that uploaded files are genuine, uncorrupted PDF documents
   by inspecting the file's 'magic bytes' header (`%PDF-`).
2. Generate a deterministic SHA-256 cryptographic hash of the file.
   This hash serves as a unique fingerprint stored in SQLite to detect
   and reject duplicate uploads in O(1) time without reading the contents again.

Why read in chunks?
-------------------
Financial 10-K and 10-Q reports can be 50-100+ MBs. Loading the entire file
into memory at once causes memory spikes and degrades server throughput.
By streaming 64 KB chunks, memory consumption remains virtually constant (< 1 MB)
regardless of document size.
"""

from dataclasses import dataclass
import hashlib
import os
from pathlib import Path
from typing import Optional, Union

# Standard PDF specifications (ISO 32000-1) define the file header as '%PDF-'
PDF_MAGIC_HEADER: bytes = b"%PDF-"
DEFAULT_CHUNK_SIZE: int = 64 * 1024  # 64 KB streaming buffer


@dataclass(frozen=True)
class PDFValidationResult:
    """
    Structured outcome of a PDF validation and hashing check.
    
    Attributes:
        file_path: Absolute or relative path to the inspected file.
        file_size_bytes: Total size of the file on disk.
        sha256_hash: 64-character hexadecimal SHA-256 digest (empty if invalid).
        is_valid: True if file exists, is non-empty, and possesses a valid PDF header.
        error_message: Explanatory error message if validation failed.
    """
    file_path: str
    file_size_bytes: int
    sha256_hash: str
    is_valid: bool
    error_message: Optional[str] = None


def compute_sha256(file_path: Union[str, Path], chunk_size: int = DEFAULT_CHUNK_SIZE) -> str:
    """
    Calculates the SHA-256 checksum of a file using buffered streaming.

    Args:
        file_path: Path to the target file.
        chunk_size: Byte size of chunks read into memory at a time (default: 64 KB).

    Returns:
        A 64-character lowercase hexadecimal hash string.
    """
    hasher = hashlib.sha256()
    with open(file_path, "rb") as f:
        while chunk := f.read(chunk_size):
            hasher.update(chunk)
    return hasher.hexdigest()


def check_pdf_header(file_path: Union[str, Path]) -> bool:
    """
    Inspects the start of the file for the standard '%PDF-' magic bytes.

    According to the PDF reference specification, the '%PDF-' header must
    appear within the first 1024 bytes of the file.

    Args:
        file_path: Path to the target file.

    Returns:
        True if the file contains the valid PDF magic bytes, False otherwise.
    """
    with open(file_path, "rb") as f:
        leading_bytes = f.read(1024)
        return PDF_MAGIC_HEADER in leading_bytes


def validate_and_hash_pdf(file_path: Union[str, Path]) -> PDFValidationResult:
    """
    Comprehensive validation and deduplication hashing for an uploaded PDF.

    Execution Flow:
    1. Checks if the file path exists on disk.
    2. Verifies the file is a regular file and is not empty (size > 0 bytes).
    3. Validates the '%PDF-' header magic bytes.
    4. Computes the streaming SHA-256 hash.

    Args:
        file_path: Path to the file to inspect.

    Returns:
        PDFValidationResult with metadata, sha256_hash, and validity flag.
    """
    path_obj = Path(file_path)
    path_str = str(path_obj.resolve())

    # 1. Check file existence
    if not path_obj.exists():
        return PDFValidationResult(
            file_path=path_str,
            file_size_bytes=0,
            sha256_hash="",
            is_valid=False,
            error_message=f"File not found: '{file_path}'"
        )

    # 2. Check if it's a file
    if not path_obj.is_file():
        return PDFValidationResult(
            file_path=path_str,
            file_size_bytes=0,
            sha256_hash="",
            is_valid=False,
            error_message=f"Path is a directory or special file, not a regular file: '{file_path}'"
        )

    # 3. Check file size
    size_bytes = path_obj.stat().st_size
    if size_bytes == 0:
        return PDFValidationResult(
            file_path=path_str,
            file_size_bytes=0,
            sha256_hash="",
            is_valid=False,
            error_message="File is completely empty (0 bytes)."
        )

    # 4. Check PDF magic bytes
    try:
        if not check_pdf_header(path_obj):
            return PDFValidationResult(
                file_path=path_str,
                file_size_bytes=size_bytes,
                sha256_hash="",
                is_valid=False,
                error_message="File does not have a valid '%PDF-' header (corrupted or wrong file type)."
            )
    except Exception as exc:
        return PDFValidationResult(
            file_path=path_str,
            file_size_bytes=size_bytes,
            sha256_hash="",
            is_valid=False,
            error_message=f"Failed reading file header: {exc}"
        )

    # 5. Compute SHA-256 hash
    try:
        digest = compute_sha256(path_obj)
        return PDFValidationResult(
            file_path=path_str,
            file_size_bytes=size_bytes,
            sha256_hash=digest,
            is_valid=True,
            error_message=None
        )
    except Exception as exc:
        return PDFValidationResult(
            file_path=path_str,
            file_size_bytes=size_bytes,
            sha256_hash="",
            is_valid=False,
            error_message=f"Failed computing SHA-256 hash: {exc}"
        )
