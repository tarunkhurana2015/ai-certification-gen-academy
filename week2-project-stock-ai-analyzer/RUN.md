# 🚀 Complete CLI Execution & Testing Playbook (`RUN.md`)

This guide provides copy-paste ready commands to run every component of the **GenStockFolio AI Analyst** backend.

All commands are arranged in chronological pipeline order:
`Parsers` ──▶ `Chunkers` ──▶ `Extractors` ──▶ `Database & Persistence` ──▶ `All Tests Master Runner`

---

## 🛠️ Step 0: Environment Setup & Directory

Always ensure you are in the `server` directory and the Python virtual environment is active:

```bash
cd /Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server
source .venv/bin/activate
```

*(Or simply use `./.venv/bin/python <script_path>`)*

---

## 📑 1. Ingestion Validation (Header Bytes & SHA-256 Hashing)

### A. Run CLI Component (Generates Checksum & Size)
```bash
python app/ingestion/validator.py tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf
```

### B. Run Unit Tests (Pure Assertions)
```bash
python tests/ingestion/test_validator.py
```

---

## 📄 2. Parsers (Page Text Extraction & Section Classification)

### A. Run Page-by-Page Text Extractor CLI
Extracts text while preserving 1-indexed page boundaries. Outputs artifact `01_extracted_<doc>.[json|md]`:
```bash
# Meta Q2 2026 (9 pages)
python app/ingestion/parsers/pdf_extractor.py tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf

# Tesla Q2 2026 (33 pages)
python app/ingestion/parsers/pdf_extractor.py tests/test_data/TSLA-Q2-2026-Update.pdf
```

### B. Run Section Classifier CLI (Financial Domain Tagger)
Normalizes spaced typography and classifies pages into GAAP domains (`PROFITABILITY`, `BALANCE_SHEET`, `CASH_FLOW`, etc.). Outputs artifact `02_classified_<doc>.[json|md]`:
```bash
# Meta Q2 2026
python app/ingestion/parsers/section_classifier.py tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf

# Tesla Q2 2026
python app/ingestion/parsers/section_classifier.py tests/test_data/TSLA-Q2-2026-Update.pdf
```

### C. Run Parser Unit Tests (Pure Assertions)
```bash
python tests/ingestion/parsers/test_pdf_extractor.py
python tests/ingestion/parsers/test_section_classifier.py
```

---

## 🧩 3. Chunkers (Recursive Splitting & Metadata Enrichment)

### A. Run Recursive Chunker CLI
Extracts text page-by-page via `pdf_extractor` and recursively splits each page into character-bounded chunks (1,000 char size / 100 overlap / financial separators). Outputs artifact `03a_recursive_splits_<doc>.[json|md]`:
```bash
# Meta Q2 2026 (9 pages -> 24 raw splits)
python app/ingestion/chunkers/recursive_chunker.py tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf

# Tesla Q2 2026 (33 pages -> 66 raw splits)
python app/ingestion/chunkers/recursive_chunker.py tests/test_data/TSLA-Q2-2026-Update.pdf
```

### B. Run Metadata Enricher CLI
Splits document pages, decorates chunks with coordinates (`ticker`, `quarter`, `year`, `page_number`), attaches classified `financial_domain`, and stamps deterministic IDs (`{ticker}_{quarter}_{year}_p{page}_c{idx}`). Outputs artifact `03b_enriched_chunks_<doc>.[json|md]`:
```bash
# Meta Q2 2026
python app/ingestion/chunkers/metadata_enricher.py tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf

# Tesla Q2 2026
python app/ingestion/chunkers/metadata_enricher.py tests/test_data/TSLA-Q2-2026-Update.pdf
```

### C. Run Chunker Unit Tests (Pure Assertions)
```bash
python tests/ingestion/chunkers/test_recursive_chunker.py
python tests/ingestion/chunkers/test_metadata_enricher.py
```

---

## 🤖 4. Extractor & LLM Prompts (Structured GAAP KPIs & SQLite Persistence)

### A. Run LLM Extraction Prompts CLI
Composes a grounded extraction prompt using realistic dummy financial statement pages (or custom data passed via CLI), applies the Wall Street auditor persona, injects GAAP extraction rules, and outputs artifact `07a_sample_extraction_prompt.[json|md]` in a clean `{"input": {}, "prompt": ""}` format:
```bash
# Default (uses 3 dummy statement pages for META Q2 2026)
python app/ingestion/extractor/llm_extraction_prompts.py

# Optional custom data from the command line
python app/ingestion/extractor/llm_extraction_prompts.py --ticker TSLA --quarter Q2 --year 2026 --text "Tesla, Inc. Statements of Operations\nTotal Revenues: $25,500M\nNet Income: $1,478M" --page 2
```

### B. Run Live KPI Extractor CLI (Full End-to-End Extraction & Persistence)
Filters document to financial statement pages, calls OpenAI `gpt-4o-mini` with structured JSON output, validates mathematical consistency (CapEx sign reconciliation, Free Cash Flow = OCF - CapEx, margin ratios), registers parent document, persists into SQLite (`data/stock_analyst.db`), and queries back to verify round-trip fidelity.
Outputs artifacts `07_extracted_kpis_<doc>.[json|md]` and `08_persisted_kpis_<doc>.[json|md]`:

```bash
# Meta Q2 2026
python app/ingestion/extractor/kpi_extractor.py tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf --ticker META --quarter Q2 --year 2026

# Tesla Q2 2026
python app/ingestion/extractor/kpi_extractor.py tests/test_data/TSLA-Q2-2026-Update.pdf --ticker TSLA --quarter Q2 --year 2026
```

### C. Run Extractor Unit Tests (Pure Assertions with Mocked LLM & In-Memory SQLite)
```bash
python tests/ingestion/extractor/test_llm_extraction_prompts.py
python tests/ingestion/extractor/test_kpi_extractor.py
```

---

## 🗄️ 5. Database Tier (SQLite & Repositories)

### A. Run Database Initialization & ORM Models CLI
Initializes tables, creates indexes, tests cascade deletes, and outputs artifacts `04_database_init.[json|md]` and `05_database_models.[json|md]`:
```bash
python app/db/models.py
```

### B. Run Deterministic Repository Queries CLI
Demonstrates exact single quarter retrieval, multi-quarter chronological time series, peer company comparisons, and 0.1ms SHA-256 deduplication. Outputs artifact `06_kpi_repo_queries.[json|md]`:
```bash
python app/db/repositories/kpi_repo.py
```

### C. Run Database Unit Tests (Pure Assertions)
```bash
python tests/db/test_session.py
python tests/db/test_models.py
python tests/db/repositories/test_kpi_repo.py
```

---

## 📋 6. Schemas & Type Contracts

### Run Schemas Unit Tests (Pure Assertions)
```bash
python tests/schemas/test_schemas.py
```

---

## 🏆 7. All-in-One Master Test Runner

Run all **11 test suites** across the entire codebase in a single command:

```bash
python tests/schemas/test_schemas.py && \
python tests/db/test_session.py && \
python tests/db/test_models.py && \
python tests/db/repositories/test_kpi_repo.py && \
python tests/ingestion/test_validator.py && \
python tests/ingestion/parsers/test_pdf_extractor.py && \
python tests/ingestion/parsers/test_section_classifier.py && \
python tests/ingestion/chunkers/test_recursive_chunker.py && \
python tests/ingestion/chunkers/test_metadata_enricher.py && \
python tests/ingestion/extractor/test_llm_extraction_prompts.py && \
python tests/ingestion/extractor/test_kpi_extractor.py
```

---

## 📂 Summary of Artifacts Created During CLI Runs

When running scripts directly via CLI (`python app/...`), human-readable Markdown and machine-readable JSON artifacts are saved in `server/.artifact/` (git-ignored):

| Artifact Prefix | Generator CLI Script | Description |
| :--- | :--- | :--- |
| `01_extracted_<doc>` | `app/ingestion/parsers/pdf_extractor.py` | Page-by-page text, character counts, and blank page detection |
| `02_classified_<doc>` | `app/ingestion/parsers/section_classifier.py` | Financial domain tagging (`profitability`, `balance_sheet`, `cash_flow`) |
| `03a_recursive_splits_<doc>` | `app/ingestion/chunkers/recursive_chunker.py` | Raw character-bounded splits (1000 chars, 100 overlap) page-by-page |
| `03b_enriched_chunks_<doc>` | `app/ingestion/chunkers/metadata_enricher.py` | 1000-char chunks enriched with ticker, quarter, year, page, and domain |
| `04_database_init` | `app/db/models.py` | SQLite schema tables & foreign key verification |
| `05_database_models` | `app/db/models.py` | 18+ GAAP metric column definitions & cascade tests |
| `06_kpi_repo_queries` | `app/db/repositories/kpi_repo.py` | Time series, peer comparison, and 0.1ms deduplication queries |
| `07a_sample_extraction_prompt` | `app/ingestion/extractor/llm_extraction_prompts.py` | Grounded extraction prompt composed from dummy financial statement pages |
| `07_extracted_kpis_<doc>` | `app/ingestion/extractor/kpi_extractor.py` | Structured Pydantic GAAP KPIs extracted via OpenAI `gpt-4o-mini` |
| `08_persisted_kpis_<doc>` | `app/ingestion/extractor/kpi_extractor.py` | SQLite persisted record verification and round-trip SQL query |

> **Note**: Unit tests (`tests/...`) **never** generate artifacts and run strictly in-memory.
