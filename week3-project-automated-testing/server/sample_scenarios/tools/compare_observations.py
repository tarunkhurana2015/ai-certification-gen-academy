"""Compare explicit saved native attributes without inferring element identity."""
# Literal publishes the two supported comparison relations in the tool schema.
from typing import Literal

# The decorator builds a LangChain tool wrapper and argument schema. Host agent
# setup later makes that wrapper available to the LLM; importing does not run it.
from langchain_core.tools import tool

# Shared helpers validate registered observations, read saved XML, and select
# exactly one native attribute value without guessing a missing value.
from ._evidence import (
    _EvidenceUnavailable, _attribute_name, _hierarchy, _observation, _target, _unique_value,
)


def build_tool(runtime):
    """Bind one saved-observation comparison tool to the host runtime."""

    # runtime is supplied by trusted host code and captured by this closure.
    # Only the inner function's capture IDs/selectors/relation become LLM
    # arguments; callers do not supply a session, driver, or artifact path.
    @tool
    def compare_observations(
        before_id: str,
        after_id: str,
        native_name: str = "",
        native_type: str = "",
        label: str = "",
        attribute: str = "visible",
        relation: Literal["unchanged", "changed"] = "unchanged",
    ) -> dict:
        """Compare one explicit attribute of an exact target in two saved captures.

        Provide the same exact native_name or label for both captures, optionally
        narrowed by native_type. Each capture must contain exactly one matching
        element and explicitly report attribute. Missing/duplicate targets or
        unknown attributes block; XML strings such as "0" remain strings. A PASS
        proves only that these saved attribute values changed or stayed equal.
        It does not prove visual equality, object continuity, or an action cause.
        No new capture, device call, or guessed element identity is used.
        """
        # Serialize registry reads and receipt writes against other tools.
        # The reentrant runtime lock also allows record()/blocked() to lock.
        with runtime.lock:
            try:
                # Check that the bound session and the run deadline are valid.
                runtime.require_active()
                # Match every nonempty selector literally in each capture.
                # A type alone cannot identify the target: name or label is
                # required, with native_type available as an extra restriction.
                target = _target(native_name, native_type, label)
                # Attribute names must be explicit rather than empty strings.
                _attribute_name(attribute)
                # Validate runtime arguments as well as the schema annotation.
                if relation not in {"unchanged", "changed"}:
                    raise _EvidenceUnavailable("The comparison relation is unsupported.")
                # Comparing a capture with itself cannot establish a before/
                # after relation, so distinct registered IDs are required.
                if before_id == after_id:
                    raise _EvidenceUnavailable("Two distinct saved observations are required for comparison.")
                # Both IDs must exist in this runtime and belong to its session.
                before = _observation(runtime, before_id)
                after = _observation(runtime, after_id)
                # Read each full saved XML artifact, not the bounded summaries
                # included in observation responses for the LLM to browse.
                before_root, before_path = _hierarchy(runtime, before)
                after_root, after_path = _hierarchy(runtime, after)
                # Different IDs must also identify different hierarchy files.
                if before_path == after_path:
                    raise _EvidenceUnavailable("The observations must refer to distinct saved hierarchy captures.")
                # Each capture must have one exact target with an explicitly
                # reported attribute. Missing/duplicate targets or a missing
                # field block rather than supplying an invented value.
                before_value = _unique_value(before_root, target, attribute)
                after_value = _unique_value(after_root, target, attribute)
                # Compare strings as stored in XML, without boolean conversion,
                # screenshot analysis, or assumptions about object continuity.
                equal = before_value == after_value
                passed = equal if relation == "unchanged" else not equal
                # PASS/FAIL describes the requested relation between these two
                # values. It does not establish that an action caused a change
                # or that the entire screen remained visually equal.
                # record() adds receipt metadata and attempts to save the result.
                return runtime.record({
                    "operation": "compare_observations", "status": "PASS" if passed else "FAIL",
                    "reason": "The saved attribute values satisfy the requested relation." if passed
                              else "The saved attribute values do not satisfy the requested relation.",
                    # Keep the requested comparison and actual strings so the
                    # verdict can be checked against its saved evidence.
                    "before_id": before_id, "after_id": after_id, "target": target,
                    "attribute": attribute, "relation": relation,
                    "observed": {"before": before_value, "after": after_value},
                    # Cite each capture's manifest and full hierarchy artifact.
                    "evidence": {
                        "before_manifest": before.get("manifest_path"), "before_hierarchy": before_path,
                        "after_manifest": after.get("manifest_path"), "after_hierarchy": after_path,
                    },
                    # Limit the claim to the two saved explicit native values.
                    "scope": "saved_native_attribute_values_only",
                })
            except (RuntimeError, _EvidenceUnavailable) as error:
                # BLOCKED means there is insufficient valid evidence/session
                # context to compare; it is distinct from a measured FAIL.
                return runtime.blocked("compare_observations", str(error))

    # The caller receives the tool with its host runtime already bound.
    return compare_observations
