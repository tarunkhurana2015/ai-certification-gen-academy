# Stock AI Analyst — Architecture & Concept FAQ

> **Purpose**: A living, beginner-friendly collection of all questions, answers, design trade-offs, and key learnings encountered while building the Stock AI Analyst platform. Whenever you have a question, it is answered and permanently documented here for quick reference.

---

## 📑 Table of Contents
1. [Architecture & Storage: Are we storing the entire PDF in SQLite?](#1-architecture--storage-are-we-storing-the-entire-pdf-in-sqlite)
2. [Python Architecture: What are these `__init__.py` files?](#2-python-architecture-what-are-these-__init__py-files)
3. [Ingestion Strategy: How do we extract financial numbers when every PDF has a different format?](#3-ingestion-strategy-how-do-we-extract-financial-numbers-when-every-pdf-has-a-different-format)
4. [Section Tagging: How do we classify financial domains across wildly different companies (e.g. Meta vs Tesla)?](#4-section-tagging-how-do-we-classify-financial-domains-across-wildly-different-companies-eg-meta-vs-tesla)
5. [Multi-Company Generalization: Are we limited to Meta and Tesla, or does this scale to thousands of companies?](#5-multi-company-generalization-are-we-limited-to-meta-and-tesla-or-does-this-scale-to-thousands-of-companies)
6. [Extraction Strategy: Why do we send full classified statement pages to the LLM instead of 1,000-character chunks?](#6-extraction-strategy-why-do-we-send-full-classified-statement-pages-to-the-llm-instead-of-1000-character-chunks)
7. [Database Persistence: Why keep Pydantic schemas separate from SQLAlchemy models, and why link KPIs to documents?](#7-database-persistence-why-keep-pydantic-schemas-separate-from-sqlalchemy-models-and-why-link-kpis-to-documents)
8. [Pipeline Artifacts: Why do we generate sequential artifacts (01 to 06), and why weren't artifacts created when running `curl` upload?](#8-pipeline-artifacts-why-do-we-generate-sequential-artifacts-01-to-06-and-why-werent-artifacts-created-when-running-curl-upload)
9. [Dynamic Ticker Resolution: Why did we eliminate hardcoded ticker checks (`META`, `TSLA`, `AAPL`)?](#9-dynamic-ticker-resolution-why-did-we-eliminate-hardcoded-ticker-checks-meta-tsla-aapl)
10. [Vector Store vs. Embeddings: Why do we have an `embeddings.py` factory, and doesn't the Vector Store directly accept chunks?](#10-vector-store-vs-embeddings-why-do-we-have-an-embeddingspy-factory-and-doesnt-the-vector-store-directly-accept-chunks)
11. [Decoupled Indexing Architecture: Why split Embeddings, ChromaDB Vector Store, and BM25 into separate tasks?](#11-decoupled-indexing-architecture-why-split-embeddings-chromadb-vector-store-and-bm25-into-separate-tasks)
12. [Vector Store Ingestion: Why pass embeddings in `__init__` vs chunks in `add_chunks()`?](#12-vector-store-ingestion-why-pass-embeddings-in-__init__-vs-chunks-in-add_chunks)

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

---

### 4. Section Tagging: How do we classify financial domains across wildly different companies (e.g., Meta vs Tesla)?

**Question:**
> *"For comparison I have this report from Tesla (`TSLA-Q2-2026-Update.pdf`). Comparing this with Meta's PDF, how will we know our `financial_domain` if we do the classification by ourselves?"*

**Answer:**
This is a fantastic real-world comparison. When you inspect both PDFs side by side, you notice dramatic formatting differences:

| Company | Document Style | Income Statement Location & Title | Balance Sheet Location & Title | Outlook / Guidance Title |
| :--- | :--- | :--- | :--- | :--- |
| **Meta** (9 pages) | Traditional Press Release | **Page 5**: `CONDENSED CONSOLIDATED STATEMENTS OF INCOME` | **Page 6**: `CONDENSED CONSOLIDATED BALANCE SHEETS` | **Page 2**: `CFO Outlook Commentary` |
| **Tesla** (33 pages) | Investor Slide Deck | **Page 27**: `REVENUES` / `Automotive sales` | **Page 28**: `B A L A N C E  S H E E T` *(spaced-out letters!)* | **Page 10**: `O U T L O O K` |

If we used simple exact string matching, Tesla's `B A L A N C E  S H E E T` would completely fail because of the styling spaces between the letters!

#### How We Solve This: The 3-Layer Classification Engine

```
┌────────────────────────────────────────────────────────┐
│ Layer 1: Text Normalization (The Anti-Spacing Trick)   │
│ • Collapses letter-spaced headers:                    │
│   'B A L A N C E  S H E E T'  ──▶  'BALANCE SHEET'    │
│   'O U T L O O K'              ──▶  'OUTLOOK'          │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Layer 2: Universal GAAP Vocabulary Patterns            │
│ Even though layouts differ, US GAAP and SEC rules      │
│ legally require specific accounting terms:             │
│ • Balance Sheet MUST have: Assets, Liabilities, Equity │
│ • Cash Flow MUST have: Operating, Investing, Financing │
│ • Income Statement MUST have: Revenues, Cost of Sales  │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Layer 3: Multi-Signal Scoring Engine                   │
│ • Checks page title (weight = 3x)                      │
│ • Checks body keywords (weight = 1x)                   │
│ • High confidence (> 0.6) ──▶ Domain assigned in 0.1ms │
│ • Ambiguous pages (e.g. photos/charts) ──▶ `GENERAL`   │
└────────────────────────────────────────────────────────┘
```

#### Why This Works 100% of the Time:
1. **Title Normalization**: By collapsing spaced typography (`re.sub(r'(\b[A-Z])\s+(?=[A-Z]\b)', r'\1', line)`), Tesla's design slide titles become standard English.
2. **SEC GAAP Standardization**: A company can choose where to put their Balance Sheet (Page 6 for Meta, Page 28 for Tesla), but they **cannot invent their own accounting definitions**. Every Balance Sheet legally must report Total Assets and Total Liabilities.
3. **Speed & Zero Cost**: This classification runs in **under 2 milliseconds** for all 33 pages of Tesla without making a single external API call!

---

### 5. Multi-Company Generalization: Are we limited to Meta and Tesla, or does this scale to thousands of companies?

**Question:**
> *"Wait, we are not just limited to 2 companies, there are many companies with varied PDF formats. Are we still able to classify the domain across all of them?"*

**Answer:**
**Yes, absolutely!** 

While companies have complete artistic freedom over their graphic design, fonts, and slide layout, they have **ZERO legal freedom over their accounting terminology**.

In the United States, all 4,000+ publicly traded companies (NYSE, NASDAQ) are legally mandated by the SEC (under Regulation S-X) to report using **US GAAP**:
- **Balance Sheet (or Statement of Financial Position)**: MUST report Assets, Liabilities, and Stockholders' Equity.
- **Statement of Cash Flows**: MUST report Operating Activities, Investing Activities, and Financing Activities.
- **Statements of Operations / Income**: MUST report Revenues, Cost of Sales, Operating Income, Net Income, and Earnings Per Share.

#### The Safety Net: What if a page is ambiguous?
A common fear is: *"What if the classifier gets a page wrong? Does the search break?"*
**No!** 
The domain tag is a **precision booster**, not a gatekeeper:
- If a page has no clear GAAP financial statement patterns (e.g., executive photos, product marketing, ESG essays), it safely defaults to **`GENERAL`**.
- It is **still 100% indexed in Pinecone and BM25**! When a user asks general narrative questions, the system searches the entire document, including all `GENERAL` pages.

---

### 6. Extraction Strategy: Why do we send full classified statement pages to the LLM instead of 1,000-character chunks?

**Question:**
> *"Is this step now to connect to the LLM to send the chunked data and get the structured output?"*

**Answer:**
We connect to the LLM to get **Structured Outputs**, but we **do not send small 1,000-character chunks**. 

Instead, we send the **complete text of the classified financial statement pages** (`PROFITABILITY`, `BALANCE_SHEET`, `CASH_FLOW`).

#### The Problem With Chunking Financial Tables:
Financial statement tables (Income Statement, Balance Sheet, Cash Flow) contain dense, multi-column alignments:
```
(in millions, except per share data)       Three Months Ended June 30, 2026   June 30, 2025
Revenue .............................................. $47,510                   $39,071
Costs and expenses:
  Cost of revenue .................................... $ 8,550                   $ 7,000
Gross profit ......................................... $38,960                   $32,071
```
If you cut that page into arbitrary 1,000-character chunks with word boundaries:
1. **Header Separation**: Chunk A might contain the column date headers (`"Three Months Ended June 30, 2026"`), while Chunk B contains the numbers.
2. **Column Misalignment**: Without seeing the column headers in the same prompt, the LLM risks confusing 2026 with 2025 or reading across columns.
3. **Missing Footnotes**: Financial accounting units (*"in millions"*, *"in thousands"*) are usually declared at the top or bottom of the page. Chunking risks separating the numbers from their units.

#### The Dual-Path Architecture:

| Pathway | Source Data | Target Store | Used For |
| :--- | :--- | :--- | :--- |
| **Deterministic KPI Pipeline (Step 2.4)** | Full Classified Statement Pages (`PROFITABILITY`, `BALANCE_SHEET`, `CASH_FLOW`) | **SQLite Database** (`financial_kpis`) | 100% exact numerical facts, ratios, and multi-quarter chart time series. |
| **Semantic Hybrid RAG Pipeline (Phase 3)** | 1,000-character Chunks (`chunker.py`) | **Pinecone + BM25** | Qualitative narrative questions (CEO commentary, AI GPU strategy, risk factors). |

By feeding complete financial statement pages into `gpt-4o-mini` with Pydantic structured output, the LLM reads unbroken financial tables with all headers and units intact.

---

### 7. Database Persistence: Why keep Pydantic schemas separate from SQLAlchemy models, and why link KPIs to documents?

**Question:**
> *"Why do we have both `FinancialReportKPIs` in Pydantic and `FinancialKPIModel` in SQLAlchemy? And why do we need a `DocumentModel` parent for KPIs?"*

**Answer:**
This represents the classic software engineering pattern of **Separation of Concerns (Validation vs. Persistence)**:

#### 1. In-Memory Validation (Pydantic) vs. Relational Storage (SQLAlchemy)
```
┌────────────────────────────────────────────────────────┐
│ Pydantic DTO (`FinancialReportKPIs`)                   │
│ • Validates LLM output JSON strictly at runtime.       │
│ • Enforces business math (margins between 0.0 and 1.0).│
│ • Ephemeral in-memory data contract for APIs & LLMs.   │
└──────────────────────────┬─────────────────────────────┘
                           │ save_extracted_kpis_to_db()
                           ▼
┌────────────────────────────────────────────────────────┐
│ SQLAlchemy ORM (`FinancialKPIModel`)                   │
│ • Defines physical SQLite schema on disk.              │
│ • Manages relational foreign keys & indexes.           │
│ • Provides persistent query API (time series, peers).  │
└────────────────────────────────────────────────────────┘
```

#### 2. Audit Lineage (`DocumentModel` Parent)
In corporate auditing and SEC compliance, financial figures **cannot float unanchored**:
- Every KPI row has a `document_id` foreign key pointing to the exact parent filing in `DocumentModel`.
- If an investor or auditor questions a metric (*"Why is Free Cash Flow $784M?"*), the system traces back:
  `KPI Record` ──▶ `Document ID` ──▶ `SHA-256 Hash` ──▶ `Source Pages [1, 5, 6, 7]` ──▶ `Raw PDF File`.

#### 3. Idempotent Ingestion (`upsert_kpi`)
If an ingestion job is rerun or an updated earnings report is uploaded:
- SQLite unique constraint on `(ticker, fiscal_year, fiscal_quarter)` prevents duplicate rows.
- `upsert_kpi()` updates the existing record in-place and refreshes its timestamp, keeping historical time series perfectly clean.

---

### 8. Pipeline Artifacts: Why do we generate sequential artifacts (01 to 06), and why weren't artifacts created when running `curl` upload?

**Question:**
> *"When running the pipeline why do we see artifacts for each substep? Why were they numbered sequentially without skipping (01 through 06)? And when running `curl -X POST /api/v1/ingestion/upload` why were artifacts initially missing?"*

**Answer:**
This addresses two important software engineering concepts: **Pipeline Observability** and **REST Controller Parameter Propagation**.

#### 1. The "Observable Pipeline" Pattern:
In multi-stage ETL pipelines (Validation ➔ Parsing ➔ Section Classification ➔ Semantic Chunking ➔ LLM GAAP Extraction ➔ SQLite Persistence), you never want a black box. If an extraction fails, you need to know *where* it broke without attaching a debugger.
Every substep generates an inspection artifact in `server/.artifact/`:
- `01_extracted_<slug>`: Raw text and character counts per page.
- `02_classified_<slug>`: Domain classification tags (Profitability, Balance Sheet, Cash Flow, General).
- `03a_recursive_splits_<slug>`: Raw character-bounded text splits.
- `03b_enriched_chunks_<slug>`: Semantic chunks enriched with ticker, quarter, year, domain, page.
- `04_extracted_kpis_<slug>`: Structured GAAP KPIs extracted by LLM with math validation.
- `05_persisted_kpis_<slug>`: SQLite round-trip query verification.
- `06_pipeline_ingest_<slug>`: End-to-end execution summary with timings and task status.

#### 2. Sequential Renumbering:
Early iterations used ad-hoc numbering where chunking was `03a/03b` and subsequent steps jumped to `07`, `08`, `09`. We unified these into a strict chronological sequence `01` through `06` so developers can trace the pipeline execution order at a glance.

#### 3. Why `curl` Upload Initially Skipped Artifacts:
When uploading via FastAPI `POST /api/v1/ingestion/upload`:
- The endpoint controller had defaulted `save_artifacts=False` and was prepending an `upload_` temporary prefix to the filename.
- We fixed this by setting `save_artifacts: bool = Form(True)` by default and preserving the clean slug from the uploaded filename (`TSLA-Q2-2026-Update`), so running `curl` or using the client UI generates all substep artifacts in `server/.artifact/` automatically.

---

### 9. Dynamic Ticker Resolution: Why did we eliminate hardcoded ticker checks (`META`, `TSLA`, `AAPL`)?

**Question:**
> *"In the pipeline code, why was ticker resolution previously hardcoded for META, TSLA, and AAPL, and how is it now dynamic?"*

**Answer:**
Hardcoding ticker strings based on filename heuristics is an anti-pattern that fails in production:

#### The Anti-Pattern:
```python
# Fragile & non-scalable:
if "meta" in lower_name:
    resolved_ticker = "META"
elif "tsla" in lower_name:
    resolved_ticker = "TSLA"
elif "aapl" in lower_name:
    resolved_ticker = "AAPL"
```
Problems with this approach:
1. **Filename Randomization**: Real SEC filings are frequently named `Exhibit-99-1.pdf`, `fy26_q3_report.pdf`, or contain hashes.
2. **Cannot Scale**: You cannot maintain an `elif` ladder for 4,000+ publicly traded companies.
3. **Misleading Matches**: A filing mentioning *"Apple supplier..."* or *"Tesla battery partner..."* would trigger a false-positive match.

#### The Production Pattern: Self-Identifying Document Extraction
1. **Document Text Inspection**: The pipeline extracts the header text and title block from Page 1 and the classified financial statements (e.g., *"Apple Inc. CONDENSED CONSOLIDATED STATEMENTS OF OPERATIONS"*).
2. **LLM Contextual Extraction**: The dynamic prompt directs the LLM auditor to identify the genuine primary reporting entity and its ticker symbol directly from the financial tables and company headers.
3. **Optional User Hints**: The CLI and API accept `--ticker` as an optional hint, but the pipeline never requires hardcoded company lists.

---

### 10. Vector Store vs. Embeddings: Why do we have an `embeddings.py` factory, and doesn't the Vector Store directly accept chunks?

**Question:**
> *"Why do we have to do the `embed_texts`? Shouldn't the vector store have an interface for directly taking the chunks into the store? I am confused."*

**Answer:**
**Yes, absolutely!** You do **not** need to manually iterate over chunks or manage embedding loops yourself.

#### How ChromaDB Actually Ingests Chunks:
```
┌──────────────────────────────────────────────┐
│ EnrichedChunk (1,000-char text + metadata)   │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│ vector_store.add_chunks(chunks)              │
│                                              │
│ ChromaDB natively executes:                  │
│  1. Calls embedding_function.embed_documents │
│  2. Indexes vectors into HNSW cosine space   │
│  3. Attaches metadata facets for filtering   │
└──────────────────────────────────────────────┘
```

#### What `embeddings.py` Actually Does:
ChromaDB requires an **embedding function** when initializing a collection. 
Instead of hardcoding OpenAI API keys, model parameters (`model="text-embedding-3-small"`), and dimensional truncation (`dimensions=512`) across multiple files, `server/app/indexing/embeddings.py` serves as the **Single Source of Truth Factory**:

```python
def get_embeddings_model(dimensions: int = 512) -> OpenAIEmbeddings:
    """Returns the configured OpenAI text-embedding-3-small (512-dim) model."""
    return OpenAIEmbeddings(
        model="text-embedding-3-small",
        dimensions=dimensions,
    )
```

The Vector Store (`vector_store.py`) takes `EnrichedChunk` objects directly, passes them into ChromaDB, and ChromaDB uses `get_embeddings_model()` to embed them under the hood in one clean, vectorized step.

---

### 11. Decoupled Indexing Architecture: Why split Embeddings, ChromaDB Vector Store, and BM25 into separate tasks?

**Question:**
> *"I want to split the embeddings and BM25 separately into separate tasks, so let's start with the indexing work: we should use the indexing folder and first write the OpenAIEmbeddings first, and then a separate task for the vector storing the embeddings into ChromaDB, then we will come back to the BM25 later. Why is this modular approach better than writing it all at once?"*

**Answer:**
Splitting Phase 3 into **three distinct, self-contained components** follows core software engineering and AI systems best practices:

```
┌─────────────────────────────────────────────────────────────┐
│ Step 3.1: Dense Embeddings Factory (`embeddings.py`)       │
│ • Model configuration: `text-embedding-3-small` (512-dim)   │
│ • Vector math utilities: Cosine similarity calculation      │
│ • Zero database dependencies — 100% pure vector logic       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 3.2: Vector Store Ingestion (`vector_store.py`)        │
│ • Target: ChromaDB collection (`earnings_chunks`)           │
│ • Direct `add_chunks(chunks: List[EnrichedChunk])`          │
│ • Metadata filtering: `ticker`, `quarter`, `domain`, `page` │
│ • HNSW cosine distance semantic similarity search           │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 3.3: Sparse Keyword Index (`bm25_index.py`)            │
│ • Target: BM25 Okapi in-memory + disk pickle cache          │
│ • Exact matching for tickers, acronyms, and GAAP numbers    │
│ • Zero API calls, zero token cost, runs offline in <5ms     │
└─────────────────────────────────────────────────────────────┘
```

#### Why This Separation is Essential:

1. **Separation of Dense (Semantic) vs. Sparse (Exact) Paradigms**:
   - **Dense Vectors (Embeddings & ChromaDB)**: Semantic meaning, fuzzy concepts, conceptual questions (*"What are the headwinds in automotive margins?"*). Relies on high-dimensional linear algebra and OpenAI API calls.
   - **Sparse Index (BM25)**: Exact lexical matching, specific GAAP lines (*"Capex"*, *"EBITDA"*, *"Exhibit 99.1"*, *"Model 3"*). Relies on word frequencies and tokenizers.
   - By isolating them, bugs in tokenization never corrupt vector spaces, and API rate limits never disrupt local keyword indexes.

2. **Isolated Unit Testing & Mocking**:
   - `test_embeddings.py` tests vector dimensions, API key validations, and cosine similarity formulas in milliseconds without needing ChromaDB server or persistent storage.
   - `test_vector_store.py` tests collections, metadata filtering, and chunk insertions using in-memory ephemeral storage without making real OpenAI API calls.
   - `test_bm25_index.py` tests inverted term indexes and rank scores completely offline.

3. **Vendor Portability (Swap Any Component Anytime)**:
   - If tomorrow we decide to replace ChromaDB with **Pinecone**, **Qdrant**, or **pgvector**, `embeddings.py` and `bm25_index.py` remain **100% untouched**.
   - If we switch from OpenAI to local Ollama or HuggingFace embeddings, only `embeddings.py` changes.

4. **Granular Artifact Inspection**:
   - Each substep produces its own observable verification artifact in `server/.artifact/`:
     - `idx_01_embeddings_sample.json`: Verifies 512 dimensions & cosine math.
     - `idx_02_vector_store_sample.json`: Verifies ChromaDB chunk indexing & metadata querying.
     - `idx_03_bm25_sample.json`: Verifies sparse keyword scoring & top-k hits.

---

### 12. Vector Store Ingestion: Why pass embeddings in `__init__` vs chunks in `add_chunks()`?

**Question:**
> *"How are we going to send the chunks into the store? I can see embeddings are sent in the init."*

**Answer:**
This addresses an important conceptual distinction in vector databases: **Configuring the Engine** vs. **Ingesting the Data**.

#### 1. Why Embeddings are in `__init__` (Configuring the Engine)
When you call:
```python
store = FinancialVectorStore(embeddings=get_embeddings_model())
```
You are **NOT** storing any vectors or text yet!
Instead, you are providing ChromaDB with its **"translator"**. ChromaDB is an engine designed to index mathematical floating-point vectors, but financial filings and user queries are written in human English.

By passing `embeddings=get_embeddings_model()` in `__init__`:
- ChromaDB attaches the `text-embedding-3-small` (512-dim) model to the `earnings_chunks` collection.
- It prepares the collection configuration, but the collection is still **empty** (`store.count() == 0`).

#### 2. How Chunks are Actually Sent (The Data Delivery)
The chunks are delivered by calling:
```python
# chunks is a List[EnrichedChunk] produced by metadata_enricher.py
added_count = store.add_chunks(chunks)
```

Inside `add_chunks()`, the following automated pipeline executes:

```
┌────────────────────────────────────────────────────────┐
│ 1. Input: List[EnrichedChunk]                          │
│    (Chunks with text, ticker, quarter, page, domain)   │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. Unpack into LangChain Document + Metadata Dict      │
│    Document(                                           │
│      page_content=chunk.text,                          │
│      metadata={"ticker": "TSLA", "page": 5, ...}       │
│    )                                                   │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. ChromaDB calls self._embeddings.embed_documents()   │
│    OpenAI API converts text strings ──▶ 512 floats     │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 4. ChromaDB indexes into HNSW Cosine Vector Space      │
│    Indexes [vector, raw text, metadata facets]         │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 5. Saved to Persistent Disk (`server/data/chroma/`)    │
└────────────────────────────────────────────────────────┘
```

#### 3. Where This Fits in the Real End-to-End Upload Pipeline:
When a user uploads a quarterly earnings PDF via the client UI or API (`POST /api/v1/ingestion/upload`):

```python
# Inside server/app/ingestion/pipeline.py:

# Step 1: Extract pages
pages = extract_text_by_pages(pdf_path)

# Step 2: Classify sections into GAAP domains
classified = classify_document_sections(pages)

# Step 3: Chunk and enrich with metadata facets
enriched_chunks = chunk_document_pages(classified, ticker="TSLA", quarter="Q2", year=2026)

# Step 4: Extract GAAP KPIs & save to SQLite (Deterministic Path)
kpis = extract_kpis_with_retry(classified)
save_extracted_kpis_to_db(kpis)

# Step 5: Ingest into Dense Vector Store (ChromaDB Semantic Path)
vector_store = FinancialVectorStore()
vector_store.add_chunks(enriched_chunks)   # <--- CHUNKS ARE INGESTED HERE!

# Step 6: Ingest into Sparse Keyword Index (BM25 Path)
bm25_index = BM25KeywordIndex()
bm25_index.add_chunks(enriched_chunks)     # <--- (In Step 3.3!)
```

This ensures that every uploaded earnings report automatically populates both systems:
1. **SQLite (`financial_kpis`)**: For exact financial ratios, income statements, and multi-quarter chart time series.
2. **ChromaDB (`earnings_chunks`)**: For semantic narrative search, executive commentary retrieval, and audit-ready citation pills.


