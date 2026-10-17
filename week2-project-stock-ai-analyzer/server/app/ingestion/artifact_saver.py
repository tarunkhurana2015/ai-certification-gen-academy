"""
Artifact Exporter Utility
=========================
Saves intermediate pipeline outputs (extracted text, section domains, chunks)
into the local '.artifact/' directory (ignored by git) for inspection and debugging.
"""

import json
from pathlib import Path
from typing import Any, Union


def get_artifact_dir() -> Path:
    """Returns the .artifact/ directory at the server root, creating it if needed."""
    server_root = Path(__file__).resolve().parent.parent.parent
    artifact_dir = server_root / ".artifact"
    artifact_dir.mkdir(exist_ok=True)
    return artifact_dir


def save_artifact(file_name: str, content: Union[str, dict, list]) -> Path:
    """
    Saves content to the .artifact/ directory with appropriate formatting.

    Args:
        file_name: Target file name (e.g. '01_extracted_meta_q2_2026.json').
        content: String, dict, or list to be written.

    Returns:
        Absolute Path to the written artifact.
    """
    out_path = get_artifact_dir() / file_name
    if isinstance(content, (dict, list)):
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(content, f, indent=2, ensure_ascii=False)
    else:
        with open(out_path, "w", encoding="utf-8") as f:
            f.write(str(content))
    return out_path
