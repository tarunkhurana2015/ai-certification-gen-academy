"""Assert exact native UI facts using registered saved XML, without device I/O."""
# Literal lists the allowed operator spellings in the tool's argument schema.
from typing import Literal

# LangChain builds a tool wrapper and argument schema from the nested function;
# the host later passes that wrapper to the agent to make it available to the LLM.
from langchain_core.tools import tool

# These helpers validate host-registered evidence and exact XML selectors.
# They read saved artifacts; none asks the device for a new capture.
from ._evidence import (
    _EvidenceUnavailable, _attribute_name, _full_native_application, _hierarchy,
    _matches, _observation, _target,
)


def build_tool(runtime):
    """Bind one assertion tool to the host-owned session and capture registry."""

    # The host supplies runtime once when building the tool. The inner function
    # closes over it, so the LLM supplies assertion arguments, never a runtime,
    # Appium driver, session, or arbitrary file path.
    @tool
    def assert_ui(
        observation_id: str,
        native_name: str = "",
        native_type: str = "",
        label: str = "",
        attribute: str = "visible",
        operator: Literal["equals", "contains", "exists", "absent", "count_equals"] = "equals",
        expected: str = "true",
    ) -> dict:
        """Check exact native target facts in one registered saved observation.

        Supply an exact native_name or label, optionally narrowed by native_type.
        equals/contains compare explicit XML attribute strings; no boolean or
        selection-state inference is made. exists/absent check target existence;
        count_equals checks its total count against a nonnegative integer string.
        Ambiguous targets block except for count_equals. Missing attributes are
        unknown and block. Absence/counts require a recognized full native iOS
        application hierarchy. PASS applies only to this saved capture, without
        claiming current, future, backend, or visual state. No device calls occur.
        """
        # Keep the active session, observation registry, and receipt writes
        # consistent with other tools. The runtime uses a reentrant lock, so
        # record() and blocked() may acquire that same lock again safely.
        with runtime.lock:
            try:
                # Saved evidence still belongs to an active, bounded host run.
                runtime.require_active()
                # At least a native name or label is required. Every nonempty
                # selector is matched exactly, including native_type if given.
                target = _target(native_name, native_type, label)
                # Reject an empty attribute name rather than guessing a field.
                _attribute_name(attribute)
                # Resolve the ID only through this runtime's observation
                # registry, checking that the capture belongs to this session.
                observation = _observation(runtime, observation_id)
                # Parse the full saved XML artifact, not the bounded element
                # summary shown to the LLM; the returned path cites that file.
                root, path = _hierarchy(runtime, observation)
                # Inspect every XML node using all supplied exact selectors.
                matches = _matches(root, target)
                count = len(matches)
                # Recognize the full native iOS application source shape.
                # Absence and total counts need this stronger evidence boundary.
                full_native = _full_native_application(root)
                # Validate at runtime as well as describing allowed operators
                # in the Literal annotation used by the tool argument schema.
                if operator not in {"equals", "contains", "exists", "absent", "count_equals"}:
                    raise _EvidenceUnavailable("The assertion operator is unsupported.")
                # A value/existence assertion must identify at most one node.
                # Only count_equals deliberately permits several matches.
                if count > 1 and operator != "count_equals":
                    raise _EvidenceUnavailable("Multiple native elements match; the exact target is ambiguous.")
                # Retain the measured count even for attribute assertions.
                observed = {"match_count": count}
                if operator == "count_equals":
                    # Accept only an ASCII nonnegative integer string; signs,
                    # decimals, and inferred numeric conversions are excluded.
                    if not expected.isascii() or not expected.isdecimal():
                        raise _EvidenceUnavailable("count_equals requires a nonnegative integer string.")
                    if not full_native:
                        raise _EvidenceUnavailable("Counting requires a recognized full native application hierarchy.")
                    passed = count == int(expected)
                elif not count:
                    # With no target, only absent can pass. A recognized full
                    # hierarchy is required before treating no matches as absence.
                    if not full_native:
                        raise _EvidenceUnavailable("Absence cannot be established from an unrecognized or partial hierarchy.")
                    passed = operator == "absent"
                elif operator in {"exists", "absent"}:
                    # There is exactly one match here: existence passes and
                    # absence fails without reading any target attributes.
                    passed = operator == "exists"
                else:
                    # Element.get() returns the XML attribute string or None.
                    # A missing field is unknown evidence, not a false value.
                    value = matches[0].get(attribute)
                    if value is None:
                        raise _EvidenceUnavailable("The saved hierarchy does not report the requested attribute.")
                    observed["value"] = value
                    # Compare raw strings: "true", "false", and "0" are not
                    # converted to booleans or inferred selection states.
                    passed = value == expected if operator == "equals" else expected in value
                # PASS and FAIL both mean the assertion was evaluated from
                # available saved evidence. FAIL means the requested fact did
                # not hold; BLOCKED below means it could not be established.
                # record() adds metadata and attempts to persist the receipt;
                # callers can inspect the resulting receipt_persisted field.
                return runtime.record({
                    "operation": "assert_ui", "status": "PASS" if passed else "FAIL",
                    "reason": "The saved native evidence satisfies the assertion." if passed
                              else "The saved native evidence does not satisfy the assertion.",
                    # Link the measured target and requested comparison to the
                    # exact registered capture used for this decision.
                    "observation_id": observation_id, "target": target,
                    "expected": {"attribute": attribute, "operator": operator, "value": expected},
                    "observed": observed,
                    # Cite both the capture manifest and the full XML artifact.
                    "evidence": {"observation_manifest": observation.get("manifest_path"), "hierarchy": path},
                    # This verdict does not establish a newer device state,
                    # backend state, or the screenshot's visual appearance.
                    "scope": "saved_observation_only",
                })
            except (RuntimeError, _EvidenceUnavailable) as error:
                # Invalid evidence/session conditions are not assertion FAILs.
                # Return an explicit BLOCKED receipt explaining the boundary.
                return runtime.blocked("assert_ui", str(error))

    # Return the decorated tool, already bound to this host's runtime.
    return assert_ui
