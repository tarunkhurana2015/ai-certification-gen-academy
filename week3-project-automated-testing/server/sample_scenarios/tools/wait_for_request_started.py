"""Observe an in-flight query only through host-owned request instrumentation."""
# isfinite rejects infinity and NaN, which would make a timeout unreliable.
import math
# monotonic measures elapsed time without depending on wall-clock changes;
# sleep pauses briefly between polls instead of repeatedly calling the probe.
import time
from langchain_core.tools import tool


# The host binds its runtime once when constructing this tool. The inner
# function closes over the runtime and its request_probe callback; the model
# only supplies query and timeout_seconds, never instrumentation or a session.
def build_tool(runtime):
    # @tool builds a wrapper/schema from the signature and docstring. The host
    # later passes returned tools to create_agent to expose them to the model.
    @tool
    def wait_for_request_started(query: str, timeout_seconds: float = 5.0) -> dict:
        """Wait at most 15 seconds for matching externally instrumented in-flight request evidence."""
        # request_probe is a host-installed callable that reports actual request
        # instrumentation for a query. This tool does not start an API request.
        probe = getattr(runtime, 'request_probe', None)
        # A UI spinner/loading label is not a substitute for request evidence.
        if not callable(probe):
            return runtime.blocked('wait_for_request_started',
                'Host request instrumentation is not configured; a spinner does not prove request start.')

        # Require a nonblank bounded query and a finite wait in (0, 15].
        # query.strip() checks for whitespace, but the original query value is
        # retained for the probe and the exact evidence comparison below.
        if (not query.strip() or len(query) > 200 or not math.isfinite(timeout_seconds)
                or not 0 < timeout_seconds <= 15):
            return runtime.blocked('wait_for_request_started',
                'A query of 1 to 200 characters and timeout greater than zero up to 15 seconds are required.')

        # A per-call timeout cannot extend the lifetime of the whole toolkit run.
        remaining = runtime.timeout_seconds_remaining()
        if remaining <= 0:
            return runtime.blocked('wait_for_request_started', 'The runtime deadline has expired.')
        # Use whichever expires first: this call's requested wait or the run.
        # The deadline is checked between synchronous probe calls; it does not
        # forcibly interrupt a host callback that is still executing.
        deadline = time.monotonic() + min(timeout_seconds, remaining)

        # Start with the honest fallback: without matching evidence, the result
        # is BLOCKED. A successful probe changes this receipt to COMPLETE later.
        # poll_count records how many probe calls returned, not HTTP requests.
        receipt = {
            'operation': 'wait_for_request_started',
            'status': 'BLOCKED',
            'source': 'external_instrumentation',
            'poll_count': 0,
            'reason': 'No matching explicitly in-flight request was observed within the bounded wait.'
        }
        try:
            # Recheck both clocks before each attempt; a different operation
            # may have consumed more of the shared run's remaining time.
            while time.monotonic() < deadline and runtime.timeout_seconds_remaining() > 0:
                # Acquire the shared lock only for this session check/probe.
                # This with block controls access to shared host state; it does
                # not create or close an Appium Session context manager.
                with runtime.lock:
                    try:
                        # Do not accept evidence for a closed/replaced session.
                        runtime.require_active()
                    except Exception:
                        return runtime.blocked('wait_for_request_started', 'An active owned session is required.')
                    # Invoke the host callback and receive its evidence value.
                    evidence = probe(query)

                # The lock has been released here, including during sleeps, so
                # this polling tool does not hold it for the entire wait.
                receipt['poll_count'] += 1
                if isinstance(evidence, dict):
                    # Either supported field can explicitly say "still running":
                    # completed=False or a present completed_at=None value.
                    explicit_inflight = (evidence.get('completed') is False
                        or ('completed_at' in evidence and evidence['completed_at'] is None))
                    # A contradictory completion signal vetoes the evidence,
                    # even if another field also claims it is still in flight.
                    explicit_complete = (evidence.get('completed') is True
                        or evidence.get('completed_at') is not None)
                    started = evidence.get('started_at')

                    # Require this exact session/query and a nonblank start
                    # marker. The marker is host evidence; this check does not
                    # parse its timestamp or infer start time from the UI.
                    if (evidence.get('session_id') == runtime.session.session_id
                            and evidence.get('query') == query
                            and isinstance(started, str) and started.strip()
                            and explicit_inflight and not explicit_complete):
                        # Keep only the required evidence fields, bounding the
                        # start marker instead of copying arbitrary probe data.
                        receipt.update(status='COMPLETE', evidence={
                            'session_id': evidence['session_id'], 'query': query,
                            'started_at': started[:100], 'completed': False})
                        # The original "no match" explanation is now obsolete.
                        receipt.pop('reason', None)
                        # record() adds receipt/session metadata and attempts to
                        # persist this evidence before returning it to the agent.
                        return runtime.record(receipt)

                # Poll no faster than once per quarter-second, shortening the
                # last sleep so it does not intentionally exceed either limit.
                delay = min(0.25, deadline - time.monotonic(), runtime.timeout_seconds_remaining())
                if delay <= 0:
                    break
                time.sleep(delay)
        except Exception as error:
            # Callback failures are different from a normal no-match timeout.
            # Return only the exception type, not arbitrary callback details.
            receipt.update(status='FAILED', error_type=type(error).__name__,
                           reason='Host request instrumentation did not complete; exception details omitted.')

        # Persist either the no-match receipt or a sanitized failure receipt.
        return runtime.record(receipt)

    # Return the decorated tool; building/registering it does not poll anything.
    return wait_for_request_started
