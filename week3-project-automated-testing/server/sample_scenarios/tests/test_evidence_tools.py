"""Offline contract checks for evidence tools; no driver or model is needed."""
import base64
import importlib
import json
from pathlib import Path
import sys
import tempfile
from threading import RLock
from types import SimpleNamespace
import unittest


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

PNG = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII="
)


class OfflineRuntime:
    """Keep real saved fixture evidence while making device use impossible."""

    def __init__(self, root):
        self.session = SimpleNamespace(session_id="session-1", artifact_root=root)
        self.observations = {}
        self.lock = RLock()
        self.last_observation_id = None
        self.active = True
        self.records = []

    def require_active(self):
        if not self.active:
            raise RuntimeError("The session is inactive.")

    def record(self, receipt):
        receipt = dict(receipt, receipt_id=f"receipt-{len(self.records) + 1}")
        self.records.append(receipt)
        return receipt

    def blocked(self, operation, reason):
        return self.record({"operation": operation, "status": "BLOCKED", "reason": reason})

    def capture(self, observation_id, xml=None, png=PNG, **changes):
        folder = self.session.artifact_root / observation_id
        folder.mkdir()
        hierarchy = folder / "hierarchy.xml"
        hierarchy.write_text(xml or native_xml(), encoding="utf-8")
        screenshot = folder / "screen.png"
        screenshot.write_bytes(png)
        receipt = {
            "observation_id": observation_id, "session_id": "session-1",
            "status": "complete", "receipt_persisted": True,
            "manifest_path": str(folder / "manifest.json"),
            "artifacts": {
                "hierarchy": {"path": str(hierarchy), "valid": True},
                "screenshot": {"path": str(screenshot), "valid": True},
            },
            # Deliberately incomplete: assertions must consult the full XML.
            "ui_summary": {"truncated": True, "elements": []},
        }
        receipt.update(changes)
        self.observations[observation_id] = receipt
        self.last_observation_id = observation_id
        return receipt


def native_xml(value="0", duplicate=False, missing=False):
    attributes = 'name="favorite" label="Favorite" type="XCUIElementTypeButton" visible="true"'
    if not missing:
        attributes += f' value="{value}"'
    node = f"<XCUIElementTypeButton {attributes}/>"
    return ('<AppiumAUT><XCUIElementTypeApplication type="XCUIElementTypeApplication">'
            + node + (node if duplicate else "")
            + "</XCUIElementTypeApplication></AppiumAUT>")


def invoke(name, runtime, **arguments):
    module = importlib.import_module(f"tools.{name}")
    return module.build_tool(runtime).invoke(arguments)


class EvidenceToolTests(unittest.TestCase):
    """Exercise every evidence boundary with standard-library test fixtures."""

    def setUp(self):
        self.fixture_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.fixture_directory.cleanup)

    def _runtime(self):
        root = Path(tempfile.mkdtemp(dir=self.fixture_directory.name)).resolve()
        runtime = OfflineRuntime(root)
        runtime.capture("before")
        return runtime

    def test_assert_uses_full_xml_and_preserves_explicit_zero(self):
        runtime = self._runtime()
        result = invoke("assert_ui", runtime, observation_id="before", native_name="favorite",
                        attribute="value", expected="0")
        self.assertEqual(result["status"], "PASS")
        self.assertEqual(result["observed"]["value"], "0")
        self.assertEqual(runtime.records[-1], result)

    def test_assert_evaluates_explicit_evidence(self):
        cases = [
            ({"expected": "true"}, "PASS"),
            ({"expected": "false"}, "FAIL"),
            ({"attribute": "label", "operator": "contains", "expected": "vor"}, "PASS"),
            ({"operator": "exists"}, "PASS"),
            ({"native_name": "missing", "operator": "absent"}, "PASS"),
            ({"native_name": "missing", "operator": "exists"}, "FAIL"),
            ({"operator": "absent"}, "FAIL"),
        ]
        for options, status in cases:
            with self.subTest(options=options):
                arguments = {"observation_id": "before", "native_name": "favorite"}
                arguments.update(options)
                self.assertEqual(invoke("assert_ui", self._runtime(), **arguments)["status"], status)

    def test_assert_blocks_missing_identity_or_evidence(self):
        cases = [
            {"native_name": "", "native_type": "XCUIElementTypeButton"},
            {"observation_id": "unknown"},
            {"attribute": "selected"},
            {"operator": "count_equals", "expected": "-1"},
        ]
        for options in cases:
            with self.subTest(options=options):
                arguments = {"observation_id": "before", "native_name": "favorite"}
                arguments.update(options)
                self.assertEqual(invoke("assert_ui", self._runtime(), **arguments)["status"], "BLOCKED")

    def test_assert_blocks_duplicates_except_explicit_count(self):
        runtime = self._runtime()
        runtime.capture("duplicates", native_xml(duplicate=True))
        self.assertEqual(invoke("assert_ui", runtime, observation_id="duplicates", native_name="favorite")["status"], "BLOCKED")
        self.assertEqual(invoke("assert_ui", runtime, observation_id="duplicates", native_name="favorite",
                                operator="count_equals", expected="2")["status"], "PASS")

    def test_absence_requires_recognized_full_native_application(self):
        runtime = self._runtime()
        runtime.capture("fragment", '<XCUIElementTypeButton name="favorite" visible="true"/>')
        result = invoke("assert_ui", runtime, observation_id="fragment", native_name="missing", operator="absent")
        self.assertEqual(result["status"], "BLOCKED")

    def test_assert_blocks_untrusted_saved_evidence(self):
        for change in ("session", "invalid", "unsupported_encoding", "missing", "escape", "inactive"):
            with self.subTest(change=change):
                runtime = self._runtime()
                receipt = runtime.observations["before"]
                artifact = receipt["artifacts"]["hierarchy"]
                if change == "session":
                    receipt["session_id"] = "another-session"
                elif change == "invalid":
                    Path(artifact["path"]).write_text("<broken>", encoding="utf-8")
                elif change == "unsupported_encoding":
                    Path(artifact["path"]).write_text('<?xml version="1.0" encoding="not-a-real-encoding"?>' + native_xml(), encoding="utf-8")
                elif change == "missing":
                    Path(artifact["path"]).unlink()
                elif change == "escape":
                    artifact["path"] = str(runtime.session.artifact_root.parent / "outside.xml")
                else:
                    runtime.active = False
                self.assertEqual(invoke("assert_ui", runtime, observation_id="before", native_name="favorite")["status"], "BLOCKED")

    def test_compare_uses_explicit_saved_values_for_changed_and_unchanged(self):
        runtime = self._runtime()
        runtime.capture("after", native_xml(value="1"))
        result = invoke("compare_observations", runtime, before_id="before", after_id="after",
                        native_name="favorite", attribute="value", relation="changed")
        self.assertEqual(result["status"], "PASS")
        self.assertEqual(result["observed"], {"before": "0", "after": "1"})
        result = invoke("compare_observations", runtime, before_id="before", after_id="after",
                        native_name="favorite", attribute="visible")
        self.assertEqual(result["status"], "PASS")
        result = invoke("compare_observations", runtime, before_id="before", after_id="after",
                        native_name="favorite", attribute="value")
        self.assertEqual(result["status"], "FAIL")

    def test_compare_blocks_reusing_one_capture_as_two_observations(self):
        result = invoke("compare_observations", self._runtime(), before_id="before", after_id="before",
                        native_name="favorite", attribute="value")
        self.assertEqual(result["status"], "BLOCKED")

    def test_compare_blocks_two_ids_aliasing_one_saved_hierarchy(self):
        runtime = self._runtime()
        after = runtime.capture("after")
        after["artifacts"]["hierarchy"] = dict(runtime.observations["before"]["artifacts"]["hierarchy"])
        result = invoke("compare_observations", runtime, before_id="before", after_id="after",
                        native_name="favorite", attribute="value")
        self.assertEqual(result["status"], "BLOCKED")

    def test_compare_blocks_missing_or_ambiguous_values(self):
        cases = [native_xml(missing=True), native_xml(duplicate=True),
                 '<AppiumAUT><XCUIElementTypeApplication/></AppiumAUT>']
        for after_xml in cases:
            with self.subTest(after_xml=after_xml):
                runtime = self._runtime()
                runtime.capture("after", after_xml)
                self.assertEqual(invoke("compare_observations", runtime, before_id="before", after_id="after",
                                        native_name="favorite", attribute="value")["status"], "BLOCKED")

    def test_label_identity_is_supported_without_name_guessing(self):
        result = invoke("assert_ui", self._runtime(), observation_id="before", label="Favorite")
        self.assertEqual(result["status"], "PASS")

    def test_visual_review_returns_registered_image_content_and_recorded_metadata(self):
        runtime = self._runtime()
        module = importlib.import_module("tools.review_visual_evidence")
        message = module.build_tool(runtime).invoke({"type": "tool_call", "id": "review-call",
                                                   "name": "review_visual_evidence",
                                                   "args": {"observation_id": "before"}})
        self.assertEqual(message.artifact["status"], "REVIEW_REQUIRED")
        self.assertEqual(message.artifact["assessment_source"], "calling_model")
        self.assertEqual(runtime.records[-1], message.artifact)
        image = next(block for block in message.content if block["type"] == "image")
        self.assertEqual(image["mime_type"], "image/png")
        self.assertEqual(base64.b64decode(image["base64"]), PNG)
        self.assertEqual(message.artifact["evidence"]["screenshot"], runtime.observations["before"]["artifacts"]["screenshot"]["path"])
        self.assertNotIn("data", json.dumps(message.artifact))

    def test_visual_review_blocks_unknown_oversized_or_invalid_images(self):
        for problem in ("unknown", "too_large", "invalid", "truncated_png", "corrupt_png", "mismatch"):
            with self.subTest(problem=problem):
                runtime = self._runtime()
                arguments = {"observation_id": "before"}
                screenshot = Path(runtime.observations["before"]["artifacts"]["screenshot"]["path"])
                if problem == "unknown":
                    arguments["observation_id"] = "/tmp/model-selected.png"
                elif problem == "too_large":
                    screenshot.write_bytes(PNG + b"x" * (2 * 1024 * 1024))
                elif problem == "invalid":
                    screenshot.write_bytes(b"not an image")
                elif problem == "truncated_png":
                    screenshot.write_bytes(PNG[:20])
                elif problem == "corrupt_png":
                    screenshot.write_bytes(PNG[:52] + b"\x00" + PNG[53:])
                else:
                    runtime.observations["before"]["session_id"] = "other"
                result = invoke("review_visual_evidence", runtime, **arguments)
                self.assertIsInstance(result, list)
                self.assertEqual(json.loads(result[0]["text"])["status"], "BLOCKED")

    def test_tool_schemas_expose_only_evidence_inputs(self):
        runtime = self._runtime()
        forbidden = {"path", "artifact_root", "session_id", "driver", "case_id", "api_key", "app_data"}
        for name in ("assert_ui", "compare_observations", "review_visual_evidence"):
            with self.subTest(tool=name):
                schema = importlib.import_module(f"tools.{name}").build_tool(runtime).args
                self.assertFalse(forbidden.intersection(schema))


if __name__ == "__main__":
    unittest.main()
