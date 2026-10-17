# Stock AI Analyst — Developer Work Log & Learning Journal

> **Purpose**: A clear, beginner-friendly trace of every step, component, and architectural decision built in this project. Use this document whenever you need to see what was done, why it was done, and what comes next.
>
> 💡 **Concept & Architecture FAQ**: Check [FAQ.md](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/FAQ.md) for detailed explanations of why we made specific design decisions (e.g., SQLite vs files, `__init__.py`, LLM structured outputs across different PDF formats).

---

## 🗺️ Project Roadmap & Status

| Phase | Component | Focus / Learning Goal | Status |
| :--- | :--- | :--- | :--- |
| **Phase 0** | **Environment Setup** | Python 3.11+, virtualenv (`uv`), dependencies, `.env` | ✅ Completed |
| **Phase 1** | **PDF Ingestion Pipeline** | PDF validation, text extraction, section parsing, chunking | 🔄 **In Progress** |
| **Phase 2** | **Deterministic Database (SQLite)** | 18+ GAAP KPIs, time-series storage, task state tracking | ⏳ Pending |
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
- **Status**: ⏳ Pending / Next Up
- **Target File**: `server/app/ingestion/chunker.py`
- **Why this component?**:
  - LLMs have finite context windows, and dense vector embeddings lose semantic sharpness if chunks are too large (e.g. 5,000 chars).
  - This component uses LangChain's `RecursiveCharacterTextSplitter` (1000 characters with 100 overlap) to split each page while respecting paragraphs, tables, and sentence boundaries.
  - Each chunk is stamped with rich, typed metadata (`chunk_id`, `ticker`, `quarter`, `year`, `page_number`, `financial_domain`), which makes hard metadata pre-filtering possible in Pinecone and BM25!


