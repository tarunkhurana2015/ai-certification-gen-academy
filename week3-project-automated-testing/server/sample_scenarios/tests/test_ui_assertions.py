"""Offline assertion fixtures; these do not execute the app or an LLM."""
from copy import deepcopy
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from modules.ui_assertions import evaluate_ui_expectation

EXPECTED = {'name':'app.tab.search','type':'XCUIElementTypeButton',
            'attributes':{'visible':'true','value':'1'}}

class UiAssertionTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        self.xml=self.root/'after.xml'
        self.write_xml()
        self.action={
            'status':'acknowledged','acknowledged':True,'dispatch_requested':True,
            'receipt_persisted':True,'session_id':'fixture-session','errors':[],
            'manifest_path':str(self.root/'tap.json'),
            'before_manifest_path':str(self.root/'before.json'),
            'observation_id':'before-observation',
            'target':{'name':EXPECTED['name'],'type':EXPECTED['type']},
            'after_observation':{
                'status':'complete','receipt_persisted':True,'errors':[],
                'session_id':'fixture-session','observation_id':'after-observation',
                'manifest_path':str(self.root/'after.json'),
                'artifacts':{'hierarchy':{'path':str(self.xml),'valid':True},
                             'screenshot':{'path':str(self.root/'after.png'),'valid':True}},
                # Deliberate omission: assertions must read full XML, not this summary.
                'ui_summary':{'status':'available','truncated':True,'elements':[]},
            },
        }
    def write_xml(self, value='1', visible='true', include=True, duplicate=False):
        value_attribute='' if value is None else f' value="{value}"'
        button=f'<Button type="XCUIElementTypeButton" name="app.tab.search" visible="{visible}"{value_attribute}/>'
        children=(button*(2 if duplicate else 1)) if include else ''
        self.xml.write_text('<AppiumAUT><Application type="XCUIElementTypeApplication" name="Fixture">'+children+'</Application></AppiumAUT>')
    def check(self, expected=None):
        return evaluate_ui_expectation(self.action, EXPECTED if expected is None else expected)
    def test_pass_reads_full_xml_and_reports_raw_evidence(self):
        result=self.check()
        self.assertEqual(result['status'],'PASS')
        self.assertEqual(result['observed']['match_count'],1)
        self.assertEqual(result['observed']['attributes'],{'visible':'true','value':'1'})
        self.assertEqual(result['evidence']['hierarchy'],str(self.xml))
        self.assertEqual(result['session_id'],'fixture-session')
    def test_known_false_values_fail_without_python_truthiness(self):
        for value,visible in (('0','true'),('1','false')):
            with self.subTest(value=value,visible=visible):
                self.write_xml(value=value,visible=visible)
                self.assertEqual(self.check()['status'],'FAIL')
    def test_missing_target_in_complete_native_xml_fails(self):
        self.write_xml(include=False)
        result=self.check()
        self.assertEqual(result['status'],'FAIL')
        self.assertEqual(result['observed']['match_count'],0)
    def test_unknown_attribute_and_duplicate_targets_are_blocked(self):
        self.write_xml(value=None)
        self.assertEqual(self.check()['status'],'BLOCKED')
        self.write_xml(duplicate=True)
        self.assertEqual(self.check()['status'],'BLOCKED')
    def test_rejected_uncertain_or_unpersisted_action_is_blocked(self):
        for change in ({'status':'rejected'},{'status':'uncertain'},{'acknowledged':False},
                       {'dispatch_requested':False},{'receipt_persisted':False}):
            with self.subTest(change=change):
                original=self.action
                self.action=deepcopy(original)
                self.action.update(change)
                self.assertEqual(self.check()['status'],'BLOCKED')
                self.action=original
        self.assertEqual(evaluate_ui_expectation(None,EXPECTED)['status'],'BLOCKED')
    def test_incomplete_or_unpersisted_after_capture_is_blocked(self):
        for change in ({'status':'partial'},{'receipt_persisted':False},{'errors':[{'type':'capture'}]}):
            with self.subTest(change=change):
                original=self.action
                self.action=deepcopy(original)
                self.action['after_observation'].update(change)
                self.assertEqual(self.check()['status'],'BLOCKED')
                self.action=original
    def test_wrong_session_reused_before_evidence_or_wrong_action_target_is_blocked(self):
        for field,value in (('session_id','another-session'),('observation_id','before-observation'),
                            ('manifest_path',self.action['before_manifest_path'])):
            with self.subTest(field=field):
                original=self.action['after_observation'][field]
                self.action['after_observation'][field]=value
                self.assertEqual(self.check()['status'],'BLOCKED')
                self.action['after_observation'][field]=original
        self.action['target']['name']='another.button'
        self.assertEqual(self.check()['status'],'BLOCKED')
    def test_unreadable_malformed_or_unrecognized_xml_is_blocked(self):
        for text in ('<broken>','<html><body>Search</body></html>','<AppiumAUT/>'):
            with self.subTest(text=text):
                self.xml.write_text(text)
                self.assertEqual(self.check()['status'],'BLOCKED')
        self.xml.unlink()
        self.assertEqual(self.check()['status'],'BLOCKED')
    def test_invalid_host_configuration_is_blocked(self):
        for expected in ({},{'name':'x'},{**EXPECTED,'attributes':{'value':1}},
                         {**EXPECTED,'type':'Button'}):
            with self.subTest(expected=expected):
                self.assertEqual(self.check(expected)['status'],'BLOCKED')
    def test_inputs_are_not_mutated(self):
        original=deepcopy(self.action)
        expected=deepcopy(EXPECTED)
        self.check(expected)
        self.assertEqual(self.action,original)
        self.assertEqual(expected,EXPECTED)

if __name__=='__main__':unittest.main()
