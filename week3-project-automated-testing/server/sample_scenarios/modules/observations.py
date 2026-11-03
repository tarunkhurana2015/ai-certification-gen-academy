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



def summarize_ui_hierarchy(hierarchy_path, max_elements=80, max_text_length=200):
    """Read bounded, visible native attributes from a saved iOS hierarchy.

    Native `name` may be an accessibility identifier or a label fallback. These
    attributes describe the snapshot, not unique locators or proven tappability.
    Truncated fields map attribute names to their original character lengths.
    """
    if max_elements < 1 or max_text_length < 1:
        raise ValueError("UI summary limits must be positive.")
    summary = {
        "status": "unavailable", "source": "native_ios_hierarchy", "elements": [],
        "matching_visible_elements": 0, "returned_elements": 0,
        "element_limit": max_elements, "text_limit": max_text_length,
        "truncated": False, "errors": [],
    }
    if not hierarchy_path:
        summary["errors"].append({"type": "MissingHierarchy", "message": "No valid hierarchy artifact was captured."})
        return summary
    try:
        root = ET.parse(hierarchy_path).getroot()
    except (OSError, ET.ParseError) as error:
        summary["errors"].append({"type": type(error).__name__, "message": str(error)})
        return summary

    def native_bool(value):
        return {"true": True, "false": False}.get(value)

    for node in root.iter():
        attributes = node.attrib
        if native_bool(attributes.get("visible")) is not True:
            continue
        # Ignore anonymous layout containers, retaining named text and controls.
        has_text = any(attributes.get(key) for key in ("name", "label", "value"))
        if not has_text and native_bool(attributes.get("accessible")) is not True:
            continue
        summary["matching_visible_elements"] += 1
        if len(summary["elements"]) >= max_elements:
            summary["truncated"] = True
            continue
        element = {
            "type": attributes.get("type", node.tag),
            "name": None, "label": None, "value": None,
            "visible": True,
            "enabled": native_bool(attributes.get("enabled")),
            "accessible": native_bool(attributes.get("accessible")),
        }
        truncated_fields = {}
        for key in ("name", "label", "value"):
            value = attributes.get(key)
            if value is not None and len(value) > max_text_length:
                truncated_fields[key] = len(value)
                value = value[:max_text_length]
                summary["truncated"] = True
            element[key] = value
        if truncated_fields:
            element["truncated_fields"] = truncated_fields
        summary["elements"].append(element)
    summary["status"] = "available"
    summary["returned_elements"] = len(summary["elements"])
    return summary


def observe_session_ui(session):
    """Capture a host-owned active session, rejecting closed or changed sessions."""
    if not session.active:
        raise RuntimeError("This session is inactive. Start a new session before observing.")
    if session.driver.session_id != session.session_id:
        raise RuntimeError("The driver session changed. Start a new session before observing.")
    receipt = observe_ui(session.driver, session.artifact_root)
    hierarchy = receipt.get("artifacts", {}).get("hierarchy", {})
    path = hierarchy.get("path") if hierarchy.get("valid") is True else None
    # Read the XML already captured; do not issue a second device source request.
    receipt["ui_summary"] = summarize_ui_hierarchy(path)
    if receipt.get("manifest_path"):
        _persist_ui_receipt(receipt)
    return receipt
