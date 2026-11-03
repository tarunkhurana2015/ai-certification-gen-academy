"""Deterministic checks over saved native UI evidence; no device or model calls."""
from copy import deepcopy
from datetime import datetime, timezone
import xml.etree.ElementTree as ET


def evaluate_ui_expectation(action_receipt, expectation):
    """Evaluate required native attributes after one acknowledged action.

    expectation configures exact native name/type and string-valued attributes.
    PASS proves those attributes in this captured state, not a transition,
    Search root, successful backend request, or the model's narrative.
    """
    action = action_receipt if isinstance(action_receipt, dict) else {}
    after = action.get('after_observation')
    after = after if isinstance(after, dict) else {}
    artifacts = after.get('artifacts', {})
    hierarchy = artifacts.get('hierarchy', {})
    screenshot = artifacts.get('screenshot', {})
    result = {
        'status': 'BLOCKED', 'reason': '',
        'evaluated_at': datetime.now(timezone.utc).isoformat(),
        'session_id': action.get('session_id'), 'action_status': action.get('status'),
        'expected': deepcopy(expectation),
        'observed': {'match_count': None, 'attributes': {}},
        'evidence': {
            'action_manifest': action.get('manifest_path'),
            'before_manifest': action.get('before_manifest_path'),
            'after_manifest': after.get('manifest_path'),
            'hierarchy': hierarchy.get('path'),
            'screenshot': screenshot.get('path') if screenshot.get('valid') is True else None,
        },
    }

    def finish(status, reason):
        result.update(status=status, reason=reason)
        return result

    if not isinstance(expectation, dict):
        return finish('BLOCKED', 'The host expectation must be a dictionary.')
    name, native_type = expectation.get('name'), expectation.get('type')
    required = expectation.get('attributes')
    if (not isinstance(name, str) or not name.strip()
            or not isinstance(native_type, str) or not native_type.startswith('XCUIElementType')
            or not isinstance(required, dict) or not required
            or not all(isinstance(k, str) and k and isinstance(v, str) for k, v in required.items())):
        return finish('BLOCKED', 'Configure native name/type and nonempty string-valued attributes before evaluation.')
    if (action.get('status') != 'acknowledged' or action.get('acknowledged') is not True
            or action.get('dispatch_requested') is not True or action.get('receipt_persisted') is not True
            or not action.get('manifest_path') or action.get('errors')):
        return finish('BLOCKED', 'An acknowledged, persisted action without operation errors is required.')
    target = action.get('target', {})
    if target.get('name') != name or target.get('type') != native_type:
        return finish('BLOCKED', 'The action targeted a different native element than the host expectation.')
    if (after.get('status') != 'complete' or after.get('receipt_persisted') is not True
            or not after.get('manifest_path') or after.get('errors')):
        return finish('BLOCKED', 'A complete, persisted post-action capture without capture errors is required.')
    if not action.get('session_id') or after.get('session_id') != action['session_id']:
        return finish('BLOCKED', 'The action and post-action capture do not identify the same session.')
    if (not action.get('observation_id') or not after.get('observation_id')
            or after['observation_id'] == action['observation_id']
            or after['manifest_path'] == action.get('before_manifest_path')):
        return finish('BLOCKED', 'Fresh post-action evidence is required; before-action evidence cannot verify the result.')
    if hierarchy.get('valid') is not True or not hierarchy.get('path'):
        return finish('BLOCKED', 'No valid saved hierarchy is available for evaluation.')
    try:
        root = ET.parse(hierarchy['path']).getroot()
    except (OSError, ET.ParseError) as error:
        return finish('BLOCKED', f'The saved hierarchy could not be read: {type(error).__name__}.')
    has_application = any(node.get('type', node.tag) == 'XCUIElementTypeApplication' for node in root.iter())
    if root.tag != 'AppiumAUT' or not has_application:
        return finish('BLOCKED', 'The artifact is not a recognized native iOS application hierarchy.')

    # Read full XML, not the bounded summary sent to the LLM.
    matches = [node for node in root.iter()
               if node.get('name') == name and node.get('type', node.tag) == native_type]
    result['observed']['match_count'] = len(matches)
    if not matches:
        return finish('FAIL', 'The required native element is absent from the complete post-action hierarchy.')
    if len(matches) != 1:
        return finish('BLOCKED', 'Multiple native elements match; the expected target is ambiguous.')
    observed = {key: matches[0].get(key) for key in required}
    result['observed'].update(name=name, type=native_type, attributes=observed)
    # XML attributes are strings: "0" is not selected merely because it is truthy in Python.
    mismatches = {key: observed[key] for key, expected in required.items()
                  if observed[key] is not None and observed[key] != expected}
    if mismatches:
        return finish('FAIL', f'Observed attributes differ from the expectation: {mismatches}.')
    missing = [key for key, value in observed.items() if value is None]
    if missing:
        return finish('BLOCKED', f'The hierarchy does not report required attributes: {missing}.')
    return finish('PASS', 'The uniquely observed native element matches every configured attribute.')
