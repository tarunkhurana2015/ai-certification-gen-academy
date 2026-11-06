"""Tap one freshly observed native control."""
# The decorator creates the tool interface that LangChain exposes to the model.
from langchain_core.tools import tool

# Only these native iOS element types may be tapped through this tool.
_TAPPABLE = {'XCUIElementTypeButton', 'XCUIElementTypeCell', 'XCUIElementTypeLink',
             'XCUIElementTypeSwitch', 'XCUIElementTypeTextField', 'XCUIElementTypeSearchField'}


def build_tool(runtime):
    # Bind the host's private runtime in a closure. The model supplies element_ref;
    # it cannot supply its own Appium driver or replace the runtime's safeguards.
    # @tool builds the callable wrapper and argument schema; it does not tap anything.
    @tool
    def tap_element(element_ref: str) -> dict:
        """Tap a current observed control and return fresh post-action evidence.

        Supply only an element_ref from the latest observation, never a guessed
        selector. The runtime checks identity, uniqueness, visibility, enabled
        state, app focus and action limits. An uncertain dispatch is not retried.
        ACKNOWLEDGED reports SDK completion, not proof of the intended outcome.
        """
        # Keep resolution and dispatch serialized with other runtime actions.
        # Leaving this block automatically releases the lock, including on errors.
        with runtime.lock:
            try:
                # Resolve a latest-observation reference into an Appium element and
                # captured identity. This also checks app focus, type, uniqueness,
                # visibility, and enabled state before allowing the click.
                element, target = runtime.resolve(element_ref, _TAPPABLE)

                # This callback describes the SDK action without executing it yet.
                def dispatch():
                    # Appium sends the tap to the resolved native element.
                    element.click()

                # mutate saves intent, checks limits, invokes dispatch once, and
                # captures fresh evidence. details records which reference and
                # observed identity were requested; the returned receipt describes
                # dispatch status, not proof that the desired app behavior occurred.
                return runtime.mutate('tap_element', dispatch, details={'element_ref':element_ref,'target':target})
            except Exception as error:
                # A validation or lookup error becomes a saved BLOCKED receipt.
                return runtime.blocked('tap_element', str(error))
    # The host receives the decorated tool, already bound to this runtime.
    return tap_element
