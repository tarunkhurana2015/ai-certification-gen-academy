# Earnings PDF ingestion — RAG demo

The implemented pipeline accepts an earnings PDF from Flutter, extracts structured financial KPIs, prepares chunks with source metadata, and returns a report to the dashboard. This document follows the current client and server code, reviewed on October 17, 2026.

## Presentation graphics

Both visuals use a **16:9 slide layout**, real technology marks, and connectors that do not cross. Insert the **3840 × 2160 PNGs** into PowerPoint, Keynote, or Google Slides. Use the SVGs for scalable artwork, or open the [two-slide PDF](assets/ingestion/ingestion-slides.pdf).

| Slide | PNG for presentations | Scalable SVG |
|---|---|---|
| Client → server → client | [Download PNG](assets/ingestion/ingestion-overview.png) | [Open SVG](assets/ingestion/ingestion-overview.svg) |
| Preparing evidence for RAG | [Download PNG](assets/ingestion/ingestion-rag-preparation.png) | [Open SVG](assets/ingestion/ingestion-rag-preparation.svg) |

## 1. Client-to-server ingestion flow

[![Client-to-server earnings PDF ingestion flow](assets/ingestion/ingestion-overview.png)](assets/ingestion/ingestion-overview.svg)

Read steps **01–05 left to right**, then follow the arrows through **06–10 back to the client**. The path shows a successful upload that is processed rather than served from the duplicate cache.

Labeled bounding boxes identify the three processing components: **Parser** groups page extraction and section classification; **Extractor** handles structured KPI extraction and report identity; **Chunker** handles splitting and metadata enrichment. Both slides preserve the existing execution order.

| Step | What the code does | Source |
|---|---|---|
| 01 · Choose PDF | Flutter's file picker reads PDF bytes. The panel submits the ticker, selected fiscal quarter, and year with the file. | [ReportIngestionPanel](../client/packages/ai_analyst_feature/lib/presentation/views/widgets/report_ingestion_panel.dart) |
| 02 · Upload | `RemoteKpiDataSource` sends multipart `POST /api/v1/ingestion/upload`. FastAPI checks the `.pdf` extension and saves the file under `server/data/uploads/`. | [Client HTTP request](../client/packages/ai_analyst_feature/lib/data/datasources/remote_kpi_datasource.dart), [upload endpoint](../server/app/api/v1/endpoints/documents.py) |
| 03 · Validate | The pipeline creates a tracking task, checks for a non-empty file and `%PDF-` header, hashes the file using SHA-256, and looks for a matching document in SQLite. | [Pipeline](../server/app/ingestion/pipeline.py), [validator](../server/app/ingestion/validator.py) |
| 04 · Extract text | `pypdf.PdfReader` extracts each page's text. `ExtractedPage` retains its **1-based page number**, character count, and blank-page flag. | [PDF extractor](../server/app/ingestion/parsers/pdf_extractor.py) |
| 05 · Classify | Python rules score page headers and body keywords to assign financial domains, confidence scores, and matched signals. | [Section classifier](../server/app/ingestion/parsers/section_classifier.py) |
| 06 · Extract KPIs | LangChain `ChatOpenAI(model="gpt-4o-mini", temperature=0.0)` receives selected statement pages and uses `with_structured_output(FinancialReportKPIs)`. Python then normalizes CapEx signs and derives missing FCF and margins where inputs are available. The extracted ticker and period become the canonical chunk metadata. | [KPI extractor](../server/app/ingestion/extractor/kpi_extractor.py), [prompt](../server/app/ingestion/extractor/llm_extraction_prompts.py), [math reconciliation](../server/app/ingestion/extractor/kpi_validator.py) |
| 07 · Prepare chunks | LangChain splits **all non-blank pages** within their page boundaries: **1,000 characters**, **100-character overlap**. Python attaches financial and source metadata to each split. | [Splitter](../server/app/ingestion/chunkers/recursive_chunker.py), [metadata enrichment](../server/app/ingestion/chunkers/metadata_enricher.py), [pipeline orchestration](../server/app/ingestion/pipeline.py) |
| 08 · Persist | SQLAlchemy saves or updates `documents` and `financial_kpis` in SQLite, with the default database at `server/data/stock_analyst.db`. `ingestion_tasks` records progress throughout. When enabled, inspection artifacts are written after processing. | [Database configuration](../server/app/db/session.py), [models](../server/app/db/models.py), [pipeline](../server/app/ingestion/pipeline.py) |
| 09 · Return JSON | The endpoint returns the pipeline result, including `task_id`, `document_id`, `status`, raw `kpis`, and dashboard-shaped `client_kpis`. | [Response schema](../server/app/schemas/ingestion.py), [endpoint](../server/app/api/v1/endpoints/documents.py) |
| 10 · Update dashboard | Flutter decodes `client_kpis` with `QuarterlyKpis.fromJson`. The panel callback calls Riverpod's `addAndSelectReport`, replacing or adding the report and selecting it for display. | [Dashboard callback](../client/packages/ai_analyst_feature/lib/presentation/views/kpi_dashboard_view.dart), [ViewModel](../client/packages/ai_analyst_feature/lib/presentation/viewmodel/kpi_dashboard_viewmodel.dart) |

**Suggested narration:** “We upload an earnings PDF from Flutter. The server validates it, preserves page boundaries, labels financial sections, extracts typed KPIs, and prepares chunks with source metadata. The report and KPIs are saved in SQLite, and the response refreshes the dashboard. Those chunks are the evidence we will embed and retrieve in the next RAG stage.”

## 2. Preparing evidence for RAG

[![How ingestion prepares traceable evidence for RAG](assets/ingestion/ingestion-rag-preparation.png)](assets/ingestion/ingestion-rag-preparation.svg)

The two kinds of output serve different purposes:

| Output | What it contains | Why it matters |
|---|---|---|
| Structured KPIs | Financial figures, ticker, fiscal period, and report-level `source_pages`; persisted in SQLite. | Supports dashboard rendering and structured numeric lookups. |
| Enriched chunks | Text, `chunk_id`, ticker, quarter, year, page number, financial domain, character count, and chunk position. | Prepares evidence for later retrieval filters and page-level citations. |

KPI extraction selects pages classified as profitability, balance sheet, or cash flow. If none qualify, it falls back to the first six non-blank pages. **Chunking still covers every non-blank page**, preserving narrative material that may help answer later questions.

Each chunk receives a deterministic ID:

```text
{TICKER}_{QUARTER}_{YEAR}_p{PAGE}_c{ZERO_BASED_CHUNK_INDEX}
```

The second slide uses metadata from the existing [Tesla enriched-chunk artifact](../server/.artifact/03b_enriched_chunks_tsla_q2_2026_update.json): `TSLA_Q2_2026_p3_c0`, financial domain `cash_flow`, 943 characters, and chunk index 0 among four chunks on that page.

**Current RAG boundary:** enriched chunks exist in memory and, with `save_artifacts=true`, in JSON and Markdown inspection files. This ingestion path does **not yet call an embedding model, write a vector index, retrieve chunks, or generate a conversational answer**. Those later steps are explicitly marked as planned in the graphic.

## 3. Details to keep accurate during the demo

- **One request completes the work.** The upload endpoint calls `pipeline.run()` directly and returns HTTP 200 after processing. The panel does not start a background job or poll task progress. Its progress bar uses locally assigned milestones; task-status records and a status endpoint exist separately.
- **The current panel forces reprocessing.** It sends `force=true`. With `force=false`, a matching SHA-256 document that already has KPIs returns the stored result early; a match without KPIs continues through processing. There is no fixed latency guarantee.
- **Artifacts are inspection outputs.** The Flutter request sends `save_artifacts=true`. Files under `server/.artifact/` capture extracted pages, classifications, raw splits, enriched chunks, extracted KPIs, persisted KPIs, and the pipeline summary. They are not a vector database.
- **The offline fallback is simulated.** If remote ingestion throws, `ReportIngestionPanel` generates hard-coded demo financial values. Its fallback messages mention embeddings and indexing, but that branch does not perform them. Use a reachable backend and a real PDF when presenting the implemented server flow.
- **Check the result, not only the HTTP status.** Pipeline failures are represented by `status="FAILED"` in the result. The upload endpoint currently wraps that result in its normal response; non-PDF extensions are rejected separately with HTTP 400.

## Artwork and editing

The graphics embed Flutter, FastAPI, Python, OpenAI, LangChain, and SQLite marks from [Simple Icons, pinned to 14.15.0](https://github.com/simple-icons/simple-icons/tree/14.15.0/icons). Custom Python steps use the Python mark; pypdf is labeled explicitly and is not represented as LlamaIndex. Standard file, code, and continuation symbols come from Font Awesome Free 7.3.1. Original files, attribution licenses, download URLs, and SHA-256 checksums are retained in [logos](assets/ingestion/logos/manifest.json).

The SVGs are self-contained and require no network access to display. To edit the labels or layout, update [build_diagrams.py](assets/ingestion/build_diagrams.py), then regenerate the SVGs:

```sh
python3 week2-project-stock-ai-analyzer/docs/assets/ingestion/build_diagrams.py
```

PNG and PDF files are rendered exports of those SVGs; re-export them after artwork changes.
