# Sample scenarios and learning notebooks

The former `server/sample_scenario.ipynb` is now a small entry-point index. Its original 16 lessons live here as focused notebooks, with new lessons added separately below. All original lesson cells, stored text outputs, and embedded screenshots were retained; Python setup copies are source-only.

## How to use them

Select the project's `.venv` Python kernel, open one notebook, and run its cells from top to bottom. Each notebook includes or imports the Python setup it needs; no cross-notebook shared kernel state is required. Lessons 01–16 retain their original source copies so the earlier learning steps remain visible. Lessons 17–21 import the shared Python helpers below instead of repeating infrastructure code.

You can start a kernel in the project root, `server/`, or this directory. Node activation locates the server through `.node-version`, `package.json`, and this directory; it does not change the working directory. The local runtimes, Appium home, audit snapshots, logs, and evidence remain under `server/.tools/`.

Python prerequisites and app-state prerequisites are different. The notebooks own/close their sessions, while the Simulator app preserves its UI/navigation state. Run device exercises serially. Lesson 14 expects Search root, and lesson 15 expects results for the scenario query. From an open details page, use Back; selecting Search retains its branch's navigation stack. Restarting a Python kernel does not restore the app UI.

Stored outputs are historical evidence, not proof that a server/session is still active. Rerunning a scenario creates new ignored evidence artifacts. Existing absolute artifact paths remain historical; embedded screenshots are retained in their lesson files. This reorganization does not install packages, change tokens, clear app data, or execute UI journeys.

For a step-by-step explanation of `ToolRuntime`, tool factories, and the agent loop, read [TOOLS.md](TOOLS.md).

Known execution, security, operational, and product-scope gaps are tracked in
[KNOWN_GAPS.md](KNOWN_GAPS.md), with status, milestones, and closure checks.
[ENHANCEMENTS.md](ENHANCEMENTS.md) retains the detailed E01–E06 execution backlog.

## Shared Python helpers (lesson 17 onward)

- [modules/appium_runtime.py](modules/appium_runtime.py) selects existing local tools, validates the configured iOS target, and owns server/session startup and cleanup through `managed_ios_session()`.
- [tools/](tools/README.md) contains the shared 18-tool registry for lesson 21, with one public tool per file and private runtime/evidence helpers. The LLM chooses tools dynamically for every selected request.
- [modules/manual_test_cases.py](modules/manual_test_cases.py) selects one CSV row locally, prepares only its human message, records the shared agent's actual tool trace/usage, and saves one report. It contains no per-test routing or tool map.
- [modules/ui_assertions.py](modules/ui_assertions.py) evaluates expected native attributes from full saved post-action XML and returns PASS, FAIL, or BLOCKED with evidence references. It makes no device/model calls.
- [modules/ui_actions.py](modules/ui_actions.py) gives current observed buttons session-bound references, guards the single permitted tap, persists action receipts, and captures post-action evidence.
- [modules/observations.py](modules/observations.py) captures native hierarchy/screenshots and persists structured receipts through `observe_ui()`. `observe_session_ui()` adds a bounded `ui_summary` read from the saved XML for the agent.

Imports perform no tool activation, server startup, or device commands. The lesson calls these operations explicitly. Earlier lessons keep their short `@tool` definitions visible. Lesson 21 imports the shared tool factories and keeps agent construction, invocation, and report inspection visible. The shared runtime exposes `start_ios_session()` / `stop_ios_session()` for the lesson and retains its owned-resource cleanup internally. These helpers currently cover local iOS; other platform/provider adapters remain future work.

After changing an imported module, close any active session and restart the kernel before rerunning. Run live device lessons serially. Lessons 01–16 are unchanged by this extraction.

## Notebook order

| Part | Notebook | Execution scope |
| --- | --- | --- |
| 01 | [Scenario input and agent workflow](01_scenario_input.ipynb) | No app/session activity. |
| 02 | [Appium, semantics, navigation, and Dart MCP](02_appium_execution_overview.ipynb) | Concepts only. |
| 03 | [Select the recorded app/Simulator profile](03_app_profile.ipynb) | Local profile values only; no device query. |
| 04 | [Inspect environment and server readiness](04_environment_readiness.ipynb) | Read-only checks and optional localhost status request. |
| 05 | [Activate the project-local Node runtime](05_local_node_runtime.ipynb) | Kernel PATH plus Node/npm version checks. |
| 06 | [Select the pinned Appium package](06_appium_server_package.ipynb) | Kernel environment plus Appium version check. |
| 07 | [Inspect the XCUITest registration and Doctor](07_xcuitest_driver.ipynb) | Existing registration/prerequisite checks; no session. |
| 08 | [Import and inspect the Python client](08_python_client.ipynb) | Imports/version checks only. |
| 09 | [Prepare requested iOS session capabilities](09_ios_session_options.ipynb) | Constructs local options; no connection. |
| 10 | [Start Appium, inspect status, and stop](10_appium_server_status.ipynb) | Own localhost server; no device session. |
| 11 | [Create and close an iOS session](11_ios_session.ipynb) | May launch/reuse Movies; no scenario action. |
| 12 | [Capture native hierarchy and screenshot](12_observe_ui.ipynb) | Real session and read operations. |
| 13 | [Locate Search and tap once](13_search_navigation.ipynb) | One Search-tab tap; preserves the tab navigation stack. |
| 14 | [Enter Interstellar and observe results](14_search_query.ipynb) | Requires Search root; clears/types the query as documented. |
| 15 | [Open the observed movie and check title/year](15_movie_details_assertions.ipynb) | Requires current-query results; one movie open and offline assertions. |
| 16 | [Reusable capture, inspection, and tap primitives](16_reusable_ui_operations.ipynb) | Live demo observes/inspects only; tap wrapper is not dispatched. |
| 17 | [First real Appium tool](17_langchain_observation_tool.ipynb) | Define `@tool`, invoke once with `{}`, inspect its capture receipt, and close the session; no model or UI action. |
| 18 | [First read-only observation agent](18_first_observation_agent.ipynb) | `create_agent()` invokes one observation tool against the real app; the LLM describes returned UI elements; no navigation. |
| 19 | [First controlled UI action agent](19_first_ui_action_agent.ipynb) | Observe, tap the permitted Search button once, capture the resulting UI, and describe it; guards run in the shared helper. |
| 20 | [UI assertions and first test result](20_ui_assertions_and_test_result.ipynb) | Reuse the Search action, then evaluate its full saved post-action XML in Python and print PASS/FAIL/BLOCKED with evidence. |
| 21 | [Manual one-test LLM agent](21_movies_automated_test.ipynb) | Select one CSV request and manually invoke the same shared agent; the model chooses from implemented tools. Shared 18-tool native iOS toolkit with bounded actions, waits, assertions, and evidence; conditional setup tools report missing dependencies. |

## Current boundary

Lessons 01–09 explain/configure prerequisites. Lesson 10 checks the local server. Lessons 11–15 develop real session/observation/action/assertion exercises against the normally configured app. Lesson 16 extracts ordinary Python primitives; its live demo observes/inspects only, with tap guards checked separately offline.

Lesson 17 defines one simple LangChain observation tool and invokes it manually. It uses a single session, returns a receipt dictionary, and keeps Appium setup/cleanup in shared helpers. Advanced runtime binding, strict schemas, and ToolMessage envelopes can be introduced in later lessons. It does not introduce MCP exposure, model-driven planning, LangGraph orchestration, or the memory/eval layers; those remain later milestones. Existing dependency-audit findings remain documented in their lessons and are not resolved by moving files.

Lesson 18 adds the first read-only `create_agent()` loop. It uses the existing `OPENAI_API_KEY` in `server/.env`; no key value belongs in a notebook. The model receives a bounded summary of actual native UI attributes and returns a description. The screenshot/XML remain saved evidence. This is not a navigation test or a pass/fail analyzer.

Offline summary, action, and assertion checks (no API/device activity):

```sh
.venv/bin/python -m unittest discover -s server/sample_scenarios/tests -v
```

Lesson 19 adds one action tool using references from the latest successful observation. The host permits the Search label and at most one click dispatch per session. Fresh uniqueness/identity/visibility/enabled checks and persisted intent precede dispatch; a new observation follows even after an uncertain response. Selecting Search can retain its existing branch stack. This exercise describes post-action evidence rather than claiming a complete scenario passed.

Lesson 20 adds a deterministic expected-state check. For the Movies iOS example it requires the native Search button to be visible with value `"1"`; this means selected in this app's captured semantics. The helper validates action/capture provenance and reads the full saved XML, independently of the agent's final answer or summary truncation. PASS applies to that captured state, not to a transition, Search root, or an entire movie-search scenario. Ambiguous, missing-value, invalid, or unavailable evidence is BLOCKED; known contradictions are FAIL.

Lesson 21 selects one human-written request locally and invokes the shared agent with the same 18 tools for every row. There are no ID-based tool requirements, prerequisite tables, execution scripts, or checker registries. The LLM reasons from the request, tool schemas, and live observations. The toolkit supports bounded native actions, literal input, scrolling, waits, saved-state assertions, visual evidence, lifecycle, external handoffs, and optional live data discovery. See [tools/README.md](tools/README.md) for arguments and dependencies.

Preview makes no model calls; a manual execution attempt uses tokens, including image tokens when screenshot review is requested. Network/storage inspectors require separately prepared condition evidence, and request-start verification requires host instrumentation. They report BLOCKED when prerequisites are unavailable. Individual assertions return scoped PASS/FAIL results; model prose and partial assertions do not certify the complete English scenario. Actual tool messages, runtime receipts, artifact references, and measured usage are retained for review. Live model/device runs remain manual.

## Saved reports from lesson 21

The final save cell writes matching JSON and HTML files in `server/.tools/manual-test-runs/`,
plus an available video with the same basename.
The HTML includes every requested tool with its target/native identifier and outcome,
plus each unique observation's recorded highlights, screenshot, and full returned UI table.
Screenshots are embedded; video is a separate neighboring file. Missing artifacts are explained.
The HTML preserves the recorded result status and does not call the model or device.

To render a previously saved JSON report without rerunning its test:

```python
import json
from modules.html_report import render_test_report

saved_path = REPORT_DIR / "MOV-HUM-027-17770123a0.json"  # Choose your saved run.
report = json.loads(saved_path.read_text(encoding="utf-8"))
html_path = saved_path.with_suffix(".html")
html_path.write_text(
    render_test_report(report, artifact_root=lesson_dir.parent / ".tools" / "observations"),
    encoding="utf-8",
)
print(html_path)
```

Export reads only referenced evidence inside that observation directory. PNGs are
limited to 10 MB each and 50 MB in total, with an explicit notice for any omitted image.
JSON remains the original recorded evidence; HTML adds presentation and embedded images.


## Automatic video recording in lesson 21

The invocation cell now sets `RECORD_VIDEO = True`. Recording is ordinary host code,
not an LLM tool: it adds no model calls or tokens. Its visible lifecycle is:

```text
Create Appium session → start_run_video → agent.invoke
                       finally: stop_run_video → close Appium session
Save report → JSON + HTML + neighboring MP4 (or original MOV fallback)
```

The recorder starts just before the agent's first request, after session creation
and app launch. It captures the screen throughout execution, including waits and
failures. The cell's `finally` block retrieves the movie before Appium closes, also
when the agent fails or you interrupt it. Run the save cell afterward to export it.
Existing runs cannot acquire video retroactively.

[modules/video_recording.py](modules/video_recording.py) uses Appium's native
XCTest recording commands (Xcode 15+/iOS 17+). This local iOS implementation needs
no FFmpeg. It checks recording/session ownership and saves the original MOV under
`server/.tools/recordings/run-video-*/`. macOS's built-in `avconvert` produces an
H.264 MP4 for browser playback; if conversion fails, the MOV remains available.
MOV browser support varies, so the report also offers a download link.

[modules/video_report.py](modules/video_report.py) copies that run's video next to
its JSON/HTML report. The HTML has video controls; there is no autoplay. **Keep the
HTML and video file together when moving or sharing the report.** Screenshots
remain embedded, and recording/export failure never changes the test verdict.

Recording statuses describe evidence availability: `SAVED`, `PARTIAL` (execution
or finalization was interrupted), `UNAVAILABLE`, or `DISABLED`. The separate
`export_status` says whether the report's video copy succeeded. Host elapsed time
is approximate; the player's duration comes from the encoded video.

Set `RECORD_VIDEO = False` before running the invocation cell if capture is not
needed. Native XCTest recording has no configured duration cap here; stop long
runs manually. Saving/exporting is limited to 256 MB per video. A kernel/process
kill, lost Appium session, or interruption before the recorder returns its UUID
can prevent retrieval. Normal Python exceptions and interrupts reach cleanup;
a hard process kill cannot. These helpers currently cover the local iOS backend;
Android, web, and HeadSpin recording adapters remain future work.
