"""Return to the configured app through the shared guarded mutation runtime."""
# The decorator gives LangChain a tool description and argument schema.
from langchain_core.tools import tool


# The host supplies one shared runtime when assembling the toolkit.
# The returned function closes over it, keeping the driver and app identity in
# host code rather than letting the model pass them as tool arguments.
def build_tool(runtime):
    # @tool constructs the wrapper and argument schema; the host later passes
    # returned tools to create_agent to expose them to the model. This empty
    # argument list has no model-controlled app name, bundle ID, or selector.
    @tool
    def return_to_app() -> dict:
        """Activate the host-configured app and capture the runtime's fresh post-action evidence."""
        # Read the app identity selected by the host for this toolkit run.
        bundle = runtime.bundle_id
        # Stop early when that setting is absent or contains only whitespace.
        if not isinstance(bundle, str) or not bundle.strip():
            # A BLOCKED receipt records that the requested action could not run.
            return runtime.blocked('return_to_app', 'Host app bundle ID is not configured.')

        # This nested callback describes the device command; defining it does
        # not execute it. The guarded runtime invokes it only after its checks.
        def dispatch():
            # Appium activates the configured installed app, bringing it back
            # from another foreground app or starting it if necessary.
            runtime.session.driver.activate_app(bundle)

        # mutate() serializes this operation with the runtime's lock, validates
        # the active owned session and remaining action/time budgets, records
        # intent, then calls dispatch and attempts a fresh observation.
        # The returned dictionary is that operation's receipt; acknowledgement
        # of activate_app alone does not establish every desired UI effect.
        return runtime.mutate('return_to_app', dispatch)

    # Registering this returned tool does not itself activate the app.
    return return_to_app
