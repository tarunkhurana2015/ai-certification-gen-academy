"""Dismiss the native keyboard through its explicit SDK command."""
# LangChain's decorator supplies the schema and wrapper for a callable tool.
from langchain_core.tools import tool


def build_tool(runtime):
    # The host binds runtime through this closure. The model-facing tool has no
    # arguments, so the model cannot choose a driver, app, or keyboard command.
    # Registration happens here; keyboard inspection happens only on invocation.
    @tool
    def dismiss_keyboard() -> dict:
        """Hide the configured app's keyboard, then capture fresh UI evidence.

        If already hidden this is a read-only no-op. An unsupported/uncertain SDK
        hide command is not retried with arbitrary screen taps or alternate keys.
        """
        # Serialize the visibility check and possible action. The context manager
        # releases this lock even when the function returns early or raises.
        with runtime.lock:
            try:
                # Confirm that the configured application is in the foreground.
                runtime.require_own_app()
                # Appium reports native keyboard visibility. A hidden keyboard
                # needs no mutation, so record a COMPLETE no-op receipt immediately.
                if not runtime.session.driver.is_keyboard_shown():
                    # operation identifies the request; keyboard_visible records
                    # the state observed without sending a hide command.
                    return runtime.record({'operation':'dismiss_keyboard','status':'COMPLETE','keyboard_visible':False})

                # mutate will call this callback after its checks and saved intent;
                # defining it alone does not send the Appium hide command.
                def dispatch():
                    runtime.session.driver.hide_keyboard()
                    # Report what the driver sees after the command. This field
                    # can still be True; command completion does not imply hidden.
                    return {'keyboard_visible':runtime.session.driver.is_keyboard_shown()}

                # The receipt includes dispatch status, callback data, and a fresh
                # UI observation captured by the shared mutation machinery.
                return runtime.mutate('dismiss_keyboard', dispatch)
            except Exception as error:
                # Preserve the reason as a BLOCKED receipt instead of retrying.
                return runtime.blocked('dismiss_keyboard', str(error))
    # Return the wrapped callable for inclusion in the host's tool collection.
    return dismiss_keyboard
