"""Native UI capture and receipts; importing this module performs no observation."""

import json
from pathlib import Path
from datetime import datetime, timezone
import tempfile
import xml.etree.ElementTree as ET

def _ui_receipt(driver, operation):
    return {"operation": operation, "session_id": driver.session_id,
            "started_at": datetime.now(timezone.utc).isoformat(), "errors": []}

def _record_error(receipt, stage, error):
    receipt["errors"].append({"stage": stage, "type": type(error).__name__, "message": str(error)})

def _receipt_folder(artifact_root, prefix):
    root = Path(artifact_root)
    root.mkdir(parents=True, exist_ok=True)
    return Path(tempfile.mkdtemp(prefix=prefix, dir=root))

def _persist_ui_receipt(receipt):
    receipt["receipt_persisted"] = True
    receipt["recorded_at"] = datetime.now(timezone.utc).isoformat()
    temporary_path = None
    try:
        destination = Path(receipt["manifest_path"])
        with tempfile.NamedTemporaryFile(dir=destination.parent, prefix=".receipt-", suffix=".tmp",
                                         delete=False) as temporary:
            temporary_path = Path(temporary.name)
        temporary_path.write_text(json.dumps(receipt, indent=2), encoding="utf-8")
        temporary_path.replace(destination)  # Atomic update keeps an earlier valid intent on write failure.
        return True
    except OSError as error:
        receipt["receipt_persisted"] = False
        _record_error(receipt, "record_receipt", error)
        return False
    finally:
        if temporary_path is not None:
            try:
                temporary_path.unlink(missing_ok=True)
            except OSError:
                pass

def observe_ui(driver, artifact_root):
    receipt = _ui_receipt(driver, "observe_ui")
    receipt.update(status="failed", artifacts={}, receipt_persisted=False)
    try:
        folder = _receipt_folder(artifact_root, "observe-")
    except OSError as error:
        _record_error(receipt, "create_artifact_folder", error)
        return receipt
    receipt["manifest_path"] = str(folder / "manifest.json")
    try:
        started = datetime.now(timezone.utc).isoformat()
        xml_text = driver.page_source
        completed = datetime.now(timezone.utc).isoformat()
        path = folder / "hierarchy.xml"
        path.write_text(xml_text, encoding="utf-8")
        receipt["artifacts"]["hierarchy"] = {
            "path": str(path), "started_at": started, "completed_at": completed, "valid": False,
        }
        ET.fromstring(xml_text)
        receipt["artifacts"]["hierarchy"]["valid"] = True
    except Exception as error:
        _record_error(receipt, "capture_hierarchy", error)
    try:
        started = datetime.now(timezone.utc).isoformat()
        png = driver.get_screenshot_as_png()
        completed = datetime.now(timezone.utc).isoformat()
        path = folder / "screen.png"
        path.write_bytes(png)
        receipt["artifacts"]["screenshot"] = {
            "path": str(path), "started_at": started, "completed_at": completed, "valid": False,
        }
        if not png.startswith(b"\x89PNG\r\n\x1a\n"):
            raise ValueError("The screenshot response was not PNG.")
        receipt["artifacts"]["screenshot"]["valid"] = True
    except Exception as error:
        _record_error(receipt, "capture_screenshot", error)
    valid_count = sum(artifact["valid"] for artifact in receipt["artifacts"].values())
    receipt["status"] = "complete" if valid_count == 2 else "partial" if valid_count else "failed"
    receipt["completed_at"] = datetime.now(timezone.utc).isoformat()
    _persist_ui_receipt(receipt)
    return receipt


def observe_session_ui(session):
    """Capture a host-owned active session, rejecting closed or changed sessions."""
    if not session.active:
        raise RuntimeError("This session is inactive. Start a new session before observing.")
    if session.driver.session_id != session.session_id:
        raise RuntimeError("The driver session changed. Start a new session before observing.")
    return observe_ui(session.driver, session.artifact_root)
