"""Turn this run's saved observations into a portable HTML evidence gallery.

No model, Appium, or network calls happen here. Only explicitly referenced local
artifacts below the host-supplied observation directory may be read.
"""
import base64
from datetime import datetime
import hashlib
from html import escape
import json
from pathlib import Path
import struct
import zlib


MAX_MANIFEST_BYTES = 2 * 1024 * 1024
MAX_SCREENSHOT_BYTES = 10 * 1024 * 1024
MAX_TOTAL_SCREENSHOT_BYTES = 50 * 1024 * 1024
_NESTED_RECEIPTS = ('clear_receipt', 'first', 'followup', 'observation', 'after_observation')


def _text(value):
    return escape(str(value), quote=True)


def _json(value):
    return json.dumps(value, ensure_ascii=False, indent=2, default=str)


def _pre(value):
    text = value if isinstance(value, str) else _json(value)
    return '<pre style="white-space:pre-wrap;overflow-wrap:anywhere">' + _text(text) + '</pre>'


def _read_artifact(raw_path, root, limit):
    """Reject outside paths (including symlinks) and bound every local read."""
    if not raw_path or not isinstance(raw_path, (str, Path)):
        raise ValueError('No local artifact path was recorded.')
    if root is None:
        raise ValueError('An observation artifact directory was not supplied.')
    path = Path(raw_path)
    if not path.is_absolute():
        path = root / path
    path = path.resolve()
    if not path.is_relative_to(root):
        raise ValueError('Artifact is outside the allowed observation directory.')
    if not path.is_file():
        raise ValueError('Referenced artifact is missing or is not a file.')
    with path.open('rb') as handle:
        data = handle.read(limit + 1)
    if len(data) > limit:
        raise ValueError(f'Artifact exceeds the {limit // (1024 * 1024)} MB read limit.')
    return data


def _payload(value):
    """Tool results may be dictionaries, JSON strings, or text/image blocks."""
    if isinstance(value, dict):
        return value
    if isinstance(value, list):
        value = '\n'.join(block.get('text', '') for block in value
                          if isinstance(block, dict) and isinstance(block.get('text'), str))
    if isinstance(value, str):
        try:
            parsed = json.loads(value)
            return parsed if isinstance(parsed, dict) else {}
        except ValueError:
            pass
    return {}


def observation_anchor(observation):
    """A stable fragment ID without inserting untrusted native IDs into HTML."""
    identity = (observation.get('observation_id') or observation.get('capture_manifest_path')
                or observation.get('manifest_path') or _json(observation))
    return 'observation-' + hashlib.sha256(str(identity).encode('utf-8')).hexdigest()[:16]


def collect_report_observations(report, artifact_root):
    """Collect this run's unique captures, including partial/error observations.

    Returns dictionaries containing anchor, observation, sources, and warnings.
    Thin runtime receipts may reference a capture manifest. Hydration is bounded
    to artifact_root and does not overwrite the original report or read any other
    observation directory entries. Sources retain the calls that used a capture.
    """
    root = Path(artifact_root).resolve() if artifact_root is not None else None
    entries, aliases = [], {}

    def add(original, source):
        observation = dict(original)
        warnings = []
        manifest = observation.get('capture_manifest_path')
        # Full captures already include their summary and artifact paths. Thin
        # observe_current_ui journal entries need their one referenced manifest.
        if manifest and not isinstance(observation.get('artifacts'), dict):
            try:
                loaded = json.loads(_read_artifact(manifest, root, MAX_MANIFEST_BYTES))
                if not isinstance(loaded, dict) or not (
                        'artifacts' in loaded or 'ui_summary' in loaded):
                    raise ValueError('The referenced manifest is not an observation capture.')
                if (loaded.get('observation_id') and observation.get('observation_id')
                        and loaded['observation_id'] != observation['observation_id']):
                    raise ValueError('Manifest observation ID does not match its receipt.')
                if (loaded.get('session_id') and observation.get('session_id')
                        and loaded['session_id'] != observation['session_id']):
                    raise ValueError('Manifest session does not match its receipt.')
                # Keep the manifest's capture status, not the wrapper's tool status.
                loaded = dict(loaded)
                if observation.get('observation_id'):
                    loaded.setdefault('observation_id', observation['observation_id'])
                observation = loaded
            except (OSError, ValueError, TypeError, RuntimeError) as error:
                warnings.append('Capture manifest unavailable: ' + str(error))

        identifiers = []
        if observation.get('observation_id'):
            identifiers.append('id:' + str(observation['observation_id']))
        for candidate in (manifest, observation.get('manifest_path')):
            if candidate:
                identifiers.append('manifest:' + str(candidate))
        existing = next((aliases[key] for key in identifiers if key in aliases), None)
        if existing is not None:
            if source not in existing['sources']:
                existing['sources'].append(source)
            # Prefer a full capture over a thin/partial copy of the same receipt.
            if ('ui_summary' not in existing['observation'] and 'ui_summary' in observation):
                existing['observation'] = observation
            existing['warnings'].extend(w for w in warnings if w not in existing['warnings'])
            entry = existing
        else:
            entry = {'anchor': observation_anchor(observation), 'observation': observation,
                     'sources': [source], 'warnings': warnings}
            # Two failed attempts can have identical messages without identifying
            # a shared capture. Keep them separate rather than invent deduplication.
            if not identifiers:
                entry['anchor'] += '-' + str(len(entries) + 1)
            entries.append(entry)
        for key in identifiers:
            aliases[key] = entry

    def visit(value, source, forced=False, depth=0):
        if not isinstance(value, dict) or depth > 20:
            return
        is_capture = (forced or 'ui_summary' in value or 'capture_manifest_path' in value
                      or value.get('operation') in ('observe_ui', 'observe_current_ui'))
        if is_capture:
            add(value, source)
        for key in _NESTED_RECEIPTS:
            nested = value.get(key)
            if isinstance(nested, dict):
                visit(nested, source + ' / ' + key,
                      forced=key in ('observation', 'after_observation'), depth=depth + 1)

    call_numbers = {call.get('id'): index for index, call in enumerate(report.get('tool_requests', []), 1)}
    for index, result in enumerate(report.get('tool_results', []), 1):
        number = call_numbers.get(result.get('tool_call_id'))
        label = f'Tool call {number}' if number is not None else f'Tool result {index}'
        label += ': ' + str(result.get('name') or 'unnamed tool')
        visit(_payload(result.get('content')), label)
        visit(_payload(result.get('artifact')), label + ' / artifact')
    for index, receipt in enumerate(report.get('runtime_receipts', []), 1):
        visit(receipt, f'Runtime receipt {index}')

    # Timestamps establish capture order independently of batched call order.
    # If any timestamp is unavailable, preserve collection order and disclose it.
    def captured_at(entry):
        observation = entry['observation']
        value = observation.get('started_at') or observation.get('recorded_at')
        try:
            timestamp = datetime.fromisoformat(value.replace('Z', '+00:00'))
            return timestamp.timestamp() if timestamp.tzinfo is not None else None
        except (AttributeError, TypeError, ValueError):
            return None
    if entries and all(captured_at(entry) is not None for entry in entries):
        entries.sort(key=captured_at)
    else:
        for entry in entries:
            entry['warnings'].append('Collection order shown; capture chronology is not fully recorded.')
    return entries


def _validate_png(data):
    """Validate PNG framing, dimensions, and chunk checksums before embedding."""
    if not data.startswith(b'\x89PNG\r\n\x1a\n'):
        raise ValueError('Screenshot file is not a PNG image.')
    position, chunks, has_pixels = 8, 0, False
    width = height = None
    while position + 12 <= len(data):
        length = struct.unpack('>I', data[position:position + 4])[0]
        kind = data[position + 4:position + 8]
        end = position + 12 + length
        if end > len(data):
            raise ValueError('Screenshot PNG is truncated.')
        payload = data[position + 8:position + 8 + length]
        checksum = struct.unpack('>I', data[position + 8 + length:end])[0]
        if zlib.crc32(kind + payload) & 0xffffffff != checksum:
            raise ValueError('Screenshot PNG has an invalid chunk checksum.')
        if chunks == 0:
            if kind != b'IHDR' or length != 13:
                raise ValueError('Screenshot PNG has no valid image header.')
            width, height = struct.unpack('>II', payload[:8])
            if not width or not height or width * height > 30_000_000:
                raise ValueError('Screenshot dimensions are invalid or exceed the pixel limit.')
        if kind == b'IDAT':
            has_pixels = True
        if kind == b'IEND':
            if length or end != len(data) or not has_pixels:
                raise ValueError('Screenshot PNG has an invalid end marker or no pixel data.')
            return width, height
        position = end
        chunks += 1
    raise ValueError('Screenshot PNG is incomplete.')


def _screenshot(observation, root, remaining):
    screenshot = observation.get('artifacts', {}).get('screenshot', {})
    if not isinstance(screenshot, dict):
        screenshot = {}
    try:
        if screenshot.get('valid') is not True:
            raise ValueError('No screenshot marked valid was recorded for this capture.')
        data = _read_artifact(screenshot.get('path'), root, MAX_SCREENSHOT_BYTES)
        width, height = _validate_png(data)
        if len(data) > remaining:
            raise ValueError('The report reached its 50 MB total embedded-screenshot limit.')
        encoded = base64.b64encode(data).decode('ascii')
        image = ('<figure><img loading="lazy" style="max-width:100%;width:330px;height:auto;'
                 'border:1px solid #9ca3af;border-radius:12px" src="data:image/png;base64,'
                 + encoded + '" alt="' + _text('Screenshot for ' + str(observation.get('observation_id', 'capture')))
                 + f'" width="{width}" height="{height}"><figcaption>'
                 + _text(f'Captured screenshot · {width} × {height} pixels · embedded in this HTML')
                 + '</figcaption></figure>')
        return image, len(data)
    except (OSError, ValueError, TypeError, RuntimeError) as error:
        return '<p class="evidence-warning"><b>Screenshot unavailable:</b> ' + _text(error) + '</p>', 0


def _highlights(observation):
    summary = observation.get('ui_summary') or {}
    elements = summary.get('elements') or []
    highlights = []
    # Explicit screen identifiers are useful context, but not proof of navigation.
    screens = [e.get('name') for e in elements if isinstance(e.get('name'), str)
               and e['name'].endswith('.screen')]
    if screens:
        highlights.append('Recorded screen identifiers: ' + ', '.join(dict.fromkeys(screens)))
    # Include controls with actual values first (selected tabs, toggles, input).
    controls = [e for e in elements if str(e.get('type', '')).endswith(
        ('Button', 'Switch', 'TextField', 'SearchField', 'TextView')) and e.get('value') is not None]
    for element in controls[:6]:
        highlights.append(str(element.get('label') or element.get('name') or 'Control')
                          + ': captured value ' + json.dumps(element['value'], ensure_ascii=False))
    text_labels = [e.get('label') for e in elements if str(e.get('type', '')).endswith('StaticText')
                   and isinstance(e.get('label'), str) and e['label']]
    for label in list(dict.fromkeys(text_labels))[:3]:
        highlights.append('Visible text: ' + (label if len(label) <= 180 else label[:180] + '… [preview shortened]'))
    if not highlights:
        highlights.append('No text highlights are available in the returned UI summary.')
    highlights.append(f'{len(elements)} elements returned; '
                      f"{summary.get('matching_visible_elements', 'unknown')} matched the observation filter.")
    if summary.get('truncated'):
        shortened = sum(bool(e.get('truncated_fields')) for e in elements)
        highlights.append(f'Observation summary is limited; {shortened} returned elements contain shortened text fields. '
                          'See the element counts for any omitted matches.')
    return '<ul>' + ''.join('<li>' + _text(line) + '</li>' for line in highlights) + '</ul>'


def _elements_table(observation):
    elements = (observation.get('ui_summary') or {}).get('elements') or []
    if not elements:
        return '<p>No summarized UI elements were recorded.</p>'
    rows = []
    for element in elements:
        name = element.get('name') or 'Not exposed'
        if element.get('truncated_fields', {}).get('name'):
            name += ' [shortened in source observation]'
        cells = [element.get('label') or 'No label',
                 str(element.get('type', '')).removeprefix('XCUIElementType'), name,
                 element.get('element_ref') or 'No actionable reference',
                 json.dumps(element.get('value'), ensure_ascii=False),
                 json.dumps(element.get('enabled'))]
        rows.append('<tr>' + ''.join('<td>' + _text(cell) + '</td>' for cell in cells) + '</tr>')
    return ('<details><summary>All ' + str(len(elements)) + ' returned UI elements</summary>'
            '<p>Native names may be semantics IDs or label fallbacks. References belong to this capture.</p>'
            '<div style="overflow-x:auto"><table><thead><tr>'
            + ''.join('<th>' + title + '</th>' for title in (
                'Label', 'Type', 'Semantics ID / native name', 'Temporary reference', 'Value', 'Enabled'))
            + '</tr></thead><tbody>' + ''.join(rows) + '</tbody></table></div></details>')


def render_observation_gallery(report, artifact_root):
    """Render each unique capture, its grounded gist, and a portable screenshot."""
    entries = collect_report_observations(report, artifact_root)
    root = Path(artifact_root).resolve() if artifact_root is not None else None
    parts = ['<section id="observation-gallery"><h2>Observation evidence</h2>',
             '<p>Each capture referenced by this run appears once, including automatic after-action '
             'captures. Highlights come from recorded native attributes; they are not AI judgments '
             'or proof of a passing test. The hierarchy and screenshot are captured separately, '
             'so dynamic UI can change between them. Screenshots are embedded for offline viewing.</p>',
             '<p><b>' + str(len(entries)) + ' unique observations</b></p>']
    remaining = MAX_TOTAL_SCREENSHOT_BYTES
    for number, entry in enumerate(entries, 1):
        observation = entry['observation']
        title = str(observation.get('observation_id') or 'Capture without an observation ID')
        parts.append('<article class="observation-card" id="' + _text(entry['anchor']) + '">')
        parts.append('<h3>Observation ' + str(number) + ' · ' + _text(title) + '</h3>')
        parts.append('<p><b>Capture status:</b> ' + _text(observation.get('status', 'Not recorded'))
                     + ' · <b>Captured at:</b> ' + _text(observation.get('started_at')
                                                     or observation.get('recorded_at') or 'Not recorded') + '</p>')
        parts.append('<p><b>Referenced by:</b> ' + _text('; '.join(entry['sources'])) + '</p>')
        if entry['warnings']:
            parts.append('<p class="evidence-warning">' + '<br>'.join(_text(w) for w in entry['warnings']) + '</p>')
        parts.append(_highlights(observation))
        image, used = _screenshot(observation, root, remaining)
        remaining -= used
        parts.append(image)
        if observation.get('errors') or observation.get('reason'):
            parts.append('<b>Capture diagnostics</b>' + _pre({
                k: observation[k] for k in ('reason', 'errors') if observation.get(k)}))
        parts.append(_elements_table(observation))
        parts.append('<details><summary>Artifact paths and capture metadata</summary>' + _pre({
            k: observation[k] for k in ('observation_id', 'manifest_path', 'capture_manifest_path',
                                      'artifacts', 'receipt_persisted') if k in observation}) + '</details>')
        parts.append('</article>')
    if not entries:
        parts.append('<p>No observation captures were referenced by this report.</p>')
    parts.append('</section>')
    return '\n'.join(parts)
