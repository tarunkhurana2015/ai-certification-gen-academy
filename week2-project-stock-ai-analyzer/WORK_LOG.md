# Stock AI Analyst — Developer Work Log & Learning Journal

> **Purpose**: A clear, beginner-friendly trace of every step, component, and architectural decision built in this project. Use this document whenever you need to see what was done, why it was done, and what comes next.

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
  - `server/tests/test_validator.py` ([test_validator.py](file:///Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server/tests/test_validator.py))
  - `server/tests/test_data/` (isolated sandbox for temporary test files)
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
- **Status**: ⏳ Pending / Next Up
- **Target File**: `server/app/ingestion/pdf_extractor.py`
- **Why this component?**:
  - In RAG systems, answers must be strictly grounded with page-level citations (e.g., *"Gross margin was 45.4% [Page 14]"*).
  - This component reads pages sequentially using `pypdf`, extracts the clean text, tracks the total page count, and bundles each page with its 1-indexed page number and character count.

