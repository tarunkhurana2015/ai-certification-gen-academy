# Shared UI testing tools

Notebook 21 registers the same 18 LangChain tools for every selected human request. The LLM chooses tools from their descriptions and live evidence. No CSV ID, severity, or feature area selects a tool or execution script.

Each public tool has one file and one `build_tool(runtime)` factory. The factory binds host context (driver, session, limits, credentials); the decorated function exposes only its task arguments to the model. `_runtime.py` and `_evidence.py` are private shared helpers, not callable model tools.

## How the agent uses them

```python
from tools import ToolRuntime, ToolLimits, build_tools
from langchain.agents import create_agent

runtime = ToolRuntime(bundle_id=run_profile['app_bundle_id'], limits=ToolLimits())
SHARED_TOOLS = build_tools(runtime)
agent = create_agent(model=llm, tools=SHARED_TOOLS, system_prompt=TEST_AGENT_PROMPT)

# The notebook explicitly starts/stops the existing Appium session.
runtime.start_run(session)
try:
    result = agent.invoke({'messages': [selected_message]}, config={'recursion_limit': 40})
finally:
    runtime.end_run()
```

`create_agent()` builds a compiled LangGraph: model → tool dispatch → model, repeated until the model produces a final answer or a limit stops execution. Individual tools do not each need their own StateGraph node. An outer StateGraph connecting executor, analyzer, documenter, and reporter can be added later.

Tool invocations inside one run share runtime state; no memory or test plan is precomputed from CSV IDs. Native UI actions are serialized. Model calls remain token-billed even when a tool ultimately reports BLOCKED.

## Tools

| File / tool | Main inputs | Behavior |
| --- | --- | --- |
| [observe_current_ui.py](observe_current_ui.py) | None | Capture live native XML and PNG; return a bounded element summary, observation ID, and opaque current element references. |
| [tap_element.py](tap_element.py) | `element_ref` | Revalidate a current native target, tap once, and capture after-evidence. |
| [enter_text.py](enter_text.py) | `element_ref`, `text`, `replace` | Literal clear/replace/append. Preserve whitespace. Clear and type are separate action units. Reacquire and check the native field value; ambiguous placeholder reads cannot prove actual text. |
| [scroll_ui.py](scroll_ui.py) | `direction`, optional `element_ref` | One bounded viewport/container gesture. Direction describes content to reveal, rather than finger movement. |
| [go_back.py](go_back.py) | Optional `element_ref` | Use an observed Back/Navigate up button. Does not blindly send an OS Back action or guess an edge gesture. |
| [dismiss_keyboard.py](dismiss_keyboard.py) | None | Hide a visible native keyboard once; capture the result. |
| [wait_for_ui.py](wait_for_ui.py) | Exact native selector, condition, timeout | Poll source locally, then recheck the matching condition in saved fresh evidence. At most 20 seconds; no model round trip per poll. |
| [assert_ui.py](assert_ui.py) | `observation_id`, exact selector, attribute/operator/expected | Evaluate full saved XML. PASS/FAIL applies to that explicit snapshot condition; ambiguity/unavailable evidence is BLOCKED. Supports equality, substring, existence, absence, and exact count. |
| [compare_observations.py](compare_observations.py) | Two observation IDs, selector, attribute, relation | Check whether an explicit native attribute changed or stayed unchanged across independent saved captures. |
| [review_visual_evidence.py](review_visual_evidence.py) | `observation_id` | Attach a registered PNG to the calling model as actual image content. Does not call another model or issue a deterministic visual verdict. |
| [relaunch_app.py](relaunch_app.py) | None | Terminate and activate the configured bundle without reinstalling or resetting data. Costs two action units. |
| [return_to_app.py](return_to_app.py) | None | Activate the configured bundle after an external handoff and observe it. |
| [inspect_external_link.py](inspect_external_link.py) | None | Inspect active-app metadata and native text/URLs only for the owned app or an external app reached through a recorded owned-app handoff. Cannot certify HTTP content or trailer playback. |
| [find_test_data.py](find_test_data.py) | `query`, `desired_content` | Read live TMDB candidates with provider provenance. Bounded to three search pages and five inspected candidates; no match does not prove global absence. |
| [inspect_network_condition.py](inspect_network_condition.py) | None | Read session-matched, host-prepared network-condition evidence. Does not change network settings or independently verify a human declaration. |
| [inspect_storage_condition.py](inspect_storage_condition.py) | None | Read session-matched, host-prepared storage-condition evidence. Does not fill storage or cause write failures. |
| [wait_for_request_started.py](wait_for_request_started.py) | `query`, timeout | Poll a host-provided request probe for matching explicit in-flight evidence. Does not infer request start from a spinner. |
| [run_timed_sequence.py](run_timed_sequence.py) | `first_element_ref`, `followup_label`, timeout | Tap a current control, then a uniquely observed follow-up button locally (for example remove/Undo). Reserves two action units and checks dispatch deadlines; no model round trip inside the window. |

Exact selectors in evidence tools use `native_name` (native XML `name`), `label`, and optional `native_type`. These values come from actual observations. They may reflect Flutter Semantics identifiers exposed through the iOS accessibility tree; they are not assumed to be Dart widget keys. Action tools take only runtime-issued `element_ref` values, never arbitrary XPath or model-generated coordinates.

## Runtime and evidence

`ToolRuntime` binds one live, unchanged Appium session. References expire on a new observation or mutation. Before mutation, the runtime rechecks native identity, uniqueness, visibility/enabled state, foreground application, limits, and writes an intent receipt. It dispatches once and attempts fresh after-evidence. A lost dispatch response is UNCERTAIN; further mutations are blocked for that run, avoiding an accidental repeated tap.

Defaults are 30 action units, 8 scrolls, 70 captures, and a 180-second run deadline. Model recursion limits are separate. A deadline prevents a new late dispatch; it cannot cancel a request already in flight. Appium/model request timeouts also apply. `start_run()` resets counters/references for the next manually selected case; `end_run()` closes tool access but retains observations and receipts for reporting.

Evidence and intent receipts are written beneath `session.artifact_root`; assertion/image tools accept registered same-session observations and confine file access to that root. Image payloads are limited to 2 MiB. A successful screenshot tool returns image content plus a ToolMessage artifact containing its saved reference. Notebook 21 sets `use_responses_api=True` on its OpenAI client so image-bearing function outputs are serialized as Responses API image input. Disk reports omit duplicate image bytes while the model conversation retains them.

A click acknowledgment is not a verified outcome. Assertions verify their explicit conditions, and visual review remains model assessment. The overall natural-language goal still needs completeness review; notebook reports do not promote model prose to an overall PASS/FAIL. The runtime journal is retained even if agent invocation fails; token usage may then be unknown.

## Optional dependencies and scope

- Set `TMDB_READ_ACCESS_TOKEN` in `server/.env` to enable direct live data discovery. The token is bound privately and never appears in tool schemas. The helper does not change Flutter configuration or silently use fixtures.
- `prepared_conditions` can contain `network` and `storage` dictionaries with the current `session_id`, a nonempty `state`, and nonempty `evidence` dictionary. These are host-provided observations/declarations, labeled unverified by the inspectors. Setup and restoration happen outside these tools.
- `request_probe(query)` must return a current-session matching query with `started_at` and explicit unfinished status (`completed=False` or `completed_at=None`). Without instrumentation this tool is BLOCKED. Controlled slow live requests, actual connectivity changes, and storage-failure injection remain separate environment work.
- Native tools currently use iOS/XCUITest through the existing local runtime. Android, web, and HeadSpin execution adapters are future work. Most tools are domain independent; TMDB data discovery is a replaceable domain-specific adapter.
- These are direct LangChain tools. Exposing them over MCP is a later transport milestone.

## Offline checks

From the project root:

```sh
.venv/bin/python -m unittest discover -s server/sample_scenarios/tests -v
```

Checks use fake drivers, saved test artifacts, and scripted model responses. They verify dispatch, schemas, bounds, evidence, and reports without provider calls or device actions. Live model reasoning and actual app journeys require manually running notebook 21.
