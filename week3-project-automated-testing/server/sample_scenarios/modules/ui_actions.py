"""Grounded, single-click iOS exercises; device work happens only on function calls."""
from collections import Counter
from dataclasses import dataclass, field
from datetime import datetime, timezone
from threading import Lock, RLock
from uuid import uuid4

from appium.webdriver.common.appiumby import AppiumBy
from .observations import (
    _persist_ui_receipt, _receipt_folder, _record_error, _ui_receipt,
    observe_session_ui,
)


@dataclass
class _ActionState:
    session_id: str
    lock: object = field(default_factory=RLock)
    observation_id: str | None = None
    targets: dict = field(default_factory=dict)
    tap_reserved: bool = False


_state_lock = Lock()


def _state_for(session):
    # Tool calls can run in parallel. Create one state/lock per host-owned session.
    with _state_lock:
        if not hasattr(session, '_ui_action_state'):
            session._ui_action_state = _ActionState(session.session_id)
        return session._ui_action_state


def _require_active_session(session, state):
    if not session.active:
        raise RuntimeError('The session is inactive. Start a new session.')
    if session.driver.session_id != session.session_id or state.session_id != session.session_id:
        raise RuntimeError('The driver session changed; old element references cannot be used.')


def observe_actionable_ui(session):
    """Capture UI and give eligible buttons references valid for this observation only."""
    state = _state_for(session)
    with state.lock:
        # Even a failed observation invalidates all earlier references.
        state.targets.clear()
        state.observation_id = 'obs_' + uuid4().hex[:12]
        _require_active_session(session, state)
        receipt = observe_session_ui(session)
        receipt['observation_id'] = state.observation_id
        pending_targets = {}
        if receipt['status'] == 'complete' and receipt['receipt_persisted']:
            elements = receipt['ui_summary']['elements']
            counts = Counter(element['name'] for element in elements if element['name'])
            for index, element in enumerate(elements):
                if (element['type'] != 'XCUIElementTypeButton'
                        or element['enabled'] is not True or element['accessible'] is not True
                        or not element['name'] or counts[element['name']] != 1
                        or element.get('truncated_fields')):
                    continue
                ref = f'{state.observation_id}:e{index}'
                element['element_ref'] = ref
                pending_targets[ref] = {
                    'name': element['name'], 'type': element['type'], 'label': element['label'],
                    'observation_id': state.observation_id, 'before_manifest_path': receipt['manifest_path'],
                }
        if receipt.get('manifest_path') and _persist_ui_receipt(receipt):
            state.targets = pending_targets
        else:
            # Do not expose actionable references without their persisted evidence.
            for element in receipt['ui_summary']['elements']:
                element.pop('element_ref', None)
        return receipt


def tap_session_element(session, element_ref: str, *, expected_label: str):
    """Tap one permitted observed button, then capture fresh post-action evidence.

    expected_label comes from host configuration, never from the tool-call arguments.
    One dispatch is allowed per session, including when its response is uncertain.
    Acknowledgment is not proof of the requested navigation outcome.
    """
    receipt = _ui_receipt(session.driver, 'tap_observed_element')
    receipt.update(status='rejected', element_ref=element_ref, dispatch_requested=False,
                   acknowledged=False, effect_verified=False, receipt_persisted=False)
    try:
        folder = _receipt_folder(session.artifact_root, 'tap-')
        receipt['manifest_path'] = str(folder / 'manifest.json')
        state = _state_for(session)
        with state.lock:
            _require_active_session(session, state)
            if state.tap_reserved:
                raise ValueError('The session has already used its one click attempt; do not retry.')
            target = state.targets.get(element_ref)
            state.targets.clear()  # Consume references; another attempt requires a fresh observation.
            if target is None or target['observation_id'] != state.observation_id:
                raise ValueError('Use an element_ref returned by the latest successful observation.')
            if target['label'] != expected_label:
                raise ValueError(f'This exercise permits only the {expected_label!r} button.')
            receipt.update(observation_id=target['observation_id'],
                           before_manifest_path=target['before_manifest_path'], target=target)
            matches = session.driver.find_elements(AppiumBy.ACCESSIBILITY_ID, target['name'])
            receipt['match_count'] = len(matches)
            if len(matches) != 1:
                raise ValueError('The live target is missing or ambiguous; click blocked.')
            element = matches[0]
            current = {key: element.get_attribute(key) for key in ('type', 'name', 'label')}
            receipt['live_element'] = current
            if any(current[key] != target[key] for key in ('type', 'name', 'label')):
                raise ValueError('The live target differs from the observed target; click blocked.')
            if element.is_displayed() is not True or element.is_enabled() is not True:
                raise ValueError('The live target is not displayed and enabled; click blocked.')
            receipt.update(status='dispatch_pending', dispatch_requested=True)
            if not _persist_ui_receipt(receipt):
                receipt.update(status='rejected', dispatch_requested=False,
                               reason='Click blocked because its intent receipt could not be saved.')
                return receipt
            state.tap_reserved = True
            try:
                element.click()  # Exactly one dispatch. Never retry an uncertain response.
                receipt.update(status='acknowledged', acknowledged=True)
            except Exception as error:
                receipt['status'] = 'uncertain'
                _record_error(receipt, 'click_dispatch', error)
            # Always attempt post-action evidence, including after an uncertain response.
            try:
                receipt['after_observation'] = observe_actionable_ui(session)
            except Exception as error:
                receipt['after_observation'] = {'status': 'failed', 'ui_summary': {'status': 'unavailable', 'elements': []}}
                _record_error(receipt, 'after_observation', error)
    except Exception as error:
        receipt['reason'] = str(error)
        _record_error(receipt, 'before_dispatch', error)
    finally:
        receipt['completed_at'] = datetime.now(timezone.utc).isoformat()
        if receipt.get('manifest_path'):
            _persist_ui_receipt(receipt)
    return receipt
