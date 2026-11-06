"""Read host preparation evidence without filling storage or injecting faults."""
# A deep copy also copies nested dictionaries/lists in the evidence record.
from copy import deepcopy
# The decorator constructs a callable tool wrapper and its argument schema.
from langchain_core.tools import tool


# The factory binds host-owned runtime to the returned tool through a closure.
# It is not a tool argument, so the model cannot substitute a driver, session,
# storage state, or evidence record when it requests this inspection.
def build_tool(runtime):
    # @tool builds a wrapper/schema using the signature and docstring. The host
    # later passes returned tools to create_agent to expose them to the model.
    # An empty signature means the agent has no input values to supply here.
    @tool
    def inspect_storage_condition() -> dict:
        """Read session-scoped host storage evidence without changing device or host storage."""
        # The lock's with block serializes protected access to shared runtime
        # state. It does not open/close an Appium Session; that session already
        # belongs to the host and is available as runtime.session.
        with runtime.lock:
            try:
                # Check that this run is open, the original Appium session is
                # still active, and its deadline has not expired.
                runtime.require_active()
            except Exception:
                # blocked() records why no useful session evidence can be read.
                return runtime.blocked('inspect_storage_condition', 'An active owned session is required.')

            # The host groups preparation records by topic. A storage entry is
            # expected to have session_id, state, and evidence fields.
            condition = runtime.prepared_conditions.get('storage')
            # Reject absent/malformed entries and entries from another run.
            if not isinstance(condition, dict) or condition.get('session_id') != runtime.session.session_id:
                return runtime.blocked('inspect_storage_condition', 'No storage preparation evidence matches this session.')

            # state is the supplied condition label; evidence contains the
            # accompanying host notes/measurements, not a tool-made diagnosis.
            state, evidence = condition.get('state'), condition.get('evidence')
            # A placeholder label or empty evidence cannot establish that the
            # host explicitly prepared the stated condition for this session.
            if (not isinstance(state, str) or not state.strip()
                    or state.strip().lower() in ('unknown', 'unprepared', 'unspecified', 'not_prepared')
                    or not isinstance(evidence, dict) or not evidence):
                return runtime.blocked('inspect_storage_condition', 'Explicit storage state and nonempty evidence record are required.')

            # COMPLETE describes a successful read of the supplied evidence.
            # Nothing here fills storage, writes test files, injects faults, or
            # measures available bytes/write failures on the device or host.
            # record() attaches receipt metadata and attempts to persist it.
            return runtime.record({
                'operation': 'inspect_storage_condition',
                'status': 'COMPLETE',
                'state': state,
                # Copying prevents later edits to this result from modifying
                # the host's original nested preparation evidence.
                'evidence': deepcopy(evidence),
                'source': 'human-provided host preparation; not independently verified',
                'verified_by_tool': False,
                'limitation': 'Storage availability and write failure have not been measured by this tool.'
            })

    # Return the decorated tool without reading evidence during registration.
    return inspect_storage_condition
