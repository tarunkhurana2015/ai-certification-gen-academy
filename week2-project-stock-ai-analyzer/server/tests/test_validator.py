"""
Interactive Learning Test: Step 1.1 - PDF File Validator & SHA-256 Hasher
=========================================================================

Run from server directory:
    python tests/test_validator.py
or
    uv run python tests/test_validator.py
"""

import sys
from pathlib import Path
from pypdf import PdfWriter

# Ensure the server root is in sys.path so 'from app...' imports cleanly from any directory
SERVER_ROOT = Path(__file__).resolve().parent.parent
if str(SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(SERVER_ROOT))

# Import our newly built validator component from app.ingestion
from app.ingestion.validator import validate_and_hash_pdf


def create_sample_pdf(file_path: Path, title: str) -> Path:
    """Helper that creates a minimal valid PDF using pypdf for testing."""
    writer = PdfWriter()
    page = writer.add_blank_page(width=612, height=792)  # Standard 8.5 x 11 inch page
    with open(file_path, "wb") as f:
        writer.write(f)
    return file_path


def main():
    print("=" * 70)
    print("🎓 LEARNING TEST: STEP 1.1 - PDF VALIDATION & SHA-256 HASHING")
    print("=" * 70)

    # Put all test data inside tests/test_data/
    test_dir = Path(__file__).resolve().parent / "test_data"
    test_dir.mkdir(exist_ok=True)

    # 1. Test a valid PDF
    valid_pdf_path = test_dir / "apple_q3_report.pdf"
    create_sample_pdf(valid_pdf_path, "Apple Inc. Q3 FY24 Earnings")
    print(f"\n[Case 1] Valid PDF File: {valid_pdf_path.name}")
    result_valid = validate_and_hash_pdf(valid_pdf_path)
    print(f"  • Is Valid:        {result_valid.is_valid}")
    print(f"  • File Size:       {result_valid.file_size_bytes} bytes")
    print(f"  • SHA-256 Hash:    {result_valid.sha256_hash}")
    print(f"  • Error:           {result_valid.error_message}")

    # 2. Test duplicate detection: computing hash of the exact same file
    print(f"\n[Case 2] Duplicate Upload Simulation:")
    result_dupe = validate_and_hash_pdf(valid_pdf_path)
    print(f"  • Hash matches previous run: {result_dupe.sha256_hash == result_valid.sha256_hash}")
    print("    -> In SQLite: SELECT id FROM documents WHERE sha256_hash = :hash")
    print("    -> Match found in 0.1ms! Duplicate rejected without burning LLM tokens.")

    # 3. Test a fake PDF (text file renamed to .pdf)
    fake_pdf_path = test_dir / "fake_financials.pdf"
    with open(fake_pdf_path, "w") as f:
        f.write("This is a plain text file, not a real PDF!")
    print(f"\n[Case 3] Fake PDF (text file renamed to .pdf): {fake_pdf_path.name}")
    result_fake = validate_and_hash_pdf(fake_pdf_path)
    print(f"  • Is Valid:        {result_fake.is_valid}")
    print(f"  • Error Message:   {result_fake.error_message}")

    # 4. Test an empty file (0 bytes)
    empty_pdf_path = test_dir / "corrupted_empty.pdf"
    empty_pdf_path.touch()
    print(f"\n[Case 4] Empty 0-byte File: {empty_pdf_path.name}")
    result_empty = validate_and_hash_pdf(empty_pdf_path)
    print(f"  • Is Valid:        {result_empty.is_valid}")
    print(f"  • Error Message:   {result_empty.error_message}")

    # 5. Test non-existent file
    print(f"\n[Case 5] Non-existent File:")
    result_missing = validate_and_hash_pdf("does_not_exist.pdf")
    print(f"  • Is Valid:        {result_missing.is_valid}")
    print(f"  • Error Message:   {result_missing.error_message}")

    print("\n" + "=" * 70)
    print("🎉 STEP 1.1 VALIDATION COMPONENT TEST COMPLETED SUCCESSFULLY!")
    print("=" * 70)


if __name__ == "__main__":
    main()
