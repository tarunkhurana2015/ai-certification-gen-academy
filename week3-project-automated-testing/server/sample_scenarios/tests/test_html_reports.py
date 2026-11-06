"""Offline checks of portable reports and their evidence attribution."""
import base64
import copy
import json
from pathlib import Path
import sys
import struct
import tempfile
import unittest
import zlib

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from modules.manual_test_cases import save_test_report


def _png_chunk(kind, payload):
    return struct.pack('>I', len(payload)) + kind + payload + struct.pack('>I', zlib.crc32(kind + payload) & 0xffffffff)


# A real 1×1 RGB PNG with valid checksums; no image library or external fixture.
PNG = (b'\x89PNG\r\n\x1a\n' + _png_chunk(b'IHDR', struct.pack('>IIBBBBB', 1, 1, 8, 2, 0, 0, 0))
       + _png_chunk(b'IDAT', zlib.compress(b'\x00\xff\xff\xff')) + _png_chunk(b'IEND', b''))


class HtmlReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.evidence = self.root / 'observations'
        self.evidence.mkdir()
        self.shot = self.evidence / 'screen.png'
        self.shot.write_bytes(PNG)
        self.observation = {
            'operation': 'observe_ui', 'observation_id': 'obs_start', 'status': 'complete',
            'artifacts': {'screenshot': {'path': str(self.shot), 'valid': True}},
            'ui_summary': {'status': 'available', 'matching_visible_elements': 1,
                'returned_elements': 1, 'elements': [{'type': 'XCUIElementTypeButton',
                    'name': 'demo.tab.search', 'label': 'Search', 'element_ref': 'obs_start:e1',
                    'value': '1', 'visible': True, 'enabled': True}]},
        }
        self.report = {
            'test_id': 'CASE-HTML', 'human_message': 'Open Search',
            'severity': 'LOW', 'area': 'Navigation', 'status': 'REVIEW_REQUIRED',
            'assessment_source': 'host', 'reason': 'Review goal coverage.',
            'agent_answer': 'Search inspected.', 'usage': {'model_responses': 2},
            'tool_requests': [{'id': 'c1', 'name': 'observe_current_ui', 'args': {}},
                              {'id': 'c2', 'name': 'tap_element', 'args': {'element_ref': 'obs_start:e1'}}],
            'tool_results': [{'tool_call_id': 'c1', 'name': 'observe_current_ui', 'content': self.observation},
                             {'tool_call_id': 'c2', 'name': 'tap_element',
                              'content': {'status': 'BLOCKED', 'reason': 'Example guard rejection'}}],
            'runtime_receipts': [], 'verified_assertions': [],
        }

    def save(self):
        path = save_test_report(self.report, self.root / 'reports', artifact_root=self.evidence)
        return path, path.with_suffix('.html').read_text()

    def test_save_always_creates_matching_json_and_html(self):
        # This also checks the existing two-argument API and its Path return value.
        before = copy.deepcopy(self.report)
        path = save_test_report(self.report, self.root / 'reports')
        self.assertTrue(path.with_suffix('.html').is_file())
        self.assertEqual(json.loads(path.read_text()), before)
        self.assertEqual(self.report, before)
        second = save_test_report(self.report, self.root / 'reports')
        self.assertNotEqual(path, second)

    def test_portable_html_contains_image_bytes_and_historical_target(self):
        _, html = self.save()
        self.assertIn('data:image/png;base64,' + base64.b64encode(PNG).decode(), html)
        self.assertIn('demo.tab.search', html)
        self.assertIn('obs_start:e1', html)
        self.assertIn('Example guard rejection', html)
        self.assertIn('REVIEW_REQUIRED', html)
        self.assertNotIn('<script', html.lower())

    def test_duplicate_observation_is_embedded_once(self):
        self.report['runtime_receipts'] = [copy.deepcopy(self.observation)]
        _, html = self.save()
        self.assertEqual(html.count('data:image/png;base64,'), 1)

    def test_missing_and_outside_root_screenshots_do_not_break_report(self):
        self.shot.unlink()
        _, missing = self.save()
        self.assertIn('unavailable', missing.lower())
        outside = self.root / 'unrelated.png'
        outside.write_bytes(PNG)
        self.observation['artifacts']['screenshot']['path'] = str(outside)
        _, html = self.save()
        self.assertNotIn('data:image/png;base64,', html)
        self.assertIn('outside', html.lower())

    def test_app_and_model_text_cannot_become_active_html(self):
        self.report['agent_answer'] = '<script>alert(1)</script>'
        self.observation['ui_summary']['elements'][0]['label'] = '<img src=x onerror=alert(1)>'
        _, html = self.save()
        self.assertIn('&lt;script&gt;', html)
        self.assertIn('&lt;img', html)
        self.assertNotIn('<script>', html)
        self.assertNotIn('<img src=x', html)

    def test_partial_run_hydrates_only_its_referenced_observation_manifest(self):
        manifest = self.evidence / 'manifest.json'
        manifest.write_text(json.dumps(self.observation))
        self.report.update(status='BLOCKED', tool_requests=[], tool_results=[],
            runtime_receipts=[{'operation': 'observe_current_ui', 'observation_id': 'obs_start',
                'status': 'complete', 'capture_manifest_path': str(manifest)}])
        unrelated = self.evidence / 'other.json'
        unrelated.write_text(json.dumps({'observation_id': 'do-not-include-this-run'}))
        _, html = self.save()
        self.assertIn('obs_start', html)
        self.assertIn('data:image/png;base64,', html)
        self.assertNotIn('do-not-include-this-run', html)

    def test_child_uncertainty_remains_visible_in_outer_blocked_action(self):
        self.report['tool_results'][1]['content']['clear_receipt'] = {
            'status': 'UNCERTAIN', 'reason': 'Dispatch response was lost.'}
        _, html = self.save()
        self.assertIn('clear_receipt: UNCERTAIN', html)
        self.assertIn('Dispatch response was lost.', html)

    def test_selector_checks_show_requested_native_name_without_claiming_a_tap(self):
        self.report['tool_requests'][1].update(name='assert_ui', args={
            'native_name': 'demo.tab.search', 'observation_id': 'obs_start',
            'attribute': 'value', 'expected': '1'})
        _, html = self.save()
        self.assertIn('Requested selector; not proof of a match', html)
        self.assertIn('demo.tab.search', html)

    def test_corrupt_png_and_symlink_escape_are_reported_as_unavailable(self):
        self.shot.write_bytes(b'not a PNG')
        _, html = self.save()
        self.assertIn('Screenshot unavailable', html)
        self.assertNotIn('data:image/png;base64,', html)

        self.shot.unlink()
        outside = self.root / 'outside.png'
        outside.write_bytes(PNG)
        self.shot.symlink_to(outside)
        _, html = self.save()
        self.assertIn('outside', html.lower())
        self.assertNotIn('data:image/png;base64,', html)

    def test_failed_invocation_still_shows_host_action_uncertainty(self):
        self.report.update(tool_requests=[], tool_results=[], status='BLOCKED',
            runtime_receipts=[{'operation': 'tap_element', 'status': 'UNCERTAIN',
                'reason': 'Lost driver response; do not repeat the tap.'}])
        _, html = self.save()
        self.assertIn('Partial runtime journal', html)
        self.assertIn('UNCERTAIN', html)
        self.assertIn('Lost driver response; do not repeat the tap.', html)


if __name__ == '__main__':
    unittest.main()
