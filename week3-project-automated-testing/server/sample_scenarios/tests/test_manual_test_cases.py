"""Offline CSV/report and shared-agent tool-choice wiring checks."""
from pathlib import Path
import csv
import json
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from modules.manual_test_cases import (
    build_agent_report, build_model_message, list_test_cases, load_test_case, save_test_report,
)
from langchain.agents import create_agent
from langchain.tools import tool
from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.messages import AIMessage, HumanMessage, ToolMessage
from langchain_core.outputs import ChatGeneration, ChatResult

class OfflineToolModel(BaseChatModel):
    """Scripted provider responses test tool dispatch, not real LLM reasoning."""
    replies: list[AIMessage]
    @property
    def _llm_type(self):return 'offline-tool-dispatch'
    def bind_tools(self, tools, **kwargs):return self
    def _generate(self, messages, stop=None, run_manager=None, **kwargs):
        return ChatResult(generations=[ChatGeneration(message=self.replies.pop(0))])

class ManualCaseTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        self.csv=self.root/'cases.csv'
        self.rows=[
            {'test_id':'arbitrary-new-id','severity':'MEDIUM','area':'Input',
             'human_message':'Enter "   Interstellar   " and then spaces only.','severity_reason':'Input behavior.'},
            {'test_id':'another-new-id','severity':'HIGH','area':'Data',
             'human_message':'Do not include this other request in the first prompt.','severity_reason':'Data integrity.'},
        ]
        with self.csv.open('w',newline='',encoding='utf-8') as file:
            writer=csv.DictWriter(file,fieldnames=list(self.rows[0]))
            writer.writeheader();writer.writerows(self.rows)
        self.selected=load_test_case(self.csv,'arbitrary-new-id')
    def test_new_ids_load_without_any_case_configuration(self):
        self.assertEqual(self.selected,self.rows[0])
        with self.assertRaises(ValueError):load_test_case(self.csv,'missing-id')
    def test_metadata_listing_excludes_human_messages(self):
        entries=list_test_cases(self.csv)
        self.assertEqual(len(entries),2)
        self.assertEqual(set(entries[0]),{'test_id','severity','area'})
    def test_only_selected_goal_reaches_the_model_payload(self):
        message=build_model_message(self.selected)
        self.assertEqual(message,{'role':'user','content':self.rows[0]['human_message']})
        self.assertNotIn(self.rows[1]['human_message'],json.dumps(message))
        self.assertNotIn('arbitrary-new-id',json.dumps(message))
    def test_one_shared_agent_dispatches_whichever_tool_the_model_requests(self):
        calls=[]
        @tool
        def read_screen() -> dict:
            """Read a fixture screen."""
            calls.append('screen');return {'screen':'fixture'}
        @tool
        def read_device() -> dict:
            """Read a fixture device."""
            calls.append('device');return {'device':'fixture'}
        model=OfflineToolModel(replies=[
            AIMessage(content='',tool_calls=[{'name':'read_screen','args':{},'id':'screen-call','type':'tool_call'}]),
            AIMessage(content='Observed fixture screen.'),
            AIMessage(content='',tool_calls=[{'name':'read_device','args':{},'id':'device-call','type':'tool_call'}]),
            AIMessage(content='Observed fixture device.'),
        ])
        agent=create_agent(model=model,tools=[read_screen,read_device])
        first=agent.invoke({'messages':[build_model_message(self.rows[0])]})
        second=agent.invoke({'messages':[build_model_message(self.rows[1])]})
        self.assertEqual(calls,['screen','device'])
        self.assertEqual([m.name for m in first['messages'] if m.type=='tool'],['read_screen'])
        self.assertEqual([m.name for m in second['messages'] if m.type=='tool'],['read_device'])
    def test_report_retains_actual_tool_calls_receipts_and_usage(self):
        usage={'input_tokens':10,'output_tokens':2,'total_tokens':12}
        messages=[HumanMessage(content='Observe'),
                  AIMessage(content='',tool_calls=[{'name':'observe_current_ui','args':{},'id':'call-one','type':'tool_call'}],usage_metadata=usage),
                  ToolMessage(content=json.dumps({'status':'complete','artifacts':{'xml':'fixture.xml'}}),name='observe_current_ui',tool_call_id='call-one'),
                  AIMessage(content='Observed screen.',usage_metadata=usage)]
        report=build_agent_report(self.selected,{'messages':messages})
        self.assertEqual(report['tool_requests'][0]['name'],'observe_current_ui')
        self.assertEqual(report['tool_results'][0]['content']['status'],'complete')
        self.assertEqual(report['usage'],{'model_responses':2,'input_tokens':20,'output_tokens':4})
        self.assertEqual(report['status'],'REVIEW_REQUIRED')
    def test_visual_report_keeps_artifact_but_not_image_bytes(self):
        content=[{'type':'text','text':'Screenshot attached.'},
                 {'type':'image','base64':'large-private-image-payload','mime_type':'image/png'}]
        artifact={'operation':'review_visual_evidence','evidence':{'screenshot':'capture.png'}}
        message=ToolMessage(content=content,artifact=artifact,name='review_visual_evidence',tool_call_id='visual')
        report=build_agent_report(self.selected,{'messages':[message,AIMessage(content='Visual review required.')]})
        saved=report['tool_results'][0]
        self.assertEqual(saved['artifact'],artifact)
        self.assertTrue(saved['content'][1]['payload_omitted'])
        self.assertNotIn('large-private-image-payload',json.dumps(report))
        self.assertEqual(message.content[1]['base64'],'large-private-image-payload')
    def test_partial_runtime_receipts_survive_an_agent_error(self):
        receipts=[{'operation':'tap_element','status':'UNCERTAIN','receipt_persisted':True}]
        report=build_agent_report(self.selected,None,error_type='GraphRecursionError',
                                  execution_attempted=True,runtime_receipts=receipts)
        self.assertEqual(report['runtime_receipts'],receipts)
        self.assertEqual(report['status'],'BLOCKED')
        self.assertIsNone(report['usage'])
    def test_scoped_assertions_do_not_promote_an_entire_goal_to_pass(self):
        receipts=[{'operation':'assert_ui','status':'PASS','receipt_persisted':True},
                  {'operation':'assert_ui','status':'FAIL','receipt_persisted':False}]
        report=build_agent_report(self.selected,{'messages':[AIMessage(content='PASS: complete')]},runtime_receipts=receipts)
        self.assertEqual(report['verified_assertions'],[receipts[0]])
        self.assertEqual(report['status'],'REVIEW_REQUIRED')
    def test_model_prose_cannot_create_verified_pass_or_fail(self):
        for answer in ('PASS: all tests passed','FAIL: a control looks wrong'):
            with self.subTest(answer=answer):
                report=build_agent_report(self.selected,{'messages':[AIMessage(content=answer)]})
                self.assertEqual(report['status'],'REVIEW_REQUIRED')
    def test_model_reported_block_is_labeled_as_model_reported(self):
        report=build_agent_report(self.selected,{'messages':[AIMessage(content='BLOCKED: No typing tool is available.')]})
        self.assertEqual(report['status'],'BLOCKED')
        self.assertEqual(report['assessment_source'],'model_reported')
        self.assertEqual(report['reason'],'No typing tool is available.')
        self.assertIsNone(report['usage']['input_tokens'])
    def test_report_preserves_string_and_dictionary_text_blocks(self):
        for content in (['BLOCKED: Missing action tool.'],
                        [{'type':'text','text':'BLOCKED: Missing action tool.'}]):
            with self.subTest(content=content):
                report=build_agent_report(self.selected,{'messages':[AIMessage(content=content)]})
                self.assertEqual(report['status'],'BLOCKED')
                self.assertEqual(report['agent_answer'],'BLOCKED: Missing action tool.')
    def test_unknown_usage_and_failed_execution_are_not_reported_as_zero(self):
        report=build_agent_report(self.selected,{'messages':[AIMessage(content='Observed.')]})
        self.assertIsNone(report['usage']['output_tokens'])
        failed=build_agent_report(self.selected,None,error_type='AuthenticationError')
        self.assertEqual(failed['status'],'BLOCKED')
        self.assertIsNone(failed['usage'])
    def test_incomplete_manual_invocation_does_not_claim_zero_token_usage(self):
        report=build_agent_report(self.selected,None,execution_attempted=True)
        self.assertEqual(report['status'],'BLOCKED')
        self.assertIsNone(report['usage'])
    def test_preview_is_not_reported_as_an_executed_test(self):
        report=build_agent_report(self.selected,None)
        self.assertEqual(report['status'],'NOT_RUN')
        self.assertEqual(report['usage']['model_responses'],0)
    def test_reports_are_unique_and_contain_only_selected_request(self):
        report=build_agent_report(self.selected,None)
        a=save_test_report(report,self.root/'reports');b=save_test_report(report,self.root/'reports')
        self.assertNotEqual(a,b)
        self.assertEqual(json.loads(a.read_text())['human_message'],self.rows[0]['human_message'])
        self.assertNotIn(self.rows[1]['human_message'],a.read_text())

if __name__=='__main__':unittest.main()
