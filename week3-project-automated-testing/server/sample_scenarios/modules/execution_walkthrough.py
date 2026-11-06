"""Local HTML learning view. It reads recorded evidence and never runs a tool."""
from collections import Counter
from html import escape
import json

from .notebook_display import (
    _conversation_text, _tool_payload, format_conversation,
)


def _text(value):
    """Escape every dynamic value so app/model text cannot become HTML."""
    return escape(str(value), quote=True)


def _pre(value):
    if not isinstance(value, str):
        value = json.dumps(value, ensure_ascii=False, indent=2, default=str)
    return '<pre style="white-space:pre-wrap;overflow-wrap:anywhere">' + _text(value) + '</pre>'


def _details(title, body):
    return '<details><summary>' + _text(title) + '</summary>' + body + '</details>'


def _table(headers, rows):
    # Cells already contain escaped HTML produced by this module.
    return ('<div style="overflow-x:auto"><table style="width:100%;text-align:left">'
            '<thead><tr>' + ''.join('<th>' + _text(h) + '</th>' for h in headers)
            + '</tr></thead><tbody>'
            + ''.join('<tr>' + ''.join(
                '<td style="vertical-align:top;white-space:normal;overflow-wrap:anywhere;padding:8px">'
                + cell + '</td>' for cell in row) + '</tr>' for row in rows)
            + '</tbody></table></div>')


def _observations(payload):
    """Walk only known receipt fields; do not load paths or inspect arbitrary data."""
    if not isinstance(payload, dict):
        return
    if isinstance(payload.get('ui_summary'), dict):
        yield payload
    for key in ('clear_receipt', 'first', 'followup', 'observation', 'after_observation'):
        yield from _observations(payload.get(key))


def _recorded_events(agent_result, saved_report):
    """Normalize a live conversation or an explicitly selected saved report.

    Saved reports retain requests/results but not every model message. We never
    reconstruct missing model explanations or pretend their turn grouping exists.
    """
    if saved_report is not None:
        yield {'kind': 'human', 'text': saved_report.get('human_message', '')}
        results = {r.get('tool_call_id'): r for r in saved_report.get('tool_results', [])}
        for call in saved_report.get('tool_requests', []):
            yield {'kind': 'call', 'call': call, 'turn': None, 'batch': None}
            result = results.get(call.get('id'))
            if result is not None:
                yield {'kind': 'result', 'id': call.get('id'),
                       'payload': _tool_payload(result.get('content'), result.get('artifact')),
                       'framework_status': result.get('framework_status')}
        if saved_report.get('agent_answer'):
            yield {'kind': 'ai', 'text': saved_report['agent_answer']}
        return

    turn = 0
    for original in (agent_result or {}).get('messages', []):
        message = (original.model_dump(mode='python')
                   if callable(getattr(original, 'model_dump', None)) else original)
        role = message.get('type', message.get('role'))
        if role in ('ai', 'assistant'):
            turn += 1
            text = _conversation_text(message.get('content'))
            if text:
                yield {'kind': 'ai', 'text': text}
            calls = message.get('tool_calls', [])
            for call in calls:
                yield {'kind': 'call', 'call': call, 'turn': turn, 'batch': len(calls)}
        elif role in ('human', 'user'):
            yield {'kind': 'human', 'text': _conversation_text(message.get('content'))}
        elif role == 'tool':
            yield {'kind': 'result', 'id': message.get('tool_call_id'),
                   'payload': _tool_payload(message.get('content'), message.get('artifact')),
                   'framework_status': message.get('status')}


def _collect_calls(events):
    """Join each request to its result and retain historical ref → UI mappings.

    This index is for explanation only. It cannot make an expired ref actionable.
    A blocked call can still be explained using the earlier UI it referred to.
    """
    rows, pending, observed_refs = [], {}, {}
    for event in events:
        if event['kind'] == 'call':
            call = event['call']
            args = call.get('args', {})
            ref = (args.get('element_ref') or args.get('first_element_ref')) if isinstance(args, dict) else None
            row = dict(event, number=len(rows) + 1, before=observed_refs.get(ref),
                       payload=None, framework_status=None)
            rows.append(row)
            pending[call.get('id')] = row
        elif event['kind'] == 'result':
            payload = event['payload']
            row = pending.get(event['id'])
            if row is not None:
                row['payload'] = payload
                row['framework_status'] = event['framework_status']
            for observation in _observations(payload):
                for element in observation['ui_summary'].get('elements', []):
                    if element.get('element_ref'):
                        observed_refs[element['element_ref']] = element
    return rows


def _target(row):
    # A successful receipt records the identity Appium actually resolved. Failed
    # attempts may only have an earlier observation, so label that distinction.
    payload = row['payload'] or {}
    request = payload.get('request') or {}
    if isinstance(request.get('target'), dict):
        return request['target'], 'Target recorded by the runtime'
    if row['before']:
        return row['before'], 'Target from an earlier observation; not proof it was tapped'
    # Assertions and waits identify targets by native attributes, not tap refs.
    # These are requested selectors, so do not describe them as resolved controls.
    target = payload.get('target')
    if isinstance(target, dict):
        return target, 'Target selector recorded in the tool result'
    args = row['call'].get('args', {})
    if isinstance(args, dict) and (args.get('native_name') or args.get('label')):
        return {'name': args.get('native_name'), 'label': args.get('label'),
                'type': args.get('native_type')}, 'Requested selector; not proof of a match'
    return {}, 'No target identity recorded'


def _native_name(element):
    name = element.get('name') or 'Not exposed'
    if element.get('truncated_fields', {}).get('name'):
        name += ' [shortened in the observation]'
    return name


def _status(row):
    if row['payload'] is None:
        return 'NO_RESULT'
    if row['framework_status'] == 'error':
        return 'ERROR'
    return row['payload'].get('status') or 'RESULT_RECORDED'


def _evidence(row):
    """Report concrete attributes; never infer a test PASS from an SDK response."""
    payload = row['payload']
    if payload is None:
        return ['No tool result recorded.']
    status = payload.get('status')
    notes = []
    if status == 'ACKNOWLEDGED':
        notes.append('Appium command completed; this alone does not verify the goal.')
    elif status == 'UNCERTAIN':
        notes.append('Dispatch outcome is uncertain; do not assume the action succeeded.')
    if payload.get('reason'):
        notes.append(str(payload['reason']))
    # Compound typing/Undo tools can fail inside a child operation. Keep that
    # failure visible instead of showing only the outer BLOCKED status.
    for key in ('clear_receipt', 'first', 'followup'):
        child = payload.get(key)
        if isinstance(child, dict) and child.get('status'):
            notes.append(f"{key}: {child['status']}" +
                         (f" — {child['reason']}" if child.get('reason') else ''))
    target, _ = _target(row)
    captures = list(_observations(payload))
    if captures:
        after = captures[-1]
        elements = after['ui_summary'].get('elements', [])
        matches = [e for e in elements if target and not e.get('truncated_fields')
                   and all(e.get(k) == target.get(k) for k in ('type', 'name', 'label'))]
        if len(matches) == 1:
            previous = row['before']
            current_value = json.dumps(matches[0].get('value'), ensure_ascii=False)
            if previous is not None:
                old_value = json.dumps(previous.get('value'), ensure_ascii=False)
                notes.append(f'Captured target value: {old_value} → {current_value}.')
            else:
                notes.append(f'Captured target value afterward: {current_value}.')
        elif target:
            notes.append('Target not uniquely matched in the returned after-summary.')
        else:
            notes.append(f"Captured {len(elements)} summarized UI elements.")
        if after.get('status') != 'complete':
            notes.append('Capture status: ' + str(after.get('status', 'unknown')) + '.')
    elif isinstance(payload.get('after_observation'), dict):
        after = payload['after_observation']
        notes.append('After-capture: ' + str(after.get('status', 'unknown')) + '.')
        if after.get('reason'):
            notes.append(str(after['reason']))
    if payload.get('errors'):
        notes.append('Errors: ' + json.dumps(payload['errors'], ensure_ascii=False))
    if payload.get('receipt_persisted') is False:
        notes.append('Evidence receipt could not be saved.')
    if row['framework_status'] == 'error':
        notes.append('Tool execution reported a framework error.')
    return notes or ['See the recorded result below.']


def _ui_table(observation):
    summary = observation['ui_summary']
    elements = summary.get('elements', [])
    matching = summary.get('matching_visible_elements', len(elements))
    shortened = sum(bool(e.get('truncated_fields')) for e in elements)
    note = (f'All {len(elements)} returned elements are shown here; '
            f'{matching} matched the observation filter. '
            f'{shortened} elements have shortened text fields.')
    rows = []
    for e in elements:
        rows.append([_text(e.get('label') or 'No label'),
                     _text(str(e.get('type', '')).removeprefix('XCUIElementType')),
                     '<code>' + _text(_native_name(e)) + '</code>',
                     '<code>' + _text(e.get('element_ref') or 'No actionable reference') + '</code>',
                     _text(json.dumps(e.get('value'), ensure_ascii=False)),
                     _text(json.dumps(e.get('enabled')))])
    paths = {k: v.get('path') for k, v in observation.get('artifacts', {}).items()
             if isinstance(v, dict) and v.get('path')}
    return ('<p>' + _text(note) + '</p>'
            + _table(['Label', 'Type', 'Semantics ID / native name', 'Temporary reference', 'Value', 'Enabled'], rows)
            + (_details('Saved screenshot and hierarchy paths', _pre(paths)) if paths else ''))


def _call_table(rows, observation_links=None):
    """Show each requested target next to its result, including failed attempts."""
    links = observation_links or {}
    overview = []
    for row in rows:
        target, source = _target(row)
        args = row['call'].get('args', {})
        args = args if isinstance(args, dict) else {}
        label = target.get('label') or target.get('name') or 'No element target'
        number = str(row['number'])
        if row['turn'] is not None:
            number += f"<br><small>LLM turn {row['turn']}</small>"
        request = '<code>' + _text(row['call'].get('name', 'unknown')) + '</code><br>' + _text(label)
        for field in ('text', 'direction', 'attribute', 'operator', 'expected'):
            if field in args:
                request += '<br><small>' + _text(field) + ': ' + _text(json.dumps(args[field], ensure_ascii=False)) + '</small>'
        payload = row['payload'] or {}
        ref = args.get('element_ref') or args.get('first_element_ref') or (payload.get('request') or {}).get('element_ref')
        ids = [args.get(k) for k in ('observation_id', 'before_id', 'after_id')]
        # A rejected call may have no before_observation_id in its receipt. Its
        # ref still identifies historical evidence; linking does not validate it.
        if isinstance(ref, str) and ref.partition(':')[0] in links:
            ids.append(ref.partition(':')[0])
        ids += [payload.get('before_observation_id')]
        ids += [o.get('observation_id') for o in _observations(payload)]
        evidence = []
        for oid in dict.fromkeys(i for i in ids if i):
            evidence.append('<a href="#' + _text(links[oid]) + '">' + _text(oid) + '</a>'
                            if oid in links else _text(oid))
        overview.append([number, request,
                         '<code>' + _text(_native_name(target) if target else '—') + '</code><br>'
                         + '<small>' + _text(source) + '</small>',
                         '<code>' + _text(ref or 'Not supplied') + '</code>',
                         '<b>' + _text(_status(row)) + '</b><br>'
                         + '<br>'.join(_text(note) for note in _evidence(row)),
                         '<br>'.join(evidence) or 'No capture attached'])
    return _table(['Call', 'LLM requested / target', 'Semantics ID / native name',
                   'Temporary reference', 'Tool outcome and captured evidence', 'Observations'], overview)


def format_tool_call_table(saved_report, *, observation_links=None):
    """Compact notebook view of actual requests; no files or model calls."""
    return _call_table(_collect_calls(list(_recorded_events(None, saved_report))), observation_links)


def format_execution_walkthrough(agent_result=None, *, saved_report=None,
                                 runtime_receipts=None, error_type=None, observation_links=None):
    """Render request → target → outcome, with details available on expansion.

    Accept either the existing agent_result OR a user-selected saved JSON report.
    Never read files, call an LLM, change the trace, or operate an Appium session.
    """
    if agent_result is not None and saved_report is not None:
        raise ValueError('Choose either agent_result or saved_report, not both.')
    events = list(_recorded_events(agent_result, saved_report))
    rows = _collect_calls(events)
    output = ['<section style="font:14px/1.6 system-ui,sans-serif;max-width:1200px">',
              '<h2>What happened in this run</h2>']
    for event in events:
        if event['kind'] == 'human':
            output += ['<b>Your request</b>', _pre(event['text'])]
    if saved_report is not None:
        output.append('<p>Source: explicitly selected saved report. Host result: <b>'
                      + _text(saved_report.get('status', 'Not recorded')) + '</b>.</p>')
    if error_type:
        output.append('<p><b>Execution error:</b> ' + _text(error_type) + '</p>')
    if not rows:
        output.append('<p>No recorded tool calls are available. Any retained evidence is partial.</p>')
    counts = Counter(_status(r) for r in rows)
    taps = sum(r['call'].get('name') == 'tap_element' and
               (r['payload'] or {}).get('status') == 'ACKNOWLEDGED' for r in rows)
    assertions = sum(r['call'].get('name') == 'assert_ui' for r in rows)
    output.append('<p><b>' + _text(
        f"{len(rows)} tool calls · {taps} acknowledged taps · "
        f"{counts['BLOCKED']} blocked attempts · {assertions} assertion calls") + '</b></p>')
    output.append('<p>Rows follow the recorded request order. Calls in the same LLM turn may be '
                  'dispatched concurrently; row order does not establish their execution order. '
                  'A native name may be an app semantics ID or a label fallback.</p>')
    if any('latest successful observation' in str((r['payload'] or {}).get('reason', '')) for r in rows):
        output.append('<p><b>Why some attempts were blocked:</b> the tool reported an expired '
                      'or invalid element reference. Each fresh observation replaces the usable references. '
                      'A later attempt must use the new reference even when the semantics ID stays the same.</p>')
    output.append(_call_table(rows, observation_links))
    if rows and not assertions:
        output.append('<p><b>No assert_ui call was recorded.</b> Captured values are evidence, '
                      'not an overall PASS. The LLM’s completion message below is its assessment.</p>')
    output.append('<p>For tab controls in this Movies app, the captured value <code>"1"</code> '
                  'indicates selection. A value of <code>null</code> means no value was exposed. '
                  'Other controls may use values differently.</p>')
    output.append('<h3>Expand a call to follow the mechanics</h3>')
    for row in rows:
        target, source = _target(row)
        body = '<b>1. LLM requested these exact arguments</b>' + _pre(row['call'].get('args', {}))
        if row['batch'] and row['batch'] > 1:
            body += '<p>This LLM response requested ' + str(row['batch']) + ' tools together.</p>'
        body += '<b>2. The reference points to this recorded UI element</b>'
        body += _pre({'label': target.get('label'), 'semantics_id_or_native_name': _native_name(target),
                      'type': target.get('type'), 'identity_source': source})
        body += '<b>3. Tool outcome</b>' + '<p>' + '<br>'.join(_text(n) for n in _evidence(row)) + '</p>'
        # Keep scoped assertions, condition checks, and failure fields visible in
        # the detail panel, while avoiding duplicate captures and provider metadata.
        payload = row['payload'] or {}
        fields = {k: payload[k] for k in ('status', 'reason', 'expected', 'observed', 'scope',
                  'condition_met', 'effect_verified', 'entered_value_verified', 'errors', 'output') if k in payload}
        body += _pre(fields)
        for observation in _observations(payload):
            body += _details('Captured UI — ' + str(observation.get('observation_id', 'unnamed capture')),
                             _ui_table(observation))
        output.append(_details(f"Call {row['number']}: {row['call'].get('name', 'unknown')} — "
                               + str(target.get('label') or 'inspect result'), body))
    model_text = [e['text'] for e in events if e['kind'] == 'ai']
    if model_text:
        output += ['<h3>LLM’s last visible message — model assessment</h3>', _pre(model_text[-1])]
    if saved_report is None:
        # Every recorded turn remains available, including model text, tool errors,
        # invalid calls, completion warnings, and token counts, without flooding
        # the overview. This uses the existing formatter and leaves messages intact.
        conversation = format_conversation(agent_result, runtime_receipts=runtime_receipts,
                                           error_type=error_type, max_ui_elements=5)
        output.append(_details('Full recorded conversation and token counts', _pre(conversation)))
    else:
        output.append('<p>The saved report does not preserve every intermediate LLM message '
                      'or exact model-turn grouping. Use agent_result for the full conversation.</p>')
        output.append(_details('Recorded token usage', _pre(saved_report.get('usage'))))
    output.append('</section>')
    return '\n'.join(output)
