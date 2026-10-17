"""
Root API v1 Router.

Conforms to ARCHITECTURE.md Section 8 (app/api/v1/router.py).
Aggregates controllers:
- /health
- /ingestion and /documents
- /kpi
"""

from fastapi import APIRouter

from app.api.v1.endpoints import documents, health, kpis

api_router = APIRouter()

api_router.include_router(health.router)
api_router.include_router(documents.router)
api_router.include_router(kpis.router)
