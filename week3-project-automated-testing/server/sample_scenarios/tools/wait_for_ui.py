"""Local bounded polling of native UI conditions, without model round trips."""
# monotonic measures elapsed time without wall-clock adjustments; sleep spaces
# out local probes so the loop does not continuously request device source.
from time import monotonic, sleep
# Literal describes the supported operator names in the generated tool schema.
from typing import Literal
# Reject NaN/infinite timeout values before doing deadline arithmetic.
import math
# ElementTree parses full native XML, both from live probes and saved evidence.
import xml.etree.ElementTree as ET
# The decorator builds the tool wrapper/schema; host agent setup exposes it later.
from langchain_core.tools import tool
# Reuse exact native selector matching and the expected full-application shape.
from ._evidence import _full_native_application, _matches, _target


# A local helper for both live XML probes and the final persisted XML capture.
# Reusing the predicate means both stages check the same requested condition.
def _condition(root, target, attribute, operator, expected):
    # A partial or unrecognized tree cannot establish this native condition.
    if not _full_native_application(root):
        raise ValueError('A complete native application hierarchy is required.')
    # Every nonempty name/type/label selector must equal the XML value exactly.
    matches = _matches(root, target)
    if operator == 'count_equals':
        # Counts use an explicit nonnegative ASCII integer string, not a float
        # or a conversion of arbitrary input into a numeric expectation.
        if not expected.isascii() or not expected.isdecimal():
            raise ValueError('Expected count must be a nonnegative integer.')
        return len(matches) == int(expected)
    if operator == 'absent':
        # An empty match list makes the absence predicate true.
        return not matches
    if operator == 'exists':
        # This helper requires unique existence, not merely one-or-more matches.
        return len(matches) == 1
    if len(matches) != 1:
        # Attribute checks must identify exactly one node. Missing or ambiguous
        # targets keep this probe false so polling may continue.
        return False
    # Read the explicit XML attribute string rather than infer a UI state.
    value = matches[0].get(attribute)
    if value is None:
        # A missing field does not satisfy the requested condition.
        return False
    # For the equals/contains cases, use raw string equality or substring search.
    return value == expected if operator == 'equals' else expected in value


def build_tool(runtime):
    # Trusted host code supplies runtime. The nested function closes over the
    # session, limits, and registry; the LLM supplies only the condition/timeout.
    @tool
    def wait_for_ui(native_name: str = '', label: str = '', native_type: str = '',
                    attribute: str = 'visible', operator: Literal['equals','contains','exists','absent','count_equals'] = 'equals',
                    expected: str = 'true', timeout_seconds: float = 8) -> dict:
        """Wait locally for an exact native condition, then return persisted fresh evidence.

        Supply a native_name or label from observations, optionally narrowed by
        native_type. Polls full native source without extra LLM calls. The timeout
        is at most 20 seconds and within the run deadline; SDK request timeouts
        also apply. A matching probe is rechecked in the saved final capture.
        TIMEOUT is not proof of a particular application defect.
        """
        # Keep other tools from changing session/observation state during this
        # wait. This is a reentrant lock, so observe()/record() may also lock.
        with runtime.lock:
            try:
                # The accepted local timeout must be finite, positive, and no
                # longer than 20 seconds, regardless of the caller's schema.
                if not math.isfinite(timeout_seconds) or not 0 < timeout_seconds <= 20:
                    raise ValueError('Wait timeout must be positive and at most20 seconds.')
                # Require an exact name or label; native_type can narrow it.
                target = _target(native_name, native_type, label)
                # Respect both this wait's limit and the enclosing run's
                # remaining time. This local check does not interrupt an SDK
                # request already in progress; its request timeout also applies.
                deadline = monotonic() + min(timeout_seconds, runtime.timeout_seconds_remaining())
                polls = 0
                while monotonic() < deadline:
                    # Check the foreground app before reading its native tree.
                    runtime.require_own_app()
                    # Ask Appium for fresh full native XML directly. These
                    # probes happen in Python without extra LLM round trips;
                    # they are not individually persisted observations.
                    root = ET.fromstring(runtime.session.driver.page_source)
                    polls += 1
                    if _condition(root, target, attribute, operator, expected):
                        # A live match is provisional: capture and register
                        # evidence that can be returned and inspected later.
                        observation = runtime.observe()
                        artifact = observation.get('artifacts', {}).get('hierarchy', {})
                        # Require a complete capture, its persisted receipt,
                        # and a valid hierarchy artifact before claiming success.
                        if (observation.get('status') != 'complete'
                                or observation.get('receipt_persisted') is not True
                                or not artifact.get('valid')):
                            return runtime.blocked('wait_for_ui', 'The matching state could not be saved as complete evidence.')
                        # Re-read the full saved XML, not the bounded element
                        # summary. The UI might change between probe and capture.
                        saved = ET.parse(artifact['path']).getroot()
                        if _condition(saved, target, attribute, operator, expected):
                            # COMPLETE means the condition was checked in the
                            # returned saved capture. It is not a visual PASS
                            # claim or a promise about later device state.
                            return runtime.record({'operation': 'wait_for_ui', 'status': 'COMPLETE', 'polls': polls,
                                                   'condition_met': True, 'observation': observation})
                    # Sleep at most a quarter-second and at most the remaining
                    # local interval. max(0, ...) prevents a negative delay.
                    sleep(min(.25, max(0, deadline - monotonic())))
                # Preserve a final diagnostic observation after polling ends.
                # Capturing it can itself consume time beyond the loop deadline.
                observation = runtime.observe()
                # TIMEOUT means this wait did not confirm a matching saved
                # capture in its loop. It does not prove an application defect;
                # inspect the attached observation's own status and artifacts.
                return runtime.record({'operation': 'wait_for_ui', 'status': 'TIMEOUT', 'condition_met': False,
                                       'polls': polls, 'observation': observation})
            except Exception as error:
                # Input, session, device, or XML errors produce a BLOCKED
                # receipt rather than masquerading as an assertion FAIL.
                return runtime.blocked('wait_for_ui', str(error))
    # Return the wrapped tool with runtime already bound by the host.
    return wait_for_ui
