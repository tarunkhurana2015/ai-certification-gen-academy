# Known gaps and enterprise readiness

Reviewed: **November 7, 2026 (America/Chicago)**.

**Current assessment:** a working, guarded local iOS prototype suitable for proposing
a controlled evaluation. Enterprise production readiness has not been established.
This register records known limitations, proposed improvements, and unfinished
product scope. It does not authorize implementation or certify that every possible
issue has been discovered.

## How to use this register

- **OPEN** means the gap remains unresolved in the reviewed implementation.
- **DEFERRED** means the capability is planned but not implemented in notebook 21.
- **RECHECK** means historical evidence needs a current verification.
- **Pilot** items should be addressed or explicitly bounded for a supervised pilot.
  Data/provider permissions apply before using company data; the company decides
  which other limitations are acceptable for its pilot.
- **Unattended** items matter before trusting runs without a reviewer or using them
  to gate a release. **Shared service** items apply before multi-user operation.
- **Roadmap** items extend product scope. More agents, MCP, RAG, or more platforms
  do not by themselves establish enterprise readiness.

All items are unassigned. The milestones and closure checks below are proposals,
not delivery commitments or approved company policy. A single-platform tool can
be enterprise software; Android/web support is a product requirement here, not a
universal enterprise requirement.

[ENHANCEMENTS.md](ENHANCEMENTS.md) remains the detailed design backlog for E01–E06.
This document links those entries and adds the broader gaps. [TOOLS.md](TOOLS.md)
explains the implemented execution model; [requirements.md](../docs/requirements.md)
describes the intended product and identifies partially reviewed sections.

## What already exists

- A manually selected English scenario drives one `create_agent()` tool loop.
  The same 18 tools are available for every scenario; there is no test-ID routing.
- Host code validates the active app/session, fresh element references, live target
  identity, visibility, action limits, and persisted intent before dispatch.
- An uncertain mutation blocks further mutations. Session/server cleanup and video
  retrieval run through explicit cleanup paths.
- Assertions check stated conditions against saved evidence. Reports preserve
  receipts, screenshots, video, and measured usage where available.
- Overall results deliberately remain `REVIEW_REQUIRED` unless a blocking condition
  is reported. A click acknowledgment or LLM statement cannot certify a full pass.
- **145 offline tests passed in the November 7 readiness review.** These exercise
  code, fake drivers, saved evidence, and scripted model responses. They do not
  measure real-model success rates. A real Simulator video capture/playback smoke
  check was also completed previously; it is not a full scenario evaluation.

Sources: [runtime](tools/_runtime.py), [tool inventory](tools/README.md),
[report builder](modules/manual_test_cases.py), [tests](tests/), and
[video documentation](README.md#automatic-video-recording-in-lesson-21).

## 1. Execution, verification, and cost

All six entries are **OPEN**. Existing host guards remain useful while these gaps
are resolved; a prompt instruction is not equivalent to dispatch enforcement.

| ID / milestone | Current limitation and consequence | Closure evidence |
| --- | --- | --- |
| **G01 · Pilot** — Sequential requests | The prompt asks for one action at a time, but the dispatcher does not enforce one tool request per response. A runtime lock cannot repair already-generated stale arguments. See **E01** in [ENHANCEMENTS](ENHANCEMENTS.md). | A multi-call response dispatches no device actions; a corrected run uses fresh references without sibling calls invalidating them. |
| **G02 · Pilot** — Recovery and progress | Errors are guarded, but there is no explicit per-error recovery policy, repeated-error counter, or goal-aware progress check. An uncertain action stops mutations without a reconciliation/resume workflow. See **E02**. | Repeated stale/ambiguous targets stop or request help within a defined budget. An uncertain action is never blindly retried. Original failures remain visible. |
| **G03 · Pilot** — Model context size | Full/nested receipts can be expensive to resend. Display formatting does not reduce tokens sent to the model. See **E03**. | Compare equivalent live scenarios before/after compact results: lower measured input usage while retaining complete identifiers, required checks, and full local evidence. |
| **G04 · Unattended** — Progress and human resume | Conversation state and `ToolRuntime` exist, but there is no durable checkpointed goal/progress model or clarification/approval/resume flow. A manual start is not an in-run human checkpoint. See **E04/E06** and [TOOLS](TOOLS.md#7-runtime-state-graph-state-and-memory). | Pause/resume retains unmet requirements and actual navigation history; the resumed run revalidates its session and obtains fresh references. An unanswered question cannot authorize an action. |
| **G05 · Unattended** — Complete scenario verdict | Assertions prove individual snapshot conditions. The host does not require evidence covering every human requirement, so the overall result remains `REVIEW_REQUIRED`. See **E05** and [report builder](modules/manual_test_cases.py). | Expected outcomes come from the human request and approved app rules. A coverage gate distinguishes verified success, observed failure, blocked setup, and inconclusive execution. Missing evidence cannot yield a pass, and a failed check cannot be rewritten to fit the screen. |
| **G06 · Pilot / Unattended** — Total budgets and cancellation | Action/scroll/observation limits and a runtime deadline exist. They do not impose a total token/spend cap or cancel an in-flight model/SDK request. Recursion limit 40 is not 40 tool calls; usage can be unknown after an interrupted invocation. See **E06**. | Explicit request/token/spend policies, deadlines, and cancellation behavior are tested. Budget exhaustion preserves partial evidence; unknown usage is labeled and accounted for conservatively. |

**Observed baseline, not a general benchmark:** the saved four-tab example used
10 tool calls, encountered five stale-reference blocks, performed zero explicit
assertions, and reported 61,718 aggregate input tokens. These are historical
measurements recorded in [ENHANCEMENTS](ENHANCEMENTS.md#1-why-revisit-the-current-loop),
not a claim that every current run has this cost or behavior.

## 2. Evaluation and test validity

All entries are **OPEN**. Running real APIs does not automatically make test setup,
expected outcomes, or the agent's final judgment reliable.

| ID / milestone | Current limitation and consequence | Closure evidence |
| --- | --- | --- |
| **G07 · Pilot / Unattended** — Real-agent evaluations | Offline checks verify enforcement and wiring. There is no established repeated, held-out real-model benchmark with agreed reliability thresholds. | Use human-reviewed expected outcomes for successful journeys, deliberate failures, ambiguous requests, missing prerequisites, and recovery cases. Measure verified completion, false passes, missed failures, interventions, latency, and cost across repeated runs and model/prompt changes. Set thresholds before making readiness claims. |
| **G08 · Pilot** — Starting state and live data | The app uses preserved local state; switching a tab can retain its navigation stack. Live catalog/backend data can change. There is no general per-app test-data setup/restoration contract. See [README](README.md#how-to-use-them) and [session runtime](modules/appium_runtime.py). | Record app/build/environment and relevant initial state. Establish test-owned data and allowed setup/cleanup actions. Repeat a journey without depending on an earlier test; distinguish unavailable data from an application defect. Keep the app connected to its real test backend. |
| **G09 · Scenario-dependent pilot** — Environment instrumentation | Network/storage tools read host-prepared declarations; they do not create or independently verify those conditions. Request-start checking needs a host probe, which is unset in the notebook. External-link inspection cannot prove HTTP content or video playback. See [tool boundaries](tools/README.md#optional-dependencies-and-scope). | For scenarios requiring these facts, implement real setup/instrumentation and restoration with matching session/time provenance. Missing prerequisites stay BLOCKED; a spinner or URL alone is not proof. |
| **G10 · Pilot** — UI and visual evidence limits | Targeting depends on what native accessibility exposes; native names may be label fallbacks rather than stable semantics IDs. Summaries are bounded, and XML/screenshots are captured separately. Visual review is model judgment, not a deterministic visual regression verdict. See [observations](modules/observations.py), [visual review](tools/review_visual_evidence.py), and [evidence gallery](modules/report_evidence.py). | Define each app's supported controls/contexts and selector expectations. Exercise missing/duplicate identifiers, dynamic screens, truncation, and capture timing. Supply a bounded inspection path and disclose unavailable/visual-only evidence; do not invent identifiers or certify unsupported behaviors. |

## 3. Permissions and company data

These entries are **OPEN**. They describe missing controls and one confirmed helper
behavior, not evidence that company data or credentials have already leaked.

| ID / milestone | Current limitation and consequence | Closure evidence |
| --- | --- | --- |
| **G11 · Pilot** — Scenario authority and untrusted UI | The host restricts app/session and tools, but has no general business-action policy distinguishing an authorized test action from a purchase, deletion, or other consequential operation inside that app. The prompt says to treat UI text as data; dedicated adversarial evaluations are not established. | Use an explicit allowed environment/action policy and least-privilege test accounts. Enforce restricted actions in host code and require approval where policy calls for it. Inject misleading UI/document instructions in tests and verify they cannot widen permissions. |
| **G12 · Before company data** — Privacy and artifacts | Raw UI XML, screenshots, video, and readable reports can contain sensitive data. File/path limits and HTML escaping exist, but there is no general redaction, protected artifact-delivery service, retention/deletion policy, or application-managed encryption. Screenshots may be sent to the configured model for visual review. | Agree approved provider/data use and storage controls with the company. Verify sensitive content handling across prompts, logs, images, video, traces, and exports; enforce authorized access, retention/deletion, and encryption requirements, including any controls provided by the deployment environment. |
| **G13 · Before company data** — Secrets and diagnostic masking | Credentials are host-bound and TMDB errors are sanitized, but secrets currently come from local configuration. In [env_utils.py](../utils/env_utils.py), `summarize_value()` exposes all characters of nonboolean values of length four or fewer after a `****` prefix; longer nonboolean values expose the final four. Boolean strings are returned unchanged. This is not a universal secret masker. | Show only presence/status for secrets, including short values, and separate nonsecret settings from credentials. Add synthetic masking checks and verify secret-free logs/reports. Establish the company's credential provisioning, rotation, and least-privilege process. No real secret needs to be displayed to verify this. |

## 4. Shared operation and support

All entries are **OPEN** for a shared company service. A supervised single-user
pilot can use a narrower operational arrangement if its limitations are recorded.

| ID / milestone | Current limitation and consequence | Closure evidence |
| --- | --- | --- |
| **G14 · Shared service** — Submission and access | Execution is started through notebook cells. The reviewed backend has no application API/runner interface with user authentication, roles, per-project authorization, or authenticated review history. | Provide a supported submission/status/cancellation interface. Verify permitted users can access only authorized apps, runs, and artifacts; record reviewer identity and decisions. |
| **G15 · Shared service** — Durable jobs and device ownership | Runtime state and locks are process-local; evidence files persist, but there is no durable job queue, checkpoint recovery, or cross-process device lease. Local Appium/WDA ports and serial-run guidance limit concurrency. | Two workers cannot own the same device simultaneously. Restart/crash tests preserve run history and reconcile uncertain actions without replay. Exercise queue cancellation, session cleanup, and defined backup/restore behavior. |
| **G16 · Shared service** — Delivery and deployment | The repository's [CI workflow](../../../.github/workflows/movies-client-quality.yml) covers the Flutter client. Backend tests are run locally; there is no demonstrated backend release/deployment/rollback pipeline or clean-machine service installation. | Run backend formatting/analysis/tests in CI; separate authorized live-device checks from offline checks. Reproduce the Python/Node/Appium/XCUITest setup on a clean runner, deploy a versioned release, and demonstrate rollback. iOS device workers require the appropriate macOS/Xcode environment; a generic container alone does not supply it. |
| **G17 · Pilot / Shared service** — Provenance and operations | Receipts, process logs, timestamps, and some usage exist. There is no consolidated versioned run manifest, central operational dashboard/alerts, or documented service ownership and recovery targets. | Correlate run, tool call, device, and artifacts; record code/model/prompt/tool/app versions and relevant environment/data context. Monitor failures, latency, stuck sessions, artifact growth, and usage. Define support ownership and test a recovery procedure. |

## 5. Product capabilities still to build

These are **DEFERRED** roadmap items, except the explicitly documented video
limitations. They should not be presented as implemented enterprise features.

| ID / milestone | Current boundary | Closure evidence |
| --- | --- | --- |
| **G18 · Roadmap** — App onboarding and domain knowledge | Most action tools are reusable, but the working example and live data-discovery adapter are Movies/TMDB. There is no completed onboarding contract or retrieval pipeline for another app's approved behavior. | Onboard another domain through an app profile and approved context rather than test-ID scripts. Keep expected behavior separate from observed UI. Add RAG when justified, with app/version/environment scoping and source provenance. |
| **G19 · Roadmap** — Cross-run memory | `ToolRuntime` holds per-run execution context; the agent has conversation state. Notebook 21 does not implement durable episodic, procedural, or semantic memory. | Scope memory by app/version/environment, retain evidence provenance, invalidate stale entries, and support deletion. Prior success cannot prove a new run passes; learned procedures cannot increase permissions or contaminate held-out evaluations. |
| **G20 · Roadmap** — Orchestration, MCP, and reporting integration | Notebook 21 runs one `create_agent` loop with direct LangChain tools. The outer classifier → executor → analyzer → documenter → reporter StateGraph, MCP transport, and external work-item integration are not implemented there. Typed tool schemas are not a completed type-safe intent-routing workflow. | Implement typed stage contracts and prerequisites when needed; test unsupported/ambiguous routing and handled failures. Expose tools with appropriate MCP authorization if selected. Prepare evidence-backed work-item drafts; create/update only with authorized policy or review, handling duplicates and partial publication failures. |
| **G21 · Roadmap** — Platforms and providers | The implemented execution/recording backend is local iOS/XCUITest. Android, web, physical-device, and HeadSpin adapters have not been demonstrated. | Define adapter capabilities and validate separate results for each supported target, including browser/native context differences. Verify provider setup, credentials, cleanup, and evidence retrieval. An iOS pass cannot stand in for another platform. |
| **G22 · OPEN · Future evidence improvements** — Video coverage and portability | Recording works around agent execution after session creation; it excludes earlier app launch. Hard process termination or a lost session can prevent retrieval. Native recording has no configured duration cap here; save/export is limited to 256 MB. HTML playback needs its sibling video; timestamp-to-step seeking is not implemented. See [video notes](README.md#automatic-video-recording-in-lesson-21). | Agree capture coverage, limits, missing-video behavior, and sharing requirements. Test interruption/size/provider boundaries. Add bounded capture, provider-specific retrieval, portable packaging, or step seeking only when selected for scope; video availability must remain independent of the test verdict. |

## 6. Dependencies and documentation

| ID / status / milestone | Known evidence and limit | Closure evidence |
| --- | --- | --- |
| **G23 · RECHECK · Pilot** — Dependency assurance | [Lessons 06](06_appium_server_package.ipynb) and [10](10_appium_server_status.ipynb) record unresolved server and managed-driver npm findings from November 2; [lesson 07](07_xcuitest_driver.ipynb) says prerequisite checks do not clear them. This register has not rerun an advisory lookup and does not assert the current vulnerability count or exploitability. Server and driver dependency installations are separate. | Review current locked server, driver, and Python dependency trees using current advisory data. Record applicability, compatible remediation or approved disposition, and a repeatable scan/update process. Do not force a major downgrade or override without compatibility verification. |
| **G24 · OPEN · Pilot / Roadmap** — Requirements consistency | [requirements.md](../docs/requirements.md) explicitly retains later draft sections with Movies/local/iOS/fixture assumptions that conflict with the updated domain-independent, iOS/Android/web, real-backend direction. The root setup [README](../../README.md) also retains unrelated course-directory references. | Reconcile the remaining requirements one section at a time and correct setup instructions. Distinguish approved scope, future milestones, and implemented behavior; preserve the real-backend requirement for application runs. Offline fake-driver checks remain valid tests of the automation code. |

## 7. Evidence-contract consistency

**G25 · OPEN · Unattended — Persisted capture provenance.** The shared evidence
lookup in [tools/_evidence.py](tools/_evidence.py) checks registered observation
identity, session, artifact validity, and path containment. It does not require
that observation's capture manifest to have `receipt_persisted=True`. Action
reference issuance in [tools/_runtime.py](tools/_runtime.py) does require a complete,
persisted capture. An assertion's own persisted receipt is a separate fact from
persistence of its source capture manifest.

**Closure evidence:** agree and enforce a consistent capture-provenance contract
for assertions, comparisons, and visual review. Test a failed manifest write with
an otherwise valid saved artifact. A result must explicitly represent any missing
provenance instead of implying a complete durable evidence chain. This static
finding does not establish that an existing user run produced a false assertion.

## Proposed order of work

1. **Before a company pilot:** agree the app, approved environment/data/model usage,
   permitted actions, and a QA reviewer. Address or bound G11–G13, recheck G23,
   and resolve relevant setup ambiguity in G24. This is a proposed company-use
   prerequisite, not a new approval requirement for local documentation work.
2. **Continue the small learning steps:** E01/G01, then E02/G02, then E03/G03 as
   already recorded in ENHANCEMENTS. Measure each change rather than building
   several new agents at once.
3. **Make results dependable:** add goal coverage (G05), sufficient progress and
   budget controls (G04/G06), repeatable setup (G08), the evidence-provenance
   contract (G25), and only the instrumentation needed by selected scenarios
   (G09/G10).
4. **Evaluate the pilot:** start with 10–15 representative human-reviewed journeys,
   including deliberate failures, and repeat them under recorded conditions (G07).
   Keep unknown/inconclusive results explicit. Expansion depends on agreed quality,
   intervention, time, and cost thresholds—not a successful demo alone.
5. **Build the shared service and expand scope:** resolve G14–G17 as adoption needs
   grow; schedule G18–G22 against the approved product milestones. Supporting every
   future capability is not a prerequisite for learning from a bounded iOS pilot.

## Keeping this register current

For any item taken into implementation, assign an owner and record its agreed
scope, linked work item, and acceptance checks. Mark it **IN PROGRESS** only when
work starts, and **CLOSED** only with dated verification evidence. Keep the G-ID
stable; when an E01–E06 item changes, update both this register's status and the
existing enhancement entry. Record accepted limitations with their scope and
review date rather than silently treating them as fixed.

Documentation checks for this update validate local links and formatting. No app
journeys, model calls, dependency upgrades, or runtime changes are part of this task.
