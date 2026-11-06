# Agent execution enhancements

Recorded: November 4, 2026 (America/Chicago).

**Status: deferred backlog.** This document records proposed improvements for
[notebook 21](21_movies_automated_test.ipynb). These enhancements have not been
implemented as part of this documentation task. Resume one small change at a time
so its behavior and impact remain easy to learn and verify.

## 1. Why revisit the current loop?

The basic workflow remains appropriate:

> Observe the app → let the LLM choose a tool → validate and execute → inspect the result.

The LLM chooses how to pursue the human scenario. Python should enforce valid
actions, bounded recovery, and evidence-based results. The system should continue
to work from human instructions and observed UI, without test-ID routing,
preassigned tool lists for individual cases, or hardcoded journeys.

### Example that exposed the gaps

Human request in saved run `MOV-HUM-031-b0e04efa40.json`:

> Switch the tabs to Home, Browse, Search, and Library.

| Recorded measurement | Value |
| --- | --- |
| Model responses | 6 |
| Tool calls | 10 |
| Initial observation calls | 1 |
| Acknowledged tap commands | 4 |
| Blocked attempts using outdated references | 5 |
| Explicit `assert_ui` calls | 0 |
| Aggregate input tokens across model responses | 61,718 |
| Aggregate output tokens | 327 |
| Host report status | `REVIEW_REQUIRED` |

The model requested four taps in one response, then three taps in a later response.
The first successful tap in each group refreshed the observation and replaced the
usable references. Other requests in that group used outdated references and were
blocked. The model eventually used fresh references to complete the remaining tap
commands. Home was already selected before its tap.

The prompt already says to issue one UI action at a time. This run demonstrates
that the prompt alone does not enforce that behavior. Recorded tool-message order
also does not prove the execution order of calls requested together.

Input-token totals include context supplied repeatedly across model responses;
they are not the number of unique words in the human request. Formatting or
shortening notebook output does not reduce the model's input. A straightforward
execution of these four requested taps would use one initial observation plus
four tap calls, before adding explicit checks. Tap tools already return fresh
after-observations.

Local evidence, when present:

- [Saved run report](../.tools/manual-test-runs/MOV-HUM-031-b0e04efa40.json)
- [Raw conversation](../.tools/manual-test-runs/agent-result-e0e728ef9f.txt)
- [Readable walkthrough](../.tools/manual-test-runs/MOV-HUM-031-walkthrough.html)

These artifacts are ignored local files and may not exist in another checkout.
The measurements above preserve the baseline without requiring those files.

## 2. Current protections and gaps

| Area | Implemented now | Still missing |
| --- | --- | --- |
| Tool arguments | Typed tool schemas constrain arguments and supported operators. | A valid call can still be inappropriate for the user's goal. |
| Element targeting | Runtime rejects unknown or outdated references, ambiguous matches, changed identities, and hidden/disabled targets. | A deterministic policy for recovering from each category of error. |
| Shared device | A runtime lock serializes access to the session. | Enforcement that the model requests one tool at a time; a lock cannot refresh already-generated arguments. |
| Run limits | 30 dispatched action units, 8 scrolls, 70 observations, 180-second runtime deadline, and graph recursion limit 40. | Repeated-error detection, progress checks, per-step recovery limits, and an explicit model/token budget. |
| Uncertain dispatch | `UNCERTAIN` blocks further mutations; diagnostic observation may remain possible. | A controlled reconciliation or human decision process. |
| Verification | Assertion tools evaluate explicit conditions against saved evidence. | Enforced coverage of the complete human goal before reporting completion. |
| Human involvement | A human selects and starts one test manually. | A checkpointed clarification/interrupt/resume flow during execution. |

Blocked attempts before dispatch do not consume dispatched-action units. Graph
recursion limit 40 is not a limit of 40 tool calls. The runtime deadline prevents
new guarded tool operations after expiry. It does not itself stop further LLM
responses or cancel an already-running model or SDK request.

## 3. Proposed enhancements, in implementation order

### E01 — Enforce sequential tool requests

**Priority: first.** Configure the model to request at most one tool per response
and validate that rule before dispatch. The installed model integration supports
disabling parallel tool calls; the eventual implementation must verify that the
setting reaches the agent's actual model request.

Start with one tool call per response, including observation calls that replace
references. After an action, reuse its returned observation when sufficient. Keep
the existing runtime lock and reference checks.

If the model still returns multiple calls, reject the batch before device actions
and return a clear correction. Do not silently choose one or execute the entire
batch with outdated arguments.

**Acceptance checks:**

- A deliberately generated multi-call response causes no device mutation.
- The tab-switching scenario uses current references for each action.
- No blocked attempt is caused by a sibling call invalidating its reference.
- Tool choice remains LLM-driven and independent of the CSV test ID.

### E02 — Add bounded recovery and detect lack of progress

**Priority: second.** Return structured error categories alongside readable
explanations. Proposed categories include `STALE_REFERENCE`, `TARGET_NOT_FOUND`,
`AMBIGUOUS_TARGET`, `INVALID_ARGUMENTS`, and `ENVIRONMENT_UNAVAILABLE`. These are
proposed categories, not a claim about the current receipt schema.

Track recovery attempts against the current unmet requirement, along with the
last action, error, and relevant UI state. An initial policy could allow at most
two recovery attempts before stopping with evidence or requesting clarification.
The threshold is a proposal to validate, not an existing setting.

| Situation | Proposed response |
| --- | --- |
| Outdated reference | Use a suitable latest observation; capture again only when needed. Never reuse the expired reference. |
| Missing or ambiguous target | Inspect context; use bounded waiting or scrolling where justified. Ask for clarification if the intended target remains unclear. |
| Wrong tool or arguments | Return a specific correction and allow a bounded revised request. |
| Valid action but wrong destination | Compare the observed result with the expected requirement; reassess the path within the recovery budget. |
| Repeated error or no progress | Stop early with the failed requirement and evidence, before exhausting the general run budget. |
| Assertion mismatch | Preserve the mismatch. Do not change the expectation to match the observed result. |
| Uncertain action dispatch | Keep further mutations blocked. Do not retry an action that might already have happened. |
| Missing device, data, or instrumentation | Report the missing prerequisite instead of exploring unrelated controls. |

A new observation ID alone is not progress. Check relevant UI state or completed
requirements. Identical-looking UI can also be a valid outcome, such as selecting
an already-selected tab; account for the goal when detecting stalled execution.

**Acceptance checks:** repeated stale references and wrong actions stop within the
configured recovery budget; an uncertain dispatch is never blindly repeated;
diagnostics retain the relevant screenshot, hierarchy, action, and error evidence.

### E03 — Reduce what tools send to the model

**Priority: third.** Separate the compact model-facing result from the full saved
receipt. Return current actionable UI elements, complete native identifiers,
temporary references, relevant values, outcomes, and useful error information.
Keep full receipts and artifacts available locally by evidence ID.

Avoid repeated nested observations, bookkeeping fields, and unnecessary artifact
paths. Preserve facts needed for targeting and assertions. Do not save tokens by
silently truncating identifiers or removing required evidence. If an observation
is limited, disclose that limit and provide a bounded way to inspect more.

Screenshots should be supplied to the model when visual inspection is needed;
saving a screenshot locally is distinct from sending its image bytes to the model.

**Acceptance checks:** required controls and complete identifiers remain
accessible; full local evidence remains intact; equivalent scenarios use fewer
input tokens without reducing their verified coverage. Measure actual provider
usage, not the length of the notebook's displayed output.

### E04 — Keep concise progress in run state

Record the original goal, current observation, navigation path, completed
requirements, pending checks, and unresolved errors in session state. Distinguish
actions attempted from requirements verified. Use that state to reduce duplicated
older context without forgetting the exact path needed for Back-navigation tests.

Historical observations remain evidence; their temporary references must not
become usable again through summarization. Keep tool requests and results properly
paired when reducing conversation context. Longer-term episodic or procedural
memory can be considered separately after this run-state behavior is reliable.

**Acceptance checks:** a longer journey retains the correct Back path, unresolved
failures, and unverified requirements after context reduction. Old references
remain rejected.

### E05 — Require evidence for completion

Derive expected outcomes from the human goal and supplied app/domain context.
Use deterministic assertion tools for conditions that can be checked from native
attributes. Ask for clarification when the goal does not define a meaningful
expectation. Do not invent expectations from whatever the app happens to show.

Keep local polling inside `wait_for_ui`; avoid a new model response for every
poll. Evaluate a final coverage check before reporting that the scenario is done.
Visual judgments remain labeled as model assessments with their supporting image.

Distinguish these concepts in the eventual result contract:

- An acknowledged command completed its SDK call; it does not establish a PASS.
- An assertion PASS/FAIL applies to its stated condition and captured evidence.
- An assertion mismatch after valid setup and action is test-failure evidence,
  not automatic proof of a particular product defect or root cause.
- Missing infrastructure is a blocker; an unreliable automation attempt may be
  inconclusive rather than an application failure.
- Overall completion requires evidence covering the human goal.

**Acceptance checks:** a model saying “verified” without supporting checks cannot
produce a verified overall PASS. Partial coverage and uncertainty remain explicit.

### E06 — Add human clarification and explicit execution budgets

Add a focused clarification path for ambiguous targets or missing user intent.
For example, “open the movie” with several visible movies may require a question;
an available semantics ID does not establish which movie the human intended.

Checkpoint the run before a human interrupt. Define how the device session is
closed or retained while waiting. On resume, validate or recreate the session,
re-observe the current app, and issue fresh references; never assume the app stayed
unchanged. This notebook currently closes its session in `finally` and does not
yet implement interrupt/resume.

Add explicit model-call and token limits alongside action/time limits. Report
which budget stopped the run and retain partial evidence. Set initial values
after measuring representative scenarios rather than promising a fixed saving.

**Acceptance checks:** ambiguous intent asks one clear question; resumption never
uses obsolete session references; budget exhaustion produces an understandable
partial result with retained evidence.

## 4. Evaluation before and after each change

Use controlled offline model/tool responses to check enforcement and error paths
without spending tokens. Separately, manually run selected human scenarios against
the real API-connected app to assess actual model behavior. Offline harness checks
do not replace live application testing.

Record model responses, requested tool calls, dispatched actions, blocked attempts,
recovery attempts, elapsed time, token usage, assertion coverage, and final result
classification. Include simple navigation, deep navigation, missing/ambiguous
targets, delayed UI, repeated mistakes, and uncertain dispatch cases.

Compare runs with the same model settings and comparable starting app state.
Account for changing live data and model variability; do not infer general
reliability from one successful run. Fewer calls are useful only when the required
coverage and evidence are preserved.

## 5. Where to resume

Start with **E01**, verify it, then introduce **E02** as the next learning step.
Follow with **E03** and measure the token impact. The remaining items can be
developed individually. Additional agents are not required for these improvements.

Relevant implementation references:

- [Notebook 21](21_movies_automated_test.ipynb): model configuration, prompt, invocation, and cleanup.
- [Shared runtime](tools/_runtime.py): reference validation, dispatch, budgets, and receipts.
- [Tool registry](tools/__init__.py): shared tools available to the agent.
- [Observation helper](modules/observations.py): native captures and bounded summaries.
- [Wait tool](tools/wait_for_ui.py) and [assertion tool](tools/assert_ui.py): local checks.
- [Run reporting](modules/manual_test_cases.py): trace, usage, and result provenance.
- [TOOLS.md](TOOLS.md): explanation of the current model/tool lifecycle.
