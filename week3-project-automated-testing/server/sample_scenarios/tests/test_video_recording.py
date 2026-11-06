"""Offline tests for recorder ownership, file evidence, and cleanup outcomes."""
import base64
from pathlib import Path
import struct
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


def movie_bytes(brand=b'qt  '):
    # Minimal container framing for file-validation tests; not a playable clip.
    def box(kind, data):
        return struct.pack('>I', 8 + len(data)) + kind + data
    return box(b'ftyp', brand + b'\x00\x00\x00\x00' + brand) + box(b'mdat', b'frame') + box(b'moov', b'metadata')


class RecordingDriver:
    session_id = 'session-one'

    def __init__(self):
        self.current = None
        self.events = []
        self.payload = base64.b64encode(movie_bytes()).decode()
        self.start_error = None

    def execute_script(self, name, args):
        self.events.append(name)
        if name == 'mobile: getXCTestScreenRecordingInfo':
            return self.current
        if name == 'mobile: startXCTestScreenRecording':
            if self.start_error:
                raise self.start_error
            assert args == {'fps': 10, 'codec': 0}
            self.current = {'uuid': 'recording-one', 'fps': 10, 'codec': 0, 'startedAt': 1.0}
            return dict(self.current)
        if name == 'mobile: stopXCTestScreenRecording':
            result = dict(self.current, payload=self.payload)
            self.current = None
            return result
        raise AssertionError(name)


class VideoRecordingTests(unittest.TestCase):
    def setUp(self):
        from modules import video_recording
        self.video = video_recording
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.driver = RecordingDriver()
        self.session = SimpleNamespace(driver=self.driver, session_id='session-one', active=True)

    def convert(self, command, **kwargs):
        self.assertEqual(command[:2], ['/usr/bin/avconvert', '--source'])
        destination = Path(command[command.index('--output') + 1])
        destination.write_bytes(movie_bytes(b'isom'))
        return SimpleNamespace(returncode=0, stdout='', stderr='')

    def test_saved_recording_has_real_files_and_no_base64_in_metadata(self):
        recording = self.video.start_run_video(self.session, self.root)
        self.assertEqual(recording['status'], 'RECORDING')
        with patch('modules.video_recording.subprocess.run', side_effect=self.convert):
            result = self.video.stop_run_video(self.session, recording)
        self.assertEqual(result['status'], 'SAVED')
        self.assertEqual(Path(result['artifact']['path']).suffix, '.mp4')
        self.assertEqual(Path(result['artifact']['path']).read_bytes(), movie_bytes(b'isom'))
        self.assertEqual(Path(result['source_artifact']['path']).read_bytes(), movie_bytes())
        self.assertNotIn(self.driver.payload, str(result))

    def test_existing_recorder_is_not_started_or_stopped(self):
        self.driver.current = {'uuid': 'someone-else'}
        recording = self.video.start_run_video(self.session, self.root)
        result = self.video.stop_run_video(self.session, recording)
        self.assertEqual(result['status'], 'UNAVAILABLE')
        self.assertEqual(self.driver.events, ['mobile: getXCTestScreenRecordingInfo'])
        self.assertEqual(self.driver.current['uuid'], 'someone-else')

    def test_uuid_or_session_change_prevents_stopping_unowned_video(self):
        recording = self.video.start_run_video(self.session, self.root)
        self.driver.current = {'uuid': 'someone-else'}
        result = self.video.stop_run_video(self.session, recording)
        self.assertEqual(result['status'], 'UNAVAILABLE')
        self.assertNotIn('mobile: stopXCTestScreenRecording', self.driver.events)

    def test_converter_failure_preserves_original_and_partial_run_label(self):
        recording = self.video.start_run_video(self.session, self.root)
        with patch('modules.video_recording.subprocess.run', side_effect=OSError('converter unavailable')):
            result = self.video.stop_run_video(self.session, recording, run_error='GraphRecursionError')
        self.assertEqual(result['status'], 'PARTIAL')
        self.assertEqual(Path(result['artifact']['path']).suffix, '.mov')
        self.assertTrue(Path(result['artifact']['path']).exists())
        self.assertTrue(result['warnings'])

    def test_invalid_payload_is_unavailable_and_repeat_stop_does_not_dispatch(self):
        recording = self.video.start_run_video(self.session, self.root)
        self.driver.payload = 'not valid base64!'
        result = self.video.stop_run_video(self.session, recording)
        self.assertEqual(result['status'], 'UNAVAILABLE')
        self.video.stop_run_video(self.session, result)
        self.assertEqual(self.driver.events.count('mobile: stopXCTestScreenRecording'), 1)

    def test_unavailable_backend_and_disabled_recording_do_not_raise(self):
        self.driver.start_error = RuntimeError('unsupported command')
        result = self.video.start_run_video(self.session, self.root)
        self.assertEqual(result['status'], 'UNAVAILABLE')
        self.driver.events.clear()
        disabled = self.video.start_run_video(self.session, self.root, enabled=False)
        self.assertEqual(disabled['status'], 'DISABLED')
        self.assertFalse(self.driver.events)

    def test_interrupted_conversion_retains_original_and_does_not_repeat_stop(self):
        recording = self.video.start_run_video(self.session, self.root)
        with patch('modules.video_recording.subprocess.run', side_effect=KeyboardInterrupt()):
            with self.assertRaises(KeyboardInterrupt):
                self.video.stop_run_video(self.session, recording)
        self.assertEqual(recording['status'], 'PARTIAL')
        self.assertTrue(Path(recording['artifact']['path']).is_file())
        self.assertNotIn('_started_monotonic', recording)
        self.video.stop_run_video(self.session, recording)
        self.assertEqual(self.driver.events.count('mobile: stopXCTestScreenRecording'), 1)

    def test_changed_driver_session_does_not_dispatch_stop(self):
        recording = self.video.start_run_video(self.session, self.root)
        self.driver.session_id = 'replacement-session'
        result = self.video.stop_run_video(self.session, recording)
        self.assertEqual(result['status'], 'UNAVAILABLE')
        self.assertNotIn('mobile: stopXCTestScreenRecording', self.driver.events)


if __name__ == '__main__':
    unittest.main()
