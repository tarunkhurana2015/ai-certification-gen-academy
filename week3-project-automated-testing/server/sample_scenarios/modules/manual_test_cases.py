"""Local CSV selection and agent-run reporting. Tool choice belongs to the agent."""
import csv
from datetime import datetime, timezone
import json
from pathlib import Path
import re
from uuid import uuid4

# Human-facing inventory only; never used to choose or dispatch tools for a row.
# tools.build_tools(runtime) is the executable registry shared by every goal.
TOOL_PLAN = {
    'observe_current_ui': ('AVAILABLE', 'Capture the live native UI with current element references.'),
    'tap_element': ('AVAILABLE', 'Tap a fresh observed native element.'),
    'enter_text': ('AVAILABLE', 'Clear, replace, or append literal input.'),
    'scroll_ui': ('AVAILABLE', 'Scroll vertically or swipe horizontally with limits.'),
    'go_back': ('AVAILABLE', 'Use an observed Back control.'),
    'dismiss_keyboard': ('AVAILABLE', 'Dismiss the native keyboard when visible.'),
    'wait_for_ui': ('AVAILABLE', 'Poll a native condition locally with a deadline.'),
    'assert_ui': ('AVAILABLE', 'Evaluate an explicit condition in saved native XML.'),
    'compare_observations': ('AVAILABLE', 'Compare an exact native attribute across two captures.'),
    'review_visual_evidence': ('AVAILABLE', 'Attach a saved screenshot to the calling model; uses image tokens.'),
    'relaunch_app': ('AVAILABLE', 'Terminate and activate the owned app, preserving local data.'),
    'return_to_app': ('AVAILABLE', 'Activate the configured app after an external handoff.'),
    'inspect_external_link': ('AVAILABLE', 'Inspect an observed external handoff destination.'),
    'run_timed_sequence': ('AVAILABLE', 'Perform two observed taps locally inside a short deadline.'),
    'find_test_data': ('CONDITIONAL', 'Live TMDB lookup; requires a host read access token.'),
    'inspect_network_condition': ('CONDITIONAL', 'Read host-prepared condition evidence; does not toggle connectivity.'),
    'inspect_storage_condition': ('CONDITIONAL', 'Read host-prepared storage condition evidence; does not fill storage.'),
    'wait_for_request_started': ('CONDITIONAL', 'Read request instrumentation; a spinner is not network proof.'),
}


def list_test_cases(csv_path):
    """Return selection metadata locally, excluding all human messages."""
    with Path(csv_path).open(newline='', encoding='utf-8-sig') as file:
        return [{key: row[key] for key in ('test_id', 'severity', 'area')}
                for row in csv.DictReader(file)]


def load_test_case(csv_path, test_id):
    """Return exactly the selected CSV row; IDs are labels, not execution routes."""
    fields = ('test_id', 'severity', 'area', 'human_message', 'severity_reason')
    with Path(csv_path).open(newline='', encoding='utf-8-sig') as file:
        reader = csv.DictReader(file)
        if not set(fields).issubset(reader.fieldnames or []):
            raise ValueError('The CSV is missing required human-test columns.')
        for row in reader:
            if row['test_id'] == test_id:
                return {key: row[key] for key in fields}
    raise ValueError(f'No test with ID {test_id!r} was found.')


def build_model_message(test_case):
    """Prepare only the selected goal; metadata and other rows stay local."""
    return {'role': 'user', 'content': test_case['human_message']}


def _text_content(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, str):
                parts.append(block)
            elif isinstance(block, dict) and isinstance(block.get('text'), str):
                parts.append(block['text'])
        return '\n'.join(parts)
    return ''


def _report_content(content):
    """Keep image payloads in model messages, but omit their bytes in disk reports.

    The ToolMessage artifact and observation receipt retain the screenshot path.
    This function returns a new value and never mutates the model conversation.
    """
    if isinstance(content, list):
        return [_report_content(block) for block in content]
    if isinstance(content, dict):
        if content.get('type') in {'image', 'image_url', 'image_base64'}:
            return {'type': 'image_reference', 'payload_omitted': True,
                    'mime_type': content.get('mime_type', 'image/png'),
                    'reason': 'See the tool artifact or observation for the saved screenshot.'}
        return {key: _report_content(value) for key, value in content.items()}
    return content


def build_agent_report(test_case, agent_result, *, execution_scope='native_ios_toolkit', error_type=None, execution_attempted=False, runtime_receipts=None, video_recording=None):
    """Retain the actual agent trace without treating prose as a verified verdict.

    BLOCKED here is explicitly model-reported or an execution error. All other
    prose remains REVIEW_REQUIRED: individual assertions establish scoped facts,
    while completeness of the entire human goal still needs review.
    This function never chooses or invokes a tool, and never branches on test ID.
    """
    report = {
        'test_id': test_case['test_id'], 'severity': test_case['severity'], 'area': test_case['area'],
        'human_message': test_case['human_message'],
        'recorded_at': datetime.now(timezone.utc).isoformat(),
        'execution_scope': execution_scope, 'status': 'NOT_RUN',
        'assessment_source': 'host', 'reason': 'The agent has not returned a result.',
        'agent_answer': '', 'message_sequence': [], 'tool_requests': [], 'tool_results': [],
        'usage': {'model_responses': 0, 'input_tokens': 0, 'output_tokens': 0},
        'runtime_receipts': _report_content(list(runtime_receipts or [])),
        'verified_assertions': [],
        # This is host evidence only. No video bytes or recording commands are
        # added to the model's messages or the LLM's tool registry.
        'video_recording': _report_content(video_recording),
    }
    report['verified_assertions'] = [receipt for receipt in report['runtime_receipts']
        if receipt.get('operation') == 'assert_ui' and receipt.get('status') in {'PASS', 'FAIL'}
        and receipt.get('receipt_persisted') is True]
    if error_type:
        report.update(status='BLOCKED', reason='Agent execution did not complete.', error_type=error_type, usage=None)
        return report
    if agent_result is None:
        if execution_attempted:
            report.update(status='BLOCKED', reason='The attempted agent invocation has no completed result.', usage=None)
        return report
    messages = agent_result.get('messages', [])
    report['message_sequence'] = [message.type for message in messages]
    ai_messages = [message for message in messages if message.type == 'ai']
    for message in messages:
        if message.type == 'ai':
            report['tool_requests'].extend(message.tool_calls)
        elif message.type == 'tool':
            content = message.content
            if isinstance(content, str):
                try:
                    content = json.loads(content)
                except (ValueError, TypeError):
                    pass
            report['tool_results'].append({
                'name': message.name, 'tool_call_id': message.tool_call_id,
                'framework_status': message.status, 'content': _report_content(content),
                'artifact': _report_content(getattr(message, 'artifact', None)),
            })
    answer = _text_content(ai_messages[-1].content) if ai_messages else ''
    report.update(agent_answer=answer, status='REVIEW_REQUIRED',
                  reason='Assertions verify their stated scope; the complete human goal still requires review.')
    if answer.lstrip().startswith('BLOCKED:'):
        report.update(status='BLOCKED', assessment_source='model_reported',
                      reason=answer.lstrip()[len('BLOCKED:'):].strip())
    # Count observed model responses and sum tokens only when metadata is complete.
    metadata = [getattr(message, 'usage_metadata', None) for message in ai_messages]
    report['usage'] = {'model_responses': len(ai_messages), 'input_tokens': None, 'output_tokens': None}
    if metadata and all(isinstance(item, dict)
                        and isinstance(item.get('input_tokens'), int)
                        and isinstance(item.get('output_tokens'), int) for item in metadata):
        report['usage'].update(input_tokens=sum(item['input_tokens'] for item in metadata),
                               output_tokens=sum(item['output_tokens'] for item in metadata))
    return report


def save_test_report(report, output_dir, *, artifact_root=None, recording_root=None):
    """Save JSON/HTML and an available sibling video; return the JSON Path.

    JSON preserves the recorded tool data. HTML adds a readable walkthrough and
    embeds existing screenshots. Video is copied alongside the HTML for playback.
    Missing screenshots are reported in the HTML. No model/device call is made.
    artifact_root restricts which local evidence files the HTML exporter may read.
    """
    from .html_report import render_test_report
    from .video_report import copy_recording_for_report

    folder = Path(output_dir)
    folder.mkdir(parents=True, exist_ok=True)
    test_id = re.sub(r'[^A-Za-z0-9_-]', '_', report['test_id'])
    path = folder / f'{test_id}-{uuid4().hex[:10]}.json'
    # Add export metadata to a new report value. Keep the original run evidence
    # unchanged if the video copy is missing, invalid, or outside its trusted root.
    saved_report = dict(report)
    if report.get('video_recording') is not None:
        video_root = (Path(recording_root) if recording_root is not None else
                      Path(__file__).resolve().parents[2] / '.tools' / 'recordings')
        saved_report['video_recording'] = copy_recording_for_report(report['video_recording'], path, video_root)
    with path.open('x', encoding='utf-8') as file:
        json.dump(saved_report, file, indent=2)
        file.write('\n')
    # Save the JSON first so an HTML/filesystem failure cannot discard the trace.
    # Keep the same basename for the two formats and retain the existing Path API.
    try:
        html = render_test_report(saved_report, artifact_root=artifact_root)
        with path.with_suffix('.html').open('x', encoding='utf-8') as file:
            file.write(html)
    except Exception as error:
        raise RuntimeError(f'JSON report saved to {path}, but HTML export failed: {type(error).__name__}') from error
    return path
