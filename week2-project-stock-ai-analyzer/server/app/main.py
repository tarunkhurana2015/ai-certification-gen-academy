"""
FastAPI Server Application Entrypoint.

Conforms to ARCHITECTURE.md Section 8 (app/main.py).
Provides:
- FastAPI factory with lifespan database initialization
- Cross-Origin Resource Sharing (CORS) for Flutter client
- Root and Health endpoints
- v1 API Router registration (/api/v1)
"""

import sys
from contextlib import asynccontextmanager
from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Ensure server root is in sys.path
_SERVER_ROOT = Path(__file__).resolve().parent.parent
if str(_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(_SERVER_ROOT))

from app.api.v1.router import api_router
from app.db.session import engine, init_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager that initializes SQLite database tables on startup."""
    init_db(engine)
    yield


app = FastAPI(
    title="Stock AI Financial Analyst API",
    description="High-performance backend for SEC filing ingestion, 18+ GAAP KPI extraction, and hybrid RAG analysis.",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS middleware for Flutter web, macOS desktop, iOS, Android clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Top-level health check
@app.get("/health", tags=["health"])
def root_health():
    """Top-level health check."""
    return {
        "status": "healthy",
        "service": "stock-ai-analyzer-api",
        "version": "1.0.0",
    }


@app.get("/", tags=["root"])
def root_index():
    """Root welcome endpoint with API documentation links."""
    return {
        "message": "Welcome to Stock AI Financial Analyst API",
        "docs_url": "/docs",
        "health_url": "/health",
        "v1_prefix": "/api/v1",
    }


# Mount v1 API Router
app.include_router(api_router, prefix="/api/v1")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
