# Stock AI Analyst — Architecture & Concept FAQ

> **Purpose**: A living, beginner-friendly collection of all questions, answers, design trade-offs, and key learnings encountered while building the Stock AI Analyst platform. Whenever you have a question, it is answered and permanently documented here for quick reference.

---

## 📑 Table of Contents
1. [Architecture & Storage: Are we storing the entire PDF in SQLite?](#1-architecture--storage-are-we-storing-the-entire-pdf-in-sqlite)
2. [Python Architecture: What are these `__init__.py` files?](#2-python-architecture-what-are-these-__init__py-files)
3. [Ingestion Strategy: How do we extract financial numbers when every PDF has a different format?](#3-ingestion-strategy-how-do-we-extract-financial-numbers-when-every-pdf-has-a-different-format)

---

### 1. Architecture & Storage: Are we storing the entire PDF in SQLite?

**Question:**
> *"Computes the SHA-256 checksum so we can store it in SQLite and immediately detect duplicate uploads. Are we going to store the entire PDF in SQLite?"*

**Answer:**
**No, absolutely not!** Storing large binary files (BLOBs) directly inside SQLite is an anti-pattern in production architectures.

#### Why We Never Store PDF Binaries in SQLite:
1. **Database Bloat**: Financial reports are typically 5 MB to 50+ MB. Storing binary files bloats the database file instantly.
2. **Degraded Query Performance**: SQLite caches pages in RAM. Large binary objects flush out table indexes and row caches, slowing down queries.
3. **Backup & Migration Friction**: Keeping SQLite purely relational and structured makes backups, migrations, and inspection fast and lightweight.

#### The Production Pattern: "Filesystem for Files, SQLite for Metadata"
- **On Disk (`server/uploads/`)**: The raw PDF is saved to the local filesystem (or S3/Cloud Storage in cloud deployments).
- **In SQLite (`documents` table)**: Only structured metadata and pointers are saved:
  - `document_id`: UUID string (`"doc_9b1deb4d"`)
  - `ticker`: Stock ticker (`"META"`)
  - `fiscal_quarter`: `"Q2"`
  - `fiscal_year`: `2026`
  - `file_path`: Local string path (`"uploads/Meta_Q2_2026.pdf"`)
  - `sha256_hash`: 64-character text fingerprint (`"b37a58fb..."`)
  - `page_count`: Total pages (`9`)

#### Why the SHA-256 Hash is So Powerful:
The SHA-256 hash is a tiny **64-character text string**. By storing it with a `UNIQUE` constraint:
- When a user uploads a PDF, we compute its hash in ~10 milliseconds.
- A quick lookup (`SELECT id FROM documents WHERE sha256_hash = :hash`) confirms in **0.1 ms** whether this report was already ingested.
- If it exists, we immediately return the cached report without wasting expensive LLM tokens or embedding compute.

---

### 2. Python Architecture: What are these `__init__.py` files?

**Question:**
> *"What are these `__init__.py` files?"*

**Answer:**
In Python, an `__init__.py` file acts as the **"front door"** of a directory, turning an ordinary folder into an **importable Python Package**.

```
server/app/ingestion/
├── __init__.py           <-- The "Front Desk / Public API"
├── validator.py          <-- Specialist 1 (Deduplication & Header Validation)
└── pdf_extractor.py      <-- Specialist 2 (Page-by-page Text Extraction)
```

#### The 3 Main Purposes:
1. **Marks Folders as Packages**:
   Without `__init__.py`, Python sees folders as plain file directories. With `__init__.py`, other modules can import code across the project (e.g., `from app.ingestion import validate_and_hash_pdf`).
2. **Defines a Clean Public API**:
   Instead of forcing other developers to remember internal file names:
   ```python
   # ❌ Clunky: The caller must know validator.py exists
   from app.ingestion.validator import validate_and_hash_pdf

   # ✅ Clean: Caller just imports from the package!
   from app.ingestion import validate_and_hash_pdf
   ```
   If we later rename `validator.py` to `checksum.py`, external code won't break because `__init__.py` continues to expose `validate_and_hash_pdf`.
3. **Namespace Protection (`__all__`)**:
   Setting `__all__ = ["validate_and_hash_pdf"]` explicitly defines what gets exported if someone writes `from app.ingestion import *`. It prevents internal helper variables from polluting the caller's namespace.
4. **Can `__init__.py` be empty?**:
   **Yes!** An empty `__init__.py` (like `server/app/__init__.py`) is completely valid. Its mere presence signals to Python that the directory is a package.

---

### 3. Ingestion Strategy: How do we extract financial numbers when every PDF has a different format?

**Question:**
> *"Here's a sample PDF I downloaded for Meta from the investor relations site (`Meta-06-30-2026-Exhibit-99-1-FINAL.pdf`). How are we going to read every bit of information we need without using any other tool or LLM, given every PDF has its own format?"*

**Answer:**
**We ARE going to use an LLM!** We never attempt to extract dense financial numbers across different companies using brittle regex or manual python string matching.

Every company uses a unique layout:
- **Meta** puts their Income Statement on **Page 5** under *"Condensed Consolidated Statements of Income"*.
- **Apple** puts theirs on **Page 1** under *"Consolidated Statements of Operations"*.
- **Tesla** puts theirs on **Page 10** with different column orderings.

#### The Three-Role Architecture:

```
┌────────────────────────────────────────────────────────┐
│ ROLE 1: The "Digitizer" (pypdf)                        │
│ • Reads binary PDF bytes into clean text.              │
│ • Preserves 1-indexed page numbers (Page 1, 2, ... 9). │
│ • Does NOT understand accounting concepts.             │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ ROLE 2: The "Accountant" (LLM + Strict Pydantic JSON)  │
│ • Feeds financial pages to OpenAI `gpt-4.1-mini`.      │
│ • Uses strict Structured Outputs (JSON Schema).        │
│ • Translates "Net Sales", "Total Revenue", or          │
│   "Revenues" into a single standard field: `revenue`.  │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ ROLE 3: The "Auditor" (Deterministic Python Math)      │
│ • Validates financial math:                            │
│   Free Cash Flow == Operating Cash Flow - CapEx        │
│ • Saves validated numbers to SQLite for instant charts!│
└────────────────────────────────────────────────────────┘
```

#### Why we needed `pypdf` (Step 1.2) before the LLM:
Before an LLM can parse the numbers, it needs text. But more importantly: **it needs page numbers**.
By extracting page-by-page upfront, when the LLM extracts `Revenue = $60,801M`, our system automatically stamps it with `[Source: Page 5]`. This ensures the AI Analyst always produces **verifiable, audit-ready citations**.
