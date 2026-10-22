import json
import tempfile
import unittest
from datetime import date
from pathlib import Path
from unittest.mock import patch

from langchain_core.messages import AIMessage, HumanMessage, ToolMessage
from langgraph.types import Interrupt

import json_utils


class ToJsonTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.data_dir = Path(directory.name) / ".data"
        data_dir_patch = patch.object(json_utils, "DATA_DIR", self.data_dir)
        data_dir_patch.start()
        self.addCleanup(data_dir_patch.stop)

    def test_saves_messages_tool_calls_and_interrupts_as_nested_json(self):
        result = {
            "messages": [
                HumanMessage(content="Leave request — tomorrow"),
                AIMessage(
                    content="",
                    tool_calls=[{
                        "name": "get_time_off_balance",
                        "args": {"user_id": "1"},
                        "id": "balance-call",
                        "type": "tool_call",
                    }],
                    response_metadata={"model_name": "example-model"},
                ),
                ToolMessage(content="10", tool_call_id="balance-call"),
            ],
            "__interrupt__": [Interrupt(value={"question": "Start date?"}, id="pause-1")],
            "requested_date": date(2026, 10, 23),
        }

        path = json_utils.toJson(result)
        text = path.read_text(encoding="utf-8")
        saved = json.loads(text)

        self.assertEqual(path, self.data_dir / "agent_result.json")
        self.assertEqual(saved["messages"][0]["content"], "Leave request — tomorrow")
        self.assertEqual(saved["messages"][1]["tool_calls"][0]["args"], {"user_id": "1"})
        self.assertEqual(saved["messages"][1]["response_metadata"]["model_name"], "example-model")
        self.assertEqual(saved["messages"][2]["tool_call_id"], "balance-call")
        self.assertEqual(saved["__interrupt__"][0]["value"], {"question": "Start date?"})
        self.assertEqual(saved["__interrupt__"][0]["id"], "pause-1")
        self.assertEqual(saved["requested_date"], "2026-10-23")
        self.assertIn("Leave request — tomorrow", text)
        self.assertIn('\n  "messages": [', text)

    def test_failed_serialization_preserves_existing_export(self):
        path = json_utils.toJson({"status": "saved"}, "result.json")

        for invalid in [object(), float("nan")]:
            with self.subTest(value_type=type(invalid).__name__):
                with self.assertRaises((TypeError, ValueError)):
                    json_utils.toJson({"invalid": invalid}, "result.json")
                self.assertEqual(json.loads(path.read_text()), {"status": "saved"})

    def test_rejects_paths_outside_the_data_folder(self):
        for filename in ["../escape.json", "/tmp/escape.json", "nested/result.json", ""]:
            with self.subTest(filename=filename):
                with self.assertRaises(ValueError):
                    json_utils.toJson({}, filename)


if __name__ == "__main__":
    unittest.main()
