"""Observe the configured app and register fresh target references."""
# This decorator converts the function into LangChain's model-callable tool form.
from langchain_core.tools import tool


def build_tool(runtime):
    # runtime is supplied by the host and retained by the nested function's
    # closure. The model calls a zero-argument tool rather than providing a session.
    # @tool builds the callable/schema now; it does not capture the screen yet.
    @tool
    def observe_current_ui() -> dict:
        """Capture the configured app's current screen and native UI.

        Returns observation_id, bounded visible attributes with current element_ref
        values, keyboard state, and saved XML/screenshot paths. References expire
        after an observation or mutation. Native name is not always a semantics ID.
        """
        # The shared observer acquires/releases the runtime lock, checks the app
        # and observation limit, saves screenshot/XML evidence, and replaces old
        # target references with references from this capture. It returns the
        # observation receipt, or a BLOCKED receipt if observation fails.
        return runtime.observe()
    # Give the host the wrapped tool already attached to the chosen runtime.
    return observe_current_ui
