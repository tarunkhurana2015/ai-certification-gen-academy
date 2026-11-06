"""Use the observed native Back control rather than assuming a route stack."""
# LangChain uses this decorator to expose a Python function as a model-callable tool.
from langchain_core.tools import tool


def build_tool(runtime):
    # The host supplies runtime once. The nested function remembers it through a
    # closure, so the model supplies only element_ref, never a driver or session.
    # Decorating builds the tool wrapper/schema; it does not press Back at build time.
    @tool
    def go_back(element_ref: str = '') -> dict:
        """Tap one observed Back/Navigate-up button and capture the resulting screen.

        Supply its current element_ref if known. Otherwise exactly one visible
        Back/Navigate-up button must be present in the latest observation. No
        blind edge gestures or alternate SDK commands are attempted on failure.
        """
        # Serialize this lookup and action with other runtime work. The context
        # manager releases the lock on success, early return, or an exception.
        with runtime.lock:
            try:
                # An omitted reference is allowed only when the latest captured
                # targets contain exactly one native button with a Back label.
                if not element_ref:
                    # Each mapping entry pairs an opaque reference with observed
                    # identity fields; neither a screen coordinate nor a guessed selector is used.
                    candidates = [ref for ref, target in runtime._targets.items()
                                  if target['type'] == 'XCUIElementTypeButton' and target['label'] in {'Back','Navigate up'}]
                    if len(candidates) != 1:
                        raise ValueError('Observe a unique Back button or supply its current reference.')
                    element_ref = candidates[0]
                # Resolve the reference to a live, unique, visible, enabled button.
                # target keeps the captured identity; element is the Appium handle.
                element, target = runtime.resolve(element_ref, {'XCUIElementTypeButton'})
                # A valid button reference alone does not establish that it is Back.
                if target['label'] not in {'Back','Navigate up'}:
                    raise ValueError('The supplied control is not an observed Back button.')

                # Defining this callback does not tap yet. mutate invokes it after
                # validating limits and saving the action's intent receipt.
                def dispatch():
                    element.click()

                # Include both the requested reference and trusted identity in the
                # receipt. mutate captures the following UI and reports dispatch status.
                return runtime.mutate('go_back', dispatch, details={'element_ref':element_ref,'target':target})
            except Exception as error:
                # Turn lookup/validation failures into a saved BLOCKED result.
                return runtime.blocked('go_back', str(error))
    # Return the wrapped tool for the host to add to its available tool list.
    return go_back
