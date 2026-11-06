"""Private saved-evidence validation shared by the public tool factories."""
# Path resolves artifact locations; ElementTree reads the saved native XML tree.
from pathlib import Path
import xml.etree.ElementTree as ET


# A dedicated error lets tools explain missing/ambiguous evidence as BLOCKED.
# Leading underscores mark these as internal helpers, not model-callable tools.
class _EvidenceUnavailable(ValueError):
    """An evidence boundary could not be established safely."""


def _observation(runtime, observation_id):
    """Return only a registered capture belonging to the active host session."""
    # The model must name a capture already registered by this run, not a file path.
    if not isinstance(observation_id, str) or not observation_id.strip():
        raise _EvidenceUnavailable("An explicit registered observation ID is required.")
    # This dictionary is populated by runtime.observe(), not by the human CSV.
    observation = runtime.observations.get(observation_id)
    if not isinstance(observation, dict):
        raise _EvidenceUnavailable("The observation ID is not registered in this runtime.")
    # Check both the lookup key and the ID inside its stored receipt agree.
    if observation.get("observation_id") != observation_id:
        raise _EvidenceUnavailable("The registered observation identity is inconsistent.")
    # Do not use a previous Appium session's screenshot/XML in the current session.
    if observation.get("session_id") != runtime.session.session_id:
        raise _EvidenceUnavailable("The observation belongs to a different session.")
    return observation


def _artifact_path(runtime, observation, kind):
    """Resolve a valid host-registered artifact confined to the session root."""
    # kind selects an evidence entry such as "hierarchy" or "screenshot".
    artifacts = observation.get("artifacts", {})
    artifact = artifacts.get(kind, {}) if isinstance(artifacts, dict) else {}
    if not isinstance(artifact, dict) or artifact.get("valid") is not True:
        raise _EvidenceUnavailable(f"No valid saved {kind} artifact is registered.")
    # Read the registered artifact path, never an arbitrary path proposed by the LLM.
    raw_path = artifact.get("path")
    if not isinstance(raw_path, str) or not raw_path:
        raise _EvidenceUnavailable(f"The saved {kind} artifact has no registered path.")
    try:
        # Resolve symlinks and require both paths to exist before comparing them.
        root = Path(runtime.session.artifact_root).resolve(strict=True)
        path = Path(raw_path).resolve(strict=True)
        # The file must be inside this session's evidence directory. A symlink
        # pointing outside that directory is rejected after resolve().
        if not path.is_relative_to(root) or not path.is_file():
            raise _EvidenceUnavailable(f"The saved {kind} artifact is outside the session artifact root.")
    except (OSError, RuntimeError, ValueError) as error:
        # Preserve our specific explanation; wrap lower-level filesystem errors below.
        if isinstance(error, _EvidenceUnavailable):
            raise
        raise _EvidenceUnavailable(f"The saved {kind} artifact is unavailable.") from error
    return path


def _hierarchy(runtime, observation):
    """Parse the full saved native XML rather than the model's bounded summary."""
    # Reuse the same path/session checks as screenshot tools before reading XML.
    path = _artifact_path(runtime, observation, "hierarchy")
    try:
        # Read the full saved hierarchy. The short summary given to the model can
        # omit elements, so it is not enough for deterministic counts/absence checks.
        root = ET.parse(path).getroot()
    except (OSError, ET.ParseError, ValueError, LookupError) as error:
        raise _EvidenceUnavailable("The saved hierarchy is not readable valid XML.") from error
    # Return both the parsed tree and its path, so the assertion can cite its source.
    return root, str(path)


def _full_native_application(root):
    """Recognize the complete native iOS source shape emitted by Appium."""
    # AppiumAUT wrapping an application is the expected complete native iOS shape.
    # This recognizes the shape; it does not claim every logical screen element
    # (for example items not loaded yet) is present in the accessibility tree.
    return root.tag == "AppiumAUT" and any(
        node.get("type", node.tag) == "XCUIElementTypeApplication" for node in root
    )


def _target(native_name, native_type, label):
    """Require explicit exact identity; a type alone does not identify a target."""
    # Selectors are exact strings from observed XML. A type alone could match
    # every button on the screen, so require a name or label as well.
    if not all(isinstance(value, str) for value in (native_name, native_type, label)):
        raise _EvidenceUnavailable("Native target selectors must be strings.")
    if not native_name.strip() and not label.strip():
        raise _EvidenceUnavailable("Specify an exact native name or label; a type alone is insufficient.")
    # Normalize public argument names to the native XML attribute names.
    return {"name": native_name, "type": native_type, "label": label}


def _matches(root, target):
    """Match only the exact selectors provided by the caller, without inference."""
    # root.iter() visits every XML node. Empty selectors are ignored; nonempty
    # selectors must all match exactly. There is no fuzzy matching or inferred ID.
    return [node for node in root.iter()
            if (not target["name"] or node.get("name") == target["name"])
            and (not target["type"] or node.get("type", node.tag) == target["type"])
            and (not target["label"] or node.get("label") == target["label"])]


def _attribute_name(attribute):
    """Validate a requested XML attribute without inventing a default value."""
    # Do not silently choose an attribute or invent its value for the assertion.
    if not isinstance(attribute, str) or not attribute.strip():
        raise _EvidenceUnavailable("An explicit native attribute name is required.")
    return attribute


def _unique_value(root, target, attribute):
    """Return a single explicit XML value or explain why comparison is unknown."""
    # Attribute comparison needs one unambiguous native element in each capture.
    matches = _matches(root, target)
    if len(matches) != 1:
        raise _EvidenceUnavailable("The exact target must match one native element in each observation.")
    # Missing is different from false/empty: an absent attribute is unknown evidence.
    value = matches[0].get(attribute)
    if value is None:
        raise _EvidenceUnavailable("The saved hierarchy does not report the requested attribute.")
    return value
