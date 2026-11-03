"""Offline action-guard fixtures; these are not real-app acceptance results."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
import json
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from modules.ui_actions import observe_actionable_ui, tap_session_element

class Element:
    def __init__(self, driver, name='shell.search', label='Search'):
        self.driver = driver
        self.attributes = {'type':'XCUIElementTypeButton','name':name,'label':label}
        self.displayed = self.enabled = True
    def get_attribute(self, key): return self.attributes.get(key)
    def is_displayed(self): return self.displayed
    def is_enabled(self): return self.enabled
    def click(self):
        # Durable intent must exist before the state-changing operation.
        intent = json.loads(next(self.driver.root.glob('tap-*/manifest.json')).read_text())
        if intent['status'] != 'dispatch_pending':
            raise AssertionError('No persisted click intent')
        self.driver.clicks += 1
        if self.driver.fail_click: raise RuntimeError('fixture uncertain response')
        self.driver.search_selected = True

class Driver:
    session_id = 'offline-action-session'
    def __init__(self, root):
        self.root = root
        self.clicks = self.lookups = 0
        self.search_selected = self.fail_source = self.fail_click = False
        self.element = Element(self)
        self.matches = [self.element]
    @property
    def page_source(self):
        if self.fail_source: raise RuntimeError('fixture source failure')
        screen = 'Search branch' if self.search_selected else 'Library'
        return f'''<AppiumAUT><Other type="XCUIElementTypeOther" name="screen" label="{screen}" visible="true" accessible="true" enabled="true"/>
        <Button type="XCUIElementTypeButton" name="shell.search" label="Search" visible="true" enabled="true" accessible="true"/>
        <Button type="XCUIElementTypeButton" name="shell.home" label="Home" visible="true" enabled="true" accessible="true"/></AppiumAUT>'''
    def get_screenshot_as_png(self): return b'\x89PNG\r\n\x1a\noffline-fixture'
    def find_elements(self, strategy, name):
        self.lookups += 1
        if strategy != 'accessibility id' or name != 'shell.search':
            raise AssertionError('Wrong locator')
        return self.matches

class UiActionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.driver = Driver(self.root)
        self.session = SimpleNamespace(active=True, session_id=self.driver.session_id,
                                       driver=self.driver, artifact_root=self.root)
    def observe(self, label='Search'):
        receipt = observe_actionable_ui(self.session)
        element = next(e for e in receipt['ui_summary']['elements'] if e['label']==label)
        return receipt, element['element_ref']
    def tap(self, ref):return tap_session_element(self.session, ref, expected_label='Search')
    def test_acknowledged_tap_has_before_and_after_evidence(self):
        before,ref = self.observe()
        result = self.tap(ref)
        self.assertEqual(result['status'],'acknowledged')
        self.assertTrue(result['acknowledged'])
        self.assertFalse(result['effect_verified'])
        self.assertEqual(result['before_manifest_path'],before['manifest_path'])
        self.assertEqual(self.driver.clicks,1)
        after = result['after_observation']
        self.assertEqual(after['status'],'complete')
        self.assertTrue(any(e['label']=='Search branch' for e in after['ui_summary']['elements']))
        self.assertEqual(json.loads(Path(result['manifest_path']).read_text()),result)
    def test_invented_and_old_references_cannot_dispatch(self):
        _,ref = self.observe()
        self.observe()
        for invalid in ('invented', ref):
            self.assertEqual(self.tap(invalid)['status'],'rejected')
        self.assertEqual(self.driver.lookups,0)
        self.assertEqual(self.driver.clicks,0)
    def test_inactive_and_changed_sessions_cannot_dispatch(self):
        _,ref = self.observe()
        self.session.active = False
        self.assertEqual(self.tap(ref)['status'],'rejected')
        self.session.active = True
        self.driver.session_id = 'different-session'
        self.assertEqual(self.tap(ref)['status'],'rejected')
        self.assertEqual(self.driver.lookups,0)
    def test_demo_permission_rejects_another_observed_button(self):
        _,ref = self.observe('Home')
        self.assertEqual(self.tap(ref)['status'],'rejected')
        self.assertEqual(self.driver.lookups,0)
        self.assertEqual(self.driver.clicks,0)
    def test_missing_ambiguous_and_changed_targets_cannot_dispatch(self):
        for case in ('missing','ambiguous','hidden','disabled','renamed','wrong_type'):
            with self.subTest(case=case):
                self.driver.element = Element(self.driver)
                self.driver.matches = [self.driver.element]
                _,ref = self.observe()
                if case=='missing':self.driver.matches=[]
                if case=='ambiguous':self.driver.matches=[self.driver.element,self.driver.element]
                if case=='hidden':self.driver.element.displayed=False
                if case=='disabled':self.driver.element.enabled=False
                if case=='renamed':self.driver.element.attributes['label']='Different'
                if case=='wrong_type':self.driver.element.attributes['type']='XCUIElementTypeStaticText'
                self.assertEqual(self.tap(ref)['status'],'rejected')
                self.assertEqual(self.driver.clicks,0)
    def test_uncertain_dispatch_consumes_the_one_click_budget(self):
        _,ref = self.observe()
        self.driver.fail_click=True
        result=self.tap(ref)
        self.assertEqual(result['status'],'uncertain')
        self.assertFalse(result['acknowledged'])
        self.assertIn('after_observation',result)
        _,new_ref=self.observe()
        self.assertEqual(self.tap(new_ref)['status'],'rejected')
        self.assertEqual(self.driver.clicks,1)
    def test_failed_intent_persistence_blocks_click(self):
        _,ref=self.observe()
        with patch('modules.ui_actions._persist_ui_receipt',return_value=False):
            result=self.tap(ref)
        self.assertEqual(result['status'],'rejected')
        self.assertFalse(result['dispatch_requested'])
        self.assertEqual(self.driver.clicks,0)
    def test_parallel_taps_dispatch_at_most_once(self):
        _,ref=self.observe()
        with ThreadPoolExecutor(max_workers=2) as pool:
            results=list(pool.map(self.tap,[ref,ref]))
        self.assertEqual(self.driver.clicks,1)
        self.assertEqual(sorted(r['status'] for r in results),['acknowledged','rejected'])
    def test_failed_observation_invalidates_earlier_references(self):
        _,ref=self.observe()
        self.driver.fail_source=True
        receipt=observe_actionable_ui(self.session)
        self.assertEqual(receipt['status'],'partial')
        self.assertEqual(self.tap(ref)['status'],'rejected')
        self.assertEqual(self.driver.clicks,0)

if __name__=='__main__':unittest.main()
