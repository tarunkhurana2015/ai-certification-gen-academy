"""Build the eight RAG pipeline slides, labeling proposed orchestration; no API calls."""
import importlib.util
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location("ingestion_art",HERE/"ingestion/build_diagrams.py")
art=importlib.util.module_from_spec(spec)
spec.loader.exec_module(art)
card, text, rect, icon, boundary, arrow = art.card, art.text, art.rect, art.icon, art.boundary, art.arrow
MUTED=art.MUTED


def start(title,subtitle,page,pipeline):
    return art.canvas(title,subtitle,page,total=2,pipeline=f"{pipeline.upper()} PIPELINE")


def wire(p,points):
    p.append(f'<polyline points="{points}" fill="none" stroke="#C8B898" stroke-width="2.4" marker-end="url(#arrow)"/>')


def panel(p,x,y,w,h,title,lines,brand="python",kind="server"):
    fill,accent=art.PALETTE[kind]
    p += [rect(x,y,w,h,fill,accent),art.logo(brand,x+22,y+22,30),text(x+70,y+45,title,19,weight=700)]
    for i,line in enumerate(lines):p.append(text(x+24,y+91+i*35,line,22,MUTED))


def save(pipeline,name,p):
    folder=HERE/pipeline
    folder.mkdir(exist_ok=True)
    (folder/f"{name}.svg").write_text('\n'.join(p+['</svg>']))


def retrieval_routes():
    p=start("One question, three evidence routes","Classify intent, select one retrieval tool, and pass its evidence to the matching generation function.","01","retrieval")
    boundary(p,460,403,390,278,"CLASSIFIER","typesafe","#D5B77C")
    boundary(p,955,227,400,244,"SQL KPI","sqlite","#A3C1AC")
    boundary(p,955,477,400,244,"HYBRID RAG","langchain","#BAA0C6")
    boundary(p,955,727,400,244,"COMPARISON","sqlite","#A3C1AC")
    card(p,70,450,1,"python","client","Receive a question",["run_retrieval / run_analyst","Python or CLI entry point","Unstructured question string"],"Python entry point",w=340)
    card(p,475,450,2,"typesafe","server","Classify intent + scope",["query_type, ticker, domain","TypeSafe Jev when available","Python rules as fallback"],"TypeSafe Jev + Python",w=360)
    card(p,975,270,3,"sqlite","data","Fetch exact financial KPIs",["get_kpis(ticker)","Latest report in router path","Dictionary of SQL record fields"],"SQLite · SQLAlchemy",w=360,h=180,compact=True)
    card(p,975,520,4,"langchain","rag","Search filing evidence",["search_filings(query, ticker)","Chroma + BM25 + weighted RRF","Up to 3 cited chunks"],"LangChain · Hybrid search",w=360,h=180,compact=True)
    card(p,975,770,5,"sqlite","data","Fetch peer comparisons",["compare_tickers(tickers)","Router uses Q2 2026","Company → metric dictionaries"],"SQLite · Peer lookup",w=360,h=180,compact=True)
    card(p,1510,520,6,"python","server","Hand off to generation",["SQL KPIs, chunks, or peers","Select matching synthesize_*","Router packages the final reply"],"Python · app.generation",w=340)
    for points in ["416,555 467,555","841,555 900,555 900,375 967,375","900,555 900,625 967,625","900,625 900,875 967,875","1341,375 1420,375 1420,625 1502,625","1341,625 1414,625","1341,875 1420,875 1420,625"]:wire(p,points)
    p += [text(70,750,"ONE SELECTED EVIDENCE ROUTE",18,"#D5B77C",700),
          text(70,790,"Exactly one route executes per question.",23,MUTED),
          text(70,832,"Unknown routes fall back to hybrid search.",22,MUTED),
          text(70,1008,"Current interface: backend Python / CLI. Flutter chat still generates local responses; no chat HTTP or SSE route is wired.",21,MUTED)]
    save("retrieval","retrieval-overview",p)


def hybrid_retrieval():
    p=start("Hybrid retrieval: meaning + exact keywords","The analyst route asks each retriever for 3 candidates, fuses rankings, and returns up to 3 evidence chunks.","02","retrieval")
    boundary(p,555,228,435,685,"CANDIDATE RETRIEVAL","langchain","#A3C1AC")
    boundary(p,1065,428,420,285,"RANK FUSION","langchain","#BAA0C6")
    card(p,70,470,1,"typesafe","client","Question + ticker scope",["Classifier supplies intent + tags","Ticker filters both retrievers","Domain is retained as metadata"],"TypeSafe Jev + Python",w=350)
    card(p,580,300,2,"chroma","data","Find semantic matches",["Embed query with OpenAI","text-embedding-3-small · 512-dim","Chroma retriever: k=3"],"Chroma + OpenAI",w=385)
    card(p,580,650,3,"langchain","data","Find keyword matches",["Filter the saved document corpus","BM25Retriever: k=3","Rank lexical term matches"],"LangChain · BM25",w=385)
    card(p,1090,475,4,"langchain","rag","Fuse the ranked lists",["EnsembleRetriever","Weights = [0.5, 0.5]; RRF c=60","Deduplicate by page_content"],"LangChain · Weighted RRF",w=370)
    card(p,1530,475,5,"python","server","Return cited evidence",["Take fused results [:3]","Text + source metadata","[Page - X, Section - Y]"],"Python · search_filings")
    for points in ["426,575 500,575 500,405 572,405","500,575 500,755 572,755","971,405 1025,405 1025,580 1082,580","971,755 1025,755 1025,580","1466,580 1522,580"]:wire(p,points)
    panel(p,70,928,1780,104,"FILTERS & FALLBACK",["Normal hybrid path filters ticker only. On engine.search failure, BM25 fallback also applies financial_domain if provided."],kind="server")
    p += [text(70,1064,"No cross-encoder reranker is called. Direct HybridEngine.search defaults to k=5; the analyst router overrides it to k=3.",19,MUTED)]
    save("retrieval","retrieval-hybrid",p)


def generation_routes():
    p=start("From retrieved evidence to an answer","Each retrieval route selects its own synthesis function; peer comparison always uses a deterministic table.","01","generation")
    boundary(p,955,227,400,244,"SQL SYNTHESIS","openai","#D5B77C")
    boundary(p,955,477,400,244,"RAG SYNTHESIS","openai","#BAA0C6")
    boundary(p,955,727,400,244,"TABLE FORMATTER","python","#A3C1AC")
    card(p,70,450,1,"python","client","Receive retrieved data",["Question + selected route","SQL record, chunks, or peers","Produced by the retrieval router"],"Python · Retrieval output",w=340)
    card(p,475,450,2,"python","server","Dispatch the generator",["synthesize_sql_kpi","synthesize_hybrid_rag","synthesize_comparison"],"Python · app.generation",w=360)
    card(p,975,270,3,"openai","server","Describe exact SQL figures",["Prompt contains selected KPIs","gpt-4o-mini or template fallback","Return a Markdown summary"],"OpenAI + Python",w=360,h=180,compact=True)
    card(p,975,520,4,"openai","rag","Answer from filing excerpts",["Prompt includes cited chunks","gpt-4o-mini or snippet fallback","Inline page / section citations"],"OpenAI + LangChain",w=360,h=180,compact=True)
    card(p,975,770,5,"python","data","Build a peer metric table",["Formats the company dictionaries","Markdown comparison table","No LLM call on this path"],"Python · Deterministic",w=360,h=180,compact=True)
    card(p,1510,520,6,"python","server","Return the final response",["answer + route_used + query","citations + ticker + domain","raw_data from retrieval"],"Python · AnalystResponse",w=340)
    for points in ["416,555 467,555","841,555 900,555 900,375 967,375","900,555 900,625 967,625","900,625 900,875 967,875","1341,375 1420,375 1420,625 1502,625","1341,625 1414,625","1341,875 1420,875 1420,625"]:wire(p,points)
    p += [text(70,750,"LIVE OR DETERMINISTIC OUTPUT",18,"#D5B77C",700),text(70,790,"SQL / RAG: ChatOpenAI.invoke(), temperature=0.",21,MUTED),
          text(70,830,"mock=True, no model, or invoke error → template.",21,MUTED),
          text(70,1008,"The functions return answer strings. The retrieval router adds metadata; no token streaming or citation validator runs here.",21,MUTED)]
    save("generation","generation-overview",p)


def grounded_generation():
    p=start("RAG generation: keep evidence in the prompt","The live narrative path uses retrieved excerpts and inline citation labels to guide a grounded answer.","02","generation")
    xs=[70,435,800,1165,1530]
    boundary(p,420,253,715,278,"PROMPT & MODEL","openai","#D5B77C")
    boundary(p,1150,253,715,278,"ANSWER & RESPONSE","python","#A3C1AC")
    steps=[
        ("python","Receive cited chunks",["query + retrieved chunk payloads","text, page, domain, citation","Empty input → no-evidence notice"],"Python · Retrieval"),
        ("langchain","Assemble the prompt",["Question + Source [citation]","Join excerpts with separators","Use ONLY supplied evidence"],"LangChain · Messages"),
        ("openai","Generate the answer",["ChatOpenAI: gpt-4o-mini","temperature=0.0; invoke()","System + Human messages"],"OpenAI"),
        ("python","Return model content",["resp.content becomes answer","No post-generation validation","Complete string, no SSE tokens"],"Python · Generation"),
        ("python","Package the response",["Router adds the retrieved chunks","route_used = hybrid_rag","AnalystResponse to Python caller"],"Python · Router"),
    ]
    for i,(brand,title,lines,vendor) in enumerate(steps):card(p,xs[i],300,i+1,brand,"rag",title,lines,vendor)
    for i in range(4):arrow(p,xs[i]+326,405,xs[i+1]-8,405)
    panel(p,70,590,855,285,"CITATION INSTRUCTION",[
        "Every key factual claim should cite its excerpt:",
        "[Page - X, Section - Y]",
        "The prompt requests this format; code does not verify",
        "citation correctness or detect unsupported claims.",
    ],brand="langchain",kind="rag")
    panel(p,965,590,885,285,"DETERMINISTIC FALLBACK",[
        "Used for mock mode, missing model, or invoke failure.",
        "Format the first 280 characters of each excerpt",
        "as a bullet, retaining its citation label.",
        "This is excerpt formatting, not a live LLM answer.",
    ],brand="python",kind="data")
    p += [text(70,958,"The comparison path bypasses this LLM flow entirely. SQL synthesis uses a separate exact-figures prompt.",22,MUTED),
          text(70,1003,"The backend result is available through Python / CLI; Flutter's current chat widget is not connected to these functions.",21,MUTED)]
    save("generation","generation-grounded",p)


if __name__ == "__main__":
    art.overview();art.response_indexing();art.rag_preparation();art.indexing();art.manifest()
    retrieval_routes();hybrid_retrieval();generation_routes();grounded_generation()
    groups=[
        {"pipeline":"ingestion","slides":["ingestion-overview","ingestion-response-indexing","ingestion-rag-preparation","ingestion-indexing"]},
        {"pipeline":"retrieval","slides":["retrieval-overview","retrieval-hybrid"]},
        {"pipeline":"generation","slides":["generation-overview","generation-grounded"]},
    ]
    (HERE/"slides.json").write_text(json.dumps(groups,indent=2)+'\n')
    print("Built 8 SVGs: ingestion (4), retrieval (2), generation (2).")
