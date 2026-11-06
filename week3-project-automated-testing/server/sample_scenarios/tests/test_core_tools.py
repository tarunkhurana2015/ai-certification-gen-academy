"""Offline runtime/driver fixtures; no provider, simulator, or real-app assertions."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
from xml.sax.saxutils import quoteattr
import json
import re
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools import ToolLimits, ToolRuntime, build_tools
from tools._runtime import _xpath_literal

class Element:
    def __init__(self, driver, name, label, native_type='XCUIElementTypeButton'):
        self.driver=driver;self.name=name;self.label=label;self.native_type=native_type
        self.enabled=self.displayed=True;self.actual_value='';self.placeholder='Search movies'
        self.rect={'x':20,'y':120,'width':380,'height':60}
    def get_attribute(self,key):
        return {'type':self.native_type,'name':self.name,'label':self.label,
                'value':self.actual_value or (self.placeholder if self.native_type=='XCUIElementTypeTextField' else None),
                'placeholderValue':self.placeholder}.get(key)
    def is_displayed(self):return self.displayed
    def is_enabled(self):return self.enabled
    def click(self):
        intents=[json.loads(p.read_text()) for p in self.driver.root.glob('toolkit-*/*.json')]
        if not any(r.get('status')=='DISPATCH_PENDING' for r in intents):raise AssertionError('No durable intent')
        self.driver.clicks+=1
        if self.driver.fail_click:raise TimeoutError('fixture uncertain click')
        if self.name=='remove':self.driver.undo.displayed=True
        if self.name=='undo':self.driver.undo.displayed=False
        if self.name=='trailer':self.driver.bundle='com.example.browser'
    def clear(self):
        self.driver.clears+=1
        if not self.driver.fail_clear:self.actual_value=''
    def send_keys(self,text):self.driver.writes.append(text);self.actual_value+=text;self.driver.keyboard=True

class Driver:
    session_id='fixture-session'
    def __init__(self,root):
        self.root=root;self.bundle='com.example.movies'
        self.clicks=self.clears=0;self.writes=[];self.swipes=[]
        self.fail_click=self.fail_clear=self.fail_source=False
        self.keyboard=False
        self.search=Element(self,'search','Search')
        self.field=Element(self,'query','Search movies','XCUIElementTypeTextField')
        self.back=Element(self,'back','Back')
        self.remove=Element(self,'remove','Remove fixture')
        self.undo=Element(self,'undo','Undo');self.undo.displayed=False
        self.trailer=Element(self,'trailer','Trailer')
        self.elements=[self.search,self.field,self.back,self.remove,self.undo,self.trailer]
    def execute_script(self,command):
        if command!='mobile: activeAppInfo':raise AssertionError('Unsupported fixture command')
        return {'bundleId':self.bundle}
    @property
    def page_source(self):
        if self.fail_source:raise RuntimeError('fixture capture failure')
        nodes=[]
        for e in self.elements:
            a={'type':e.native_type,'name':e.name,'label':e.label,
               'visible':'true' if e.displayed else 'false','enabled':'true' if e.enabled else 'false','accessible':'true',
               'x':'20','y':'120','width':'380','height':'60'}
            value=e.get_attribute('value')
            if value is not None:a['value']=value
            nodes.append('<Node '+' '.join(k+'='+quoteattr(v) for k,v in a.items())+'/>')
        if self.keyboard:nodes.append('<Node type="XCUIElementTypeKeyboard" visible="true"/>')
        return '<AppiumAUT><Application type="XCUIElementTypeApplication" name="Movies" visible="true">'+''.join(nodes)+'</Application></AppiumAUT>'
    def get_screenshot_as_png(self):return b'\x89PNG\r\n\x1a\nfixture-not-visual-review-data'
    def find_elements(self,strategy,selector):
        if strategy!='xpath':raise AssertionError('Expected host-generated XPath')
        pairs=re.findall(r"@(\w+)='([^']*)'",selector)
        return [e for e in self.elements if all(e.get_attribute(k)==v for k,v in pairs)]
    def get_window_size(self):return {'width':440,'height':956}
    def swipe(self,*coords,duration=0):self.swipes.append((coords,duration));return self
    def is_keyboard_shown(self):return self.keyboard
    def hide_keyboard(self):self.keyboard=False;return self
    def activate_app(self,bundle):self.bundle=bundle;return self
    def terminate_app(self,bundle):return self

class CoreToolTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name);self.driver=Driver(self.root)
        self.session=SimpleNamespace(active=True,session_id=self.driver.session_id,driver=self.driver,artifact_root=self.root)
        self.runtime=ToolRuntime('com.example.movies',limits=ToolLimits(timeout_seconds=60))
        self.runtime.start_run(self.session)
        self.tools={t.name:t for t in build_tools(self.runtime)}
    def observe(self):
        result=self.tools['observe_current_ui'].invoke({})
        self.assertEqual(result['status'],'complete')
        return result
    def ref(self,name):
        return next(e['element_ref'] for e in self.observe()['ui_summary']['elements'] if e['name']==name)
    def test_registry_has_all_tools_with_host_context_hidden(self):
        self.assertEqual(len(self.tools),18)
        for t in self.tools.values():
            self.assertFalse({'runtime','session','driver','tmdb_token','artifact_root','bundle_id'} & set(t.args))
    def test_fresh_reference_taps_and_returns_new_evidence(self):
        ref=self.ref('search')
        result=self.tools['tap_element'].invoke({'element_ref':ref})
        self.assertEqual(result['status'],'ACKNOWLEDGED')
        self.assertEqual(self.driver.clicks,1)
        self.assertEqual(result['after_observation']['status'],'complete')
        self.assertEqual(self.runtime.actions_used,1)
    def test_forged_stale_and_changed_identity_references_do_not_click(self):
        ref=self.ref('search');self.observe()
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':ref})['status'],'BLOCKED')
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':'invented'})['status'],'BLOCKED')
        ref=self.ref('search');self.driver.search.label='Changed'
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':ref})['status'],'BLOCKED')
        self.assertEqual(self.driver.clicks,0)
    def test_changed_session_wrong_app_and_disabled_target_do_not_click(self):
        ref=self.ref('search');self.driver.session_id='other'
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':ref})['status'],'BLOCKED')
        self.driver.session_id=self.session.session_id;ref=self.ref('search');self.driver.bundle='other.app'
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':ref})['status'],'BLOCKED')
        self.driver.bundle='com.example.movies';ref=self.ref('search');self.driver.search.enabled=False
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':ref})['status'],'BLOCKED')
        self.assertEqual(self.driver.clicks,0)
    def test_failed_observation_invalidates_targets(self):
        ref=self.ref('search');self.driver.fail_source=True;self.runtime.observe()
        self.driver.fail_source=False
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':ref})['status'],'BLOCKED')
        self.assertEqual(self.driver.clicks,0)
    def test_uncertain_click_locks_mutations_but_allows_observation(self):
        ref=self.ref('search');self.driver.fail_click=True
        result=self.tools['tap_element'].invoke({'element_ref':ref})
        self.assertEqual(result['status'],'UNCERTAIN')
        self.assertEqual(result['after_observation']['status'],'complete')
        self.driver.fail_click=False;ref=self.ref('search')
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':ref})['status'],'REJECTED')
        self.assertEqual(self.driver.clicks,1)
    def test_failed_intent_write_causes_zero_clicks(self):
        ref=self.ref('search')
        with patch('tools._runtime.tempfile.NamedTemporaryFile',side_effect=OSError('fixture write failure')):
            result=self.tools['tap_element'].invoke({'element_ref':ref})
        self.assertEqual(result['status'],'REJECTED');self.assertEqual(self.driver.clicks,0)
    def test_budget_and_deadline_guard_dispatch(self):
        ref=self.ref('search');self.runtime.actions_used=self.runtime.limits.max_actions
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':ref})['status'],'REJECTED')
        self.runtime.actions_used=0;self.runtime._deadline=0
        self.assertEqual(self.tools['tap_element'].invoke({'element_ref':ref})['status'],'BLOCKED')
        self.assertEqual(self.driver.clicks,0)
    def test_run_deadline_expiring_during_intent_persistence_does_not_dispatch(self):
        ref=self.ref('search')
        clock=SimpleNamespace(now=10.0)
        self.runtime._deadline=11.0
        record=self.runtime.record
        def delayed_record(receipt):
            result=record(receipt)
            if receipt['status']=='DISPATCH_PENDING':clock.now=12.0
            return result
        with patch('tools._runtime.monotonic',side_effect=lambda:clock.now), \
                patch.object(self.runtime,'record',side_effect=delayed_record):
            result=self.tools['tap_element'].invoke({'element_ref':ref})
        self.assertEqual(result['status'],'REJECTED')
        self.assertFalse(result['dispatch_requested'])
        self.assertEqual(self.driver.clicks,0)
        self.assertEqual(self.runtime.actions_used,0)
        self.assertFalse(self.runtime.uncertain)
    def test_parallel_calls_cannot_reuse_one_reference(self):
        ref=self.ref('search')
        with ThreadPoolExecutor(max_workers=2) as pool:
            results=list(pool.map(lambda _:self.tools['tap_element'].invoke({'element_ref':ref}),range(2)))
        self.assertEqual(self.driver.clicks,1)
        self.assertEqual(sorted(r['status'] for r in results),['ACKNOWLEDGED','BLOCKED'])
    def test_text_preserves_whitespace_and_counts_clear_type_separately(self):
        self.driver.field.actual_value='Old'
        ref=self.ref('query')
        result=self.tools['enter_text'].invoke({'element_ref':ref,'text':'   Interstellar   '})
        self.assertEqual(result['status'],'ACKNOWLEDGED')
        self.assertEqual(self.driver.writes,['   Interstellar   '])
        self.assertEqual(self.driver.field.actual_value,'   Interstellar   ')
        self.assertEqual(self.runtime.actions_used,2)
    def test_failed_clear_blocks_typing_and_is_not_retried(self):
        self.driver.field.actual_value='Old';self.driver.fail_clear=True
        result=self.tools['enter_text'].invoke({'element_ref':self.ref('query'),'text':'New'})
        self.assertEqual(result['status'],'BLOCKED')
        self.assertEqual(self.driver.clears,1);self.assertEqual(self.driver.writes,[])
        self.assertTrue(self.runtime.uncertain)
    def test_placeholder_clear_is_reported_without_claiming_verified_empty_value(self):
        result=self.tools['enter_text'].invoke({'element_ref':self.ref('query'),'text':''})
        self.assertEqual(result['status'],'ACKNOWLEDGED')
        self.assertFalse(result['entered_value_verified'])
    def test_enter_text_reserves_complete_budget_before_clearing(self):
        self.runtime.actions_used=self.runtime.limits.max_actions-1
        result=self.tools['enter_text'].invoke({'element_ref':self.ref('query'),'text':'New'})
        self.assertEqual(result['status'],'BLOCKED')
        self.assertEqual(self.driver.clears,0);self.assertEqual(self.driver.writes,[])
    def test_unpersisted_clear_observation_blocks_typing(self):
        from modules.observations import _persist_ui_receipt
        self.driver.field.actual_value='Old'
        ref=self.ref('query')
        def fail_enriched_capture(receipt):
            if 'tool_receipt_path' in receipt:
                receipt['receipt_persisted']=False
                return False
            return _persist_ui_receipt(receipt)
        with patch('modules.observations._persist_ui_receipt',side_effect=fail_enriched_capture):
            result=self.tools['enter_text'].invoke({'element_ref':ref,'text':'New'})
        self.assertEqual(result['status'],'BLOCKED')
        self.assertEqual(self.driver.clears,1)
        self.assertEqual(self.driver.writes,[])
        self.assertEqual(self.driver.field.actual_value,'')
        self.assertFalse(result['clear_receipt']['after_observation']['receipt_persisted'])
    def test_unpersisted_clear_receipt_blocks_typing(self):
        self.driver.field.actual_value='Old'
        ref=self.ref('query')
        record=self.runtime.record
        def fail_clear_completion(receipt):
            if receipt.get('operation')=='clear_text' and receipt['status']=='ACKNOWLEDGED':
                receipt['receipt_persisted']=False
                return receipt
            return record(receipt)
        with patch.object(self.runtime,'record',side_effect=fail_clear_completion):
            result=self.tools['enter_text'].invoke({'element_ref':ref,'text':'New'})
        self.assertEqual(result['status'],'BLOCKED')
        self.assertEqual(self.driver.clears,1)
        self.assertEqual(self.driver.writes,[])
    def test_append_blocks_text_that_is_indistinguishable_from_placeholder(self):
        self.driver.field.actual_value=self.driver.field.placeholder
        ref=self.ref('query')
        result=self.tools['enter_text'].invoke({'element_ref':ref,'text':' plus','replace':False})
        self.assertEqual(result['status'],'BLOCKED')
        self.assertEqual(self.driver.field.actual_value,'Search movies')
        self.assertEqual(self.driver.clears,0)
        self.assertEqual(self.driver.writes,[])
        self.assertEqual(self.runtime.actions_used,0)
        self.assertFalse(self.runtime.uncertain)
    def test_append_preserves_unambiguous_existing_text(self):
        self.driver.field.actual_value='Existing'
        result=self.tools['enter_text'].invoke({'element_ref':self.ref('query'),'text':' + literal ','replace':False})
        self.assertEqual(result['status'],'ACKNOWLEDGED')
        self.assertEqual(self.driver.field.actual_value,'Existing + literal ')
        self.assertEqual(self.driver.clears,0)
        self.assertEqual(self.driver.writes,[' + literal '])
        self.assertEqual(self.runtime.actions_used,1)
    def test_scroll_and_keyboard_use_explicit_sdk_commands(self):
        self.observe()
        result=self.tools['scroll_ui'].invoke({'direction':'down'})
        self.assertEqual(result['status'],'ACKNOWLEDGED');self.assertEqual(len(self.driver.swipes),1)
        coords,duration=self.driver.swipes[0];self.assertGreater(coords[1],coords[3]);self.assertEqual(duration,450)
        self.driver.keyboard=True
        result=self.tools['dismiss_keyboard'].invoke({})
        self.assertEqual(result['status'],'ACKNOWLEDGED');self.assertFalse(self.driver.keyboard)
    def test_back_requires_observed_back_control(self):
        self.observe();result=self.tools['go_back'].invoke({})
        self.assertEqual(result['status'],'ACKNOWLEDGED');self.assertEqual(self.driver.clicks,1)
    def test_wait_rechecks_saved_evidence_and_unknown_condition_times_out(self):
        result=self.tools['wait_for_ui'].invoke({'native_name':'search','operator':'exists','timeout_seconds':.2})
        self.assertEqual(result['status'],'COMPLETE')
        self.assertIn(result['observation']['observation_id'],self.runtime.observations)
        result=self.tools['wait_for_ui'].invoke({'native_name':'missing','operator':'exists','timeout_seconds':.01})
        self.assertEqual(result['status'],'TIMEOUT')
    def test_wait_does_not_accept_matching_but_unpersisted_observation(self):
        from modules.observations import _persist_ui_receipt
        def fail_enriched_capture(receipt):
            if 'tool_receipt_path' in receipt:
                receipt['receipt_persisted']=False
                return False
            return _persist_ui_receipt(receipt)
        with patch('modules.observations._persist_ui_receipt',side_effect=fail_enriched_capture):
            result=self.tools['wait_for_ui'].invoke({'native_name':'search','operator':'exists','timeout_seconds':.2})
        self.assertEqual(result['status'],'BLOCKED')
        self.assertIsNot(result.get('condition_met'),True)
        self.assertEqual(self.runtime.actions_used,0)
    def test_timed_sequence_executes_locally_and_reserves_two_units(self):
        result=self.tools['run_timed_sequence'].invoke({'first_element_ref':self.ref('remove'),'followup_label':'Undo'})
        self.assertEqual(result['status'],'ACKNOWLEDGED')
        self.assertEqual(self.driver.clicks,2);self.assertEqual(self.runtime.actions_used,2)
    def test_timed_sequence_with_insufficient_budget_does_not_remove(self):
        self.runtime.actions_used=self.runtime.limits.max_actions-1
        result=self.tools['run_timed_sequence'].invoke({'first_element_ref':self.ref('remove')})
        self.assertEqual(result['status'],'BLOCKED');self.assertEqual(self.driver.clicks,0)
    def test_timed_sequence_does_not_repeat_uncertain_first_tap(self):
        ref=self.ref('remove');self.driver.fail_click=True
        result=self.tools['run_timed_sequence'].invoke({'first_element_ref':ref})
        self.assertEqual(result['status'],'BLOCKED');self.assertEqual(self.driver.clicks,1)
    def test_timed_followup_deadline_is_rechecked_after_intent_persistence(self):
        ref=self.ref('remove')
        clock=SimpleNamespace(now=0.0)
        self.runtime._deadline=60.0
        record=self.runtime.record
        def delayed_record(receipt):
            result=record(receipt)
            if receipt.get('operation')=='timed_followup_tap' and receipt['status']=='DISPATCH_PENDING':
                clock.now=5.0
            return result
        with patch('tools._runtime.monotonic',side_effect=lambda:clock.now), \
                patch('tools.run_timed_sequence.monotonic',side_effect=lambda:clock.now), \
                patch.object(self.runtime,'record',side_effect=delayed_record):
            result=self.tools['run_timed_sequence'].invoke({'first_element_ref':ref,'timeout_seconds':4})
        self.assertEqual(result['followup']['status'],'REJECTED')
        self.assertFalse(result['followup']['dispatch_requested'])
        self.assertEqual(self.driver.clicks,1)
        self.assertEqual(self.runtime.actions_used,1)
        self.assertFalse(self.runtime.uncertain)
    def test_timed_first_tap_is_blocked_when_intent_persistence_exhausts_window(self):
        ref=self.ref('remove')
        clock=SimpleNamespace(now=0.0)
        self.runtime._deadline=60.0
        record=self.runtime.record
        def delayed_record(receipt):
            result=record(receipt)
            if receipt.get('operation')=='timed_first_tap' and receipt['status']=='DISPATCH_PENDING':
                clock.now=5.0
            return result
        with patch('tools._runtime.monotonic',side_effect=lambda:clock.now), \
                patch('tools.run_timed_sequence.monotonic',side_effect=lambda:clock.now), \
                patch.object(self.runtime,'record',side_effect=delayed_record):
            result=self.tools['run_timed_sequence'].invoke({'first_element_ref':ref,'timeout_seconds':4})
        self.assertEqual(result['status'],'BLOCKED')
        self.assertEqual(result['first']['status'],'REJECTED')
        self.assertEqual(self.driver.clicks,0)
        self.assertEqual(self.runtime.actions_used,0)
        self.assertFalse(self.runtime.uncertain)
    def test_external_handoff_is_recorded_and_return_targets_owned_app(self):
        result=self.tools['tap_element'].invoke({'element_ref':self.ref('trailer')})
        self.assertEqual(result['after_observation']['status'],'EXTERNAL_APP')
        self.assertEqual(self.runtime.external_handoff['bundleId'],'com.example.browser')
        result=self.tools['return_to_app'].invoke({})
        self.assertEqual(result['status'],'ACKNOWLEDGED');self.assertTrue(result['receipt_persisted'])
        self.assertEqual(self.driver.bundle,'com.example.movies')
    def test_after_close_observation_is_blocked(self):
        self.runtime.end_run()
        self.assertEqual(self.tools['observe_current_ui'].invoke({})['status'],'BLOCKED')
    def test_xpath_values_with_both_quote_types_are_host_escaped(self):
        self.assertEqual(_xpath_literal("a'b"),'"a\'b"')
        self.assertTrue(_xpath_literal('a\'b"c').startswith('concat('))

if __name__=='__main__':unittest.main()
