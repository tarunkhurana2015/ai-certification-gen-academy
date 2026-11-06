"""Host-owned state shared by the tools; no device commands run on import."""
# The public tool files delegate shared session, targeting, and receipt work here.
# Nothing in this module chooses tools for a test case; the LLM makes that choice.

# These standard-library helpers provide configuration, paths, locking, clocks,
# unique IDs, JSON receipts, temporary files, and XML parsing.
from dataclasses import dataclass
from pathlib import Path
from threading import RLock
from time import monotonic
from uuid import uuid4
from datetime import datetime, timezone
import json
import math
import tempfile
import xml.etree.ElementTree as ET

# AppiumBy names locator strategies; observe_session_ui performs the actual capture.
from appium.webdriver.common.appiumby import AppiumBy
from modules.observations import observe_session_ui


def _now():
    # UTC wall-clock timestamps are readable in saved reports; they are not timers.
    return datetime.now(timezone.utc).isoformat()


def _xpath_literal(value):
    # Construct an XPath string literal from an observed attribute. XPath has
    # different quote rules from Python: use the other quote or concat() as needed.
    if "'" not in value:
        return "'" + value + "'"
    if '"' not in value:
        return '"' + value + '"'
    # If the value contains both quote types, join safely quoted pieces in XPath.
    parts = value.split("'")
    return 'concat(' + ', "\'", '.join("'" + part + "'" for part in parts) + ')'


# dataclass generates the constructor for these limits. frozen=True prevents
# accidentally changing a limit partway through a run.
@dataclass(frozen=True)
class ToolLimits:
    # Action units count dispatched operations; clear+type and relaunch each cost two.
    max_actions: int = 30
    # Scrolls also consume action units, but have their own smaller cap.
    max_scrolls: int = 8
    # Captures include the automatic after-observations returned by actions.
    max_observations: int = 70
    # A run deadline stops NEW dispatches; it cannot cancel a request already sent.
    timeout_seconds: float = 180
    # Bound literal input length to keep accidental large text entry contained.
    max_input_characters: int = 1000

    # dataclasses call this automatically after their generated constructor.
    def __post_init__(self):
        # bool is a subclass of int in Python, so explicitly reject True/False as limits.
        if any(not isinstance(v, int) or isinstance(v, bool) or v < 1
               for v in (self.max_actions, self.max_scrolls, self.max_observations, self.max_input_characters)):
            raise ValueError('Tool count/input limits must be positive integers.')
        # Reject zero, negative, infinity, and NaN rather than creating an unusable timer.
        if not math.isfinite(self.timeout_seconds) or self.timeout_seconds <= 0:
            raise ValueError('The run timeout must be positive and finite.')


class ToolRuntime:
    """One toolkit for a manually started app session; no CSV-specific routing."""
    def __init__(self, bundle_id, *, limits=None, tmdb_token=None, prepared_conditions=None, request_probe=None):
        # self stores this one runtime's state. These host values are captured by
        # the tools, not exposed as model-selectable tool arguments.
        # bundle_id identifies the app this run is allowed to control.
        self.bundle_id = bundle_id
        self.limits = limits or ToolLimits()
        # Only the optional live-data tool uses this credential; do not print it.
        self.tmdb_token = tmdb_token
        # Optional host evidence/probes support special environment checks. They
        # do not themselves turn off connectivity or create storage failures.
        self.prepared_conditions = prepared_conditions or {}
        self.request_probe = request_probe
        # Serialize tools sharing one driver. RLock allows the same thread to
        # enter nested helpers, such as mutate() calling observe() and record().
        # "with self.lock" releases the lock automatically even if an error occurs.
        self.lock = RLock()
        # The notebook attaches a live session later via start_run(); construction
        # here does not create an Appium server, session, or device connection.
        self.session = None
        # Map observation_id -> capture receipt (XML/PNG paths, summary, provenance).
        self.observations = {}
        # The operation journal records checks/actions for the final local report.
        self.receipts = []
        self.last_observation_id = None
        # Track an external app opened through a recorded action, such as a trailer link.
        self.external_handoff = None
        # Map opaque element_ref -> trusted native identity from the latest capture.
        # Leading underscores denote internal state the model must not edit.
        self._targets = {}
        self._open = False
        # monotonic() measures elapsed time without changes to the system clock.
        self._deadline = 0
        self._run_dir = None
        # Remember the exact Appium session so references cannot cross sessions.
        self._bound_session_id = None
        self.actions_used = self.scrolls_used = 0
        # If a mutation response is lost, we cannot safely know whether it happened.
        # Mark the run uncertain and block additional mutations instead of retrying.
        self.uncertain = False

    # The notebook calls this after start_ios_session(); all tools then share this session.
    def start_run(self, session):
        with self.lock:
            # Rebinding an open runtime could mix two sessions' targets and evidence.
            if self._open:
                raise RuntimeError('Finish the current toolkit run before attaching another session.')
            # Compare the managed session and live driver IDs before accepting ownership.
            if session.active is not True or not session.session_id or session.driver.session_id != session.session_id:
                raise ValueError('Attach a live, unchanged Appium session.')
            self.session = session
            self._bound_session_id = session.session_id
            # Convert a duration into an absolute monotonic deadline for this run.
            self._deadline = monotonic() + self.limits.timeout_seconds
            # Put tool journal receipts inside a unique subfolder of this session's evidence.
            self._run_dir = Path(session.artifact_root) / ('toolkit-' + uuid4().hex[:12])
            self._run_dir.mkdir(parents=True)
            self._open = True
            # A new manually selected run starts with no old references, captures, or counts.
            self.observations = {}
            self.receipts = []
            self._targets = {}
            self.last_observation_id = None
            self.external_handoff = None
            self.actions_used = self.scrolls_used = 0
            self.uncertain = False

    # Close tool access while retaining observations/receipts for report generation.
    # This does not quit Appium; the notebook separately calls stop_ios_session().
    def end_run(self):
        with self.lock:
            self._targets.clear()
            self._open = False

    def timeout_seconds_remaining(self):
        # Clamp at zero so callers never receive a negative remaining duration.
        return max(0.0, self._deadline - monotonic()) if self._open else 0.0

    # Shared guard: fail early if the run/session is closed, replaced, or expired.
    def require_active(self):
        if not self._open or self.session is None or self.session.active is not True:
            raise RuntimeError('The toolkit has no active app session.')
        if self.session.session_id != self._bound_session_id or self.session.driver.session_id != self._bound_session_id:
            raise RuntimeError('The Appium session changed; old references cannot be used.')
        if self.timeout_seconds_remaining() <= 0:
            raise TimeoutError('The toolkit run deadline has expired.')

    # Ask XCUITest which native application currently has foreground focus.
    def active_app(self):
        self.require_active()
        # "mobile:" is an Appium driver command, not JavaScript injected into the app.
        info = self.session.driver.execute_script('mobile: activeAppInfo')
        if not isinstance(info, dict) or not info.get('bundleId'):
            raise RuntimeError('The foreground application could not be identified.')
        return info

    # Keep ordinary actions on the configured app; returning from an external app
    # requires an explicit lifecycle tool rather than silently interacting there.
    def require_own_app(self):
        info = self.active_app()
        if info['bundleId'] != self.bundle_id:
            raise RuntimeError('The configured app is not in the foreground; use return_to_app.')
        return info

    # A receipt is an ordinary dictionary documenting one operation and its evidence.
    # Save it atomically, then retain it in the in-memory journal as well.
    def record(self, receipt):
        with self.lock:
            # setdefault fills missing fields; recording an existing receipt keeps its ID.
            receipt.setdefault('receipt_id', 'receipt_' + uuid4().hex[:12])
            receipt.setdefault('session_id', self._bound_session_id)
            receipt.setdefault('recorded_at', _now())
            receipt.setdefault('errors', [])
            # Do not claim a saved receipt until writing/replacing the JSON succeeds.
            receipt['receipt_persisted'] = False
            # A tool called before start_run() can still return an explanatory result,
            # but there is no owned run directory in which to persist it.
            if self._run_dir is None:
                return receipt
            destination = self._run_dir / (receipt['receipt_id'] + '.json')
            receipt.setdefault('manifest_path', str(destination))
            # Always use our destination, never a path supplied by a model/tool result.
            if Path(receipt['manifest_path']).resolve() != destination.resolve():
                receipt['manifest_path'] = str(destination)
            # Write to a sibling temporary file, then replace the destination. This
            # avoids leaving a half-written JSON receipt if serialization/write fails.
            temporary = None
            try:
                # Include the successful-persistence flag in the intended disk version;
                # the except branch resets it if any write/replace step fails.
                receipt['receipt_persisted'] = True
                with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=self._run_dir,
                                                 prefix='.receipt-', delete=False) as file:
                    temporary = Path(file.name)
                    # Reject non-JSON NaN/infinity; downstream reports need valid JSON.
                    json.dump(receipt, file, indent=2, allow_nan=False)
                # Same-directory replacement publishes the complete JSON file atomically.
                temporary.replace(destination)
            # Preserve the operation result in memory even if its receipt cannot be saved.
            except (OSError, TypeError, ValueError) as error:
                receipt['receipt_persisted'] = False
                receipt['errors'].append({'stage':'persist_receipt', 'type':type(error).__name__})
            finally:
                if temporary is not None:
                    try:
                        # Clean up a leftover temp file; a successful replace already removed it.
                        temporary.unlink(missing_ok=True)
                    except OSError:
                        pass
            # Journal a receipt once. Its dictionary can be updated and saved again
            # as DISPATCH_PENDING becomes ACKNOWLEDGED/UNCERTAIN/REJECTED.
            if not any(item['receipt_id'] == receipt['receipt_id'] for item in self.receipts):
                self.receipts.append(receipt)
            return receipt

    # BLOCKED means a prerequisite/evidence boundary prevented a supported check/action;
    # it is not proof of an application defect.
    def blocked(self, operation, reason):
        return self.record({'operation': operation, 'status': 'BLOCKED', 'reason': str(reason)})

    # Capture the live app, then issue references that later action tools can validate.
    def observe(self):
        with self.lock:
            # Invalidate old references even if this new capture subsequently fails.
            self._targets.clear()
            try:
                self.require_own_app()
                if len(self.observations) >= self.limits.max_observations:
                    raise RuntimeError('The observation limit is exhausted.')
                # The existing helper captures native XML and PNG and writes its manifest.
                receipt = observe_session_ui(self.session)
                # This unique capture ID differs from a native name/semantics identifier.
                observation_id = 'obs_' + uuid4().hex[:12]
                receipt['observation_id'] = observation_id
                self.last_observation_id = observation_id
                self.observations[observation_id] = receipt
                # References are issued only from a complete saved capture with valid XML.
                hierarchy = receipt.get('artifacts', {}).get('hierarchy', {})
                if receipt['status'] == 'complete' and receipt['receipt_persisted'] and hierarchy.get('valid'):
                    root = ET.parse(hierarchy['path']).getroot()
                    # Read every visible native element for uniqueness checks, not just
                    # the bounded summary that will be sent to the LLM.
                    native = [node.attrib for node in root.iter() if node.get('visible') == 'true']
                    receipt['keyboard_visible'] = any(a.get('type') == 'XCUIElementTypeKeyboard' for a in native)
                    # Add actionable references to the concise summary the model can read.
                    for index, element in enumerate(receipt['ui_summary']['elements']):
                        # Together, type/name/label describe the observed native identity.
                        identity = {key: element.get(key) for key in ('type','name','label')}
                        # Cropped names and anonymous controls are insufficient for exact targeting.
                        if element.get('truncated_fields') or not (identity['name'] or identity['label']):
                            continue
                        # The same identity must identify exactly one visible element in the full XML.
                        matches = [a for a in native if all(a.get(k) == v for k,v in identity.items())]
                        if len(matches) != 1:
                            continue
                        # Return an opaque handle instead of letting the model construct XPath.
                        ref = f'{observation_id}:e{index}'
                        # Save observed geometry for optional bounded scrolling containers.
                        rect = {k: float(matches[0].get(k, 0)) for k in ('x','y','width','height')}
                        element['element_ref'] = ref
                        element['rect'] = rect
                        # Keep the authoritative identity privately; do not trust later model rewrites.
                        self._targets[ref] = {**identity, 'observation_id': observation_id, 'rect': rect}
                # The registered receipt keeps its original capture manifest; record a wrapper.
                wrapper = self.record({'operation':'observe_current_ui','status':receipt['status'],
                                       'observation_id':observation_id,'capture_manifest_path':receipt.get('manifest_path')})
                receipt['tool_receipt_path'] = wrapper.get('manifest_path')
                # Persist added opaque refs into the trusted capture manifest as well.
                if receipt.get('manifest_path'):
                    from modules.observations import _persist_ui_receipt
                    # References added in memory also need a persisted capture manifest.
                    if not _persist_ui_receipt(receipt):
                        self._targets.clear()
                        for element in receipt['ui_summary']['elements']:
                            # Do not offer a model a handle whose final capture was not saved.
                            element.pop('element_ref', None)
                return receipt
            except Exception as error:
                self._targets.clear()
                self.last_observation_id = None
                return self.blocked('observe_current_ui', f'Observation unavailable: {type(error).__name__}: {error}')

    # Resolve a model-provided opaque handle to a freshly validated Appium element.
    def resolve(self, element_ref, allowed_types=None):
        self.require_own_app()
        # A forged/expired handle is absent from this latest-capture registry.
        target = self._targets.get(element_ref)
        # Even a once-valid handle must not be used after another observation/action.
        if target is None or target['observation_id'] != self.last_observation_id:
            raise ValueError('Use an element_ref from the latest successful observation.')
        if allowed_types and target['type'] not in allowed_types:
            raise ValueError('This native element type is not supported for the requested action.')
        # Return both the live Appium object and its trusted identity for the receipt.
        return self.resolve_identity(target, allowed_types), target

    def resolve_identity(self, target, allowed_types=None):
        """Reacquire a trusted identity after an intentional intermediate change."""
        self.require_own_app()
        if allowed_types and target['type'] not in allowed_types:
            raise ValueError('This native type is not supported for this action.')
        # Build exact XPath equality conditions from captured native values only.
        predicates = []
        for key in ('type','name','label'):
            value = target[key]
            if value is not None:
                # Quote each observed value correctly, including embedded quote characters.
                predicates.append(f'@{key}={_xpath_literal(value)}')
        # Selector values originate only from the captured native tree, not tool arguments.
        xpath = '//*[' + ' and '.join(predicates) + ']'
        # Ask the current live tree again; the screen may have changed since capture.
        matches = self.session.driver.find_elements(AppiumBy.XPATH, xpath)
        if len(matches) != 1:
            raise ValueError('The live native target is missing or ambiguous.')
        # Selecting index zero is safe only after the exact-one-match check above.
        element = matches[0]
        # Recheck attributes on the returned object, plus visibility/enabled state below.
        for key in ('type','name','label'):
            if element.get_attribute(key) != target[key]:
                raise ValueError('The live target differs from the observed identity.')
        if element.is_displayed() is not True or element.is_enabled() is not True:
            raise ValueError('The live target is not displayed and enabled.')
        return element

    # Compound tools check their total cost before doing a partial operation.
    def require_budget(self, actions, scrolls=0):
        """Call under lock before a compound operation; keep the lock until done."""
        self.require_active()
        if self.uncertain:
            raise RuntimeError('An earlier mutation is uncertain; further mutations are blocked.')
        # Checking does not consume units. mutate() increments counters only at dispatch.
        if self.actions_used + actions > self.limits.max_actions:
            raise RuntimeError('Insufficient action budget for the complete operation.')
        if self.scrolls_used + scrolls > self.limits.max_scrolls:
            raise RuntimeError('Insufficient scroll budget for the complete operation.')

    # Shared mutation lifecycle: validate -> save intent -> dispatch once -> capture -> save.
    # callback is a small Python function containing the actual Appium action. Merely
    # passing callback here does not run it; callback() below is the execution point.
    def mutate(self, operation, callback, *, action_cost=1, details=None, dispatch_deadline=None):
        with self.lock:
            # Start conservatively: nothing is acknowledged and no outcome is verified.
            receipt = {'operation':operation,'status':'REJECTED','dispatch_requested':False,
                       'acknowledged':False,'effect_verified':False,'started_at':_now(),
                       'action_cost':action_cost, 'request':details or {}}
            try:
                self.require_active()
                # These two lifecycle tools may explicitly reactivate the owned app
                # while an external destination is currently in the foreground.
                if operation not in {'return_to_app','relaunch_app'}:
                    self.require_own_app()
                # A lost response could still mean the previous action happened; do not retry.
                if self.uncertain:
                    raise RuntimeError('An earlier mutation is uncertain; inspect evidence and restart manually before more actions.')
                if not isinstance(action_cost, int) or action_cost < 1:
                    raise ValueError('Action cost must be a positive integer.')
                if dispatch_deadline is not None and not math.isfinite(dispatch_deadline):
                    raise ValueError('The dispatch deadline must be finite.')
                self.require_budget(action_cost)
                if operation == 'scroll_ui' and self.scrolls_used >= self.limits.max_scrolls:
                    raise RuntimeError('The scroll limit is exhausted.')
                # This records intent, not proof that Appium has received an action.
                receipt.update(status='DISPATCH_PENDING', dispatch_requested=True,
                               before_observation_id=self.last_observation_id)
                # Without a saved intent receipt, do not make the UI mutation.
                if not self.record(receipt)['receipt_persisted']:
                    receipt.update(status='REJECTED',dispatch_requested=False,reason='Intent could not be saved; no action dispatched.')
                    return receipt
                # Foreground checks and durable intent writes can consume the window.
                # Expiry here means nothing was dispatched, so do not consume budget
                # or mark the mutation uncertain.
                try:
                    self.require_active()
                    # Time-sensitive helpers supply a shorter absolute cutoff (for example Undo).
                    if dispatch_deadline is not None and monotonic() >= dispatch_deadline:
                        raise TimeoutError('The operation dispatch deadline has expired.')
                except Exception:
                    receipt.update(status='REJECTED',dispatch_requested=False)
                    raise
                # All pre-dispatch checks passed. Consume the action units immediately
                # before the single attempted dispatch; an uncertain attempt still costs units.
                self.actions_used += action_cost
                if operation == 'scroll_ui':
                    self.scrolls_used += 1
                # A mutation can change the screen, so old handles must not survive it.
                self._targets.clear()
                try:
                    # This is the actual Appium action. There is no automatic retry.
                    receipt['dispatch_result'] = callback()
                    # SDK completion is acknowledged; assert_ui must separately check outcomes.
                    receipt.update(status='ACKNOWLEDGED',acknowledged=True)
                except Exception as error:
                    self.uncertain = True
                    # An exception after dispatch cannot prove the app ignored the action.
                    receipt.update(status='UNCERTAIN',reason='Dispatch response is uncertain; do not retry.')
                    receipt.setdefault('errors',[]).append({'stage':'dispatch','type':type(error).__name__})
                try:
                    # Attempt fresh after-evidence even if the dispatch response was uncertain.
                    active = self.active_app()
                    if active['bundleId'] != self.bundle_id:
                        if operation not in {'return_to_app','relaunch_app'}:
                            # Remember where this owned-app action handed control, so the
                            # external-link inspector does not read an unrelated foreground app.
                            self.external_handoff = {'bundleId':active['bundleId'],'source_receipt_id':receipt['receipt_id']}
                        receipt['after_observation'] = {'status':'EXTERNAL_APP','active_app':active,
                                                        'reason':'Use inspect_external_link or return_to_app.'}
                    else:
                        self.external_handoff = None
                        # The next model turn can use these fresh references without another capture.
                        receipt['after_observation'] = self.observe()
                except Exception as error:
                    receipt['after_observation'] = {'status':'BLOCKED','reason':type(error).__name__}
            except Exception as error:
                receipt['reason'] = f'{type(error).__name__}: {error}'
            # Always save the final action receipt, including early rejection/uncertainty.
            finally:
                receipt['completed_at'] = _now()
                self.record(receipt)
            return receipt
