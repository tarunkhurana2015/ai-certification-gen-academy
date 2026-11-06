"""A bounded local two-tap sequence for time-sensitive UI, such as remove/Undo."""
# Use an elapsed-time clock that is unaffected by wall-clock changes, plus
# brief sleeps between local searches for the follow-up control.
from time import monotonic, sleep
# isfinite rejects NaN/infinite values before constructing a local deadline.
import math
# @tool builds a callable wrapper/schema; the host later gives it to the agent.
from langchain_core.tools import tool
# Reuse the native element types accepted for an ordinary observed-control tap.
from .tap_element import _TAPPABLE


def build_tool(runtime):
    # runtime is the host-owned session/registry/limits object, captured by this
    # closure. The LLM supplies only an observed reference, label, and timeout;
    # it cannot supply an Appium driver, Python callback, or arbitrary selector.
    @tool
    def run_timed_sequence(first_element_ref: str, followup_label: str = 'Undo', timeout_seconds: float = 4) -> dict:
        """Tap an observed control, then a unique follow-up button locally before timeout.

        Useful for remove then Undo without a model round trip inside the five
        second offer. Both actions and captures must fit the remaining budget
        before anything is tapped. Uses fresh follow-up identity and no automatic
        retries after an uncertain action. A missed window is reported explicitly.
        """
        # Hold one reentrant lock through both actions and intermediate reads.
        # Other tools cannot consume action units or replace this runtime's
        # latest target registry while the compound sequence is in progress.
        with runtime.lock:
            try:
                # Require a nonblank label, but keep the original string for
                # exact matching below rather than trimming or guessing it.
                if not followup_label.strip():
                    raise ValueError('An exact follow-up label is required.')
                # Keep the requested local window finite, positive, and at most
                # 4.5 seconds, leaving nominal room within a five-second offer.
                if not math.isfinite(timeout_seconds) or not 0 < timeout_seconds <= 4.5:
                    raise ValueError('The local sequence window must be positive and at most4.5 seconds.')
                # Check both action units before sending the first tap. This
                # also rejects inactive or already uncertain mutation state.
                runtime.require_budget(2)
                # Each action normally captures its aftermath. This preflight
                # requires room for two captures; additional polling captures
                # below can also consume the remaining observation budget.
                if len(runtime.observations) + 2 > runtime.limits.max_observations:
                    raise RuntimeError('Insufficient observation budget for the complete sequence.')
                # Refuse to start if the enclosing run has no more time than
                # the requested local window. SDK requests and captures still
                # take real time; this is not a completion-time guarantee.
                if runtime.timeout_seconds_remaining() <= timeout_seconds:
                    raise RuntimeError('The remaining run deadline is too short for the sequence.')
                # Resolve an opaque reference from the latest observation,
                # reacquiring exactly one live, enabled, displayed target of an
                # allowed type. target retains its captured native identity.
                element, target = runtime.resolve(first_element_ref, _TAPPABLE)
                # Holding this lock reserves both action units against other tool calls.
                # Start the local sequence clock after resolving the first
                # element. The same deadline guards both mutation dispatches.
                started = monotonic()
                deadline = started + timeout_seconds
                # A zero-argument lambda delays the actual click until mutate()
                # has checked the session/budget and durably recorded intent.
                # mutate() checks dispatch_deadline before invoking the callback
                # and then captures the aftermath. Its SDK call and after-capture
                # can finish after the deadline; they are not cut off by it.
                first = runtime.mutate('timed_first_tap', lambda: element.click(), details={'target': target},
                                       dispatch_deadline=deadline)
                # ACKNOWLEDGED means the driver callback returned successfully;
                # it does not prove the intended UI effect. An uncertain or
                # rejected first action must not trigger a follow-up or retry.
                if first['status'] != 'ACKNOWLEDGED':
                    return runtime.record({'operation': 'run_timed_sequence', 'status': 'BLOCKED',
                                           'reason': 'The first tap is not acknowledged; follow-up was not attempted.', 'first': first})
                while monotonic() < deadline:
                    # mutate() clears old targets and normally refreshes this
                    # registry from its after-observation. Search those fresh
                    # trusted identities, matching both native button type and
                    # the complete follow-up label without substring matching.
                    candidates = [(ref, t) for ref, t in runtime._targets.items()
                                  if t['type'] == 'XCUIElementTypeButton' and t['label'] == followup_label]
                    if len(candidates) > 1:
                        # Never choose arbitrarily between duplicate buttons.
                        raise ValueError('The follow-up button is ambiguous.')
                    if len(candidates) == 1:
                        ref, identity = candidates[0]
                        # Revalidate the observed reference against the live
                        # device. The underscore discards the repeated identity.
                        followup, _ = runtime.resolve(ref, {'XCUIElementTypeButton'})
                        # Resolution itself takes time, so check the clock again.
                        if monotonic() >= deadline:
                            break
                        # mutate() also rechecks the deadline after recording
                        # intent, before dispatching this second click callback.
                        second = runtime.mutate('timed_followup_tap', lambda: followup.click(), details={'target': identity},
                                                dispatch_deadline=deadline)
                        # Propagate the action receipt's status, which may be
                        # ACKNOWLEDGED, UNCERTAIN, or REJECTED; this is not a
                        # PASS/FAIL assertion about Undo's visible result.
                        # elapsed_seconds includes the returned after-capture
                        # work, so it may exceed the dispatch window. Keep both
                        # nested receipts for their requests and saved evidence.
                        return runtime.record({'operation': 'run_timed_sequence', 'status': second['status'],
                                               'elapsed_seconds': monotonic() - started, 'first': first, 'followup': second})
                    # With no candidate, pause briefly and refresh observation
                    # locally. This retries discovery, never an uncertain tap,
                    # and does not ask the LLM to plan another action mid-window.
                    sleep(min(.1, max(0, deadline - monotonic())))
                    runtime.observe()
                # The local opportunity ended before a follow-up dispatch was
                # attempted. BLOCKED preserves that boundary and the first tap's
                # receipt; it is not proof of a particular application failure.
                return runtime.record({'operation': 'run_timed_sequence', 'status': 'BLOCKED',
                                       'reason': 'The follow-up was not available within the local time window; no late tap was sent.',
                                       'elapsed_seconds': monotonic() - started, 'first': first})
            except Exception as error:
                # Validation, budget, session, and device-resolution failures
                # become recorded BLOCKED outcomes instead of guessed success.
                return runtime.blocked('run_timed_sequence', str(error))
    # Return the tool wrapper with its host session context already bound.
    return run_timed_sequence
