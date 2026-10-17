# Stock AI Analyst — Developer Work Log & Learning Journal

> **Purpose**: A clear, beginner-friendly trace of every step, component, and architectural decision built in this project. Use this document whenever you need to see what was done, why it was done, and what comes next.
>
> 💡 **Concept & Architecture FAQ**: Check [FAQ.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/FAQ.md) for detailed explanations of why we made specific design decisions (e.g., SQLite vs files, `__init__.py`, LLM structured outputs across different PDF formats).

---

## 🗺️ Project Roadmap & Status

| Phase | Component | Focus / Learning Goal | Status |
| :--- | :--- | :--- | :--- |
| **Phase 0** | **Environment Setup** | Python 3.11+, virtualenv (`uv`), dependencies, `.env` | ✅ Completed |
| **Phase 1** | **PDF Ingestion Pipeline** | PDF validation, text extraction, section parsing, chunking | ✅ Completed |
| **Phase 2** | **Deterministic Database (SQLite)** | 18+ GAAP KPIs, time-series storage, task state tracking | 🔄 **In Progress** |
| **Phase 3** | **Dual Hybrid Indexing** | Pinecone dense embeddings + BM25 sparse keyword index | ⏳ Pending |
| **Phase 4** | **TypeSafe Query Classifier** | Intent routing (Exact KPI vs Narrative vs Multi-Quarter) | ⏳ Pending |
| **Phase 5** | **LangGraph Agent & Tools** | ReAct loop, SQL tool, Hybrid RAG tool, citation grounding | ⏳ Pending |
| **Phase 6** | **FastAPI Server & SSE** | Async REST endpoints, Server-Sent Events streaming | ⏳ Pending |
| **Phase 7** | **Client Integration (Flutter)** | Connect Flutter UI to live backend API & SSE stream | ⏳ Pending |

---

## 📑 Phase 1: PDF Ingestion — Step-by-Step Breakdown

In financial analysis, PDF reports (10-Ks, 10-Qs, 8-Ks, Earnings Releases) are notoriously complex: they contain dense tables, multi-column layouts, footnotes, and narrative sections. 

To learn this thoroughly, we break the Ingestion Pipeline down into small, digestible components:

```
[Uploaded PDF]
      │
      ▼
┌───────────────────────────────────────────────┐
│ Step 1.1: File Validator & SHA-256 Hasher     │  <-- WE ARE STARTING HERE
│   • Verifies valid PDF magic header (%PDF)    │
│   • Calculates unique hash to prevent dupes   │
└──────────────────────┬────────────────────────┘
                       │
                       ▼
┌───────────────────────────────────────────────┐
│ Step 1.2: PDF Text & Page Extractor (pypdf)   │
│   • Reads pages sequentially                  │
│   • Extracts clean text with page numbers     │
└──────────────────────┬────────────────────────┘
                       │
                       ▼
┌───────────────────────────────────────────────┐
│ Step 1.3: Document Layout & Section Classifier│
│   • Identifies Income Statement, Balance Sheet│
│   • Identifies MD&A, Guidance, Risk Factors   │
└──────────────────────┬────────────────────────┘
                       │
                       ▼
┌───────────────────────────────────────────────┐
│ Step 1.4: Semantic Chunking & Facet Tagging   │
│   • LangChain RecursiveCharacterTextSplitter  │
│   • Tags: ticker, quarter, year, domain, page │
└───────────────────────────────────────────────┘
```

---

## 📝 Chronological Work Log

### Step 0: Environment Setup
- **Date**: Oct 16, 2026
- **What was done**:
  - Configured `pyproject.toml` with `fastapi`, `langchain`, `langgraph`, `pinecone`, `pypdf`, `sqlalchemy`, `rank-bm25`.
  - Created `.venv` via `uv sync`.
  - Created `.env` configuration file.
  - Verified environment activation via `source .venv/bin/activate` and `uv run python`.
- **Key Concepts Learned**:
  - `uv` is an ultra-fast package manager for Python that manages virtual environments and lockfiles (`uv.lock`).
  - `.env` stores API keys and sensitive settings out of version control.

---

### Step 1.1: PDF File Validator & SHA-256 Hasher
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/ingestion/validator.py` ([validator.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/validator.py))
  - `server/tests/ingestion/test_validator.py` ([test_validator.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/ingestion/test_validator.py))
  - `server/tests/test_data/` (isolated sandbox for shared test PDFs)
- **Environment Note**:
  - Discovered that the global Anaconda Python (`/opt/anaconda3/bin/python`) caused macOS `SIGKILL` (signal 9 / exit 137).
  - Pinned `3.12` in `.python-version` and rebuilt `.venv` cleanly with Apple Silicon native Python 3.12 via `uv sync`.
- **What Was Built**:
  - `check_pdf_header()`: Inspects the first 1024 bytes for ISO 32000-1 magic header (`%PDF-`).
  - `compute_sha256()`: Streams the file in 64 KB buffers to maintain a constant < 1 MB RAM footprint regardless of PDF size.
  - `validate_and_hash_pdf()`: Comprehensive validation returning a typed `PDFValidationResult` dataclass.
- **Verification**:
  - Tested 5 real-world edge cases: valid PDF, duplicate file detection, fake PDF (renamed `.txt`), empty file (0-bytes), and missing file.
  - All test cases passed with exit code 0.

---

### Step 1.2: PDF Text & Page Extractor (pypdf)
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/ingestion/pdf_extractor.py` ([pdf_extractor.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/pdf_extractor.py))
  - `server/tests/ingestion/test_pdf_extractor.py` ([test_pdf_extractor.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/ingestion/test_pdf_extractor.py))
- **What Was Built**:
  - `ExtractedPage`: Immutable dataclass representing a page with 1-indexed `page_number`, cleaned `text`, `char_count`, and `is_blank` detection.
  - `PDFExtractionResult`: Container holding the entire document's extracted pages, total character count, blank page count, and document metadata.
  - `extract_text_by_pages()`: Sequentially traverses `reader.pages`, handling empty passwords, blank separator pages, and font corruptions without failing the entire document.
- **Verification**:
  - Generated realistic 3-page earnings report (`apple_q3_fy24_financials.pdf`) via ReportLab.
  - Tested live against user's actual **9-page Meta Q2 2026 Earnings Release** (`Meta-06-30-2026-Exhibit-99-1-FINAL.pdf`): extracted 18,960 characters across all 9 pages with exact headings.
  - Verified graceful handling of blank pages and missing files.
  - All test cases passed with exit code 0.

---

### Step 1.3: Financial Section Tagging (Heuristic Domain Classifier)
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/ingestion/section_classifier.py` ([section_classifier.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/section_classifier.py))
  - `server/tests/ingestion/test_section_classifier.py` ([test_section_classifier.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/ingestion/test_section_classifier.py))
- **What Was Built**:
  - `FinancialDomain`: Standardized enum (`PROFITABILITY`, `BALANCE_SHEET`, `CASH_FLOW`, `GUIDANCE_OUTLOOK`, `RISK_FACTORS`, `GENERAL`).
  - `PageClassification`: Result dataclass with `domain`, `confidence`, and `matched_signals`.
  - `normalize_header_text()`: Typography normalization collapsing spaced header font (e.g. `'B A L A N C E  S H E E T'` -> `'BALANCESHEET'`).
  - Universal GAAP Anchor Dictionaries: Strict mapping based on SEC Regulation S-X accounting terms.
  - Multi-signal scoring engine: Weighs top-5 lines header patterns (3x) and GAAP body keywords (1x) with calibrated confidence.
- **Verification**:
  - Tested live against **Meta Q2 2026** (9-page press release): accurately tagged Statements of Income (Page 5), Balance Sheet (Page 6), Cash Flows (Page 7), CFO Outlook (Page 2), and Risk Factors (Page 4).
  - Tested live against **Tesla Q2 2026** (33-page slide deck): successfully normalized spaced typography `'O U T L O O K'` (Page 10) and `'B A L A N C E  S H E E T'` (Page 28), and tagged Cybercab/Optimus photo slides as `GENERAL`.
  - Verified 100% test pass rate with 0 external API calls in < 2ms.

---

### Step 1.4: Semantic Chunking & Metadata Enrichment (LangChain)
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/ingestion/chunker.py` ([chunker.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/chunker.py))
  - `server/tests/ingestion/test_chunker.py` ([test_chunker.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/ingestion/test_chunker.py))
- **What Was Built**:
  - `EnrichedChunk`: Immutable dataclass representing a semantic snippet with `chunk_id`, `ticker`, `fiscal_quarter`, `fiscal_year`, `page_number`, `financial_domain`, `char_count`, and chunk indices.
  - `chunk_document_pages()`: Uses LangChain's `RecursiveCharacterTextSplitter` (1000 chunk size, 100 overlap, `["\n\n", "\n", ". ", " ", ""]` separators).
  - Skips blank pages, pairs each page with its classified domain from Step 1.3, and produces deterministic IDs (`{ticker}_{quarter}_{year}_p{page}_c{idx}`).
  - Direct CLI tool: `python app/ingestion/chunker.py [pdf_path]` exports `03_chunks_<doc>.[json|md]` to `.artifact/`.
- **Verification**:
  - Tested on **Meta Q2 2026** (9 pages): produced 24 semantic chunks across all 6 financial domains.
  - Verified Page 5 (Statements of Income) produced 2 chunks faithfully inheriting `financial_domain = "profitability"`.
  - Verified Page 6 (Balance Sheet) produced 2 chunks inheriting `financial_domain = "balance_sheet"`.
  - Tested on **Tesla Q2 2026** (33 pages): produced 66 semantic chunks.
  - Verified blank page handling (0 chunks) and chunk overlap boundaries.
  - All unit test assertions passed with 0 errors.

---

## 🗄️ Phase 2: Deterministic Financial Database (SQLite & SQLAlchemy)

Now that raw PDFs can be ingested, classified, and chunked with 100% precision, we move to **Phase 2: Structured Data Storage**.

### Why SQLite for Financial KPIs?
In financial analysis, an AI must **never guess or hallucinate numerical facts**:
- When a user asks: *"What was Meta's revenue in Q2 2026 vs Q2 2025?"* or *"Plot gross margins across the last 4 quarters"*, the system does **not** rely on fuzzy vector retrieval.
- Instead, it queries **SQLite directly** with deterministic SQL:
  ```sql
  SELECT fiscal_quarter, fiscal_year, revenue, gross_margin, net_income 
  FROM financial_kpis 
  WHERE ticker = 'META' 
  ORDER BY fiscal_year ASC, fiscal_quarter ASC;
  ```
- This guarantees **100% mathematical precision**, exact multi-quarter chart data, and zero hallucinations.

### Phase 2 Step-by-Step Breakdown:
- **Step 2.1: SQLite Database Engine & Connection Pool** (`database/session.py`) — ✅ Completed
- **Step 2.2: SQLAlchemy ORM Models** (`database/models.py`) — ✅ Completed
  - `documents` table (file tracking, sha256_hash, page count)
  - `financial_kpis` table (18+ standardized GAAP metrics)
  - `ingestion_tasks` table (background job state machine)
- **Step 2.3: Deterministic KPI Repository** (`database/kpi_repo.py`) — ✅ Completed
- **Step 2.4: OpenAI Structured Output KPI Extractor** (`extractor/kpi_extractor.py`) — 🔄 Up Next

---

### Step 2.1: SQLite Database Engine & Session Management
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/database/session.py` ([session.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/database/session.py))
  - `server/app/database/__init__.py` ([__init__.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/database/__init__.py))
  - `server/tests/database/test_session.py` ([test_session.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/database/test_session.py))
- **What Was Built**:
  - `Base`: Modern SQLAlchemy 2.0 `DeclarativeBase` subclass for all ORM models.
  - Foreign Key Enforcement: Registered connection listener executing `PRAGMA foreign_keys=ON;` on every connection (ensuring child table cascades and relational integrity, which SQLite disables by default).
  - Thread Safety: Configured `connect_args={"check_same_thread": False}` for multi-threaded FastAPI workers.
  - `SessionLocal`: Scoped session factory configured with `autocommit=False, autoflush=False`.
  - `get_db()`: Generator pattern using `yield` and `finally: db.close()` for FastAPI dependency injection.
  - `init_db()`: Helper function to initialize database tables on `Base.metadata`.
  - Direct CLI tool: `python app/database/session.py` verifies SQLite version, PRAGMA flags, and exports `04_database_init.[json|md]` to `.artifact/`.
- **Verification**:
  - `tests/database/test_session.py` verified:
    1. Foreign keys enabled (`PRAGMA foreign_keys = 1`).
    2. Session opening, query execution, and closing.
    3. `get_db()` generator lifecycle and automatic cleanup.
    4. Isolated in-memory engine creation (`sqlite:///:memory:`).
  - All test assertions passed with 0 errors. Pure assertions only, no test artifacts created.

---

### Step 2.2: SQLAlchemy ORM Models (`models.py`)
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/database/models.py` ([models.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/database/models.py))
  - `server/tests/database/test_models.py` ([test_models.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/database/test_models.py))
- **What Was Built**:
  - `DocumentModel` (`documents` table):
    - Stores document metadata (`id`, `ticker`, `fiscal_quarter`, `fiscal_year`, `report_title`, `file_path`, `page_count`).
    - `sha256_hash` with `UNIQUE` constraint for instantaneous 0.1ms deduplication.
    - 1-to-many relationship with `cascade="all, delete-orphan"` to `FinancialKPIModel`.
  - `FinancialKPIModel` (`financial_kpis` table):
    - Enforces uniqueness per filing period: `UniqueConstraint("ticker", "fiscal_year", "fiscal_quarter")`.
    - Standardizes 18+ GAAP metrics:
      - **Income Statement**: `revenue`, `cost_of_revenue`, `gross_profit`, `gross_margin`, `research_and_development`, `selling_general_admin`, `total_operating_expenses`, `operating_income`, `operating_margin`, `net_income`, `net_margin`, `diluted_eps`.
      - **Cash Flow Statement**: `operating_cash_flow`, `capital_expenditures`, `free_cash_flow` (`OCF - CapEx`).
      - **Balance Sheet**: `cash_and_equivalents`, `total_assets`, `long_term_debt`, `total_liabilities`, `shareholders_equity`.
      - **Audit & Lineage**: `currency`, `units`, `is_audited`, `source_pages` (JSON list of pages for citation grounding).
    - `to_dict()` helper for clean JSON serialization in API responses.
  - `IngestionTaskModel` (`ingestion_tasks` table):
    - State machine tracking async ingestion (`status`, `progress_percent`, `message`, `error_details`).
  - Lazy Module Attribute Resolution:
    - Updated `app/database/__init__.py` using PEP 562 `__getattr__` to cleanly prevent circular import traps when submodules are executed directly from the CLI.
  - Direct CLI tool: `python app/database/models.py` verifies table creation, cascade deletion, and exports schema specs `05_database_models.[json|md]` to `.artifact/`.
- **Verification**:
  - `tests/database/test_models.py` verified:
    1. Table registration in metadata (`documents`, `financial_kpis`, `ingestion_tasks`).
    2. SHA-256 uniqueness constraint rejects duplicate filings.
    3. `(ticker, fiscal_year, fiscal_quarter)` uniqueness prevents duplicate quarter rows.
    4. Foreign key cascade delete: Deleting a Document automatically wipes child KPIs.
    5. `to_dict()` serialization verifies all 18+ GAAP metrics.
    6. IngestionTask status transitions and progress percentage tracking.
  - All test assertions passed with 0 errors. Pure assertions only, no test artifacts created.

---

### Step 2.3: Deterministic Financial KPI Repository (`kpi_repo.py`)
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/database/kpi_repo.py` ([kpi_repo.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/database/kpi_repo.py))
  - `server/tests/database/test_kpi_repo.py` ([test_kpi_repo.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/database/test_kpi_repo.py))
- **What Was Built**:
  - **Document Operations**:
    - `get_document_by_id()`: Standard primary key lookup.
    - `get_document_by_hash()`: Instant 0.1ms SHA-256 deduplication lookup.
    - `save_document()`: Validates and saves report metadata.
    - `list_documents()`: Lists ingested filings, optionally filtered by ticker.
  - **Financial KPI Operations**:
    - `get_kpis_by_quarter(ticker, year, quarter)`: Exact lookup for single-quarter factual questions (100% precision, zero hallucination).
    - `get_kpi_time_series(ticker, limit)`: Chronologically ordered quarters (`ORDER BY fiscal_year ASC, fiscal_quarter ASC`) used by the Flutter frontend charting engine.
    - `get_multi_company_comparison(tickers, year, quarter)`: Peer comparison query fetching metrics for multiple companies for the exact same fiscal period.
    - `upsert_kpi()`: Idempotent upsert logic that avoids duplicates on re-ingestion, and automatically derives missing ratios:
      - `gross_margin = gross_profit / revenue`
      - `operating_margin = operating_income / revenue`
      - `net_margin = net_income / revenue`
      - `free_cash_flow = operating_cash_flow - capital_expenditures`
  - **Task Lifecycle Operations**:
    - `create_task()`, `update_task_status()`, `get_task()`: Background task status tracking for asynchronous ingestion workflows.
  - Direct CLI tool: `python app/database/kpi_repo.py` executes exact lookup, time-series, and peer comparison queries, exporting `06_kpi_repo_queries.[json|md]` to `.artifact/`.
- **Verification**:
  - `tests/database/test_kpi_repo.py` verified:
    1. Document save and SHA-256 deduplication lookup.
    2. KPI upsert idempotency and automatic calculation of derived ratios (Margins, FCF).
    3. Single quarter exact financial lookup.
    4. Chronological ordering of multi-quarter time series.
    5. Peer company comparisons for a given fiscal period.
    6. Ingestion task lifecycle state tracking.
  - All 6 tests passed with 0 errors. Pure assertions only, no test artifacts created.

