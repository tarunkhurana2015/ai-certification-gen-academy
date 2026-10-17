"""Build two presentation SVGs from the implemented ingestion flow (stdlib only)."""
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
         "openai": "#F4F0E8", "langchain": "#BEDCC4", "sqlite": "#C2DDE2"}


def text(x, y, value, size=20, fill=FG, weight=400, family="Arial, Helvetica, sans-serif"):
    return f'<text x="{x}" y="{y}" font-size="{size}" fill="{fill}" font-weight="{weight}" font-family="{family}">{escape(value)}</text>'


def rect(x, y, w, h, fill, stroke="none", radius=18, extra=""):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radius}" fill="{fill}" stroke="{stroke}" {extra}/>'


def logo(name, x, y, size=34):
    raw = (LOGOS / f"{name}.svg").read_text()
    vb = re.search(r'viewBox="([^"]+)"', raw).group(1)
    inner = re.sub(r'^.*?<svg\b[^>]*>', '', raw, count=1, flags=re.S).rsplit('</svg>', 1)[0]
    inner = re.sub(r'<title>.*?</title>', '', inner, flags=re.S)
    return f'<svg x="{x}" y="{y}" width="{size}" height="{size}" viewBox="{vb}" fill="{BRAND.get(name, FG)}" aria-label="{name}">{inner}</svg>'


def icon(name, x, y, size=30, color=FG):
    raw = (LOGOS / f"fa-{name}.svg").read_text()
    vb = re.search(r'viewBox="([^"]+)"', raw).group(1)
    paths = ''.join(re.findall(r'<path\b[^>]*/?>', raw))
    return f'<svg x="{x}" y="{y}" width="{size}" height="{size}" viewBox="{vb}" fill="{color}" color="{color}">{paths}</svg>'


def canvas(title, subtitle, page):
    return [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-labelledby="title desc">',
            f'<title id="title">{escape(title)}</title><desc id="desc">{escape(subtitle)}</desc>',
            '<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z" fill="#C8B898"/></marker></defs>',
            rect(0, 0, W, H, BG, radius=0),
            text(70, 66, "GENSTOCKFOLIO  /  RAG DEMO", 16, "#D5B77C", 700),
            text(70, 129, title, 48, weight=700),
            text(70, 174, subtitle, 23, MUTED),
            text(1770, 66, f"{page} / 02", 16, MUTED),
            '<path d="M70 205 H1850" stroke="#494339" stroke-width="1"/>']


def card(parts, x, y, number, brand, kind, title, lines, vendor=None, w=320, h=210):
    fill, accent = PALETTE[kind]
    parts += [rect(x, y + 5, w, h, "#11110F", radius=18),
              rect(x, y, w, h, fill, accent, extra='stroke-width="1.5"'),
              logo(brand, x + 21, y + 22),
              text(x + 69, y + 39, (vendor or brand).upper(), 14, MUTED, 700),
              f'<circle cx="{x+w-31}" cy="{y+34}" r="17" fill="{accent}"/>',
              text(x+w-40, y+40, f"{number:02}", 15, BG, 700),
              text(x+21, y+91, title, 23, weight=700)]
    for i, line in enumerate(lines):
        parts.append(text(x+21, y+128+i*27, line, 18.5, FG if i == 0 else MUTED))


def arrow(parts, x1, y1, x2, y2):
    parts.append(f'<path d="M{x1} {y1} L{x2} {y2}" stroke="#C8B898" stroke-width="2.4" fill="none" marker-end="url(#arrow)"/>')


def boundary(parts, x, y, w, h, label, brand, accent):
    """Group existing cards without changing their content or execution order."""
    parts += [f'<g data-component="{label.lower()}">',
              rect(x, y, w, h, "#211F1B", accent, radius=22, extra='stroke-width="1.4"'),
              logo(brand, x + 18, y + 12, 20),
              text(x + 48, y + 28, label, 15, accent, 700),
              '</g>']


def write(name, parts):
    (HERE / f"{name}.svg").write_text('\n'.join(parts + ['</svg>']))


def overview():
    p = canvas("From earnings PDF to usable evidence", "The implemented ingestion flow, from Flutter upload to server processing and back to the dashboard.", "01")
    for x, label, color in [(70, "CLIENT", "#92B59A"), (260, "SERVER PROCESSING", "#D5B77C"), (590, "RAG PREPARATION", "#BAA0C6"), (900, "PERSISTED OUTPUTS", "#A3C1AC")]:
        p += [f'<circle cx="{x+6}" cy="235" r="5" fill="{color}"/>', text(x+22, 241, label, 14, MUTED, 700)]
    xs = [70, 435, 800, 1165, 1530]
    top, bottom = 300, 650
    boundary(p, 1150, 256, 715, 275, "PARSER", "python", "#9FB59D")
    boundary(p, 1515, 606, 350, 274, "EXTRACTOR", "openai", "#D5B77C")
    boundary(p, 1150, 606, 350, 274, "CHUNKER", "langchain", "#BAA0C6")
    steps = [
        (1, "flutter", "client", "Choose an earnings PDF", ["PDF bytes + ticker / period", "Flutter file picker", "Submit for ingestion"], "Flutter client"),
        (2, "fastapi", "server", "Receive the upload", ["POST /api/v1/ingestion/upload", "multipart/form-data", "Save PDF in data/uploads/"], "FastAPI server"),
        (3, "python", "server", "Validate & fingerprint", ["Check %PDF- header + SHA-256", "SQLite duplicate lookup", "force=true skips cache reuse"], "Python + SQLite"),
        (4, "python", "server", "Read page-aligned text", ["pypdf.PdfReader", "Keep 1-based page numbers", "Track blank pages"], "pypdf · Python"),
        (5, "python", "server", "Tag financial sections", ["Rules score headers + keywords", "Cash flow, profitability, etc.", "Retain page-domain metadata"], "Python classifier"),
        (6, "openai", "server", "Extract structured KPIs", ["gpt-4o-mini via LangChain", "Selected financial pages", "Pydantic schema + math rules"], "OpenAI"),
        (7, "langchain", "rag", "Build enriched chunks", ["1,000 chars / 100 overlap", "All non-blank pages", "Ticker, period, page + domain"], "LangChain + Python"),
        (8, "sqlite", "data", "Save report & KPIs", ["SQLite: stock_analyst.db", "documents + financial_kpis", "Task status → COMPLETED"], "SQLite · SQLAlchemy"),
        (9, "fastapi", "server", "Return the result", ["HTTP 200 JSON after processing", "task_id, document_id, status", "kpis + client_kpis"], "FastAPI response"),
        (10, "flutter", "client", "Refresh the dashboard", ["QuarterlyKpis.fromJson", "Riverpod addAndSelectReport", "Render scorecards + charts"], "Flutter + Riverpod"),
    ]
    for n, brand, kind, title, lines, vendor in steps:
        x, y = (xs[n-1], top) if n <= 5 else (xs[10-n], bottom)
        card(p, x, y, n, brand, kind, title, lines, vendor)
    for i in range(4):
        arrow(p, xs[i]+326, top+105, xs[i+1]-8, top+105)
        arrow(p, xs[i+1]-6, bottom+105, xs[i]+328, bottom+105)
    arrow(p, 1690, top+216, 1690, bottom-9)
    p += [text(70, 550, "01–05  Upload, validate, extract and classify", 19, MUTED),
          text(70, 581, "06–10  Follow the arrows back to the client", 19, MUTED)]
    p += [rect(70, 890, 1780, 105, "#24221E", "#514A40", radius=14), icon("folder-open", 95, 918, 40, "#D5B77C"),
          text(155, 928, "INSPECTABLE OUTPUTS  ·  server/.artifact/", 19, weight=700),
          text(155, 964, "Pages → section tags → raw splits → enriched chunks → KPI extraction → persistence snapshot → run summary", 21, MUTED),
          text(70, 1038, "RAG boundary: chunk preparation is implemented. Embeddings, vector indexing, retrieval and answer generation are next.", 19, MUTED)]
    write("ingestion-overview", p)


def rag_preparation():
    p = canvas("What makes ingestion useful for RAG?", "Turn a PDF into small, traceable pieces of evidence before adding embeddings and retrieval.", "02")
    xs = [70, 435, 800, 1165, 1530]
    boundary(p, 55, 253, 715, 278, "PARSER", "python", "#9FB59D")
    boundary(p, 785, 253, 350, 278, "EXTRACTOR", "openai", "#D5B77C")
    boundary(p, 1150, 253, 715, 278, "CHUNKER", "langchain", "#BAA0C6")
    stages = [
        (1, "python", "Keep page boundaries", ["pypdf extracts page text", "Page numbers start at 1", "Blank pages are skipped later"], "pypdf · Python"),
        (2, "python", "Keep financial context", ["Rule-based domain labels", "Headers + body keywords", "Each page keeps its domain"], "Python classifier"),
        (3, "openai", "Resolve report identity", ["KPIs supply canonical metadata", "Ticker + fiscal quarter + year", "Statement pages sent to LLM"], "OpenAI · gpt-4o-mini"),
        (4, "langchain", "Split within each page", ["RecursiveCharacterTextSplitter", "1,000 characters per chunk", "100-character overlap"], "LangChain"),
        (5, "python", "Attach source metadata", ["Stable chunk ID + text", "Ticker, period, page + domain", "Chunk position + char count"], "Python enrichment"),
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
          text(1210, 688, "EnrichedChunk objects in memory", 25, weight=700),
          text(1210, 732, "03b_enriched_chunks_*.json / .md", 23, "#B8CEB2"),
          text(1210, 775, "Written when save_artifacts=true", 22, MUTED),
          text(1210, 833, "The Flutter upload enables artifact saving.", 21, MUTED)]
    p += [rect(70, 925, 1780, 94, "#24221E", "#655F53", extra='stroke-dasharray="8 6"'),
          icon("circle-arrow-right", 96, 955, 30, "#D5B77C"),
          text(146, 959, "NEXT RAG STAGE  ·  planned, outside the current ingestion implementation", 18, "#D5B77C", 700),
          text(146, 995, "Enriched chunks → embeddings → vector index → retrieve relevant evidence → generate a cited answer", 23, FG)]
    write("ingestion-rag-preparation", p)


def manifest():
    entries = []
    for path in sorted(LOGOS.glob("*.svg")):
        source = (f"https://raw.githubusercontent.com/simple-icons/simple-icons/14.15.0/icons/{path.stem}.svg"
                  if not path.stem.startswith("fa-") else
                  f"https://github.com/FortAwesome/Font-Awesome/blob/7.3.1/svgs/solid/{path.stem[3:]}.svg")
        entries.append({"file": path.name, "source": source, "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
    (LOGOS / "manifest.json").write_text(json.dumps({"notes": "Technology marks identify the actual tools; standard icons identify files, code and future work. Marks are recoloured only in the composed SVGs for contrast.", "assets": entries}, indent=2)+'\n')


if __name__ == "__main__":
    overview()
    rag_preparation()
    manifest()
    print("Built 2 standalone 1920×1080 SVG slides.")
