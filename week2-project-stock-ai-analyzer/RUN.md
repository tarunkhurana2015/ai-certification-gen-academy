# 🚀 Complete CLI Execution & Testing Playbook (`RUN.md`)

This guide provides copy-paste ready commands to run every component of the **GenStockFolio AI Analyst** backend.

All commands are arranged in logical pipeline order:
`Top-Level Ingestion Pipeline` ──▶ `Parsers` ──▶ `Chunkers` ──▶ `Extractors` ──▶ `Database & Persistence` ──▶ `All Tests Master Runner`

---

## 🛠️ Step 0: Environment Setup & Directory

Always ensure you are in the `server` directory and the Python virtual environment is active:

```bash
cd /Users/tarunkhurana/Engineering/projects/tarunkhurana2015/ai-certification-gen-academy/week2-project-stock-ai-analyzer/server
source .venv/bin/activate
```

*(Or simply use `./.venv/bin/python <script_path>`)*

---

## 📑 1. Document Ingestion Pipeline & Validation (Top-Level)

### A. Run Full Ingestion Pipeline CLI (End-to-End Orchestrator)
Chains validation, 0.1ms instant deduplication, page layout extraction, GAAP section classification, dynamic LLM GAAP KPI extraction, semantic chunking, and SQLite persistence.
When executed, generates inspection artifacts for every substep (`01_extracted_*`, `02_classified_*`, `03a_recursive_splits_*`, `03b_enriched_chunks_*`, `04_extracted_kpis_*`, `05_persisted_kpis_*`, and `06_pipeline_ingest_*`) in `server/.artifact/`:

```bash
# Meta Q2 2026 (demonstrates 0.1ms instant deduplication)
python app/ingestion/pipeline.py tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf

# Tesla Q2 2026 (use --force to bypass deduplication cache and regenerate all substep artifacts)
python app/ingestion/pipeline.py tests/test_data/TSLA-Q2-2026-Update.pdf --force

# With optional explicit hints
python app/ingestion/pipeline.py tests/test_data/TSLA-Q2-2026-Update.pdf --ticker TSLA --quarter Q2 --year 2026 --force
```

### B. Run Pipeline Unit Tests (Pure In-Memory Assertions)
```bash
python tests/ingestion/test_pipeline.py
```

---

### C. Run Independent File: Validation & SHA-256 Hashing (`validator.py`)
Runs standalone PDF header byte validation and SHA-256 fingerprinting:
```bash
python app/ingestion/validator.py tests/test_data/Meta-06-30-2026-Exhibit-99-1-FINAL.pdf
```

### D. Run Validation Unit Tests (Pure Assertions)
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
Composes a grounded extraction prompt using realistic dummy financial statement pages (or custom data passed via CLI), applies the Wall Street auditor persona, injects GAAP extraction rules, and outputs artifact `04a_sample_extraction_prompt.[json|md]` in a clean `{"input": {}, "prompt": ""}` format:
```bash
# Default dummy data
python app/ingestion/extractor/llm_extraction_prompts.py

# Custom data
python app/ingestion/extractor/llm_extraction_prompts.py --ticker TSLA --quarter Q2 --year 2026
```

### B. Run KPI Extractor & Persistence CLI (OpenAI Structured Outputs)
Filters document to financial statement pages, calls OpenAI `gpt-4o-mini` with structured JSON output, validates mathematical consistency (CapEx sign reconciliation, Free Cash Flow = OCF - CapEx, margin ratios), registers parent document, persists into SQLite (`data/stock_analyst.db`), and queries back to verify round-trip fidelity.
Outputs artifacts `04_extracted_kpis_<doc>.[json|md]` and `05_persisted_kpis_<doc>.[json|md]`:

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
Initializes tables, creates indexes, tests cascade deletes, and outputs artifacts `db_01_database_init.[json|md]` and `db_02_database_models.[json|md]`:
```bash
python app/db/models.py
```

### B. Run Deterministic Repository Queries CLI
Demonstrates exact single quarter retrieval, multi-quarter chronological time series, peer company comparisons, and 0.1ms SHA-256 deduplication. Outputs artifact `db_03_kpi_repo_queries.[json|md]`:
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

## ⚡ 7. FastAPI Gateway Server & REST Endpoints

### A. Start FastAPI Development Server
Starts the high-performance ASGI server on port 8000 with CORS enabled and auto-reloading:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Interactive Swagger / OpenAPI documentation is immediately available at:
- **Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **ReDoc**: [http://localhost:8000/redoc](http://localhost:8000/redoc)

### B. Sample API Invocations via cURL

```bash
# 1. Health Probe
curl -s http://localhost:8000/health

# 2. Upload & Ingest PDF Filing (Multipart Form)
curl -s -X POST "http://localhost:8000/api/v1/ingestion/upload" \
  -F "file=@tests/test_data/TSLA-Q2-2026-Update.pdf" \
  -F "force=true"

# 3. Retrieve Exact Single Quarter KPIs (TSLA Q2 2026)
curl -s "http://localhost:8000/api/v1/kpi/TSLA?quarter=Q2&year=2026"

# 4. Retrieve Chronological Time Series for Charts (META)
curl -s "http://localhost:8000/api/v1/kpi/META"

# 5. Retrieve Most Recent Reported Quarter
curl -s "http://localhost:8000/api/v1/kpi/META/latest"

# 6. Peer Company Comparison (META vs TSLA in Q2 2026)
curl -s "http://localhost:8000/api/v1/kpi/compare?tickers=META&tickers=TSLA&quarter=Q2&year=2026"

# 7. List Ingested Documents Catalog
curl -s http://localhost:8000/api/v1/documents

# 8. Query Financial Analyst RAG (Intent Routing -> Tool Retrieval -> Synthesized Answer)
curl -s -X POST "http://localhost:8000/api/v1/analyst/query" \
  -H "Content-Type: application/json" \
  -d '{"query": "What was Tesla Q2 2026 revenue and free cash flow?", "mock": true}'

# 9. Conversational Chat Alias Endpoint
curl -s -X POST "http://localhost:8000/api/v1/chat" \
  -H "Content-Type: application/json" \
  -d '{"query": "Compare Meta and Tesla operating margins over the last year", "mock": true}'

# 10. Inspect Intent Classification & Metadata Filters
curl -s "http://localhost:8000/api/v1/analyst/classify?q=What%20was%20Meta%20net%20income?&mock=true"

# 11. List Supported Routing Modes & Sample Prompt Chips
curl -s "http://localhost:8000/api/v1/analyst/routes"
```

### C. Run API Unit & Integration Tests (Pure Assertions)
```bash
python tests/api/test_health.py
python tests/api/test_kpis_api.py
python tests/api/test_documents_api.py
python tests/api/test_analyst_api.py
```

---

## 🧠 8. Simplified Indexing & Hybrid Retrieval (ChromaDB + BM25 + EnsembleRetriever)

Matches the educational, notebook-aligned implementation from `week2-rag/1_rag_pipeline.ipynb` and `week2-rag/3_hybrid_rag.ipynb`.

### A. Run ChromaDB Vector Store Self-Test (CLI & Artifact Generation)
Ingests sample chunks into ChromaDB (`text-embedding-3-small`, 512 dimensions) and exports `server/.artifact/idx_02_vector_store_sample.md`:
```bash
python app/indexing/vector_index.py --mock
```

### B. Run ChromaDB Vector Store Unit Tests (Pure In-Memory Assertions)
100% in-memory assertions using `chromadb.EphemeralClient()` and `FakeEmbeddings(size=512)`:
```bash
python tests/indexing/test_vector_index.py
```

### C. Run BM25 Sparse Keyword Index Self-Test (CLI & Artifact Generation)
Ingests sample chunks into LangChain's `BM25Retriever`, persists corpus to `server/data/bm25/documents.json`, and exports `server/.artifact/idx_03_bm25_sample.md`:
```bash
python app/indexing/bm25_index.py
```

### D. Run BM25 Keyword Index Unit Tests (Pure In-Memory Assertions)
Pure in-memory and isolated temporary storage assertions:
```bash
python tests/indexing/test_bm25_index.py
```

### E. Run Hybrid Retrieval Engine Self-Test (CLI & Artifact Generation)
Fuses semantic vector search and sparse BM25 keyword search using `langchain_classic.retrievers.EnsembleRetriever` with weighted Reciprocal Rank Fusion (RRF), and exports `server/.artifact/idx_04_hybrid_retrieval_sample.md`:
```bash
python app/retrieval/hybrid_engine.py "What was the Free Cash Flow and why did it decline?" --ticker TSLA --k 5 --mock
```

### F. Run Hybrid Retrieval Unit Tests (Pure In-Memory Assertions)
100% in-memory test coverage for `create_ensemble_retriever`, `search`, and `show_hybrid`:
```bash
python tests/retrieval/test_retrieval.py
```

---

## 🎯 9. TypeSafe Query Intent Classifier (Jev Decision Model)

Matches the educational decision model implementation from `week2-rag/2_metadata_filtering.ipynb` (lines 562–612).
Uses TypeSafe's Jev model to classify queries into `query_type` (`sql_kpi`, `hybrid_rag`, `comparison`), `financial_domain`, and `ticker`, and generates metadata filters for downstream retrieval.

### A. Run Jev Query Classifier CLI (Live API & Artifact Generation)
Evaluates financial questions using live TypeSafe Jev calibrated decision model and saves inspection artifact `server/.artifact/idx_05_classifier_sample.md`:
```bash
# Evaluate standard financial test battery
python app/retrieval/classifier/jev_classifier.py

# Evaluate custom query
python app/retrieval/classifier/jev_classifier.py "Why did automotive gross margin decline sequentially in Q2 2026?"
```

### B. Run Jev Query Classifier CLI in Mock / Offline Mode
Runs deterministic rule-based classifier without network connectivity:
```bash
python app/retrieval/classifier/jev_classifier.py --mock
```

### C. Run Jev Classifier Unit Tests (Pure In-Memory Assertions)
100% in-memory assertions covering Pydantic models, metadata filtering, Chroma `$and` syntax, offline classification, Choice criteria schemas, and None mapping:
```bash
python tests/retrieval/test_classifier.py
```

---

## 🛠️ 10. Financial Retrieval Tools & Router (`app/retrieval` & `app/generation`)

Organized into clean three-stage architecture (**Ingestion ──▶ Retrieval ──▶ Generation**):
- **Ingestion Indexing** (`app/ingestion/indexing/`): `vector_index.py`, `bm25_index.py` (ChromaDB + BM25)
- **Retrieval Tools** (`app/retrieval/tools/`): `sql_tool.py`, `rag_tool.py`, `comparison_tool.py`
- **Retrieval Router** (`app/retrieval/retrieval.py`): Jev-calibrated fast intent router
- **Generation Module** (`app/generation/generation.py`): Modular response synthesizers (`synthesize_sql_kpi`, `synthesize_hybrid_rag`, `synthesize_comparison`)

### A. Run Retrieval Tools Self-Test (CLI & Artifact Generation)
Executes tool suite verification across SQLite KPIs, Hybrid RAG over filings, and peer comparison, and saves inspection artifact `server/.artifact/agent_01_tools_sample.md`:
```bash
python app/retrieval/tools/__init__.py
```

### B. Run Retrieval Tools Unit Tests (Pure In-Memory Assertions)
100% in-memory assertions covering exact KPI queries, unknown tickers, hybrid filing citations `[Page - X, Section - Y]`, peer comparison tables, and submodule imports:
```bash
python tests/retrieval/test_tools.py
```

### C. Run Financial Response Generation Unit Tests
Validates deterministic formatting and markdown synthesis in `generation.py`:
```bash
python tests/generation/test_generation.py
```

### D. Run Financial Retrieval Router CLI (Intent Routing & Synthesis)
Runs the full intent router across live questions, calls the specialized retrieval tools, synthesizes audit-grade answers with citations via `app.generation`, and saves `server/.artifact/agent_02_analyst_query_sample.md`:
```bash
# Evaluate battery of standard test queries (SQL KPI, Hybrid RAG, Peer Comparison)
python app/retrieval/retrieval.py

# Evaluate custom query
python app/retrieval/retrieval.py "What was Tesla Q2 2026 revenue and free cash flow?"

# Run in offline / mock mode
python app/retrieval/retrieval.py --mock
```

### E. Run Financial Retrieval Router Unit Tests (Pure In-Memory Assertions)
100% in-memory unit tests validating SQL routing, Hybrid RAG routing, Peer comparison tables, and citation formatting:
```bash
python tests/retrieval/test_retrieval_router.py
```

---

## 🏆 11. All-in-One Master Test Runner

Run all **24 test suites** across the entire codebase in a single command:

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
python tests/ingestion/extractor/test_kpi_extractor.py && \
python tests/ingestion/test_pipeline.py && \
python tests/api/test_health.py && \
python tests/api/test_kpis_api.py && \
python tests/api/test_documents_api.py && \
python tests/api/test_analyst_api.py && \
python tests/indexing/test_vector_index.py && \
python tests/indexing/test_bm25_index.py && \
python tests/retrieval/test_retrieval.py && \
python tests/retrieval/test_classifier.py && \
python tests/retrieval/test_tools.py && \
python tests/retrieval/test_retrieval_router.py && \
python tests/generation/test_generation.py && \
python tests/test_artifact_saver.py
```

---

## 📱 12. Flutter Client Execution & Tests

### A. Run Feature Package Tests (`ai_analyst_feature`)
```bash
cd client/packages/ai_analyst_feature
flutter test
```

### B. Run Main App Smoke & Navigation Tests (`gen_stock_folio`)
```bash
cd client/apps/gen_stock_folio
flutter test
```

---

## 📂 Summary of Artifacts Created During CLI Runs

When running scripts directly via CLI (`python app/...`), human-readable Markdown artifacts are saved in `server/.artifact/` (git-ignored):

| Artifact Prefix | Generator CLI Script | Description |
| :--- | :--- | :--- |
| `01_extracted_<doc>` | `app/ingestion/parsers/pdf_extractor.py` or `pipeline.py` | Page-by-page text, character counts, and blank page detection |
| `02_classified_<doc>` | `app/ingestion/parsers/section_classifier.py` or `pipeline.py` | Financial domain tagging (`profitability`, `balance_sheet`, `cash_flow`) |
| `03a_recursive_splits_<doc>` | `app/ingestion/chunkers/recursive_chunker.py` or `pipeline.py` | Raw character-bounded splits (1000 chars, 100 overlap) page-by-page |
| `03b_enriched_chunks_<doc>` | `app/ingestion/chunkers/metadata_enricher.py` or `pipeline.py` | 1000-char chunks enriched with ticker, quarter, year, page, and domain |
| `04a_sample_extraction_prompt` | `app/ingestion/extractor/llm_extraction_prompts.py` | Grounded extraction prompt composed from dummy financial statement pages |
| `04_extracted_kpis_<doc>` | `app/ingestion/extractor/kpi_extractor.py` or `pipeline.py` | Structured Pydantic GAAP KPIs extracted via OpenAI `gpt-4o-mini` |
| `05_persisted_kpis_<doc>` | `app/ingestion/extractor/kpi_extractor.py` or `pipeline.py` | SQLite persisted record verification and round-trip SQL query |
| `06_pipeline_ingest_<doc>` | `app/ingestion/pipeline.py` | End-to-end ingestion execution summary, timing, and persisted KPIs |
| `idx_02_vector_store_sample` | `app/ingestion/indexing/vector_index.py` | ChromaDB collection summary, chunk counts, and sample filtered searches |
| `idx_03_bm25_sample` | `app/ingestion/indexing/bm25_index.py` | BM25 corpus summary, chunk counts, and sample keyword searches |
| `idx_04_hybrid_retrieval_sample` | `app/retrieval/hybrid_engine.py` | Ranked fused search results via `EnsembleRetriever` with text snippets |
| `idx_05_classifier_sample` | `app/retrieval/classifier/jev_classifier.py` | Jev calibrated intent classification, domain routing, and metadata filters |
| `agent_01_tools_sample` | `app/retrieval/tools/__init__.py` | Financial analyst tool invocation verification, SQL metrics, and RAG citations |
| `agent_02_analyst_query_sample` | `app/retrieval/retrieval.py` | Financial analyst intent routing, synthesized answers, and audit citation chips |
| `db_01_database_init` | `app/db/session.py` or `models.py` | SQLite schema tables & foreign key verification |
| `db_02_database_models` | `app/db/models.py` | 18+ GAAP metric column definitions & cascade tests |
| `db_03_kpi_repo_queries` | `app/db/repositories/kpi_repo.py` | Time series, peer comparison, and 0.1ms deduplication queries |

> **Note**: Unit tests (`tests/...`) **never** generate artifacts and run strictly in-memory.




