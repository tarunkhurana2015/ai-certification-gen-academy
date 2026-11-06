"""Relaunch only the configured app, preserving its installed data."""
# LangChain's decorator turns the inner Python function into a callable tool.
from langchain_core.tools import tool


# The host calls this factory with its already configured shared runtime.
# The inner function remembers that object through a Python closure: the model
# cannot supply a different driver, session, or app bundle as tool arguments.
def build_tool(runtime):
    # @tool constructs a wrapper/schema from the function and its docstring.
    # The host later passes returned tools to create_agent for model access.
    # This tool has no model-supplied arguments; its target comes from the host.
    @tool
    def relaunch_app() -> dict:
        """Terminate and activate the configured app through guarded runtime; preserve app data."""
        # A bundle ID identifies the installed app, for example an iOS bundle.
        bundle = runtime.bundle_id
        # Reject a missing/blank host setting before creating a device action.
        if not isinstance(bundle, str) or not bundle.strip():
            # blocked() returns a structured receipt explaining why no action ran.
            return runtime.blocked('relaunch_app', 'Host app bundle ID is not configured.')

        # Defining this callback does not run either Appium command yet.
        # mutate() decides whether it is safe to invoke it for the owned session.
        def dispatch():
            # Ask Appium to stop only this app's running process.
            runtime.session.driver.terminate_app(bundle)
            # Start/foreground the same installed app. No uninstall or data reset
            # is requested, so its existing installed app data is preserved.
            runtime.session.driver.activate_app(bundle)

        # The shared runtime holds its one-tool-at-a-time lock, checks session,
        # deadline and action budget, and saves intent before calling dispatch.
        # There are two device actions here, so reserve an action_cost of 2.
        # Its receipt distinguishes dispatch acknowledgement from verified effect
        # and includes fresh UI evidence when the configured app is foreground.
        return runtime.mutate('relaunch_app', dispatch, action_cost=2)

    # Return the decorated tool for registration; building it does not relaunch.
    return relaunch_app
