"""Exact native text entry, with guarded clear/type operations."""
# The decorator supplies LangChain's model-callable wrapper and argument schema.
from langchain_core.tools import tool

# Restrict text operations to native editable input types, including search boxes.
_INPUTS = {'XCUIElementTypeTextField','XCUIElementTypeSearchField','XCUIElementTypeTextView'}


def build_tool(runtime):
    # The host binds its private runtime once through this closure. The model
    # supplies only the observed reference, literal text, and replacement choice.
    # @tool builds the callable wrapper; it does not clear or type during construction.
    @tool
    def enter_text(element_ref: str, text: str, replace: bool = True) -> dict:
        """Enter literal text in an observed input; preserve spaces and punctuation.

        replace=True clears first; an empty text clears the field. replace=False
        appends. Clear and type consume separate action units, reserved together
        before clearing. Native empty values can display placeholder text; final
        nonempty input is checked exactly. No automatic retries occur. Use UI
        assertions to confirm empty-search state or query results afterward.
        """
        # Keep the entire clear/type sequence serialized so another runtime action
        # cannot interleave. The lock is released on return or exception as well.
        with runtime.lock:
            try:
                # Reject an oversized request before resolving or changing a field.
                if len(text) > runtime.limits.max_input_characters:
                    raise ValueError('The requested text exceeds the configured input length limit.')
                # element is the live Appium handle; target is the captured identity
                # used to reacquire that same input after intermediate UI changes.
                element, target = runtime.resolve(element_ref, _INPUTS)
                # bool-to-int conversion charges one action for clearing, if asked,
                # and one for typing, if the supplied string contains any characters.
                cost = int(replace) + int(bool(text))
                if not cost:
                    # Empty text with replace=False requests no action at all.
                    return runtime.record({'operation':'enter_text','status':'COMPLETE','reason':'Nothing to append.'})
                # Check the complete sequence's action allowance before clearing;
                # the individual mutate calls consume their own action units later.
                runtime.require_budget(cost)
                # Each possible mutation captures another observation. Ensure both
                # clear and type can have evidence before performing either action.
                if len(runtime.observations) + cost > runtime.limits.max_observations:
                    raise RuntimeError('Insufficient observation budget for clear/type evidence.')
                # Keep the clear receipt for evidence checks and the combined result;
                # it remains None when the caller requests append-only behavior.
                clear_receipt = None
                if replace:
                    # This callback runs only when mutate dispatches the clear action.
                    def clear():
                        # Appium clears the original input, then we reacquire its
                        # trusted identity because clearing can rebuild native UI.
                        element.clear()
                        fresh = runtime.resolve_identity(target, _INPUTS)
                        # A cleared native input may report either an empty value
                        # or its placeholder, so read both attributes for comparison.
                        value = fresh.get_attribute('value')
                        placeholder = fresh.get_attribute('placeholderValue')
                        if value not in (None, '', placeholder):
                            raise RuntimeError('The input did not show an empty or placeholder state after clear.')
                        # Preserve raw native data and distinguish confirmed empty
                        # from the less certain empty-or-placeholder presentation.
                        return {'native_value':value,'placeholder':placeholder,
                                'empty_state':'empty' if value in (None,'') else 'empty_or_placeholder'}
                    # Save intent, perform the clear, and capture the resulting UI.
                    clear_receipt = runtime.mutate('clear_text', clear, details={'target':target})
                    # Default to an empty mapping when no after-observation exists,
                    # which makes the following completion checks fail safely.
                    after_clear = clear_receipt.get('after_observation', {})
                    # Typing may follow only if the SDK acknowledged the clear and
                    # both its receipt and complete after-observation were saved.
                    if (clear_receipt['status'] != 'ACKNOWLEDGED'
                            or clear_receipt.get('receipt_persisted') is not True
                            or after_clear.get('status') != 'complete'
                            or after_clear.get('receipt_persisted') is not True):
                        # Include the clear receipt so callers can inspect why the
                        # compound operation stopped before typing.
                        return runtime.record({'operation':'enter_text','status':'BLOCKED',
                                               'reason':'Clear did not complete with saved after-evidence; typing was not attempted.',
                                               'clear_receipt':clear_receipt})
                if not text:
                    # An empty replacement needs only the completed clear. Report
                    # whether its native value was definitely empty and reuse the
                    # clear's after-observation as evidence for this overall result.
                    return runtime.record({'operation':'enter_text','status':'ACKNOWLEDGED','clear_receipt':clear_receipt,
                                           'entered_value_verified':clear_receipt['dispatch_result']['empty_state']=='empty',
                                           'after_observation':clear_receipt['after_observation']})
                # Clear can invalidate old references/handles. Resolve the captured
                # identity again to obtain the live input before sending characters.
                fresh = runtime.resolve_identity(target, _INPUTS)
                old = fresh.get_attribute('value')
                placeholder = fresh.get_attribute('placeholderValue')
                # Appending requires knowing the actual existing value; a value
                # identical to placeholder text cannot establish that reliably.
                if not replace and placeholder and old == placeholder:
                    raise ValueError('The existing input is indistinguishable from its placeholder; appending is blocked.')
                # Replacements start with an empty prefix. Appends retain a known
                # existing value; None/empty are treated as no existing characters.
                prefix = '' if replace or old in (None, '') else old
                expected = prefix + text
                # A short append can still produce an overlong final field value.
                if len(expected) > runtime.limits.max_input_characters:
                    raise ValueError('The resulting text exceeds the input length limit.')

                # Define the typing callback now; mutate controls when it executes.
                def write():
                    # send_keys passes the supplied text to Appium without editing
                    # its spaces or punctuation, then re-read the live native value.
                    fresh.send_keys(text)
                    current = runtime.resolve_identity(target, _INPUTS).get_attribute('value')
                    # Exact equality checks the entire expected replacement/append.
                    if current != expected:
                        raise RuntimeError('The final native input value differs from the intended literal text.')
                    # These fields become dispatch_result in the mutation receipt.
                    return {'native_value':current,'entered_value_verified':True}
                # Request details preserve the target, literal text, and append/
                # replace choice. mutate also captures the screen after typing.
                receipt = runtime.mutate('enter_text', write, details={'target':target,'text':text,'replace':replace})
                if clear_receipt is not None:
                    # Link the two mutation receipts when typing followed clearing.
                    receipt['clear_receipt_id'] = clear_receipt['receipt_id']
                # Save the receipt again so the added clear link is persisted too.
                return runtime.record(receipt)
            except Exception as error:
                # Precondition/lookup failures become saved BLOCKED results. Errors
                # inside callbacks are handled separately by mutate as uncertainty.
                return runtime.blocked('enter_text', str(error))
    # Return the wrapped callable, with this runtime retained by its closure.
    return enter_text
