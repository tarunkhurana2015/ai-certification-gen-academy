"""Build ingestion presentation SVGs from the implementation (stdlib only)."""
from pathlib import Path
from html import escape
import hashlib
import json
import re

HERE = Path(__file__).resolve().parent
LOGOS = HERE / "logos"
W, H = 1920, 1080
BG, FG, MUTED = "#191816", "#F4F0E8", "#BFB7AA"
PALETTE = {
    "client": ("#26332C", "#92B59A"),
    "server": ("#302B22", "#D5B77C"),
    "rag": ("#342C38", "#BAA0C6"),
    "data": ("#283630", "#A3C1AC"),
}
BRAND = {"flutter": "#67C8F2", "fastapi": "#53D0B5", "python": "#F2CC72",
         "openai": "#F4F0E8", "langchain": "#BEDCC4", "sqlite": "#C2DDE2",
         "chroma": "#F4F0E8", "typesafe": "#F4F0E8"}


def text(x, y, value, size=20, fill=FG, weight=400, family="Arial, Helvetica, sans-serif"):
    return f'<text x="{x}" y="{y}" font-size="{size}" fill="{fill}" font-weight="{weight}" font-family="{family}">{escape(value)}</text>'


def rect(x, y, w, h, fill, stroke="none", radius=18, extra=""):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radius}" fill="{fill}" stroke="{stroke}" {extra}/>'


def logo(name, x, y, size=34):
    raw = (LOGOS / f"{name}.svg").read_text()
    vb = re.search(r'viewBox="([^"]+)"', raw).group(1)
    inner = re.sub(r'^.*?<svg\b[^>]*>', '', raw, count=1, flags=re.S).rsplit('</svg>', 1)[0]
    inner = re.sub(r'<title>.*?</title>', '', inner, flags=re.S)
    inner = re.sub(r'fill="var\([^"]+"', f'fill="{BRAND.get(name, FG)}"', inner)
    return f'<svg x="{x}" y="{y}" width="{size}" height="{size}" viewBox="{vb}" fill="{BRAND.get(name, FG)}" aria-label="{name}">{inner}</svg>'


def icon(name, x, y, size=30, color=FG):
    raw = (LOGOS / f"fa-{name}.svg").read_text()
    vb = re.search(r'viewBox="([^"]+)"', raw).group(1)
    paths = ''.join(re.findall(r'<path\b[^>]*/?>', raw))
    return f'<svg x="{x}" y="{y}" width="{size}" height="{size}" viewBox="{vb}" fill="{color}" color="{color}">{paths}</svg>'


def canvas(title, subtitle, page, total=4, pipeline="INGESTION PIPELINE"):
    return [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-labelledby="title desc">',
            f'<title id="title">{escape(title)}</title><desc id="desc">{escape(subtitle)}</desc>',
            '<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z" fill="#C8B898"/></marker></defs>',
            rect(0, 0, W, H, BG, radius=0),
            text(70, 66, f"{pipeline}  /  GENSTOCKFOLIO  /  RAG DEMO", 16, "#D5B77C", 700),
            text(70, 129, title, 48, weight=700),
            text(70, 174, subtitle, 23, MUTED),
            text(1770, 66, f"{page} / {total:02}", 16, MUTED),
            '<path d="M70 205 H1850" stroke="#494339" stroke-width="1"/>']


def card(parts, x, y, number, brand, kind, title, lines, vendor=None, w=320, h=210, compact=False):
    fill, accent = PALETTE[kind]
    number_label = f"{number:02}" if isinstance(number, int) else number
    number_x = x+w-40 if isinstance(number, int) else x+w-44.5
    parts += [rect(x, y + 5, w, h, "#11110F", radius=18),
              rect(x, y, w, h, fill, accent, extra=f'stroke-width="1.5" data-card="{number}"'),
              logo(brand, x + 21, y + 22),
              text(x + 69, y + 39, (vendor or brand).upper(), 14, MUTED, 700),
              f'<circle cx="{x+w-31}" cy="{y+34}" r="17" fill="{accent}"/>',
              text(number_x, y+40, number_label, 15, BG, 700),
              text(x+21, y+(75 if compact else 91), title, 23, weight=700)]
    for i, line in enumerate(lines):
        parts.append(text(x+21, y+(108+i*25 if compact else 128+i*27), line, 18.5, FG if i == 0 else MUTED))


def arrow(parts, x1, y1, x2, y2):
    parts.append(f'<path d="M{x1} {y1} L{x2} {y2}" stroke="#C8B898" stroke-width="2.4" fill="none" marker-end="url(#arrow)"/>')


def boundary(parts, x, y, w, h, label, brand, accent):
    """Group existing cards without changing their content or execution order."""
    parts += [f'<g data-component="{escape(label.lower(), quote=True)}">',
              rect(x, y, w, h, "#211F1B", accent, radius=22, extra='stroke-width="1.4"'),
              logo(brand, x + 18, y + 12, 20),
              text(x + 48, y + 28, label, 15, accent, 700),
              '</g>']


def chunker_stages(parts, x, y, w=415):
    """Show splitting and enrichment as two sequential stages within step 07."""
    fill, accent = PALETTE["rag"]
    stages = [
        ("07a", "langchain", "Recursive Chunker", "1,000 chars · 100 overlap · non-blank pages"),
        ("07b", "python", "Metadata Enrichment", "Ticker, period, page, domain + chunk ID"),
    ]
    for i, (number, brand, title, detail) in enumerate(stages):
        sy = y + i * 100
        parts += [rect(x, sy + 4, w, 78, "#11110F"),
                  rect(x, sy, w, 78, fill, accent, extra=f'stroke-width="1.5" data-card="{number}"'),
                  logo(brand, x + 17, sy + 15, 25),
                  text(x + 56, sy + 31, title, 21, weight=700),
                  rect(x + w - 64, sy + 13, 48, 24, accent, radius=12),
                  text(x + w - 56, sy + 30, number, 13, BG, 700),
                  text(x + 18, sy + 63, detail, 17.5, MUTED)]
    arrow(parts, x + w / 2, y + 84, x + w / 2, y + 92)


def write(name, parts):
    (HERE / f"{name}.svg").write_text('\n'.join(parts + ['</svg>']))


def overview_steps():
    """Shared labels keep the two overview slides consistent at the handoff."""
    return [
        (1, "flutter", "client", "Choose an earnings PDF", ["PDF bytes + ticker / period", "Flutter file picker", "Submit for ingestion"], "Flutter client"),
        (2, "fastapi", "server", "Receive the upload", ["POST /api/v1/ingestion/upload", "multipart/form-data", "Save PDF in data/uploads/"], "FastAPI server"),
        (3, "python", "server", "Validate & fingerprint", ["Check %PDF- header + SHA-256", "SQLite duplicate lookup", "force=true skips cache reuse"], "Python + SQLite"),
        (4, "python", "server", "Read page-aligned text", ["pypdf.PdfReader", "Keep 1-based page numbers", "Track blank pages"], "pypdf · Python"),
        (5, "python", "server", "Tag financial sections", ["Rules score headers + keywords", "Cash flow, profitability, etc.", "Retain page-domain metadata"], "Python classifier"),
        (6, "openai", "server", "Extract structured KPIs", ["gpt-4o-mini via LangChain", "Selected financial pages", "Pydantic schema + math rules"], "OpenAI"),
        (7, "langchain", "rag", "Build enriched chunks", ["1,000 chars / 100 overlap", "All non-blank pages", "Ticker, period, page + domain"], "LangChain + Python"),
        (8, "sqlite", "data", "Save report & KPIs", ["SQLite: stock_analyst.db", "documents + financial_kpis", "Persisted before indexing"], "SQLite · SQLAlchemy"),
        (9, "fastapi", "server", "Return the result", ["Persisted report + KPIs", "Response does not wait for indexing", "Background work continues"], "FastAPI response"),
        (10, "flutter", "client", "Refresh the dashboard", ["QuarterlyKpis.fromJson", "Riverpod addAndSelectReport", "Render scorecards + charts"], "Flutter + Riverpod"),
        (11, "openai", "data", "Embed & store in Chroma", ["text-embedding-3-small · 512-dim", "LangChain Documents + metadata", "Chroma: earnings_chunks"], "OpenAI + Chroma"),
        (12, "langchain", "data", "Build the BM25 index", ["BM25Retriever.from_documents", "Keyword ranking; no embeddings", "Corpus: data/bm25/documents.json"], "LangChain · BM25"),
    ]


def overview():
    p = canvas("From an earnings PDF to a saved report", "Client → upload → validation → parsing → extraction → chunk preparation → persistence.", "01")
    xs = [70, 710, 1350]
    ys = [290, 545, 800]
    # Wider cards and generous routing gutters; each component stays on one row.
    boundary(p, 695, 497, 1170, 243, "PARSER", "python", "#9FB59D")
    boundary(p, 55, 497, 530, 243, "EXTRACTOR", "openai", "#D5B77C")
    boundary(p, 55, 752, 1170, 243, "CHUNKER", "langchain", "#BAA0C6")
    positions = {1: (0, 0), 2: (1, 0), 3: (2, 0), 4: (2, 1), 5: (1, 1), 6: (0, 1), 8: (2, 2)}
    for n, brand, kind, title, lines, vendor in overview_steps():
        if n not in positions:
            continue
        col, row = positions[n]
        card(p, xs[col], ys[row], n, brand, kind, title, lines, vendor, w=500, h=175, compact=True)
    card(p, xs[0], ys[2], "07a", "langchain", "rag", "Recursive Chunker",
         ["1,000 chars · 100 overlap · non-blank pages"], "LangChain", w=500, h=175, compact=True)
    card(p, xs[1], ys[2], "07b", "python", "rag", "Metadata Enrichment",
         ["Ticker, period, page, domain + chunk ID"], "Python", w=500, h=175, compact=True)
    for row in (0, 2):
        for col in (0, 1):
            arrow(p, xs[col]+508, ys[row]+87.5, xs[col+1]-10, ys[row]+87.5)
    for col in (2, 1):
        arrow(p, xs[col]-8, ys[1]+87.5, xs[col-1]+510, ys[1]+87.5)
    arrow(p, 1600, 473, 1600, 537)
    arrow(p, 320, 728, 320, 792)
    p += [text(70, 252, "01–03  ·  CLIENT & SERVER", 16, "#D5B77C", 700),
          text(1350, 780, "08  ·  PERSISTENCE", 16, "#A3C1AC", 700),
          text(70, 1040, "CONTINUE ON SLIDE 02  →  After saving, return the result and prepare the search indexes independently (proposed).", 21, MUTED)]
    write("ingestion-overview", p)


def response_indexing():
    p = canvas("Return results while indexing continues", "Proposed flow · after saving report + KPIs, fork into a response path and independent background indexing.", "02")
    boundary(p, 765, 250, 1100, 300, "RESPONSE NOW", "fastapi", "#D5B77C")
    boundary(p, 765, 660, 1100, 300, "BACKGROUND INDEXER", "chroma", "#A3C1AC")
    positions = {8: (70, 480, 440), 9: (790, 320, 460), 10: (1390, 320, 460),
                 11: (790, 730, 460), 12: (1390, 730, 460)}
    for n, brand, kind, title, lines, vendor in overview_steps():
        if n not in positions:
            continue
        x, y, w = positions[n]
        card(p, x, y, n, brand, kind, title, lines, vendor, w=w)
    # One visible fork in open space. The background lane never rejoins the response.
    p += ['<path d="M518 585 H640" fill="none" stroke="#C8B898" stroke-width="2.4"/>',
          '<path data-flow="immediate-response" d="M640 585 V425 H782" fill="none" stroke="#C8B898" stroke-width="2.4" marker-end="url(#arrow)"/>',
          '<path data-flow="background-indexing" d="M640 585 V835 H782" fill="none" stroke="#C8B898" stroke-width="2.4" stroke-dasharray="8 6" marker-end="url(#arrow)"/>',
          '<circle cx="640" cy="585" r="6" fill="#F4F0E8"/>']
    arrow(p, 1258, 425, 1382, 425)
    arrow(p, 1258, 835, 1382, 835)
    p += [text(70, 438, "CONTINUED FROM SLIDE 01", 17, "#A3C1AC", 700),
          text(790, 305, "Return without waiting for the search indexes.", 20, MUTED),
          text(790, 715, "Independent execution · no join back to the response.", 20, MUTED),
          rect(70, 994, 1780, 58, "#24221E", "#514A40", radius=12), icon("folder-open", 92, 1010, 26, "#D5B77C"),
          text(138, 1030, "PROPOSED FLOW · Current code still indexes before returning; independent background execution requires a server change.", 20, MUTED)]
    write("ingestion-response-indexing", p)


def rag_preparation():
    p = canvas("What makes ingestion useful for RAG?", "Keep small, traceable pieces of evidence that the vector and keyword indexes can search.", "03")
    xs = [70, 435, 800, 1165, 1530]
    boundary(p, 55, 253, 715, 278, "PARSER", "python", "#9FB59D")
    boundary(p, 785, 253, 350, 278, "EXTRACTOR", "openai", "#D5B77C")
    boundary(p, 1150, 253, 715, 278, "CHUNKER", "langchain", "#BAA0C6")
    stages = [
        (1, "python", "Keep page boundaries", ["pypdf extracts page text", "Page numbers start at 1", "Blank pages are skipped later"], "pypdf · Python"),
        (2, "python", "Keep financial context", ["Rule-based domain labels", "Headers + body keywords", "Each page keeps its domain"], "Python classifier"),
        (3, "openai", "Resolve report identity", ["KPIs supply canonical metadata", "Ticker + fiscal quarter + year", "Statement pages sent to LLM"], "OpenAI · gpt-4o-mini"),
        (4, "langchain", "Recursive Chunker", ["RecursiveCharacterTextSplitter", "1,000 characters per chunk", "100-character overlap"], "LangChain"),
        (5, "python", "Metadata Enrichment", ["Stable chunk ID + text", "Ticker, period, page + domain", "Chunk position + char count"], "Python enrichment"),
    ]
    for n, brand, title, lines, vendor in stages:
        card(p, xs[n-1], 300, n, brand, "rag", title, lines, vendor)
    for i in range(4):
        arrow(p, xs[i]+326, 405, xs[i+1]-8, 405)
    p += [text(70, 566, "Chunking uses all non-blank pages, including narrative pages outside the KPI extraction subset.", 23, MUTED)]
    p += [rect(70, 580, 1070, 300, "#28242D", "#8B7795"), icon("code", 96, 606, 30, "#CDB7D8"),
          text(145, 632, "A SAVED CHUNK  ·  actual inspection-artifact metadata", 18, weight=700)]
    example = [
        'chunk_id:          "TSLA_Q2_2026_p3_c0"',
        'ticker / period:   "TSLA" / "Q2" / 2026',
        'page_number:      3',
        'financial_domain: "cash_flow"',
        'chunk position:   0 of 4  ·  char_count: 943',
    ]
    for i, line in enumerate(example):
        p.append(text(100, 680+i*36, line, 23, "#E8DDF0", family="Menlo, Consolas, monospace"))
    p += [rect(1180, 580, 670, 300, "#242720", "#7F937D"), icon("folder-open", 1206, 607, 30, "#B8CEB2"),
          text(1250, 632, "WHERE THE EVIDENCE LIVES TODAY", 18, weight=700),
          text(1210, 688, "Chunks feed Chroma + BM25", 25, weight=700),
          text(1210, 732, "03b_enriched_chunks_*.json / .md", 23, "#B8CEB2"),
          text(1210, 775, "Written when save_artifacts=true", 22, MUTED),
          text(1210, 833, "The Flutter upload enables artifact saving.", 21, MUTED)]
    p += [rect(70, 925, 1780, 94, "#24221E", "#655F53", extra='stroke-dasharray="8 6"'),
          icon("circle-arrow-right", 96, 955, 30, "#D5B77C"),
          text(146, 959, "INDEXING HANDOFF  ·  implemented in the ingestion orchestrator", 18, "#D5B77C", 700),
          text(146, 995, "Same enriched chunks → OpenAI embeddings + Chroma dense index, and LangChain BM25 sparse index", 23, FG)]
    write("ingestion-rag-preparation", p)


def indexing():
    p=canvas("Background indexing after persistence", "Proposed worker path · the saved report result is already returned while the indexes are being prepared.", "04")
    boundary(p, 570, 228, 910, 684, "BACKGROUND INDEXER", "chroma", "#A3C1AC")
    card(p,70,470,1,"langchain","rag","LangChain Documents",["page_content = chunk text","metadata = source + financial tags","chunk_id becomes the stable ID"],"LangChain",w=350)
    card(p,605,300,2,"openai","data","Embed the chunk text",["text-embedding-3-small","512-dimensional dense vectors","OpenAIEmbeddings via LangChain"],"OpenAI",w=350)
    card(p,1105,300,3,"chroma","data","Persist dense evidence",["Collection: earnings_chunks","Vectors + text + source metadata","PersistentClient: data/chroma/"],"Chroma",w=350)
    card(p,605,650,4,"langchain","data","Build lexical retrieval",["BM25Retriever.from_documents","Keyword ranking over the corpus","No embedding API call"],"LangChain · BM25",w=350)
    card(p,1105,650,5,"python","data","Save the BM25 corpus",["data/bm25/documents.json","page_content + metadata","Rebuild BM25 on reload"],"Python · JSON",w=350)
    card(p,1530,470,6,"python","server","Track index readiness",["Record vector + BM25 outcomes","Ready after both succeed","Independent of HTTP response"],"Python worker (proposed)")
    p += [text(605,284,"DENSE · SEMANTIC SEARCH",17,"#A3C1AC",700),text(605,634,"SPARSE · KEYWORD SEARCH",17,"#A3C1AC",700)]
    for points in ["420,575 505,575 505,405 597,405","505,575 505,755 597,755","961,405 1097,405","961,755 1097,755","1461,405 1500,405 1500,575 1522,575","1461,755 1500,755 1500,575"]:
        p.append(f'<polyline points="{points}" fill="none" stroke="#C8B898" stroke-width="2.4" marker-end="url(#arrow)"/>')
    p += [text(70,957,"Report availability and RAG search readiness are separate: the dashboard can load while indexing continues.",22,MUTED),
          text(70,1000,"Vector and BM25 work may remain sequential inside the worker; neither blocks the response branch.",21,"#D5B77C"),
          text(70,1041,"Proposed orchestration. Current code performs both indexing attempts inline before returning the result.",20,MUTED)]
    write("ingestion-indexing",p)


def manifest():
    entries = []
    for path in sorted(LOGOS.glob("*.svg")):
        source = (f"https://raw.githubusercontent.com/simple-icons/simple-icons/14.15.0/icons/{path.stem}.svg"
                  if not path.stem.startswith("fa-") else
                  f"https://github.com/FortAwesome/Font-Awesome/blob/7.3.1/svgs/solid/{path.stem[3:]}.svg")
        if path.stem == "chroma": source="https://raw.githubusercontent.com/chroma-core/chroma/ddc17cd7c508f15f237c965e74e536ff64396ddb/docs/mintlify/images/favicon.svg"
        if path.stem == "typesafe": source="https://typesafe.ai/ (official home-link SVG symbol svg-684955628_986; captured 2026-10-18)"
        entries.append({"file": path.name, "source": source, "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
    (LOGOS / "manifest.json").write_text(json.dumps({"notes": "Technology marks identify the actual tools; standard icons identify files, code and future work. Marks are recoloured only in the composed SVGs for contrast.", "assets": entries}, indent=2)+'\n')


if __name__ == "__main__":
    overview()
    response_indexing()
    rag_preparation()
    indexing()
    manifest()
    print("Built 4 standalone 1920×1080 ingestion SVG slides.")
