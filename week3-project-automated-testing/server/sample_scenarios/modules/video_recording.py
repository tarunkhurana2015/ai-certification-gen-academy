"""Host-owned XCTest recording. These helpers are never exposed as LLM tools."""
import base64
from datetime import datetime, timezone
import hashlib
from pathlib import Path
import struct
import subprocess
import tempfile
from time import monotonic


MAX_VIDEO_BYTES = 256 * 1024 * 1024


def _now():
    return datetime.now(timezone.utc).isoformat()


def _same_session(session, recording=None):
    if not session.active or session.driver.session_id != session.session_id:
        raise RuntimeError('The Appium session is no longer active or has changed.')
    if recording and recording.get('session_id') != session.session_id:
        raise RuntimeError('This recording belongs to another Appium session.')


def _movie_artifact(path, mime_type):
    """Check container framing and hash the saved file, without claiming playback.

    XCTest returns MOV; avconvert produces MP4. Both use ISO-BMFF style boxes.
    A real decoder/browser check is separate from this basic completeness check.
    """
    path = Path(path)
    size = path.stat().st_size
    if not 24 <= size <= MAX_VIDEO_BYTES:
        raise ValueError('Video is empty, too small, or exceeds the 256 MB limit.')
    boxes = set()
    with path.open('rb') as file:
        offset = 0
        while offset < size:
            file.seek(offset)
            header = file.read(8)
            if len(header) != 8:
                raise ValueError('Video has a truncated container header.')
            length, kind = struct.unpack('>I4s', header)
            header_size = 8
            if length == 1:
                extra = file.read(8)
                if len(extra) != 8:
                    raise ValueError('Video has a truncated extended header.')
                length = struct.unpack('>Q', extra)[0]
                header_size = 16
            elif length == 0:
                length = size - offset
            if length < header_size or offset + length > size:
                raise ValueError('Video has incomplete container data.')
            if kind in (b'ftyp', b'moov', b'mdat') and length > header_size:
                boxes.add(kind)
            offset += length
    if not {b'ftyp', b'moov', b'mdat'}.issubset(boxes):
        raise ValueError('Video is missing its file, movie, or media data boxes.')
    digest = hashlib.sha256()
    with path.open('rb') as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b''):
            digest.update(chunk)
    return {'path': str(path.resolve()), 'mime_type': mime_type,
            'size_bytes': size, 'sha256': digest.hexdigest()}


def start_run_video(session, output_dir, *, enabled=True):
    """Start recording this run, returning readable status rather than raising.

    Check for another recording first: XCTest's start command otherwise silently
    reuses it. Track the returned UUID so cleanup cannot stop someone else's clip.
    This native backend needs Xcode 15/iOS 17+, but does not need FFmpeg.
    """
    recording = {'status': 'DISABLED' if not enabled else 'UNAVAILABLE',
                 'backend': 'appium_xctest', 'warnings': [],
                 'coverage': 'Agent execution after session creation; app launch is not included.'}
    if not enabled:
        recording['reason'] = 'Video recording was disabled for this run.'
        return recording
    try:
        _same_session(session)
        recording['session_id'] = session.session_id
        current = session.driver.execute_script('mobile: getXCTestScreenRecordingInfo', {})
        if current is not None:
            raise RuntimeError('Another recording is already active; it was left untouched.')
        # Create an exclusive directory before capture, so later runs cannot
        # overwrite this run's movie, even when saving the report multiple times.
        root = Path(output_dir).resolve()
        root.mkdir(parents=True, exist_ok=True)
        folder = Path(tempfile.mkdtemp(prefix='run-video-', dir=root))
        recording['directory'] = str(folder)
        recording['start_requested_at'] = _now()
        info = session.driver.execute_script('mobile: startXCTestScreenRecording', {'fps': 10, 'codec': 0})
        if not isinstance(info, dict) or not isinstance(info.get('uuid'), str) or not info['uuid']:
            raise ValueError('Recorder did not return an ownership UUID.')
        recording.update(status='RECORDING', recording_id=info['uuid'], started_at=_now(),
                         fps=10, codec='H.264', _started_monotonic=monotonic())
    except Exception as error:
        # Recording failure must not prevent the selected scenario from running.
        recording.update(status='UNAVAILABLE', reason=f'{type(error).__name__}: {error}')
    return recording


def stop_run_video(session, recording, *, run_error=None):
    """Stop/retrieve before driver.quit(), preserving native video on MP4 failure.

    The dictionary is updated in place, making repeated cleanup calls harmless.
    No retries are made after a failed stop: its response might already be lost.
    Elapsed time measures the host capture interval, not exact playable duration.
    """
    if not recording or recording.get('status') != 'RECORDING':
        return recording or {'status': 'UNAVAILABLE', 'reason': 'No recording was started.'}
    # Change state before dispatch so a second cleanup never repeats stop.
    recording['status'] = 'FINALIZING'
    try:
        _same_session(session, recording)
        current = session.driver.execute_script('mobile: getXCTestScreenRecordingInfo', {})
        if not isinstance(current, dict) or current.get('uuid') != recording['recording_id']:
            raise RuntimeError('The owned recording is no longer active; no other recording was stopped.')
        recording['stop_requested_at'] = _now()
        response = session.driver.execute_script('mobile: stopXCTestScreenRecording', {})
        if not isinstance(response, dict) or response.get('uuid') != recording['recording_id']:
            raise ValueError('Stopped recording identity did not match this run.')
        recording['stopped_at'] = _now()
        # Measure through retrieval, before conversion adds unrelated elapsed time.
        recording['elapsed_seconds'] = round(max(0, monotonic() - recording['_started_monotonic']), 3)
        payload = response.get('payload')
        if not isinstance(payload, str) or not payload:
            raise ValueError('The recorder returned no movie bytes.')
        if len(payload) > ((MAX_VIDEO_BYTES + 2) // 3) * 4:
            raise ValueError('Recorded movie exceeds the 256 MB save limit.')
        movie = base64.b64decode(payload, validate=True)
        folder = Path(recording['directory'])
        original = folder / 'recording.mov'
        with original.open('xb') as file:
            file.write(movie)
        # Only metadata leaves this function; base64 never enters the agent,
        # notebook output, or JSON report.
        source = _movie_artifact(original, 'video/quicktime')
        recording['source_artifact'] = source
        recording['artifact'] = source
        converted = folder / 'recording.mp4'
        try:
            # Built-in macOS container conversion keeps H.264 and avoids a new
            # FFmpeg installation. No shell interpretation or overwrite flag.
            subprocess.run(['/usr/bin/avconvert', '--source', str(original),
                            '--preset', 'PresetPassthrough', '--output', str(converted)],
                           check=True, capture_output=True, text=True, timeout=120)
            recording['artifact'] = _movie_artifact(converted, 'video/mp4')
        except Exception as error:
            recording['warnings'].append(
                f'MP4 conversion unavailable ({type(error).__name__}); original MOV retained. '
                'Browser playback may vary; the MOV can be downloaded.')
        recording['status'] = 'PARTIAL' if run_error else 'SAVED'
        if run_error:
            recording['reason'] = f'Test execution stopped with {run_error}; recorded video was retained.'
        else:
            recording['reason'] = 'Recording retrieved and saved; this does not verify the test outcome.'
    except KeyboardInterrupt:
        # A second interrupt can arrive while saving/converting the movie. Keep
        # any already-validated MOV and an honest final status before propagating
        # the interrupt to the notebook's session-cleanup finally block.
        recording['status'] = 'PARTIAL' if recording.get('source_artifact') else 'UNAVAILABLE'
        recording['reason'] = 'Recording finalization was interrupted.'
        raise
    except Exception as error:
        recording.update(status='UNAVAILABLE', reason=f'{type(error).__name__}: {error}')
    finally:
        started = recording.pop('_started_monotonic', None)
        if started is not None and 'elapsed_seconds' not in recording:
            recording['elapsed_seconds'] = round(max(0, monotonic() - started), 3)
        recording['finalized_at'] = _now()
    return recording
