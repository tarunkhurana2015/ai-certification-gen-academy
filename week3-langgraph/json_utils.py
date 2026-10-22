"""Save notebook results as readable, structured JSON."""

import json
from dataclasses import asdict, is_dataclass
from datetime import date, datetime
from pathlib import Path
from typing import Any

from pydantic import BaseModel


DATA_DIR = Path(__file__).resolve().parent / ".data"


def _json_default(value: Any) -> Any:
    if isinstance(value, BaseModel):
        return value.model_dump(mode="json")
    if is_dataclass(value) and not isinstance(value, type):
        return asdict(value)
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    raise TypeError(f"Object of type {type(value).__name__} is not JSON serializable")


def toJson(result: Any, filename: str = "agent_result.json") -> Path:
    """Save a result under this project's .data folder and return its path.

    LangChain messages and LangGraph interrupts retain their nested fields.
    Dates use ISO format. The same filename is overwritten on subsequent calls.
    """
    if Path(filename).name != filename or Path(filename).suffix.lower() != ".json":
        raise ValueError("filename must be a plain JSON filename, such as 'result.json'")

    # Serialize first so unsupported values cannot truncate an existing export.
    text = json.dumps(
        result,
        default=_json_default,
        indent=2,
        ensure_ascii=False,
        allow_nan=False,
    )
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    output_path = DATA_DIR / filename
    output_path.write_text(text + "\n", encoding="utf-8")
    return output_path
