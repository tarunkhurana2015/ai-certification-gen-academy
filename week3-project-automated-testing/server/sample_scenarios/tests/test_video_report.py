"""Offline checks of portable video artifacts and HTML rendering."""
import copy
import hashlib
from pathlib import Path
import struct
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from modules.video_report import copy_recording_for_report, render_report_video


def box(kind, payload):
    return struct.pack('>I', len(payload) + 8) + kind + payload


# Container framing fixtures exercise copy/validation, not media decoding.
MP4 = box(b'ftyp', b'isom\x00\x00\x02\x00isommp42') + box(b'moov', b'x') + box(b'mdat', b'pixels')
MOV = box(b'ftyp', b'qt  \x00\x00\x00\x00qt  ') + box(b'moov', b'x') + box(b'mdat', b'pixels')


class VideoReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.recordings = self.root / 'recordings'
        self.recordings.mkdir()
        self.source = self.recordings / 'run.mp4'
        self.source.write_bytes(MP4)
        self.report_path = self.root / 'reports' / 'CASE-1-abc.json'
        self.recording = {'status': 'SAVED', 'elapsed_seconds': 3.5,
                          'artifact': {'path': str(self.source), 'mime_type': 'video/mp4',
                                       'size_bytes': len(MP4), 'sha256': hashlib.sha256(MP4).hexdigest()}}

    def export(self):
        return copy_recording_for_report(self.recording, self.report_path, self.recordings)

    def test_copies_video_to_report_basename_without_mutating_receipt(self):
        before = copy.deepcopy(self.recording)
        result = self.export()
        self.assertEqual(result['export_status'], 'SAVED')
        self.assertEqual(result['relative_path'], 'CASE-1-abc.mp4')
        self.assertEqual(self.report_path.with_suffix('.mp4').read_bytes(), MP4)
        self.assertEqual(self.recording, before)
        self.assertEqual(self.source.read_bytes(), MP4)
        html = render_report_video(result)
        self.assertIn('<video controls', html)
        self.assertIn('src="CASE-1-abc.mp4"', html)
        self.assertNotIn('base64', html)
        self.assertNotIn('autoplay', html)

    def test_existing_video_is_never_overwritten(self):
        self.report_path.parent.mkdir()
        destination = self.report_path.with_suffix('.mp4')
        destination.write_bytes(b'keep this evidence')
        result = self.export()
        self.assertEqual(result['export_status'], 'UNAVAILABLE')
        self.assertEqual(destination.read_bytes(), b'keep this evidence')

    def test_hash_mismatch_cannot_publish_an_unrelated_video(self):
        self.recording['artifact']['sha256'] = '0' * 64
        result = self.export()
        self.assertEqual(result['export_status'], 'UNAVAILABLE')
        self.assertFalse(self.report_path.with_suffix('.mp4').exists())
        self.assertEqual(result['status'], 'SAVED')

    def test_size_mismatch_and_export_limit_do_not_publish_a_copy(self):
        self.recording['artifact']['size_bytes'] += 1
        self.assertEqual(self.export()['export_status'], 'UNAVAILABLE')
        self.recording['artifact']['size_bytes'] = len(MP4)
        with patch('modules.video_report.MAX_VIDEO_BYTES', len(MP4) - 1):
            self.assertEqual(self.export()['export_status'], 'UNAVAILABLE')
        self.assertFalse(self.report_path.with_suffix('.mp4').exists())

    def test_outside_root_and_symlink_escape_are_rejected(self):
        outside = self.root / 'unrelated.mp4'
        outside.write_bytes(MP4)
        self.recording['artifact']['path'] = str(outside)
        self.assertEqual(self.export()['export_status'], 'UNAVAILABLE')
        self.source.unlink()
        self.source.symlink_to(outside)
        self.recording['artifact']['path'] = str(self.source)
        self.assertEqual(self.export()['export_status'], 'UNAVAILABLE')
        self.assertFalse(self.report_path.with_suffix('.mp4').exists())

    def test_missing_or_malformed_video_produces_a_visible_export_reason(self):
        self.source.unlink()
        result = self.export()
        self.assertEqual(result['export_status'], 'UNAVAILABLE')
        self.assertIn('unavailable', render_report_video(result).lower())
        self.source.write_bytes(b'not a movie')
        result = self.export()
        self.assertEqual(result['export_status'], 'UNAVAILABLE')
        self.assertFalse(self.report_path.with_suffix('.mp4').exists())

    def test_mov_fallback_keeps_its_actual_extension_and_mime_type(self):
        source = self.recordings / 'native.mov'
        source.write_bytes(MOV)
        self.recording['status'] = 'PARTIAL'
        self.recording['artifact'] = {'path': str(source), 'mime_type': 'video/quicktime'}
        result = self.export()
        self.assertEqual(result['relative_path'], 'CASE-1-abc.mov')
        html = render_report_video(result)
        self.assertIn('video/quicktime', html)
        self.assertIn('QuickTime', html)
        self.assertIn('PARTIAL', html)

    def test_mp4_extension_cannot_mislabel_a_quicktime_container(self):
        self.source.write_bytes(MOV)
        self.recording['artifact'] = {'path': str(self.source), 'mime_type': 'video/mp4'}
        self.assertEqual(self.export()['export_status'], 'UNAVAILABLE')

    def test_renderer_rejects_nonlocal_or_traversal_video_urls(self):
        for name in ('../secret.mp4', '/tmp/video.mp4', 'https://example.com/x.mp4',
                     'javascript:alert(1)', 'folder\\x.mp4', 'data:video/mp4;base64,x'):
            html = render_report_video({'status': 'SAVED', 'export_status': 'SAVED',
                                       'relative_path': name, 'artifact': {'mime_type': 'video/mp4'}})
            self.assertNotIn('<video', html)

    def test_html_escapes_reason_and_url_encodes_local_filename(self):
        result = self.export()
        result['reason'] = '<script>alert(1)</script>'
        result['relative_path'] = 'clip name.mp4'
        html = render_report_video(result)
        self.assertIn('clip%20name.mp4', html)
        self.assertIn('&lt;script&gt;', html)
        self.assertNotIn('<script>', html)

    def test_old_reports_and_failed_recordings_remain_explicit_without_player(self):
        self.assertIn('No video was recorded', render_report_video(None))
        result = copy_recording_for_report({'status': 'UNAVAILABLE', 'reason': 'Recorder not supported'},
                                           self.report_path, self.recordings)
        html = render_report_video(result)
        self.assertIn('Recorder not supported', html)
        self.assertNotIn('<video', html)


if __name__ == '__main__':
    unittest.main()
