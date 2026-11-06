"""Offline create_agent dispatch through the actual registry; no provider or device."""
import base64
import json
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from langchain.agents import create_agent
from langchain_core.language_models.chat_models import BaseChatModel
from langchain_core.messages import AIMessage, HumanMessage, ToolMessage
from langchain_core.outputs import ChatGeneration, ChatResult
from langchain_openai import ChatOpenAI
from pydantic import Field

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from test_core_tools import Driver
from test_evidence_tools import PNG
from tools import ToolLimits, ToolRuntime, build_tools


class ScriptedToolModel(BaseChatModel):
    """Emit scripted model decisions, grounding action refs in the actual ToolMessage."""
    next_tool: str
    literal_text: str = '   Arrival?!   '
    bound_tool_names: list[str] = Field(default_factory=list)

    @property
    def _llm_type(self): return 'offline-scripted-tool-model'

    def bind_tools(self, tools, *, tool_choice=None, **kwargs):
        self.bound_tool_names = [item.name for item in tools]
        return self

    def _generate(self, messages, stop=None, run_manager=None, **kwargs):
        results = [message for message in messages if isinstance(message, ToolMessage)]
        if not results:
            name, arguments = 'observe_current_ui', {}
        elif results[-1].name == 'observe_current_ui':
            observed = json.loads(results[-1].content)
            name = self.next_tool
            if name == 'review_visual_evidence':
                arguments = {'observation_id': observed['observation_id']}
            else:
                native_name = 'query' if name == 'enter_text' else 'search'
                target = next(element for element in observed['ui_summary']['elements']
                              if element['name'] == native_name)
                arguments = {'element_ref': target['element_ref']}
                if name == 'enter_text': arguments['text'] = self.literal_text
        else:
            return ChatResult(generations=[ChatGeneration(message=AIMessage(
                content='Offline dispatch finished; no real-app outcome is asserted.'))])
        message = AIMessage(content='', tool_calls=[{
            'name': name, 'args': arguments, 'id': f'call-{len(results)}', 'type': 'tool_call'}])
        return ChatResult(generations=[ChatGeneration(message=message)])


class ToolkitAgentDispatchTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.driver = Driver(Path(directory.name))
        session = SimpleNamespace(active=True, session_id=self.driver.session_id,
                                  driver=self.driver, artifact_root=Path(directory.name))
        self.runtime = ToolRuntime('com.example.movies', limits=ToolLimits(timeout_seconds=60))
        self.runtime.start_run(session)
        self.addCleanup(self.runtime.end_run)
        self.registry = build_tools(self.runtime)

    def run_agent(self, selected_tool, request):
        model = ScriptedToolModel(next_tool=selected_tool)
        agent = create_agent(model=model, tools=self.registry,
                             system_prompt='Use observed evidence and return a bounded result.')
        result = agent.invoke({'messages': [HumanMessage(content=request)]},
                              config={'recursion_limit': 10})
        self.assertEqual(set(model.bound_tool_names), {item.name for item in self.registry})
        self.assertEqual(len(model.bound_tool_names), 18)
        self.assertEqual(result['messages'][0].content, request)
        tool_messages = [message for message in result['messages'] if isinstance(message, ToolMessage)]
        self.assertEqual([message.name for message in tool_messages],
                         ['observe_current_ui', selected_tool])
        self.assertEqual([message.tool_call_id for message in tool_messages], ['call-0', 'call-1'])
        return tool_messages

    def test_agent_observes_then_taps_an_observed_reference(self):
        messages = self.run_agent('tap_element', 'Please open the visible search control for me.')
        before, action = (json.loads(message.content) for message in messages)
        self.assertEqual(action['status'], 'ACKNOWLEDGED')
        self.assertEqual(action['before_observation_id'], before['observation_id'])
        self.assertIn(action['request']['element_ref'],
                      [element.get('element_ref') for element in before['ui_summary']['elements']])
        self.assertEqual(self.driver.clicks, 1)
        self.assertTrue(action['receipt_persisted'])
        saved = json.loads(Path(action['manifest_path']).read_text())
        self.assertEqual(saved['receipt_id'], action['receipt_id'])
        self.assertEqual(saved['status'], 'ACKNOWLEDGED')
        self.assertIn(action['receipt_id'], [receipt['receipt_id'] for receipt in self.runtime.receipts])

    def test_agent_enters_literal_text_through_the_same_registry(self):
        messages = self.run_agent('enter_text', 'Put my punctuation and surrounding spaces in the movie search field.')
        action = json.loads(messages[-1].content)
        self.assertEqual(action['status'], 'ACKNOWLEDGED')
        self.assertEqual(self.driver.writes, ['   Arrival?!   '])
        self.assertEqual(self.runtime.actions_used, 2)
        self.assertTrue(action['dispatch_result']['entered_value_verified'])
        self.assertTrue(action['after_observation']['receipt_persisted'])
        operations = [receipt['operation'] for receipt in self.runtime.receipts]
        self.assertIn('clear_text', operations)
        self.assertIn('enter_text', operations)

    def test_agent_receives_actual_image_content_and_recorded_visual_artifact(self):
        with patch.object(self.driver, 'get_screenshot_as_png', return_value=PNG):
            messages = self.run_agent('review_visual_evidence', 'Show me the saved screen so I can assess its appearance.')
        visual = messages[-1]
        self.assertEqual(visual.artifact['status'], 'REVIEW_REQUIRED')
        self.assertTrue(visual.artifact['receipt_persisted'])
        image = next(block for block in visual.content if block['type'] == 'image')
        self.assertEqual(base64.b64decode(image['base64']), PNG)
        self.assertEqual(image['mime_type'], 'image/png')
        self.assertIn(visual.artifact, self.runtime.receipts)
        self.assertEqual(Path(visual.artifact['evidence']['screenshot']).read_bytes(), PNG)

    def test_visual_tool_message_serializes_as_a_responses_image_output(self):
        with patch.object(self.driver, 'get_screenshot_as_png', return_value=PNG):
            visual = self.run_agent('review_visual_evidence', 'Inspect this saved screenshot.')[-1]
        model = ChatOpenAI(use_responses_api=True, api_key='offline-test-key', model='gpt-4.1-mini')
        call = AIMessage(content='', tool_calls=[{
            'name': visual.name, 'args': {'observation_id': visual.artifact['observation_id']},
            'id': visual.tool_call_id, 'type': 'tool_call'}])
        payload = model._get_request_payload([HumanMessage(content='Inspect the image.'), call, visual])
        output = next(item for item in payload['input'] if item['type'] == 'function_call_output')
        self.assertEqual(output['call_id'], visual.tool_call_id)
        self.assertIsInstance(output['output'], list)
        image = next(block for block in output['output'] if block['type'] == 'input_image')
        self.assertEqual(image['image_url'], 'data:image/png;base64,' + base64.b64encode(PNG).decode('ascii'))


if __name__ == '__main__': unittest.main()
