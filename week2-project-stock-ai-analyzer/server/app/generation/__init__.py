"""
Generation package for response synthesis and markdown reports.
"""

from app.generation.generation import (
    synthesize_comparison,
    synthesize_hybrid_rag,
    synthesize_sql_kpi,
)

__all__ = [
    "synthesize_sql_kpi",
    "synthesize_hybrid_rag",
    "synthesize_comparison",
]
