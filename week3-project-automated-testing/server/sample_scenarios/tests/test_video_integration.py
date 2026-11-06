"""Exercise the actual notebook lifecycle and report export without an LLM/device."""
from contextlib import redirect_stdout
import copy
import io
import json
from pathlib import Path
import struct
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

LESSONS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(LESSONS))
from modules.manual_test_cases import build_agent_report, save_test_report


class VideoLifecycleTests(unittest.TestCase):
    def invoke_cell(self, *, agent_error=None, stop_error=None):
        notebook = json.loads((LESSONS / '21_movies_automated_test.ipynb').read_text())
        source = next(''.join(cell['source']) for cell in notebook['cells']
                      if cell.get('id') == '7184491d60fe')
        events = []
        session = SimpleNamespace(session_closed=True, server_exit_code=0)

        def start_session(*args):
            events.append('session_start')
            return session

        def start_video(*args, **kwargs):
            events.append('video_start')
            return {'status': 'RECORDING'}

        def stop_video(session, recording, *, run_error):
            events.append('video_stop')
            self.assertEqual(run_error, type(agent_error).__name__ if agent_error else None)
            if stop_error:
                raise stop_error
            return {'status': 'PARTIAL' if run_error else 'SAVED'}

        def invoke(*args, **kwargs):
            events.append('invoke')
            if agent_error:
                raise agent_error
            return {'messages': []}

        namespace = {
            'lesson_dir': LESSONS, 'selected_test': {'test_id': 'OFFLINE'},
            'selected_message': {'role': 'user', 'content': 'Offline check'},
            'environment': {}, 'run_profile': {}, 'start_ios_session': start_session,
            'stop_ios_session': lambda session: events.append('session_close'),
            'test_agent': SimpleNamespace(invoke=invoke),
            'tool_runtime': SimpleNamespace(
                receipts=[{'operation': 'offline evidence'}],
                start_run=lambda session: events.append('runtime_start'),
                end_run=lambda: events.append('runtime_close')),
        }
        caught = None
        with patch('modules.video_recording.start_run_video', side_effect=start_video), \
             patch('modules.video_recording.stop_run_video', side_effect=stop_video), \
             redirect_stdout(io.StringIO()):
            try:
                exec(compile(source, 'notebook invocation', 'exec'), namespace)
            except BaseException as error:
                caught = error
        self.assertEqual(events, ['session_start', 'runtime_start', 'video_start',
                                 'invoke', 'video_stop', 'runtime_close', 'session_close'])
        self.assertEqual(len(namespace['run_receipts']), 1)
        return namespace, caught

    def test_success_stops_recording_before_session_cleanup(self):
        namespace, caught = self.invoke_cell()
        self.assertIsNone(caught)
        self.assertEqual(namespace['video_recording']['status'], 'SAVED')
        self.assertIsNone(namespace['run_error'])

    def test_agent_failure_still_saves_partial_video(self):
        namespace, caught = self.invoke_cell(agent_error=ValueError('agent failed'))
        self.assertIsNone(caught)
        self.assertEqual(namespace['run_error'], 'ValueError')
        self.assertEqual(namespace['video_recording']['status'], 'PARTIAL')

    def test_keyboard_interrupt_finalizes_before_propagating(self):
        namespace, caught = self.invoke_cell(agent_error=KeyboardInterrupt())
        self.assertIsInstance(caught, KeyboardInterrupt)
        self.assertEqual(namespace['video_recording']['status'], 'PARTIAL')

    def test_unexpected_video_failure_does_not_replace_agent_result(self):
        namespace, caught = self.invoke_cell(stop_error=RuntimeError('unexpected video failure'))
        self.assertIsNone(caught)
        self.assertEqual(namespace['agent_result'], {'messages': []})
        self.assertIsNone(namespace['run_error'])
        self.assertEqual(namespace['video_recording']['status'], 'UNAVAILABLE')


class VideoReportIntegrationTests(unittest.TestCase):
    def test_partial_video_exports_without_changing_blocked_verdict(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            recordings = root / 'recordings'
            recordings.mkdir()
            # Framing fixture checks export only; real playback is a separate smoke check.
            def box(kind, body):
                return struct.pack('>I', len(body) + 8) + kind + body
            video = recordings / 'run.mp4'
            video.write_bytes(box(b'ftyp', b'isom\x00\x00\x00\x00isom')
                              + box(b'moov', b'metadata') + box(b'mdat', b'frame'))
            receipt = {'status': 'PARTIAL', 'artifact': {
                'path': str(video), 'mime_type': 'video/mp4'}}
            report = build_agent_report(
                {'test_id': 'OFFLINE', 'severity': 'LOW', 'area': 'Test', 'human_message': 'Test'},
                None, error_type='GraphRecursionError', video_recording=receipt)
            original = copy.deepcopy(report)
            path = save_test_report(report, root / 'reports', recording_root=recordings)
            saved = json.loads(path.read_text())
            html = path.with_suffix('.html').read_text()
            self.assertEqual(report, original)
            self.assertEqual(saved['status'], 'BLOCKED')
            self.assertEqual(saved['video_recording']['status'], 'PARTIAL')
            self.assertEqual(saved['video_recording']['export_status'], 'SAVED')
            self.assertEqual(path.with_suffix('.mp4').read_bytes(), video.read_bytes())
            self.assertIn(path.with_suffix('.mp4').name, html)
            self.assertIn('<video', html)
            self.assertNotIn('data:video', html)

    def test_missing_video_still_saves_json_and_html(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report = build_agent_report(
                {'test_id': 'OFFLINE', 'severity': 'LOW', 'area': 'Test', 'human_message': 'Test'},
                {'messages': []}, video_recording={'status': 'UNAVAILABLE', 'reason': 'No capture'})
            path = save_test_report(report, root, recording_root=root)
            self.assertEqual(json.loads(path.read_text())['status'], 'REVIEW_REQUIRED')
            self.assertTrue(path.with_suffix('.html').is_file())
            self.assertNotIn('<video', path.with_suffix('.html').read_text())


if __name__ == '__main__':
    unittest.main()
