"""
Health and readiness probes.

Conforms to ARCHITECTURE.md Section 8 (app/api/v1/endpoints/health.py).
"""

from typing import Dict
from fastapi import APIRouter

router = APIRouter()


@router.get("/health", response_model=Dict[str, str], tags=["health"])
def get_health() -> Dict[str, str]:
    """Liveness probe verifying that the FastAPI server is running."""
    return {
        "status": "healthy",
        "service": "stock-ai-analyzer-api",
        "version": "1.0.0",
    }
