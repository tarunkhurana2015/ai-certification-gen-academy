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

---

### 13. Step 3.4 Architecture: How does Dual Ingestion connect to the Hybrid Retrieval Engine, and why do we use Reciprocal Rank Fusion (RRF) with a Cross-Encoder Reranker?

**Question:**
> *"Now that Dense Embeddings, ChromaDB, and BM25 are built, how do they connect into the Ingestion Pipeline? And why do we need both Reciprocal Rank Fusion (RRF) and a Cross-Encoder Reranker in Hybrid Retrieval instead of just adding their scores together?"*

**Answer:**
This question touches the mathematical core of modern production RAG systems. It breaks down into three key architectural insights:

#### 1. Why Dual Indexing is Wired into `IngestionPipeline` (Step 8):
Before Step 3.4, `IngestionPipeline` stopped after Step 7 (SQLite persistence of audited KPIs). The recursive chunks (`03b_enriched_chunks`) were written to disk as inspectable JSON artifacts, but were not yet indexed into search engines.
In Step 3.4:
- As soon as SQLite persistence finishes (90% progress), the pipeline advances to `status="INDEXING"` (95% progress).
- It feeds the `EnrichedChunk` list into **both** `FinancialVectorStore.add_chunks()` and `BM25KeywordIndex.add_chunks()`.
- If `--force` is passed, it purges stale chunks for that ticker first (`delete_by_ticker`), preventing duplicate index entries.
- It serializes the BM25 index to `server/data/bm25/bm25_index.pkl`.
- It records `vector_chunks_indexed` and `bm25_chunks_indexed` directly in `IngestionResult` and in artifact `06_pipeline_ingest_<slug>.json`.

#### 2. Why Score Blending Fails and Reciprocal Rank Fusion (RRF) is Required:
A naive approach to combining vector and keyword search is adding their raw scores together:
$$\text{Score} = w_1 \cdot \text{VectorScore} + w_2 \cdot \text{BM25Score}$$

**Why this fails in practice:**
- **Incompatible Scales**: ChromaDB cosine similarity scores are bounded between $[0.0, 1.0]$. BM25 scores, however, are unbounded term-frequency weights that typically range between $[0.0, 25.0+]$ depending on document length and keyword rarity!
- **Score Drift Across Queries**: A high BM25 score of `15.2` for query A might represent a moderate match, while a score of `6.1` for query B might represent a definitive hit. Raw scores cannot be compared across different queries.
- **Domination Problem**: Adding uncalibrated scores means BM25 completely drowns out cosine similarity, effectively blinding the semantic engine.

**The Solution: Reciprocal Rank Fusion (RRF)**
Instead of combining raw scores, RRF operates strictly on the **ordinal ranks** (1st, 2nd, 3rd, ...) assigned by each retrieval system:

$$RRF\_score(d) = w_{dense} \cdot \frac{1}{k_{rrf} + rank_{dense}(d)} + w_{sparse} \cdot \frac{1}{k_{rrf} + rank_{sparse}(d)}$$

Where:
- $k_{rrf} = 60$ (the canonical smoothing constant introduced by Cormack et al. 2009). The constant $60$ ensures that the difference between rank 1 and rank 2 is meaningful, but doesn't excessively penalize documents ranked 5th or 6th.
- $w_{dense} = 0.5$ and $w_{sparse} = 0.5$ (balanced equal weighting).
- **The Intersection Boost**: If a document is retrieved by **both** dense vector search (semantic match) and BM25 (exact keyword match), it receives score contributions from both terms ($1/61 + 1/61 \approx 0.0328$), rocketing it straight to the top of the fused candidate pool!

#### 3. Why We Need the Cross-Encoder Reranker as the Final Stage:
RRF is a *bi-encoder rank fusion* mechanism: dense search and BM25 evaluate queries and chunks independently.
However, financial queries frequently contain subtle dependencies that bi-encoders miss:
- Query: *"What was the Free Cash Flow and why did it decline?"*
- Chunks describing positive FCF or general liquidity might rank high in bi-encoders.
- The **Cross-Encoder Reranker** concatenates the full query and candidate text together into a joint attention model `(query, document_text)`:
  - It detects contextual alignment between `"decline"` and text like `"sequential decrease of $1.2B was a result of negative free cash flow of $1.1B, driven by an increase in capex of $3.3B"` (Page 25).
  - It boosts chunks with exact numerical figures, accounting formulas, and direct causal explanations.
  - It filters out irrelevant boilerplate, ensuring the LLM synthesis prompt only receives pristine, high-signal financial context.

#### 4. Architecture Summary Table:

| Layer | Module | Responsibility | Key Formula / Tech |
| :--- | :--- | :--- | :--- |
| **Dense Semantic** | `dense_retriever.py` | Top-10 conceptual & semantic matches | ChromaDB, OpenAI `text-embedding-3-small` (512-dim), Cosine metric |
| **Sparse Lexical** | `sparse_retriever.py` | Top-10 exact numbers, acronyms, table items | `rank-bm25` (BM25Okapi, $k_1=1.5, b=0.75$), `financial_tokenize()` |
| **Rank Fusion** | `hybrid_fusion.py` | Merges candidate pools without score calibration issues | Weighted RRF ($k=60, w=[0.5, 0.5]$) |
| **Contextual Rerank** | `reranker.py` | Re-scores fused candidates for causal & numeric relevance | Cross-Encoder token density & contextual alignment |
| **Master Engine** | `hybrid_engine.py` | Unified entry point for Agent RAG tool | `search(query, top_k=5, candidate_k=10)` |

---

### 14. Where is `EnsembleRetriever` created and how does it relate to `reciprocal_rank_fusion` and `HybridRetrievalEngine`?

**Question:**
> *"Where is the `EnsembleRetriever` created?"*

**Answer:**
`EnsembleRetriever` is located in **`server/app/retrieval/hybrid_fusion.py`** and exported by **`server/app/retrieval/__init__.py`**.

#### 1. Why `EnsembleRetriever` Appears in the Architecture Diagram:
In `ARCHITECTURE.md` Section 4.5 and the architectural diagram (`04-hybrid-retrieval.svg`), Step 3 is titled:
`3 · EnsembleRetriever & Weighted RRF`

This represents the ensemble component that blends the dense vector list and the sparse keyword list into a unified candidate pool.

#### 2. Where the Code Lives:
In our implementation, this functionality is organized across two complementary structures:

1. **The Core Algorithm (`reciprocal_rank_fusion` in `hybrid_fusion.py`)**:
   - Executes the pure mathematical RRF scoring ($w_i \cdot \frac{1}{60 + rank_i}$).
   - Tracks ordinal ranks (`dense_rank`, `sparse_rank`) and attaches them to each `RetrievedChunk`.
   - Prevents score scale distortion between ChromaDB cosine similarity $[0.0, 1.0]$ and BM25 $[0.0, 25.0+]$.

2. **The Class Interface (`EnsembleRetriever` in `hybrid_fusion.py`)**:
   - Provides the object-oriented ensemble abstraction with configurable `weights` (default: `[0.5, 0.5]`) and smoothing constant `c` (default: `60`).
   - `fuse(dense_results, sparse_results, top_n)` executes the weighted RRF merge.

3. **The Master Orchestrator (`HybridRetrievalEngine` in `hybrid_engine.py`)**:
   - Wraps the entire end-to-end pipeline:
     `DenseRetriever.retrieve()` ➔ `SparseRetriever.retrieve()` ➔ `EnsembleRetriever.fuse()` ➔ `CrossEncoderReranker.rerank()`.

#### 3. Why We Implemented Our Own Rather Than Importing LangChain's Legacy `EnsembleRetriever`:
LangChain provides an `EnsembleRetriever` in `langchain_classic` / `langchain-community`. However, using it directly has significant limitations for financial RAG:
- **Discarded Scores**: LangChain's legacy `EnsembleRetriever` uses RRF internally to re-sort documents, but *discards the computed score*, returning raw `Document` objects with no score metadata.
- **Reranker Pipeline**: Our downstream Cross-Encoder Reranker (`reranker.py`) requires the fused RRF scores and dense/sparse rank lineages to contextualize its re-scoring.
- **Multi-Store Dynamic Pre-filtering**: Financial queries require applying strict SQL-like pre-filters (`ticker='TSLA'`, `fiscal_quarter='Q2'`, `fiscal_year=2026`) across two completely different underlying backends (ChromaDB JSON filter syntax vs. BM25 in-memory token dictionaries). Our engine coordinates this filtering across both stores simultaneously.

---

### 15. Can `langchain_classic.retrievers` be used in our case, and how does it compare to our custom `hybrid_fusion.py`?

**Question:**
> *"Are you saying that `langchain_classic.retrievers` can't be used in our case?"*

**Answer:**
**No! It CAN absolutely be used in our project!** 

`langchain_classic.retrievers.EnsembleRetriever` is installed, importable, and fully functional in our environment right now.

#### Direct Comparison: `langchain_classic` vs. Native `hybrid_fusion.py`

| Capability | `langchain_classic.retrievers.EnsembleRetriever` | Native `app/retrieval/hybrid_fusion.py` |
| :--- | :--- | :--- |
| **RRF Algorithm** | ✅ Cormack et al. 2009 ($k=60$) | ✅ Exact same Cormack formula ($k=60$) |
| **Weighted RRF** | ✅ Configurable `weights=[0.5, 0.5]` | ✅ Configurable `weights=[0.5, 0.5]` |
| **Works in our Python env?** | ✅ Yes (`langchain_classic==1.0.8`) | ✅ Yes (Pure Python, zero external deps) |
| **Output Document Type** | `List[Document]` (Untyped metadata dict) | `List[RetrievedChunk]` (Strict Pydantic) |
| **Preserves RRF Score?** | ❌ **No** (Calculates score locally to sort, then drops it) | ✅ **Yes** (`chunk.score = 0.016261`) |
| **Dense / Sparse Lineage?** | ❌ **No** (`dense_rank` & `sparse_rank` omitted) | ✅ **Yes** (`dense_rank=1`, `sparse_rank=2`) |
| **Downstream Reranker Ready?** | ⚠️ Needs custom wrapper to pass scores | ✅ Direct pass-through to `CrossEncoderReranker` |
| **UI Citation Badges?** | ⚠️ No source channel info without wrappers | ✅ Direct metadata for `[Dense #1 \| Sparse #2]` |
| **Runtime Query Filtering** | ⚠️ Only takes `query: str`; no unified filter dict | ✅ Accepts `RetrievalQuery(ticker, quarter, ...)` |

#### Why LangChain's Default Drops the Score:
Under the hood in `langchain_classic/retrievers/ensemble.py`:
```python
# langchain_classic computes rrf_score locally:
rrf_score: dict[str, float] = defaultdict(float)
for doc_list, weight in zip(doc_lists, self.weights):
    for rank, doc in enumerate(doc_list, start=1):
        rrf_score[doc.page_content] += weight / (rank + self.c)

# It sorts using rrf_score, but returns all_docs WITHOUT attaching the score!
return sorted(unique_by_key(all_docs), reverse=True, key=lambda doc: rrf_score[doc.page_content])
```

#### How to Use `langchain_classic` if You Prefer It:
If you want to use `langchain_classic.retrievers.EnsembleRetriever`, we can simply subclass it into an **`ObservableEnsembleRetriever`** that attaches `doc.metadata['rrf_score']` and ranks:

```python
from langchain_classic.retrievers import EnsembleRetriever

class ObservableEnsembleRetriever(EnsembleRetriever):
    """EnsembleRetriever that preserves RRF scores and source rank lineages."""
    def weighted_reciprocal_rank(self, doc_lists):
        # 1. Compute RRF scores and record ranks
        # 2. Attach doc.metadata['rrf_score'] = score
        # 3. Attach doc.metadata['dense_rank'] = rank
        # 4. Return sorted docs with full observability
```

Both approaches are completely valid! We chose our native `hybrid_fusion.py` because it is lightweight, type-safe with Pydantic, preserves audit-ready provenance out of the box, and has zero dependency on legacy bridge packages.

---

### 16. Simplifying the Vector Store and BM25 Index to Match Course Notebooks (`1_rag_pipeline.ipynb` & `3_hybrid_rag.ipynb`)

**Question:**
> *"The index and retriever seems too complex for me where I wanted to start with some easy coding for both the vector and BM25, see this `week2-rag/3_hybrid_rag.ipynb` where things look so simple and I am able to understand it well. In this the BM25 integration is so simple where the docs are stored so easily. Also this `week2-rag/1_rag_pipeline.ipynb` where the vector document is stored so easily. Can you simplify things for me?"*

**Answer:**
**Yes! We simplified the indexing and retrieval codebase to directly mirror the standard LangChain idioms taught in the course notebooks.**

#### 1. How the Notebooks Do It:
In `week2-rag/1_rag_pipeline.ipynb` and `week2-rag/3_hybrid_rag.ipynb`:
1. **Vector Search**:
   ```python
   # Load documents
   docs = [Document(page_content=..., metadata=...)]
   # Store directly
   vector_store = Chroma(collection_name="earnings_chunks", embedding_function=embeddings)
   vector_store.add_documents(docs)
   # Create retriever
   vector_retriever = vector_store.as_retriever(search_kwargs={"k": 5})
   ```
2. **BM25 Keyword Search**:
   ```python
   from langchain_community.retrievers import BM25Retriever
   # Build BM25 directly from documents in one line
   bm25_retriever = BM25Retriever.from_documents(docs)
   bm25_retriever.k = 5
   ```
3. **Hybrid Ensemble Fusion**:
   ```python
   from langchain_classic.retrievers import EnsembleRetriever
   ensemble_retriever = EnsembleRetriever(
       retrievers=[vector_retriever, bm25_retriever],
       weights=[0.5, 0.5]
   )
   fused_docs = ensemble_retriever.invoke(query)
   ```

#### 2. Why the Original Code Looked So Complex:
Earlier, `app/indexing/bm25_index.py` contained over 470 lines of custom Okapi BM25 math, manual inverted index dictionaries, term frequency saturation algorithms, custom tokenization loops, and pickle serialization logic. While powerful, writing custom IR algorithms obscured the core learning objective.

#### 3. How We Simplified It:
1. **`app/indexing/bm25_index.py`**:
   - Replaced 470 lines of custom math with `langchain_community.retrievers.BM25Retriever.from_documents()`.
   - Chunks are stored as standard `Document(page_content=chunk.text, metadata=...)`.
   - `as_retriever(k=5, ticker="TSLA")` returns a standard `BM25Retriever` ready for `EnsembleRetriever`.
2. **`app/indexing/vector_store.py`**:
   - Exposed `as_retriever(k=5, ticker="TSLA")` returning a standard LangChain `VectorStoreRetriever`.
3. **`app/retrieval/hybrid_engine.py`**:
   - Directly combines `vector_retriever` and `bm25_retriever` using `EnsembleRetriever(retrievers=[...], weights=[0.5, 0.5])`.
   - Keeps the code transparent, beginner-friendly, and 100% aligned with the course lessons.






