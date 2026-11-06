"""Readable local notebook output; never changes model inputs or saved JSON reports."""
from html import escape
import json
import re
import textwrap


def format_multiline(value, *, width=100, include_image_payloads=False):
    """Format all fields/messages as indented text, wrapping long text values.

    Tool-message JSON content is expanded for inspection. Human/AI text retains
    its existing newlines; wrapping only affects this returned display string.
    Image bytes are explicitly summarized unless include_image_payloads=True.
    """
    if not isinstance(width, int) or isinstance(width, bool) or width < 40:
        raise ValueError("Display width must be an integer of at least 40.")
    lines = []

    def add_text(text, indent):
        # Wrap each existing line separately, preserving paragraph breaks and
        # spaces rather than flattening the entire answer into one long line.
        prefix = " " * indent
        for line in text.split("\n"):
            wrapped = textwrap.wrap(
                line, width=max(10, width - indent),
                expand_tabs=False, replace_whitespace=False, drop_whitespace=False,
                break_long_words=True, break_on_hyphens=False,
            )
            lines.extend(prefix + part for part in (wrapped or [""]))

    def render(item, indent=0, image_context=False):
        # LangChain messages are Pydantic objects. model_dump includes content,
        # IDs, tool calls, artifacts, and usage/response metadata in a new dict.
        if callable(getattr(item, "model_dump", None)):
            is_tool_message = getattr(item, "type", None) == "tool"
            item = item.model_dump(mode="python")
            if is_tool_message and isinstance(item.get("content"), str):
                # Decode JSON only for tool content, never a human's literal text.
                try:
                    parsed = json.loads(item["content"])
                    if isinstance(parsed, (dict, list)):
                        item["content"] = parsed
                except (TypeError, ValueError):
                    pass

        if isinstance(item, dict):
            if not item:
                add_text("{}", indent)
            kind = item.get("type")
            image_context = image_context or (isinstance(kind, str) and kind in {
                "image", "image_url", "input_image", "image_base64",
            })
            for key, child in item.items():
                add_text(f"{key}:", indent)
                # Keep the image block and artifact references visible while
                # avoiding pages of encoded bytes in the normal text inspection.
                if (not include_image_payloads and image_context
                        and key in {"base64", "data"} and isinstance(child, str)):
                    child = f"[Image payload omitted: {len(child)} characters; retained in agent_result.]"
                render(child, indent + 2, image_context)
        elif isinstance(item, (list, tuple)):
            if not item:
                add_text("[]", indent)
            for index, child in enumerate(item, start=1):
                role = getattr(child, "type", None)
                label = f"[{index}] {role.upper()} message" if isinstance(role, str) else f"[{index}]"
                add_text(label, indent)
                render(child, indent + 2, image_context)
        elif isinstance(item, str):
            if not include_image_payloads and item.startswith("data:image/"):
                item = f"[Image data URL omitted: {len(item)} characters; retained in agent_result.]"
            add_text(item if item else '""', indent)
        else:
            # None, booleans, and numbers have clear JSON spellings. Unusual
            # metadata types such as dates fall back to their string form.
            add_text(json.dumps(item, ensure_ascii=False, default=str), indent)

    render(value)
    return "\n".join(lines)


def print_multiline(value, *, title=None, width=100, include_image_payloads=False):
    """Print a titled text/structured value using the same notebook formatting."""
    if title:
        print(f"\n{title}:\n")
    print(format_multiline(value, width=width, include_image_payloads=include_image_payloads))


def _conversation_text(content):
    """Keep visible text; tool-call blocks are shown separately as actual calls."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, str):
                parts.append(block)
            elif isinstance(block, dict) and block.get("type") in {"text", "output_text", "input_text"}:
                if isinstance(block.get("text"), str):
                    parts.append(block["text"])
            elif isinstance(block, dict) and block.get("type") == "refusal":
                parts.append(str(block.get("refusal", "")))
        return "\n".join(parts)
    return ""


def _tool_payload(content, artifact=None):
    """Read structured tool output for display without changing its messages."""
    if isinstance(content, dict):
        return content
    text = _conversation_text(content)
    try:
        parsed = json.loads(text)
        if isinstance(parsed, dict):
            return parsed
    except (TypeError, ValueError):
        pass
    # Screenshot tools return text + image blocks and a separate receipt artifact.
    if isinstance(artifact, dict) and artifact.get("status"):
        return artifact
    return {"output": text or "Image/non-text content returned; see full trace."}


def _brief_tool_result(payload, max_ui_elements):
    """Keep outcomes and a small UI preview; leave raw evidence in the full trace."""
    result = {}
    for key in ("status", "reason", "condition_met", "expected", "observed",
                "dispatch_result", "entered_value_verified", "keyboard_visible",
                "state", "verified_by_tool", "limitation", "output", "scope", "target",
                "attribute", "relation", "observation_id", "before_id", "after_id", "elapsed_seconds"):
        if key in payload and payload[key] is not None:
            result[key] = payload[key]
    if payload.get("errors"):
        result["errors"] = payload["errors"]
    if payload.get("receipt_persisted") is False:
        result["receipt_persisted"] = False
    for key in ("clear_receipt", "first", "followup"):
        nested = payload.get(key)
        if isinstance(nested, dict):
            result[key] = {field: nested[field] for field in ("status", "reason") if field in nested}
            if nested.get("receipt_persisted") is False:
                result[key]["receipt_persisted"] = False

    # A mutation normally returns a fresh after-observation. Prefer its UI over
    # nested copies of earlier captures/receipts that otherwise flood the output.
    observation = payload
    if isinstance(payload.get("after_observation"), dict):
        observation = payload["after_observation"]
    elif isinstance(payload.get("observation"), dict):
        observation = payload["observation"]
    elif isinstance(payload.get("followup"), dict):
        observation = payload["followup"].get("after_observation", {})
    if observation is not payload:
        after_capture = {key: observation[key] for key in ("status", "reason") if key in observation}
        if observation.get("receipt_persisted") is False:
            after_capture["receipt_persisted"] = False
        if observation.get("errors"):
            after_capture["errors"] = observation["errors"]
        if after_capture:
            result["after_capture"] = after_capture
    if observation.get("active_app"):
        result["active_app"] = observation["active_app"]
    summary = observation.get("ui_summary", {})
    elements = summary.get("elements", []) if isinstance(summary, dict) else []
    if elements:
        # Show actionable controls first, then other visible text. Descriptions
        # can be very long, so this preview is explicitly bounded and labeled.
        interactive = ("Button", "TextField", "SearchField", "TextView", "Cell", "Link", "Switch")
        ordered = sorted(elements, key=lambda e: not str(e.get("type", "")).endswith(interactive))
        preview = []
        for element in ordered[:max_ui_elements]:
            kind = str(element.get("type", "")).removeprefix("XCUIElementType")
            label = str(element.get("label") or element.get("name") or "Unnamed element")
            if len(label) > 140:
                label = label[:140] + "… [label shortened]"
            # Keep the native name distinct from the friendly label and temporary
            # reference. A native name can fall back to a label without an app ID.
            item = {
                "type": kind,
                "label": label,
                "native_name": element.get("name"),
                "element_ref": element.get("element_ref"),
            }
            if element.get("truncated_fields", {}).get("name"):
                item["name_note"] = "Incomplete: shortened in the source observation."
            if element.get("value") is not None:
                value = str(element["value"])
                item["value"] = value if len(value) <= 140 else value[:140] + "… [value shortened]"
            if element.get("enabled") is False:
                item["enabled"] = False
            preview.append(item)
        result["visible_UI_preview"] = preview
        result["UI_preview_note"] = (
            f"Showing {len(preview)} of {len(elements)} returned summary elements. "
            + ("The returned summary was also truncated. " if summary.get("truncated") else "")
            + "Full tool result is in the raw trace."
        )
    elif isinstance(summary, dict) and summary.get("status") == "unavailable":
        result["UI_summary"] = {key: summary[key] for key in ("status", "errors") if key in summary}
    if payload.get("candidates"):
        result["live_data_candidates"] = [
            {key: candidate[key] for key in ("id", "title", "release_date", "collection", "missing_artwork_fields") if key in candidate}
            for candidate in payload["candidates"]
        ]
    if payload.get("operation") == "review_visual_evidence":
        result["visual_evidence"] = "Saved screenshot supplied for model review; image bytes hidden here."
        if isinstance(payload.get("evidence"), dict) and payload["evidence"].get("screenshot"):
            result["screenshot"] = payload["evidence"]["screenshot"]
    for key in ("visible_text", "exposed_urls", "active_app", "source", "search_scope", "app_ui_verified"):
        if key in payload:
            result[key] = payload[key]
    if not result:
        result["note"] = "Structured tool result returned; inspect the raw trace for its fields."
    return result


def _markdown_fence(text, language="text"):
    """Use a fence longer than any backticks inside the actual message text."""
    fence = "`" * max(3, max((len(run) + 1 for run in re.findall(r"`+", text)), default=3))
    return f"{fence}{language}\n{text}\n{fence}"


def _markdown_label(text):
    """Render a UI label as text rather than active HTML or Markdown syntax."""
    return re.sub(r"([\\`*_{}\[\]()#+.!|>~-])", r"\\\1", escape(str(text), quote=False))


def _conversation_value(value, width, markdown):
    """Give the learning view clear labels and compact UI cards in either format."""
    if not isinstance(value, dict):
        text = format_multiline(value, width=width)
        return _markdown_fence(text) if markdown else text
    lines = []
    for key, child in value.items():
        title = key.replace("_", " ").capitalize().replace("Llm", "LLM").replace("Ui ", "UI ").replace(" id", " ID")
        if key == "visible_UI_preview":
            lines.append("**Visible UI**" if markdown else "Visible UI")
            for number, element in enumerate(child, start=1):
                heading = f"{number}. {element['label']} ({element['type']})"
                lines.append(f"**{_markdown_label(heading)}**" if markdown else heading)
                # Do not manufacture an ID for anonymous/native-label-only elements.
                native_name = element.get("native_name")
                fields = {
                    "Native name (semantics ID when exposed)": native_name if native_name else "Not exposed",
                    "Reference": element.get("element_ref") or "Not available",
                }
                if element.get("name_note"):
                    fields["Name note"] = element["name_note"]
                if "value" in element:
                    fields["Value"] = json.dumps(element["value"], ensure_ascii=False)
                if element.get("enabled") is False:
                    fields["Enabled"] = "false (disabled)"
                details = "\n".join(f"{label}: {item}" for label, item in fields.items())
                wrapped = format_multiline(details, width=width)
                lines.append(_markdown_fence(wrapped) if markdown else textwrap.indent(wrapped, "  "))
        elif isinstance(child, (dict, list)):
            # JSON preserves literal spaces/quotes in expectations and observations.
            lines.append(f"**{title}**" if markdown else title + ":")
            text = json.dumps(child, indent=2, ensure_ascii=False, default=str)
            lines.append(_markdown_fence(format_multiline(text, width=width), "json") if markdown
                         else textwrap.indent(format_multiline(text, width=width - 2), "  "))
        else:
            text = child if isinstance(child, str) else json.dumps(child, ensure_ascii=False)
            line = f"{title}: {text}"
            if markdown:
                # Complex text stays in a literal block; ordinary statuses fit inline.
                if "\n" not in text and len(text) < 70 and not re.search(r"[<>`*_\[\]{}|]", text):
                    lines.append(f"**{title}:** {_markdown_label(text)}")
                else:
                    lines.append(f"**{title}**\n\n" + _markdown_fence(format_multiline(text, width=width)))
            else:
                lines.append(format_multiline(line, width=width))
    return ("\n\n" if markdown else "\n").join(lines)


def format_conversation(agent_result, *, width=100, max_ui_elements=5,
                        runtime_receipts=None, error_type=None, output_format="text"):
    """Show every recorded turn, actual tool choice, and concise tool outcomes.

    Keeps full human/AI text and tool arguments. Omits provider IDs, repeated
    capture data, empty metadata, and image bytes. This is the recorded exchange,
    not an explanation of the model's private internal reasoning. Markdown mode
    renders headings/UI cards; the default text mode remains available.
    """
    if output_format not in {"text", "markdown"}:
        raise ValueError("Conversation format must be text or markdown.")
    markdown = output_format == "markdown"
    if not isinstance(max_ui_elements, int) or isinstance(max_ui_elements, bool) or max_ui_elements < 1:
        raise ValueError("UI preview size must be a positive integer.")
    messages = (agent_result or {}).get("messages", [])
    output = []
    calls = {}
    tool_names = []
    usage = []
    ai_count = tool_count = call_count = 0

    def add(value):
        output.append(_conversation_value(value, width, markdown))

    def heading(title):
        output.append("\n### " + _markdown_label(title) if markdown else "\n" + title)

    if not messages:
        output.append("No completed conversation is available. Retained tool evidence is partial.")
        if error_type:
            add({"execution_error": error_type})
        # Observation wrappers repeat capture receipts; use the action/check journal.
        for receipt in runtime_receipts or []:
            heading("TOOL EVIDENCE — " + receipt.get("operation", "unknown"))
            add(_brief_tool_result(receipt, max_ui_elements))
        return ("\n\n" if markdown else "\n").join(output)

    for index, original in enumerate(messages, start=1):
        message = original.model_dump(mode="python") if callable(getattr(original, "model_dump", None)) else original
        role = message.get("type", message.get("role", "unknown"))
        content = message.get("content", "")
        if role in {"ai", "assistant"}:
            ai_count += 1
            usage.append(message.get("usage_metadata"))
            heading(f"{index}. LLM")
            text = _conversation_text(content)
            if text:
                add(text)  # Keep all visible model text, including the final answer.
            metadata = message.get("response_metadata") or {}
            completion = {}
            if metadata.get("finish_reason") not in (None, "stop", "tool_calls"):
                completion["finish_reason"] = metadata["finish_reason"]
            if metadata.get("status") in {"incomplete", "failed", "cancelled"}:
                completion["status"] = metadata["status"]
            if metadata.get("incomplete_details"):
                completion["incomplete_details"] = metadata["incomplete_details"]
            if completion:
                add({"completion_issue": completion})
            requested = message.get("tool_calls", [])
            for call in requested:
                call_count += 1
                name = call.get("name", "unknown")
                calls[call.get("id")] = (call_count, name)
                tool_names.append(name)
                title = f"Tool call {call_count}: {name}"
                output.append(f"**{_markdown_label(title)}**" if markdown else title)
                output.append("**Arguments**" if markdown else "Arguments:")
                # Quotes make literal leading/trailing spaces in text arguments visible.
                arguments = json.dumps(call.get("args", {}), indent=2, ensure_ascii=False, default=str)
                output.append(_markdown_fence(arguments, "json") if markdown else format_multiline(arguments, width=width))
            for invalid in message.get("invalid_tool_calls", []):
                add({"invalid_tool_call": invalid})
            if not text and not requested and not message.get("invalid_tool_calls"):
                output.append("No visible text or tool call was returned.")
        elif role == "tool":
            tool_count += 1
            number, name = calls.get(message.get("tool_call_id"), (None, message.get("name") or "unknown"))
            label = f"call {number}: {name}" if number is not None else name
            heading(f"{index}. TOOL RESULT — {label}")
            if message.get("status") == "error":
                add({"tool_execution_status": "error"})
            payload = _tool_payload(content, message.get("artifact"))
            add(_brief_tool_result(payload, max_ui_elements))
        else:
            heading(f"{index}. {role.upper()}")
            add(_conversation_text(content))

    heading("RUN SUMMARY")
    summary = {"LLM_responses": ai_count, "tool_calls_requested": call_count,
               "tool_results_returned": tool_count}
    summary["tools_chosen"] = {name: tool_names.count(name) for name in dict.fromkeys(tool_names)}
    if usage and all(isinstance(item, dict) and isinstance(item.get("input_tokens"), int)
                     and isinstance(item.get("output_tokens"), int) for item in usage):
        summary["tokens"] = {"input": sum(item["input_tokens"] for item in usage),
                            "output": sum(item["output_tokens"] for item in usage)}
    else:
        summary["tokens"] = "Unavailable for one or more responses."
    add(summary)
    return ("\n\n" if markdown else "\n").join(output).lstrip()
