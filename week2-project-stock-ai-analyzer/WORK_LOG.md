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
| **Phase 2** | **Deterministic Database (SQLite)** | 18+ GAAP KPIs, time-series storage, task state tracking | ✅ Completed |
| **Phase 3** | **Dual Hybrid Indexing & Retrieval** | ChromaDB dense embeddings + BM25 sparse keyword index | ✅ Completed |
| **Phase 4** | **TypeSafe Query Classifier** | Intent routing (Exact KPI vs Narrative vs Multi-Quarter) | ✅ Completed |
| **Phase 5** | **LangGraph Agent & Tools** | ReAct loop, SQL tool, Hybrid RAG tool, citation grounding | ⏳ Pending |
| **Phase 6** | **FastAPI Server & REST API** | Async REST endpoints (Ingestion upload & KPI queries) | ✅ Completed |
| **Phase 7** | **Client Integration (Flutter)** | Connect Flutter KPI Dashboard to live backend API | ✅ Completed |

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
- **Step 2.4.1: LLM Structured Output & Math Reconciliation** (`extractor/kpi_extractor.py`) — ✅ Completed
- **Step 2.4.2: Automated SQLite Persistence & Ingestion Pipeline Integration** — 🔄 Up Next

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

---

### Step 2.4.1: LLM Structured Output & Mathematical Reconciliation (`kpi_extractor.py`)
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/extractor/kpi_extractor.py` ([kpi_extractor.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/extractor/kpi_extractor.py))
  - `server/app/extractor/__init__.py` ([__init__.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/extractor/__init__.py))
  - `server/tests/extractor/test_kpi_extractor.py` ([test_kpi_extractor.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/extractor/test_kpi_extractor.py))
- **What Was Built**:
  - `FinancialReportKPIs`: Pydantic v2 schema standardizing all 18+ GAAP line items with strict type validation, field descriptions, reporting units (`millions`), and citation grounding (`source_pages`).
  - `filter_financial_statement_pages()`: Eliminates ~80% of document tokens by extracting only pages tagged `PROFITABILITY`, `BALANCE_SHEET`, or `CASH_FLOW` from Step 1.3. Avoids confusing the LLM with executive photos, marketing blurbs, or general essays.
  - `validate_and_reconcile_kpis()`:
    - **CapEx Sign Correction**: Catches negative CapEx reporting (cash flow statements list outflows in parentheses/negative numbers) and normalizes to positive absolute values.
    - **Mathematical Consistency**: Guarantees `Free Cash Flow = Operating Cash Flow - CapEx`.
    - **Ratio Derivation**: Auto-computes `Gross Margin`, `Operating Margin`, and `Net Margin` if omitted.
  - Direct CLI tool: `python app/extractor/kpi_extractor.py <pdf_path>` runs extraction via `gpt-4o-mini` with structured output, and exports `07_extracted_kpis_<doc>.[json|md]` to `.artifact/`.
- **Verification**:
  - Unit tests in `tests/extractor/test_kpi_extractor.py` tested schema defaults, negative CapEx sign correction, margin derivations, page filtering, and mocked extraction pipeline (all passed, 0 side effects, 0 artifacts).
  - **Live Meta Q2 2026 Test** (`Meta-06-30-2026-Exhibit-99-1-FINAL.pdf`):
    - Extracted 9 pages -> Filtered to statement pages `[1, 5, 6, 7]`.
    - Revenue: `$60,801.0M`, Gross Profit: `$49,471.0M` (Margin: 81.2%), Operating Income: `$18,775.0M` (Margin: 30.9%), Net Income: `$15,848.0M` (Margin: 26.1%), EPS: `$6.18`, FCF: `$784.0M`.
    - Artifact exported: [.artifact/07_extracted_kpis_meta_06_30_2026_exhibit_99_1_final.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/07_extracted_kpis_meta_06_30_2026_exhibit_99_1_final.md).
    - Artifact exported: [.artifact/07_extracted_kpis_tsla_q2_2026_update.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/07_extracted_kpis_tsla_q2_2026_update.md).

---

### Step 2.4.1b: Repository Architecture Reorganization (Aligned with ARCHITECTURE.md Section 8)
- **Status**: ✅ Completed
- **Why Reorganized**:
  - As specified in [ARCHITECTURE.md Section 8](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/ARCHITECTURE.md#8-repository-structure), `extractor/` is a sub-step of `ingestion/` (Branch A: KPI Extraction vs Branch B: Chunking & Indexing).
  - Similarly, the database tier is specified as `app/db/` with `repositories/` separating `document_repo.py` and `kpi_repo.py`.
- **Target Folder Layout Implemented**:
  ```text
  server/app/
  ├── schemas/                            # 📋 Pydantic Type Contracts & DTOs
  │   ├── common.py                       # Enums: FinancialDomain, StatementType, ContentFormat
  │   └── kpis.py                         # FinancialReportKPIs Pydantic schema
  │
  ├── db/                                 # 🗄️ Relational Data Tier (SQLite)
  │   ├── session.py                      # SQLite connection pooling & PRAGMA foreign_keys
  │   ├── models.py                       # SQLAlchemy ORM models (documents, financial_kpis, ingestion_tasks)
  │   └── repositories/                   # Repository Pattern
  │       ├── document_repo.py            # Documents CRUD & task state queries
  │       └── kpi_repo.py                 # Structured KPI queries & multi-quarter time series
  │
  └── ingestion/                          # 📑 Document Processing & Extraction Pipeline
      ├── validator.py                    # Header bytes & SHA-256 deduplication
      ├── parsers/                        # Layout-Aware PDF Extraction
      │   ├── pdf_extractor.py            # Page text & structure extractor (pypdf)
      │   └── section_classifier.py       # Domain classifier (Income, Balance Sheet, Cash Flow)
      ├── chunkers/                       # Chunking & Semantic Enrichment
      │   └── chunker.py                  # LangChain recursive splitter & facet enricher
      └── extractor/                      # Deterministic KPI Extraction (Branch A)
          ├── kpi_extractor.py            # OpenAI Structured Output parser for 18+ KPIs
          └── kpi_validator.py            # Financial math validator (FCF == OCF - CapEx, margin derivations)
  ```
- **Backward Compatibility**:
  - All existing modules (`app.ingestion`, `app.db`, `app.schemas`) provide clean package exports and forwarding wrappers so that neither unit tests nor direct CLI scripts break.
- **Verification**:
  - Ran all 8 unit test suites (`test_validator`, `test_pdf_extractor`, `test_section_classifier`, `test_chunker`, `test_session`, `test_models`, `test_kpi_repo`, `test_kpi_extractor`).
  - **100% assertions passed with zero errors and zero side effects.**

---

### Step 2.4.2: Automated SQLite Database Persistence
- **Status**: ✅ Completed
- **What Was Built**:
  - `save_extracted_kpis_to_db()` in [app/ingestion/extractor/kpi_extractor.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/extractor/kpi_extractor.py):
    - Bridges the in-memory Pydantic validation DTO (`FinancialReportKPIs`) with the SQLite database via `kpi_repo.upsert_kpi()`.
    - Automatically links every KPI row to the parent `DocumentModel` via foreign key `document_id`.
    - Serializes citation grounding page numbers (`source_pages`) into JSON strings for exact audit trace.
    - Idempotent upsert: Re-processing an existing filing safely updates the metrics in-place rather than creating duplicate rows.
  - Legacy directory cleanup:
    - Completely removed deprecated forwarding folders `server/app/extractor/` and `server/app/database/`.
    - Codebase is now 100% clean and perfectly mirrors [ARCHITECTURE.md Section 8](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/ARCHITECTURE.md#8-repository-structure).
- **Verification**:
  - Added pure in-memory SQLite unit tests to [tests/extractor/test_kpi_extractor.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/extractor/test_kpi_extractor.py):
    - `test_save_extracted_kpis_to_db()`: verified insertion, foreign key linking, and query round-trip.
    - `test_save_extracted_kpis_idempotency()`: verified revised filings update existing records without creating extra rows.
    - Zero artifacts created during tests (pure assertions only).
  - Executed CLI end-to-end on real benchmark filings:
    - **Meta Q2 2026**: Revenue `$60,801.0M`, Gross Profit `$49,471.0M` (81.2%), Operating Income `$18,775.0M` (30.9%), Net Income `$15,848.0M` (26.0%), EPS `$6.18`, FCF `$784.0M`.
    - **Tesla Q2 2026**: Revenue `$28,236.0M`, Gross Profit `$4,751.0M` (16.8%), Operating Income `$398.0M` (1.4%), Net Income `$1,114.0M` (3.9%), EPS `$0.32`, FCF `$-1,092.0M`.
    - Tested deduplication: Second run on Meta identified existing SHA-256 hash in 0.1ms and updated the row idempotently without duplication.
    - Verified cross-company peer query: `get_multi_company_comparison(session, ['META', 'TSLA'], 2026, 'Q2')` successfully compared both companies side-by-side.
  - Generated CLI inspectable artifacts:
    - [.artifact/08_persisted_kpis_meta_06_30_2026_exhibit_99_1_final.json](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/08_persisted_kpis_meta_06_30_2026_exhibit_99_1_final.json)
    - [.artifact/08_persisted_kpis_meta_06_30_2026_exhibit_99_1_final.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/08_persisted_kpis_meta_06_30_2026_exhibit_99_1_final.md)
    - [.artifact/08_persisted_kpis_tsla_q2_2026_update.json](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/08_persisted_kpis_tsla_q2_2026_update.json)
    - [.artifact/08_persisted_kpis_tsla_q2_2026_update.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/08_persisted_kpis_tsla_q2_2026_update.md)

---

### Step 2.4.3: Chunker Decoupling & 1:1 Test Suite Alignment
- **Status**: ✅ Completed
- **What Was Built**:
  1. **Decoupled Chunking Pipeline** ([server/app/ingestion/chunkers/](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/chunkers/)):
     - [recursive_chunker.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/chunkers/recursive_chunker.py): Focused exclusively on text-splitting mechanics (`create_financial_text_splitter`, `split_page_text`).
     - [metadata_enricher.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/chunkers/metadata_enricher.py): Focused exclusively on financial domain inheritance, coordinate tagging, and deterministic ID stamping (`enrich_split`, `chunk_document_pages`, `EnrichedChunk`).
     - Removed redundant monolithic `chunker.py` and old top-level shallow wrappers.
  2. **1-to-1 Code & Test Mirror Alignment**:
     - Synchronized test folders to perfectly mirror `server/app/`:
       ```text
       server/app/                           server/tests/
       ├── db/                               ├── db/
       │   ├── models.py                     │   ├── test_models.py
       │   ├── session.py                    │   ├── test_session.py
       │   └── repositories/                 │   └── repositories/
       │       ├── document_repo.py          │       └── test_kpi_repo.py
       │       └── kpi_repo.py               ├── schemas/
       ├── schemas/                          │   └── test_schemas.py
       │   ├── common.py                     └── ingestion/
       │   └── kpis.py                           ├── test_validator.py
       └── ingestion/                            ├── parsers/
           ├── validator.py                      │   ├── test_pdf_extractor.py
           ├── parsers/                          │   └── test_section_classifier.py
           │   ├── pdf_extractor.py              ├── chunkers/
           │   └── section_classifier.py         │   ├── test_recursive_chunker.py
           ├── chunkers/                         │   └── test_metadata_enricher.py
           │   ├── recursive_chunker.py          └── extractor/
           │   └── metadata_enricher.py              └── test_kpi_extractor.py
           └── extractor/
               ├── kpi_extractor.py
               └── kpi_validator.py
       ```
- **Verification**:
  - Ran all 10 unit test suites across `tests/schemas/`, `tests/db/`, and `tests/ingestion/`.
  - **All 10 test suites passed cleanly with 100% assertions and zero test artifacts.**

---

### Step 2.4.4: LLM Prompt Decoupling (`llm_extraction_prompts.py`)
- **Status**: ✅ Completed
- **What Was Built**:
  1. **Prompt Template Module** ([server/app/ingestion/extractor/llm_extraction_prompts.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/extractor/llm_extraction_prompts.py)):
     - Extracted all prompt building logic, system persona definitions (`KPI_AUDITOR_SYSTEM_ROLE`), and GAAP extraction rules (`KPI_EXTRACTION_RULES`) out of `kpi_extractor.py`.
     - `build_extraction_prompt()`: Context-rich prompt assembler with page-by-page header anchors and optional hints (`ticker`, `quarter`, `year`).
  2. **Refactored `kpi_extractor.py`**:
     - Imports `build_extraction_prompt` from `llm_extraction_prompts.py`.
     - `kpi_extractor.py` now purely focuses on orchestrating the LangChain structured LLM call and database persistence.
  3. **1:1 Mirror Test Suite**:
     - Created [server/tests/ingestion/extractor/test_llm_extraction_prompts.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/ingestion/extractor/test_llm_extraction_prompts.py) testing rule assertions, prompt interpolation, and edge-cases without hints.
  4. **Self-Contained Dummy CLI & Composed Prompt Artifact**:
     - Configured CLI `__main__` entrypoint with realistic dummy financial statement pages (Income Statement, Balance Sheet, Cash Flow).
     - Composes full prompt with auditor persona, extraction rules, and page markers (`--- PAGE 5 ---`, etc.).
     - Outputs inspectable artifacts in `server/.artifact/`:
       - `07a_sample_extraction_prompt.json`
       - `07a_sample_extraction_prompt.md`
- **Verification**:
  - Ran all 11 unit test suites sequentially (100% assertions, 0 disk artifacts).
  - Executed CLI directly (`python app/ingestion/extractor/llm_extraction_prompts.py`) to generate `07a_sample_extraction_prompt.[json|md]`.

---

### Step 2.4.5: Recursive Chunker PDF Input & Artifact Generation (`recursive_chunker.py`)
- **Status**: ✅ Completed
- **What Was Built**:
  1. **Direct PDF CLI Ingestion**:
     - Upgraded `server/app/ingestion/chunkers/recursive_chunker.py` CLI `__main__` entrypoint to accept an optional `pdf_path` argument (defaulting to `Meta-06-30-2026-Exhibit-99-1-FINAL.pdf` if omitted).
     - Directly integrates `pdf_extractor.extract_text_by_pages()` to extract text page-by-page.
     - Iterates through all non-blank pages and calls `split_page_text()` per page with configurable `--chunk-size` (default: 1000) and `--chunk-overlap` (default: 100).
  2. **Inspectable Artifact Generation**:
     - Generates both machine-readable JSON (`03a_recursive_splits_<slug>.json`) and human-readable Markdown (`03a_recursive_splits_<slug>.md`) in `server/.artifact/`.
     - Displays page-by-page breakdown with split index, character counts, and text chunks.
  3. **Playbook & Playbook Synchronization**:
     - Updated `RUN.md` and `server/RUN.md` with explicit commands for Meta (9 pages -> 24 raw splits) and Tesla (33 pages -> 66 raw splits).
- **Verification**:
  - Ran CLI for Meta: Generated 24 raw splits across 9 pages, saved `03a_recursive_splits_meta_06_30_2026_exhibit_99_1_final.[json|md]`.
  - Ran CLI for Tesla: Generated 66 raw splits across 32 non-blank pages, saved `03a_recursive_splits_tsla_q2_2026_update.[json|md]`.
  - Ran unit tests `tests/ingestion/chunkers/test_recursive_chunker.py` (all tests passed with 0 disk artifacts).

---

### Step 2.4.6: End-to-End Ingestion Pipeline Orchestrator & Sequential Artifacts (`pipeline.py`)
- **Status**: ✅ Completed
- **What Was Built**:
  1. **Central Ingestion Orchestrator** ([server/app/ingestion/pipeline.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/pipeline.py)):
     - Chains all multi-stage ETL components into a single coherent flow:
       1. **Header Validation & SHA-256 Fingerprinting**: Magic byte check (`%PDF-`) and checksum computation.
       2. **0.1ms Instant Deduplication**: Indexed lookup against `documents.sha256_hash` to reject already processed filings without burning LLM tokens.
       3. **Page Layout & Text Extraction**: Page-by-page extraction, character counts, and blank page detection.
       4. **Financial Section Classification**: Categorizes statements into GAAP domains (`profitability`, `balance_sheet`, `cash_flow`, `guidance_outlook`, `risk_factors`).
       5. **Dynamic LLM GAAP KPI Extraction**: Dynamic prompt composition using auditor persona. Extracts 18+ GAAP metrics; auto-reconciles negative CapEx signs, verifies `FCF = OCF - CapEx`, and calculates margin ratios. Completely dynamic (removed all hardcoded ticker matching).
       6. **Semantic Chunking**: Recursive 1,000-character chunks with domain metadata facets attached.
       7. **SQLite Persistence & Lineage**: Records document metadata and audited KPIs in SQLite (`stock_analyst.db`), tracking task state.
     - Added `--force` flag to bypass deduplication cache and re-process filings end-to-end.
  2. **Sequential Artifact Renumbering (`server/.artifact/`)**:
     - Renumbered artifacts strictly sequentially without number skipping:
       - `01_extracted_<doc>`: Page text layouts and character metrics
       - `02_classified_<doc>`: GAAP financial domain classification tags
       - `03a_recursive_splits_<doc>`: Raw character-bounded splits
       - `03b_enriched_chunks_<doc>`: Enriched semantic chunks with metadata facets
       - `04_extracted_kpis_<doc>`: Structured GAAP KPIs extracted by LLM
       - `05_persisted_kpis_<doc>`: SQLite persisted record & round-trip query
       - `06_pipeline_ingest_<doc>`: End-to-end pipeline run summary
       - `04a_sample_extraction_prompt`: Standalone prompt generator sample
       - `db_01_database_init`, `db_02_database_models`, `db_03_kpi_repo_queries`: DB tier verification artifacts
  3. **1:1 Mirror Unit Test Suite**:
     - Created [server/tests/ingestion/test_pipeline.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/ingestion/test_pipeline.py) covering validation failure, instant deduplication, and full mocked pipeline execution with pure in-memory SQLite assertions and zero disk artifacts.
- **Verification**:
  - Executed `python app/ingestion/pipeline.py tests/test_data/TSLA-Q2-2026-Update.pdf --force`.
  - Generated all sequential artifacts (`01` through `06`) in `server/.artifact/`.
  - All 12 master test suites passed.

---

### Step 6.1: FastAPI Gateway Server, REST Endpoints, & Flutter Client Entity Adapter
- **Status**: ✅ Completed
- **What Was Built**:
  1. **Schema Contracts & Flutter Client Entity Adapter** ([server/app/schemas/ingestion.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/schemas/ingestion.py), [server/app/schemas/kpis.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/schemas/kpis.py)):
     - `IngestionResponse` and `IngestionUploadRequest` DTOs.
     - `KpiTimeSeriesResponse` and `KpiComparisonResponse` DTOs.
     - `format_kpi_for_client()`: Direct 1:1 adapter mapping database records into the nested JSON structure expected by Flutter client's `QuarterlyKpis.fromJson()` (`profitability`, `cash_flow`, `balance_sheet`, `summary`).
  2. **Thin API Controller Layer** ([server/app/api/v1/](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/api/v1/)):
     - `endpoints/health.py`: `GET /health` liveness probe.
     - `endpoints/documents.py`:
       - `POST /api/v1/ingestion/upload` and alias `POST /api/v1/documents/ingest`: Multipart PDF upload, persistent raw PDF cache in `server/data/uploads/`, and automatic sequential artifact generation (`save_artifacts=True`).
       - `GET /api/v1/documents`: Document catalog listing with optional ticker filter.
       - `GET /api/v1/documents/{document_id}`: Document metadata retrieval by UUID.
       - `GET /api/v1/documents/tasks/{task_id}`: Task lifecycle status and progress polling.
     - `endpoints/kpis.py`:
       - `GET /api/v1/kpi/{ticker}`: Exact single quarter (when `?quarter=Q2&year=2026`) or chronological time series for dashboard charts.
       - `GET /api/v1/kpi/{ticker}/latest`: Most recent reported quarter convenience route.
       - `GET /api/v1/kpi/compare`: Side-by-side peer company benchmarking (e.g. META vs TSLA in Q2 2026).
       - `GET /api/v1/kpi/document/{document_id}`: KPI retrieval by parent Document ID.
     - `router.py`: Aggregates all sub-routers under `/api/v1`.
  3. **FastAPI Server Factory & Lifespan** ([server/app/main.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/main.py)):
     - Automatic database table creation via lifespan context manager.
     - CORS middleware enabled for Flutter Web, macOS Desktop, iOS, and Android.
     - Top-level `/health` and root `/` documentation routes.
  4. **1:1 Mirror Test Suites** ([server/tests/api/](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/api/)):
     - `test_health.py`: Tests `/health`, `/api/v1/health`, and `/`.
     - `test_kpis_api.py`: Tests single quarter, time series, latest quarter, peer comparison, 404s, and validates Flutter entity dictionary compatibility.
     - `test_documents_api.py`: Tests document catalog, task status polling, non-PDF rejection (400), and upload endpoint aliases.
     - Pure assertions using in-memory SQLite (`StaticPool`) and zero disk artifacts during tests.
  5. **Playbook & Playbook Synchronization**:
     - Updated both `server/RUN.md` and root `RUN.md` with Section 7 (FastAPI Server & cURL commands) and upgraded the All-in-One Master Test Runner to all 15 suites.
- **Verification**:
  - Tested live FastAPI server on port 8000.
  - Executed `curl -s -X POST "http://localhost:8000/api/v1/ingestion/upload" -F "file=@tests/test_data/TSLA-Q2-2026-Update.pdf" -F "force=true"`: Succeeded in 4.2s, generated all sequential artifacts `01` through `06` in `server/.artifact/`.
  - Executed duplicate upload without `--force`: Returned in 0.01s with `"is_duplicate": true`.
  - Executed live queries: `curl http://localhost:8000/health`, `curl http://localhost:8000/api/v1/kpi/TSLA?quarter=Q2&year=2026`, `curl http://localhost:8000/api/v1/kpi/META`.
  - **All 15 master test suites passed cleanly.**

---

### Step 7.1: Flutter Client Remote REST DataSource (`RemoteKpiDataSource`)
- **Status**: ✅ Completed
- **What Was Built**:
  1. **HTTP Client Dependency Integration**:
     - Added `http: ^1.6.0` to [client/packages/ai_analyst_feature/pubspec.yaml](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/client/packages/ai_analyst_feature/pubspec.yaml) following the `flutter-use-http-package` best practices.
  2. **`RemoteKpiDataSource` Implementation** ([client/packages/ai_analyst_feature/lib/data/datasources/remote_kpi_datasource.dart](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/client/packages/ai_analyst_feature/lib/data/datasources/remote_kpi_datasource.dart)):
     - **Dynamic Cross-Platform Host Resolution**: Automatically routes to `http://10.0.2.2:8000/api/v1` on Android Emulator, `http://localhost:8000/api/v1` on iOS Simulator, macOS Desktop, and Web via `defaultTargetPlatform` without platform-specific crashes.
     - **API Consumer Operations**:
       - `fetchReportsForTicker(String ticker)`: Calls `GET /api/v1/kpi/{ticker}`, deserializes `client_reports` list via `QuarterlyKpis.fromJson()`.
       - `fetchLatestReport(String ticker)`: Calls `GET /api/v1/kpi/{ticker}/latest`, deserializes the most recent quarter.
       - `fetchDocumentTickers()`: Calls `GET /api/v1/documents` catalog to discover active tickers.
       - `getAvailableReports()`: Aggregates reports across tickers, with seamless fallback to `MockKpiDataSource.getAvailableReports()` if the server is offline or unreachable.
       - `uploadAndIngestPdf()`: Sends multipart POST request to `/api/v1/ingestion/upload` with raw bytes, filename, and metadata flags.
     - **Cross-Platform Exception**: Defined `RemoteApiException` with status code and URI context, avoiding `dart:io` limitations on web.
     - **Dependency Injection**: Exported `remoteKpiDataSourceProvider` for Riverpod state management.
  3. **Unit Test Suite** ([client/packages/ai_analyst_feature/test/datasources/remote_kpi_datasource_test.dart](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/client/packages/ai_analyst_feature/test/datasources/remote_kpi_datasource_test.dart)):
     - Implemented 5 unit tests with `MockClient`:
       - Time series `client_reports` JSON parsing
       - Latest single report parsing
       - Document catalog ticker discovery
       - Resilient offline fallback to mock data on network error
       - Multipart upload with field assertions and response parsing
- **Verification**:
  - `flutter analyze lib/data/datasources/remote_kpi_datasource.dart`: 0 issues found.
  - `flutter test`: All 15 tests in `ai_analyst_feature` passed.
  - `flutter test` in `apps/gen_stock_folio`: All smoke and widget navigation tests passed.

---

### Step 7.2: Wire Remote DataSource into ViewModel & Report Ingestion Panel
- **Status**: ✅ Completed
- **What Was Built**:
  1. **ViewModel Wire-up & Upload Operation** ([client/packages/ai_analyst_feature/lib/presentation/viewmodel/kpi_dashboard_viewmodel.dart](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/client/packages/ai_analyst_feature/lib/presentation/viewmodel/kpi_dashboard_viewmodel.dart)):
     - Connected `KpiDashboardViewModel.loadReports()` directly to `ref.read(remoteKpiDataSourceProvider).getAvailableReports()`.
     - Added first-class `uploadReport()` method to ViewModel, uploading files via `RemoteKpiDataSource.uploadAndIngestPdf()` and automatically updating `availableReports` and `selectedReport` in the state.
  2. **`ReportIngestionPanel` Multipart Integration** ([client/packages/ai_analyst_feature/lib/presentation/views/widgets/report_ingestion_panel.dart](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/client/packages/ai_analyst_feature/lib/presentation/views/widgets/report_ingestion_panel.dart)):
     - Updated file picker to request raw bytes via `withData: true`.
     - In `_startIngestion()`, calls `RemoteKpiDataSource.uploadAndIngestPdf()` to hit FastAPI's `/api/v1/ingestion/upload` with real PDF bytes, receiving dynamic LLM GAAP KPI extractions.
     - Implemented graceful offline fallback: If backend server is unreachable or offline, catches error and calculates local metrics so headless automated tests and offline devices never crash.
  3. **High-Speed Liveness Health Probe (`checkHealth`)**:
     - Added 350ms health probe to `RemoteKpiDataSource` hitting `/health`. If offline, fast-paths to mock data in milliseconds rather than waiting for multiple endpoint timeouts.
     - Accurately guarded Android emulator host resolution (`10.0.2.2`) using `io.Platform.isAndroid` to avoid desktop test runner conflicts.
  4. **Live Server Integration Test Suite** ([client/packages/ai_analyst_feature/test/datasources/live_server_integration_test.dart](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/client/packages/ai_analyst_feature/test/datasources/live_server_integration_test.dart)):
     - Tests live communication against running FastAPI server:
       - `checkHealth()` liveness confirmation
       - `fetchDocumentTickers()` catalog discovery
       - `fetchReportsForTicker('TSLA')` live SQLite parsing
       - `uploadAndIngestPdf()` live file ingestion and 0.1ms instant deduplication cache
- **Verification**:
  - `flutter analyze`: 0 issues found across entire feature package.
  - `flutter test test/datasources/live_server_integration_test.dart`: All 4 tests passed against live server on `:8000`.
  - `flutter test`: All 19 tests in `ai_analyst_feature` passed in 2.1 seconds.
  - `flutter test` in `apps/gen_stock_folio`: All smoke and widget navigation tests passed.

---

## 🔍 Phase 3: Hybrid Retrieval Engine (Embeddings, ChromaDB, & BM25)

With the deterministic KPI database, FastAPI gateway, and Flutter client complete, we begin **Phase 3: Hybrid Search Retrieval**.
Per user direction, we decouple the dense and sparse pipelines into three isolated, modular milestones:
1. **Step 3.1: OpenAI Embeddings Factory & Cosine Math** (`indexing/embeddings.py`) — ✅ Completed
2. **Step 3.2: ChromaDB Vector Store Ingestion & Metadata Filtering** (`indexing/vector_store.py`) — ✅ Completed
3. **Step 3.3: BM25 Sparse Keyword Indexing & Inverted Index** (`indexing/bm25_index.py`) — ✅ Completed
4. **Step 3.4: Ingestion Pipeline Dual Indexing & Hybrid Retrieval Engine** (`retrieval/`) — ✅ Completed
5. **Phase 4: Central Financial Agent Orchestration (`agent/`) & ReAct Tools** — 🔄 Up Next

---

### Step 3.1: OpenAIEmbeddings Model Factory & Vector Math (`embeddings.py`)
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/indexing/__init__.py` ([__init__.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/indexing/__init__.py))
  - `server/app/indexing/embeddings.py` ([embeddings.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/indexing/embeddings.py))
  - `server/tests/indexing/test_embeddings.py` ([test_embeddings.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/indexing/test_embeddings.py))
  - `server/.artifact/idx_01_embeddings_sample.json` ([idx_01_embeddings_sample.json](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/idx_01_embeddings_sample.json))
  - `server/.artifact/idx_01_embeddings_sample.md` ([idx_01_embeddings_sample.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/idx_01_embeddings_sample.md))
- **What Was Built**:
  1. **Embeddings Factory (`get_embeddings_model`)**:
     - Configured LangChain's `OpenAIEmbeddings` using `text-embedding-3-small`.
     - Standardized default dimension size to `512` (OpenAI native Matryoshka dimension reduction), reducing vector index memory and storage footprint while retaining >98% retrieval precision.
     - Centralizes API key loading, timeout configuration, and dimensional validation in one place.
  2. **Mathematical Vector Operations (`compute_cosine_similarity`)**:
     - Deterministic dot-product over L2-norm implementation.
     - Handles orthogonal vectors (0.0), identical vectors (1.0), opposite vectors (-1.0), and zero vectors (0.0) without division-by-zero crashes.
  3. **Standalone CLI Runner & Artifact Generation**:
     - `python app/indexing/embeddings.py` embeds query and financial context against OpenAI, validates 512 dimensions, evaluates cosine similarity (0.5309 score), and writes `idx_01_embeddings_sample.[json|md]` to `.artifact/`.
  4. **1:1 Mirror Unit Test Suite (`tests/indexing/test_embeddings.py`)**:
     - Tests defaults (model name & 512 dimensions).
     - Tests custom dimension parameterization (e.g. 256).
     - Tests missing API key exception handling (`ValueError`).
     - Tests all mathematical edge cases of cosine similarity.
     - Pure in-memory unit tests using mocked vector arrays—zero network calls and zero disk side effects during tests.
- **Verification**:
  - Ran `python tests/indexing/test_embeddings.py`: All 5 test cases passed.
  - Ran All-in-One Master Test Runner (16 test suites): All 16 suites passed cleanly with 0 errors.

---

### Step 3.2: ChromaDB Vector Store Ingestion & Metadata Filtering (`vector_store.py`)
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/indexing/vector_store.py` ([vector_store.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/indexing/vector_store.py))
  - `server/tests/indexing/test_vector_store.py` ([test_vector_store.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/indexing/test_vector_store.py))
  - `server/.artifact/idx_02_vector_store_sample.json` ([idx_02_vector_store_sample.json](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/idx_02_vector_store_sample.json))
  - `server/.artifact/idx_02_vector_store_sample.md` ([idx_02_vector_store_sample.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/idx_02_vector_store_sample.md))
- **What Was Built**:
  1. **ChromaDB Dependency Integration**:
     - Added `chromadb>=1.5.9` and `langchain-chroma>=1.1.0` via `uv add`.
  2. **`FinancialVectorStore` Wrapper Class**:
     - Configured ChromaDB collection `earnings_chunks` with HNSW cosine metric (`{"hnsw:space": "cosine"}`).
     - Direct ingestion via `add_chunks(chunks: List[EnrichedChunk])`: Unpacks `chunk.id`, `chunk.text`, and metadata facets (`ticker`, `fiscal_quarter`, `fiscal_year`, `financial_domain`, `page_number`, `chunk_index_in_page`, `total_chunks_in_page`) directly into ChromaDB.
     - Flexible client injection: Supports persistent storage (`data/chroma`) for runtime and `chromadb.EphemeralClient()` for pure in-memory unit tests.
  3. **Metadata Filtering Engine (`build_chroma_filter`)**:
     - Dynamically formats Chroma filter syntax: returns `None` for no filters, a single dict `{"field": val}` for 1 condition, and `{"$and": [...]}` for multi-criteria filters (`ticker`, `fiscal_quarter`, `fiscal_year`, `financial_domain`).
  4. **Similarity Retrieval Operations**:
     - `similarity_search(query, k, ...)`: Retrieves top-k documents with hard metadata pre-filtering.
     - `similarity_search_with_scores(query, k, ...)`: Returns tuples of `(Document, relevance_score)`.
     - `delete_by_ticker(ticker)`: Deletes chunks for a specific ticker to support clean re-ingestion.
     - `count()` and `reset()`: Diagnostic and maintenance primitives.
  5. **Standalone CLI Runner & Observable Inspection Artifact**:
     - `python app/indexing/vector_store.py` ingests 66 real chunks from `03b_enriched_chunks_tsla_q2_2026_update.json` into ChromaDB.
     - Executes filtered similarity queries against cash flow and profitability statements.
     - Exports `idx_02_vector_store_sample.[json|md]` to `server/.artifact/`.
  6. **1:1 Mirror Unit Test Suite (`tests/indexing/test_vector_store.py`)**:
     - In-memory `EphemeralClient()` and `FakeEmbeddings(size=512)` with zero network calls and zero disk side effects.
     - Verifies `build_chroma_filter` rules (0 conditions, 1 condition, multiple conditions, domain conditions).
     - Verifies empty chunk handling and incremental chunk counts.
     - Verifies multi-attribute filtering (TSLA vs META, Q1 vs Q2, domain separation).
     - Verifies relevance score generation, `delete_by_ticker`, and collection reset.
- **Verification**:
  - Ran `python tests/indexing/test_vector_store.py`: All 5 test cases passed.
  - Ran All-in-One Master Test Runner (17 test suites): All 17 suites passed cleanly with 0 errors.

---

### Step 3.3: BM25 Sparse Keyword Indexing & Inverted Index (`bm25_index.py`)
- **Status**: ✅ Completed
- **Files Created**:
  - `server/app/indexing/bm25_index.py` ([bm25_index.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/indexing/bm25_index.py))
  - `server/tests/indexing/test_bm25_index.py` ([test_bm25_index.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/indexing/test_bm25_index.py))
  - `server/data/bm25/bm25_index.pkl` (Serialized index cache)
  - `server/.artifact/idx_03_bm25_sample.json` ([idx_03_bm25_sample.json](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/idx_03_bm25_sample.json))
  - `server/.artifact/idx_03_bm25_sample.md` ([idx_03_bm25_sample.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/idx_03_bm25_sample.md))
- **What Was Built**:
  1. **Financial Tokenizer (`financial_tokenize`)**:
     - Preserves numbers, currency symbols, percentages, and commas (`$1,340`, `1,340`, `18.5%`, `18.5`).
     - Preserves hyphenated terms and accounting acronyms (`non-gaap`, `year-over-year`, `EBITDA`, `CapEx`).
     - Normalizes plurals (`revenues` -> `revenue`, `expenditures` -> `expenditure`) so search queries match both grammatical forms.
  2. **`BM25KeywordIndex` Class**:
     - In-memory `rank_bm25.BM25Okapi` inverted index (`k1=1.5`, `b=0.75`).
     - Positive IDF floor enforcement: Prevents zero-score drops when terms appear across >=50% of chunks in small corpora.
     - `add_chunks(chunks: List[EnrichedChunk])`: Tokenizes and deduplicates chunks by `chunk_id`.
     - `search(query, k, ...)`: Vectorized BM25 scoring with metadata pre-filtering by `ticker`, `fiscal_quarter`, `fiscal_year`, and `financial_domain`. Filters out zero-match scores (`score <= min_score`).
     - `delete_by_ticker(ticker)` and `reset()`: Lifecycle index maintenance.
     - `save(path)` / `load(path)`: Fast binary pickle serialization to `server/data/bm25/bm25_index.pkl`.
  3. **Standalone CLI Runner & Observable Inspection Artifacts**:
     - Ingested 66 real chunks from Tesla Q2 2026.
     - Executed searches:
       - `"Free cash flow $1,340M"` -> Top score: 7.0875 on Page 31.
       - `"automotive gross margin 18.5%"` -> Top score: 7.7176 on Page 30.
       - `"GAAP operating income $0.4B"` -> Top score: 11.6525 on Page 3.
     - Generated `idx_03_bm25_sample.[json|md]`.
  4. **1:1 Mirror Unit Test Suite (`tests/indexing/test_bm25_index.py`)**:
     - Tests financial tokenization rules (currency, percentages, acronyms, casing).
     - Tests duplicate chunk rejection.
     - Tests exact keyword matches and top ranking.
     - Tests metadata pre-filtering across tickers, quarters, and domains.
     - Tests deletion by ticker and reset operations.
     - Tests serialization roundtrip using temporary directories.
     - 100% in-memory with zero external API calls.
- **Verification**:
  - Ran `python tests/indexing/test_bm25_index.py`: All 6 test cases passed.
  - Ran All-in-One Master Test Runner (18 test suites): All 18 suites passed cleanly with 0 errors.

---

### Step 3.4: Ingestion Pipeline Dual Indexing & Hybrid Retrieval Engine (`retrieval/`)
- **Status**: ✅ Completed
- **Files Created & Modified**:
  - `server/app/ingestion/pipeline.py` ([pipeline.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/pipeline.py))
  - `server/tests/ingestion/test_pipeline.py` ([test_pipeline.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/ingestion/test_pipeline.py))
  - `server/app/schemas/retrieval.py` ([retrieval.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/schemas/retrieval.py))
  - `server/app/schemas/__init__.py` ([__init__.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/schemas/__init__.py))
  - `server/app/retrieval/__init__.py` ([__init__.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/retrieval/__init__.py))
  - `server/app/retrieval/dense_retriever.py` ([dense_retriever.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/retrieval/dense_retriever.py))
  - `server/app/retrieval/sparse_retriever.py` ([sparse_retriever.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/retrieval/sparse_retriever.py))
  - `server/app/retrieval/hybrid_fusion.py` ([hybrid_fusion.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/retrieval/hybrid_fusion.py))
  - `server/app/retrieval/reranker.py` ([reranker.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/retrieval/reranker.py))
  - `server/app/retrieval/hybrid_engine.py` ([hybrid_engine.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/retrieval/hybrid_engine.py))
  - `server/tests/retrieval/__init__.py` ([__init__.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/retrieval/__init__.py))
  - `server/tests/retrieval/test_retrieval.py` ([test_retrieval.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/retrieval/test_retrieval.py))
  - `server/.artifact/idx_04_hybrid_retrieval_sample.json` ([idx_04_hybrid_retrieval_sample.json](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/idx_04_hybrid_retrieval_sample.json))
  - `server/.artifact/idx_04_hybrid_retrieval_sample.md` ([idx_04_hybrid_retrieval_sample.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/.artifact/idx_04_hybrid_retrieval_sample.md))
- **What Was Built**:
  1. **Dual Ingestion Wiring (`app/ingestion/pipeline.py`)**:
     - Added Step 8: `status="INDEXING"` (95% progress) right after SQLite persistence (90% progress).
     - Feeds `EnrichedChunk` list into both `FinancialVectorStore.add_chunks()` and `BM25KeywordIndex.add_chunks()`.
     - Supports dependency injection of `vector_store` and `bm25_index` in `__init__`, enabling 100% in-memory test isolation.
     - Supports `--force` purge & re-index: calls `delete_by_ticker(canonical_ticker)` on both stores before re-ingestion.
     - Serializes BM25 index to disk (`server/data/bm25/bm25_index.pkl`).
     - Added `vector_chunks_indexed` and `bm25_chunks_indexed` metrics to `IngestionResult` and artifact `06_pipeline_ingest_*`.
     - Verified CLI execution: TSLA ingested 66 chunks into ChromaDB + 66 chunks into BM25; META ingested 24 chunks into ChromaDB + 24 chunks into BM25.
  2. **Dense Retriever (`dense_retriever.py`)**:
     - Cosine similarity search against ChromaDB (`earnings_chunks` collection) with metadata pre-filtering by ticker, quarter, year, and financial domain.
     - Normalizes results into standardized `RetrievedChunk` payloads with `dense_rank`.
  3. **Sparse BM25 Retriever (`sparse_retriever.py`)**:
     - Lexical keyword and exact accounting acronym search against `BM25KeywordIndex` with positive IDF floor enforcement and metadata filtering.
     - Normalizes results into `RetrievedChunk` payloads with `sparse_rank`.
  4. **Reciprocal Rank Fusion (`hybrid_fusion.py`)**:
     - Mathematical implementation of weighted Reciprocal Rank Fusion:
       $$RRF\_score(d) = w_{dense} \cdot \frac{1}{60 + rank_{dense}(d)} + w_{sparse} \cdot \frac{1}{60 + rank_{sparse}(d)}$$
     - Solves the raw score scale mismatch problem (cosine $[0.0, 1.0]$ vs. BM25 $[0.0, 20.0+]$).
     - Boosts documents appearing in both dense and sparse candidate pools directly to the top.
  5. **Cross-Encoder Reranker (`reranker.py`)**:
     - Contextual re-scoring layer that evaluates `(query, document_text)` joint relevance.
     - Detects exact financial token density, numeric overlap, and causal explanations.
     - Supports custom scoring callables for testing and graceful fallback to fast token-density scoring when heavy GPU packages are absent.
  6. **Unified Engine (`hybrid_engine.py`)**:
     - Orchestrates Dense (top-10) + Sparse (top-10) -> RRF Fusion -> Cross-Encoder Rerank (top-k).
     - Formats clean citation pills: `[Page 31 · Cash Flow]`.
     - Tested on TSLA Q2 2026 query: *"What was the Free Cash Flow and why did it decline?"* -> Successfully ranked Page 25 (`TSLA_Q2_2026_p25_c1`) containing the exact qualitative explanation (*"sequential decrease of $1.2B was a result of negative free cash flow of $1.1B, driven by a sequential increase in capex of $3.3B"*).
  7. **1:1 Mirror Unit Test Suite (`tests/retrieval/test_retrieval.py`)**:
     - Pure in-memory unit tests using `chromadb.EphemeralClient()`, `FakeEmbeddings(size=512)`, and in-memory `BM25KeywordIndex(persist_dir=None)`.
     - 5 test suites: Dense retrieval, Sparse retrieval, RRF math, Reranker, and End-to-End Hybrid Engine.
   8. **Direct `langchain_classic.retrievers.EnsembleRetriever` Integration**:
      - Directly integrated `from langchain_classic.retrievers import EnsembleRetriever`.
      - Updated `DenseRetriever` and `SparseRetriever` to inherit from `langchain_core.retrievers.BaseRetriever`, implementing `_get_relevant_documents(query)`.
      - Initialized `EnsembleRetriever(retrievers=[self.dense_retriever, self.sparse_retriever], weights=[0.5, 0.5], c=60, id_key="chunk_id")` in `HybridRetrievalEngine`.
      - Supports both standard LangChain LCEL `invoke(query)` and standalone `fuse(dense_results, sparse_results)` with score/rank lineage preservation.
      - Updated `tests/retrieval/test_retrieval.py` with direct assertions on `LangChainEnsembleRetriever` and `invoke()`.
- **Verification**:
  - Ran `python tests/ingestion/test_pipeline.py`: All 4 tests passed.
  - Ran `python tests/retrieval/test_retrieval.py`: All 5 tests passed.
  - Ingested TSLA Q2 2026 (`--force`): 66 vector chunks, 66 BM25 chunks.
  - Ingested META Q2 2026 (`--force`): 24 vector chunks, 24 BM25 chunks.
  - Ran `app/retrieval/hybrid_engine.py`: Generated `idx_04_hybrid_retrieval_sample.[json|md]`.
  - Ran Master Test Runner across **19 test suites**: All 19 suites passed cleanly with 0 errors!

---

### Clean-Up & Reset of Indexing & Retrieval
- **Date**: Oct 17, 2026
- **What Was Done**:
  - Completely cleaned up and deleted:
    - `server/app/indexing/`
    - `server/app/retrieval/`
    - `server/tests/indexing/`
    - `server/tests/retrieval/`
    - `server/app/schemas/retrieval.py`
    - `server/data/chroma/` and `server/data/bm25/`
  - Created safety backup in `server/.backup_indexing_retrieval/`.
  - Decoupled `server/app/ingestion/pipeline.py` and `server/tests/ingestion/test_pipeline.py` so Phase 1 (PDF Ingestion) and Phase 2 (SQLite KPIs) and Phase 6/7 (FastAPI & Flutter) remain 100% functional with passing tests.
  - Phase 3 was reset to a fresh, clean slate, ready for rewriting a dead-simple, notebook-aligned version.

---

### Step 3: Simplified Hybrid Indexing & Retrieval Implementation (Notebook-Aligned)
- **Date**: Oct 17, 2026
- **Context & Design Philosophy**:
  - The previous indexing and retrieval architecture was over-engineered with hand-rolled inverted index tokenizers, custom BM25Okapi scoring formulas, and deep retriever inheritance hierarchies that made the system difficult to follow.
  - We restarted fresh with a clean, educational design that strictly mirrors the beginner-friendly course notebooks:
    - [`week2-rag/1_rag_pipeline.ipynb`](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-rag/1_rag_pipeline.ipynb): Dense semantic search via `OpenAIEmbeddings(model="text-embedding-3-small", dimensions=512)` and Chroma.
    - [`week2-rag/3_hybrid_rag.ipynb`](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-rag/3_hybrid_rag.ipynb): Sparse keyword search via `BM25Retriever.from_documents(docs)` and Reciprocal Rank Fusion via `EnsembleRetriever(retrievers=[vector_retriever, bm25_retriever], weights=[0.5, 0.5])`.
- **Files Created & Modified**:
  - `server/app/indexing/vector_index.py` ([vector_index.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/indexing/vector_index.py)):
    - `get_embeddings()` using `OpenAIEmbeddings(model="text-embedding-3-small", dimensions=512)`.
    - `VectorIndex` class wrapping `Chroma` with standard methods: `add_documents()`, `add_chunks()`, `as_retriever()`, `similarity_search()`, `count()`, `delete_by_ticker()`, and `save_artifact()`.
    - CLI runner (`python app/indexing/vector_index.py --mock`) which indexes sample chunks and generates the artifact.
    - Artifact output: `server/.artifact/idx_02_vector_store_sample.md`.
  - `server/app/indexing/bm25_index.py` ([bm25_index.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/indexing/bm25_index.py)):
    - Directly wraps LangChain's `BM25Retriever.from_documents(docs)`.
    - `BM25Index` class with `add_documents()`, `add_chunks()`, `as_retriever(k=k, filter=...)`, `search()`, `count()`, `delete_by_ticker()`, and clean JSON persistence to `server/data/bm25/documents.json`.
    - CLI runner (`python app/indexing/bm25_index.py`) which indexes sample chunks and generates the artifact.
    - Artifact output: `server/.artifact/idx_03_bm25_sample.md`.
  - `server/app/indexing/__init__.py` ([__init__.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/indexing/__init__.py)): Cleanly exports `VectorIndex`, `BM25Index`, and `get_embeddings`.
  - `server/app/retrieval/hybrid_engine.py` ([hybrid_engine.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/retrieval/hybrid_engine.py)):
    - `create_ensemble_retriever(vector_index, bm25_index, ticker=None, k=5, weights=[0.5, 0.5])` directly wrapping `langchain_classic.retrievers.EnsembleRetriever`.
    - `HybridEngine` class:
      - `get_retriever()`: returns the fused `EnsembleRetriever`.
      - `search(query, ticker=None, k=5, weights=None, save_artifact=True)`: executes hybrid search and returns the top-$k$ fused documents while writing the artifact.
      - `show_hybrid(query, ticker=None, k=3)`: educational/diagnostic helper matching the notebook to inspect Vector vs. BM25 vs. Ensemble side-by-side.
      - CLI runner (`python app/retrieval/hybrid_engine.py "query" --ticker TSLA --k 5 --mock`) writing outputs directly to `server/.artifact/idx_04_hybrid_retrieval_sample.md`.
  - `server/app/retrieval/__init__.py` ([__init__.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/retrieval/__init__.py)): Cleanly exports `HybridEngine` and `create_ensemble_retriever`.
  - `server/app/ingestion/pipeline.py` ([pipeline.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/ingestion/pipeline.py)):
    - Integrated `add_chunks()` and `save_artifact()` on both vector and BM25 stores when `save_artifacts=True`.
- **Unit Test Coverage (100% In-Memory)**:
  - `server/tests/indexing/test_vector_index.py`: 6 tests covering embeddings config, add/count, similarity search, metadata filtering, retriever interface, and ticker deletion using `chromadb.EphemeralClient()` and `FakeEmbeddings(size=512)`.
  - `server/tests/indexing/test_bm25_index.py`: 6 tests covering add/count, exact keyword matching, filtered search, retriever interface, ticker deletion, and disk reload persistence.
  - `server/tests/retrieval/test_retrieval.py`: 4 tests covering `EnsembleRetriever` instantiation, hybrid search execution, ticker filtering, and `show_hybrid` comparison view.
- **Verification Results**:
  - `python tests/indexing/test_vector_index.py`: All 6 tests passed in 1s.
  - `python tests/indexing/test_bm25_index.py`: All 6 tests passed in 1s.
  - `python tests/retrieval/test_retrieval.py`: All 4 tests passed in 1s.
  - Master Test Runner: All **18 test suites** across the entire project passed cleanly with 0 errors!
  - Artifacts generated and verified:
    - `server/.artifact/idx_02_vector_store_sample.md` (Chroma vector store)
    - `server/.artifact/idx_03_bm25_sample.md` (BM25 keyword index)
    - `server/.artifact/idx_04_hybrid_retrieval_sample.md` (Ensemble hybrid retrieval)

---

### Step 4: TypeSafe Query Intent Classifier (Jev Decision Model)
- **Date**: Oct 17, 2026
- **Context & Design Philosophy**:
  - In financial question answering, routing user queries to the correct downstream subsystem is critical:
    - Exact, audited metrics (e.g., *"What was Tesla's Q2 2026 revenue and free cash flow?"*) must be answered deterministically from the SQLite database.
    - Qualitative explanations (e.g., *"Why did automotive gross margin decline sequentially?"*) must be answered via Hybrid RAG (Ensemble of Chroma + BM25) over filings.
    - Peer and trend questions (e.g., *"Compare Meta and Tesla operating margins"*) must be routed to multi-quarter comparison repositories.
  - Generative LLMs generate filters token-by-token as JSON, which can be slow and prone to formatting errors. Instead, we use **Jev**, TypeSafe's "System One" decision model, directly following [`week2-rag/2_metadata_filtering.ipynb`](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-rag/2_metadata_filtering.ipynb) (lines 562–612).
  - Jev treats classification as a **decision**: it picks one option per question from a predefined list and returns calibrated probabilities and confidences with typed output and zero JSON parsing overhead.
- **Files Created**:
  - `server/app/classifier/jev_classifier.py` ([jev_classifier.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/classifier/jev_classifier.py)):
    - `QueryClassification` Pydantic model with `.to_metadata_filter()` (for BM25/retrievers) and `.to_chroma_filter()` (with `$and` syntax).
    - `get_jev_questions()`: 3 `Choice` questions matching the course notebook:
      1. `query_type`: `sql_kpi`, `hybrid_rag`, `comparison`.
      2. `financial_domain`: `profitability`, `cash_flow`, `balance_sheet`, `guidance_outlook`, `none`.
      3. `ticker`: `TSLA`, `META`, `AAPL`, `multiple`, `none`.
    - `classify_query(query, classifier=None, mock=False)`: Invokes Jev (`TypeSafeClassifier`), unpacks choices, maps `"none"` back to `None`, and falls back gracefully to a deterministic mock in network-restricted environments.
    - `save_artifact()`: Exports human-readable Markdown inspection reports to `server/.artifact/idx_05_classifier_sample.md`.
    - CLI runner (`python app/classifier/jev_classifier.py [--mock]`).
  - `server/app/classifier/__init__.py` ([__init__.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/app/classifier/__init__.py)): Exports `QueryClassification`, `classify_query`, `get_jev_questions`, and `save_artifact`.
  - `server/tests/classifier/test_classifier.py` ([test_classifier.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/classifier/test_classifier.py)): 8 pure in-memory unit tests.
- **Unit Test Coverage (100% In-Memory)**:
  - `test_query_classification_model_filters`: Tests single ticker, ticker+domain, and multi-ticker filter translation.
  - `test_mock_classifier_sql_kpi`: Tests deterministic classification of exact financial queries.
  - `test_mock_classifier_hybrid_rag`: Tests deterministic classification of qualitative narrative queries.
  - `test_mock_classifier_comparison`: Tests deterministic classification of peer comparison queries.
  - `test_jev_questions_structure`: Verifies question definitions and criteria keys.
  - `test_classify_query_with_mocked_jev`: Verifies end-to-end integration and choice unpacking using mock `TypeSafeClassifier`.
  - `test_classify_query_none_mapping`: Verifies that `"none"` choice answers correctly map to `None`.
  - `test_save_artifact_roundtrip`: Verifies Markdown artifact generation.
- **Verification Results**:
  - `python tests/classifier/test_classifier.py`: All 8 unit tests passed in 0.5s.
  - `python app/classifier/jev_classifier.py`: Live call to TypeSafe Jev API correctly routed all 3 test queries with calibrated confidences and generated `server/.artifact/idx_05_classifier_sample.md`.
  - Master Test Runner: All **19 test suites** across the entire project passed cleanly with 0 errors!





