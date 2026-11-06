"""Copy one run's video beside its report and render local HTML playback.

The original recording receipt is retained. Export errors describe missing video
evidence without changing the test verdict or raising over an existing test error.
"""
from copy import deepcopy
import hashlib
from html import escape
from pathlib import Path
import re
import stat
import struct
from urllib.parse import quote


MAX_VIDEO_BYTES = 256 * 1024 * 1024
_MIME_TYPES = {'.mp4': 'video/mp4', '.mov': 'video/quicktime'}


def _validate_container(handle, size, suffix):
    """Check bounded ISO media framing, not whether a decoder can play the movie."""
    position = 0
    major_brand = None
    found = set()
    while position < size:
        handle.seek(position)
        header = handle.read(8)
        if len(header) != 8:
            raise ValueError('Video has an incomplete container header.')
        length, kind = struct.unpack('>I4s', header)
        header_size = 8
        if length == 1:
            extended = handle.read(8)
            if len(extended) != 8:
                raise ValueError('Video has an incomplete extended header.')
            length = struct.unpack('>Q', extended)[0]
            header_size = 16
        elif length == 0:
            length = size - position
        if length < header_size or position + length > size:
            raise ValueError('Video container is truncated or has an invalid box size.')
        if kind == b'ftyp':
            if length - header_size < 8:
                raise ValueError('Video has an incomplete file-type box.')
            major_brand = handle.read(4)
        if kind in (b'moov', b'mdat') and length > header_size:
            found.add(kind)
        position += length
    if major_brand is None or found != {b'moov', b'mdat'}:
        raise ValueError('Video is missing its file type, movie metadata, or media data.')
    if suffix == '.mp4' and major_brand == b'qt  ':
        raise ValueError('A QuickTime recording cannot be relabeled as MP4.')
    if suffix == '.mov' and major_brand != b'qt  ':
        raise ValueError('Video file type does not match its QuickTime extension.')


def copy_recording_for_report(recording, report_path, recording_root):
    """Return copied receipt metadata and export one authorized local movie.

    The output file shares the JSON/HTML basename. Only the recorded artifact
    inside recording_root is read; no directory scanning or remote access occurs.
    A hash binds the exported copy to its recorded bytes when one was supplied.
    """
    result = deepcopy(recording) if isinstance(recording, dict) else {'status': 'NOT_RECORDED'}
    # Never reuse a previous export's relative path if this export fails.
    for key in ('relative_path', 'export_artifact', 'export_reason'):
        result.pop(key, None)
    result['export_status'] = 'UNAVAILABLE'
    destination = None
    created = False
    try:
        artifact = result.get('artifact')
        if not isinstance(artifact, dict) or not artifact.get('path'):
            raise ValueError('No video artifact was recorded for this run.')
        if recording_root is None:
            raise ValueError('No allowed recording directory was supplied.')
        root = Path(recording_root).resolve()
        source = Path(artifact['path'])
        if not source.is_absolute():
            source = root / source
        source = source.resolve()
        if not source.is_relative_to(root):
            raise ValueError('Video is outside the allowed recording directory.')
        suffix = source.suffix.lower()
        if suffix not in _MIME_TYPES or artifact.get('mime_type', _MIME_TYPES[suffix]) != _MIME_TYPES[suffix]:
            raise ValueError('Video extension or MIME type is unsupported or inconsistent.')
        source_stat = source.stat()
        if not stat.S_ISREG(source_stat.st_mode) or not 0 < source_stat.st_size <= MAX_VIDEO_BYTES:
            raise ValueError('Video is not a regular nonempty file within the 256 MB limit.')
        expected_size = artifact.get('size_bytes')
        if expected_size is not None and (isinstance(expected_size, bool) or expected_size != source_stat.st_size):
            raise ValueError('Video size differs from the recorded artifact.')
        expected_hash = artifact.get('sha256')
        if expected_hash is not None and (not isinstance(expected_hash, str)
                                         or re.fullmatch(r'[0-9a-fA-F]{64}', expected_hash) is None):
            raise ValueError('Recorded video hash is malformed.')
        destination = Path(report_path).with_suffix(suffix)
        destination.parent.mkdir(parents=True, exist_ok=True)
        with source.open('rb') as incoming:
            _validate_container(incoming, source_stat.st_size, suffix)
            incoming.seek(0)
            # Exclusive creation preserves an existing report's evidence.
            with destination.open('xb') as outgoing:
                created = True
                digest = hashlib.sha256()
                copied = 0
                while chunk := incoming.read(1024 * 1024):
                    copied += len(chunk)
                    if copied > MAX_VIDEO_BYTES:
                        raise ValueError('Video grew beyond the 256 MB export limit.')
                    digest.update(chunk)
                    outgoing.write(chunk)
        actual_hash = digest.hexdigest()
        if copied != source_stat.st_size or (expected_hash and actual_hash != expected_hash.lower()):
            raise ValueError('Video bytes differ from the recorded artifact.')
        # Validate the copied bytes too, in case the source changed during copying.
        with destination.open('rb') as copied_file:
            _validate_container(copied_file, copied, suffix)
        result.update(export_status='SAVED', relative_path=destination.name,
                      export_artifact={'path': str(destination.resolve()), 'mime_type': _MIME_TYPES[suffix],
                                       'size_bytes': copied, 'sha256': actual_hash})
    except (OSError, ValueError, TypeError, RuntimeError, struct.error) as error:
        result['export_reason'] = 'Video export unavailable: ' + str(error)
        if created and destination is not None:
            try:
                destination.unlink(missing_ok=True)
            except OSError:
                result['export_reason'] += ' An incomplete export could not be removed.'
    return result


def _playable_relative_path(recording):
    """Only a single local basename is permitted in a player/download URL."""
    name = recording.get('relative_path')
    if not isinstance(name, str) or not name or any(c in name for c in ('/', '\\', ':', '\x00')):
        return None
    if name in ('.', '..') or Path(name).suffix.lower() not in _MIME_TYPES:
        return None
    if any(ord(c) < 32 for c in name):
        return None
    return name


def render_report_video(recording):
    """Render a local player only for a successfully exported video artifact."""
    parts = ['<section id="run-video"><h2>Test-run video</h2>']
    if not isinstance(recording, dict):
        return ''.join(parts) + '<p>No video was recorded for this run.</p></section>'
    parts.append('<p><b>Recording status:</b> ' + escape(str(recording.get('status', 'Not recorded')))
                 + ' · <b>Report copy:</b> ' + escape(str(recording.get('export_status', 'Not exported'))) + '</p>')
    for key in ('reason', 'export_reason'):
        if recording.get(key):
            parts.append('<p>' + escape(str(recording[key])) + '</p>')
    for key, label in (('started_at', 'Started'), ('stopped_at', 'Stopped')):
        if recording.get(key):
            parts.append('<p><b>' + label + ':</b> ' + escape(str(recording[key])) + '</p>')
    if recording.get('elapsed_seconds') is not None:
        parts.append('<p><b>Host-measured recording window:</b> '
                     + escape(str(recording['elapsed_seconds'])) + ' seconds. '
                     'This is not an exact measurement of the encoded video duration.</p>')
    warnings = recording.get('warnings') or []
    if not isinstance(warnings, list):
        warnings = [warnings]
    for warning in warnings:
        parts.append('<p class="evidence-warning">' + escape(str(warning)) + '</p>')
    name = _playable_relative_path(recording)
    if recording.get('export_status') == 'SAVED' and name:
        suffix = Path(name).suffix.lower()
        url = escape(quote(name, safe=''), quote=True)
        parts.append('<video controls preload="metadata" playsinline style="display:block;max-width:100%;'
                     'width:720px;max-height:800px;background:#111;border-radius:10px">'
                     '<source src="' + url + '" type="' + _MIME_TYPES[suffix] + '">'
                     'Your browser cannot play this recording. Use the download link below.</video>')
        parts.append('<p><a href="' + url + '" download>Download recording</a>. '
                     'Keep this video beside the HTML when moving or sharing the report.</p>')
        if suffix == '.mov':
            parts.append('<p>The original QuickTime recording is preserved. Browser support varies; '
                         'download it and open it in QuickTime if playback is unavailable.</p>')
        parts.append('<p>The video shows captured screen activity, not a test verdict. '
                     'Recording covers the agent run after session setup; earlier app launch activity '
                     'and events after recording stops are outside its coverage.</p>')
    else:
        parts.append('<p>Video playback is unavailable in this report. '
                     'Screenshots and the recorded tool evidence remain available.</p>')
    parts.append('</section>')
    return '\n'.join(parts)
