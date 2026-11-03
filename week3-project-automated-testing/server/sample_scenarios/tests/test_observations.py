"""Offline checks for UI summaries; these fixtures are not app acceptance evidence."""
from pathlib import Path
from types import SimpleNamespace
import json
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from modules.observations import observe_session_ui, summarize_ui_hierarchy

XML = '''<AppiumAUT><XCUIElementTypeApplication type="XCUIElementTypeApplication" name="Sample App" visible="true" enabled="true" accessible="false">
<Button type="XCUIElementTypeButton" name="app.search" label="Search" value="" visible="true" enabled="false" accessible="true" />
<Button type="XCUIElementTypeButton" label="Hidden" visible="false" enabled="true" />
<Text type="XCUIElementTypeStaticText" label="Visible text" visible="true" />
<Other type="XCUIElementTypeOther" visible="true" accessible="false" />
<Button type="XCUIElementTypeButton" visible="true" accessible="true" />
</XCUIElementTypeApplication></AppiumAUT>'''

class ObservationSummaryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.xml_path = self.root / 'hierarchy.xml'
        self.xml_path.write_text(XML)

    def test_visible_source_fields_and_boolean_values(self):
        summary = summarize_ui_hierarchy(self.xml_path)
        self.assertEqual(summary['status'], 'available')
        self.assertEqual(summary['matching_visible_elements'], 4)
        search = next(e for e in summary['elements'] if e['name'] == 'app.search')
        self.assertEqual(search['label'], 'Search')
        self.assertIs(search['enabled'], False)
        self.assertIs(search['accessible'], True)
        self.assertNotIn('accessibility_id', search)
        self.assertFalse(any(e['label'] == 'Hidden' for e in summary['elements']))
        text = next(e for e in summary['elements'] if e['label'] == 'Visible text')
        self.assertIsNone(text['name'])
        self.assertIsNone(text['enabled'])

    def test_element_and_text_limits_are_explicit(self):
        summary = summarize_ui_hierarchy(self.xml_path, max_elements=2, max_text_length=4)
        self.assertEqual(summary['returned_elements'], 2)
        self.assertEqual(summary['matching_visible_elements'], 4)
        self.assertTrue(summary['truncated'])
        self.assertEqual(summary['element_limit'], 2)
        self.assertEqual(summary['text_limit'], 4)
        first = summary['elements'][0]
        self.assertEqual(first['name'], 'Samp')
        self.assertEqual(first['truncated_fields']['name'], len('Sample App'))
        self.assertTrue(all(len(e[k] or '') <= 4 for e in summary['elements'] for k in ('name','label','value')))

    def test_missing_or_malformed_xml_reports_unavailable(self):
        self.xml_path.write_text('<broken>')
        for path in (None, self.root / 'absent.xml', self.xml_path):
            with self.subTest(path=path):
                summary = summarize_ui_hierarchy(path)
                self.assertEqual(summary['status'], 'unavailable')
                self.assertEqual(summary['elements'], [])
                self.assertTrue(summary['errors'])

    def test_empty_hierarchy_is_not_a_parse_failure(self):
        self.xml_path.write_text('<AppiumAUT/>')
        summary = summarize_ui_hierarchy(self.xml_path)
        self.assertEqual(summary['status'], 'available')
        self.assertEqual(summary['returned_elements'], 0)
        self.assertFalse(summary['truncated'])

    def test_enrichment_uses_saved_xml_and_persists_receipt(self):
        class Driver:
            session_id = 'offline-fixture-session'
            reads = 0
            screenshots = 0
            @property
            def page_source(self):
                self.reads += 1
                return XML
            def get_screenshot_as_png(self):
                self.screenshots += 1
                return b'\x89PNG\r\n\x1a\nunit-test-fixture'
        driver = Driver()
        session = SimpleNamespace(active=True, driver=driver, session_id=driver.session_id, artifact_root=self.root)
        receipt = observe_session_ui(session)
        self.assertEqual(receipt['status'], 'complete')
        self.assertEqual(receipt['errors'], [])
        self.assertTrue(receipt['receipt_persisted'])
        self.assertEqual(receipt['ui_summary']['status'], 'available')
        self.assertEqual(driver.reads, 1)
        self.assertEqual(driver.screenshots, 1)
        saved = json.loads(Path(receipt['manifest_path']).read_text())
        self.assertEqual(saved, receipt)
        self.assertEqual(set(receipt['artifacts']), {'hierarchy','screenshot'})

    def test_partial_capture_keeps_capture_status_and_errors(self):
        class Driver:
            session_id = 'offline-partial-fixture'
            @property
            def page_source(self):
                raise RuntimeError('fixture hierarchy failure')
            def get_screenshot_as_png(self):
                return b'\x89PNG\r\n\x1a\nunit-test-fixture'
        driver = Driver()
        receipt = observe_session_ui(SimpleNamespace(active=True, driver=driver, session_id=driver.session_id, artifact_root=self.root))
        self.assertEqual(receipt['status'], 'partial')
        self.assertEqual(receipt['errors'][0]['stage'], 'capture_hierarchy')
        self.assertEqual(receipt['ui_summary']['status'], 'unavailable')
        self.assertTrue(receipt['ui_summary']['errors'])

    def test_inactive_or_changed_session_is_rejected_before_capture(self):
        for active, session_id in ((False,'expected'), (True,'different')):
            with self.subTest(active=active, session_id=session_id):
                session = SimpleNamespace(active=active, session_id='expected', driver=SimpleNamespace(session_id=session_id), artifact_root=self.root)
                with self.assertRaises(RuntimeError):
                    observe_session_ui(session)

if __name__ == '__main__':
    unittest.main()
