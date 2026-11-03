# Sample scenarios and learning notebooks

The former `server/sample_scenario.ipynb` is now a small entry-point index. Its 16 lessons live here as focused notebooks. All original lesson cells, stored text outputs, and embedded screenshots were retained; Python setup copies are source-only.

## How to use them

Select the project's `.venv` Python kernel, open one notebook, and run its cells from top to bottom. Each notebook includes the Python setup it needs; no cross-notebook shared kernel state is required. Setup cells intentionally repeat earlier source so their behavior is visible while this remains a learning project. We have not introduced a new shared runtime/bootstrap module in this refactor.

You can start a kernel in the project root, `server/`, or this directory. Node activation locates the server through `.node-version`, `package.json`, and this directory; it does not change the working directory. The local runtimes, Appium home, audit snapshots, logs, and evidence remain under `server/.tools/`.

Python prerequisites and app-state prerequisites are different. The notebooks own/close their sessions, while the Simulator app preserves its UI/navigation state. Run device exercises serially. Lesson 14 expects Search root, and lesson 15 expects results for the scenario query. From an open details page, use Back; selecting Search retains its branch's navigation stack. Restarting a Python kernel does not restore the app UI.

Stored outputs are historical evidence, not proof that a server/session is still active. Rerunning a scenario creates new ignored evidence artifacts. Existing absolute artifact paths remain historical; embedded screenshots are retained in their lesson files. This reorganization does not install packages, change tokens, clear app data, or execute UI journeys.

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

## Current boundary

Lessons 01–09 explain/configure prerequisites. Lesson 10 checks the local server. Lessons 11–15 develop real session/observation/action/assertion exercises against the normally configured app. Lesson 16 extracts ordinary Python primitives; its live demo observes/inspects only, with tap guards checked separately offline.

MCP exposure, LangChain tool registration, model-driven planning, LangGraph orchestration, and the memory/eval layers have not been introduced by this file split. Existing dependency-audit findings remain documented in their lessons and are not resolved by moving files.
