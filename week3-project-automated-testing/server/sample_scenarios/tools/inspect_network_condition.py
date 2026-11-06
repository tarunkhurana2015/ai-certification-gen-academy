"""Read host preparation evidence without changing connectivity."""
# Copy nested evidence so this result does not share mutable lists/dicts with
# the host's original preparation record.
from copy import deepcopy
# @tool constructs a callable wrapper and its typed argument schema.
from langchain_core.tools import tool


# The host supplies runtime once. The inner function remembers that host-owned
# context through a closure, so the model cannot submit its own evidence here.
def build_tool(runtime):
    # @tool builds the wrapper/schema; the host later supplies returned tools
    # to create_agent to expose them to the model. There are no model-facing
    # arguments: this reads host preparation for the attached session.
    @tool
    def inspect_network_condition() -> dict:
        """Read session-scoped host network evidence; never infer API reachability from the UI."""
        # This context manager acquires a shared Python lock until the indented
        # block ends. It prevents overlapping protected tool operations; it does
        # not create, enter, or close an Appium Session context manager.
        with runtime.lock:
            try:
                # Require an open run, the original live Appium session, and
                # time remaining before trusting any session-scoped record.
                runtime.require_active()
            except Exception:
                # Return a recorded explanation instead of reading stale state.
                return runtime.blocked('inspect_network_condition', 'An active owned session is required.')

            # prepared_conditions is a host-supplied dictionary. Its 'network'
            # entry should contain session_id, state, and an evidence dictionary.
            condition = runtime.prepared_conditions.get('network')
            # A record from another session must not describe this device run.
            if not isinstance(condition, dict) or condition.get('session_id') != runtime.session.session_id:
                return runtime.blocked('inspect_network_condition', 'No network preparation evidence matches this session.')

            # state is a human-provided label; evidence holds the supporting
            # host notes/measurements rather than a value inferred from a UI.
            state, evidence = condition.get('state'), condition.get('evidence')
            # Require a meaningful label and at least one evidence field.
            # Placeholder states deliberately do not count as preparation.
            if (not isinstance(state, str) or not state.strip()
                    or state.strip().lower() in ('unknown', 'unprepared', 'unspecified', 'not_prepared')
                    or not isinstance(evidence, dict) or not evidence):
                return runtime.blocked('inspect_network_condition', 'Explicit network state and nonempty evidence record are required.')

            # COMPLETE means the record was read successfully. This tool does
            # not disable Wi-Fi, inject a failure, ping an API, or verify notes.
            # record() adds receipt/session IDs and timestamps and attempts to
            # save the result as a receipt for later review.
            return runtime.record({
                'operation': 'inspect_network_condition',
                'status': 'COMPLETE',
                'state': state,
                'evidence': deepcopy(evidence),
                # Preserve the distinction between host testimony and a check
                # performed by this tool, even when the state sounds certain.
                'source': 'human-provided host preparation; not independently verified',
                'verified_by_tool': False,
                'limitation': 'Prepared evidence does not independently establish API reachability.'
            })

    # The host registers this tool object; no inspection runs during building.
    return inspect_network_condition
