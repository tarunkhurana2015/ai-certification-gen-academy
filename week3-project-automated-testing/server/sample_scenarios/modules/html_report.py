"""Build a portable run report from saved evidence, without model/device calls."""
from html import escape
from pathlib import Path

from .execution_walkthrough import format_execution_walkthrough, _pre
from .report_evidence import collect_report_observations, render_observation_gallery
from .video_report import render_report_video


# Everything is local: no fonts, JavaScript, or images fetched from the internet.
_STYLE = """
body {margin:0;background:#f4f6fb;color:#172238;font:15px/1.6 system-ui,sans-serif}
main {max-width:1280px;margin:auto;padding:28px}
header,section {background:white;border:1px solid #dde3ed;border-radius:14px;padding:22px;margin:18px 0}
header {border-top:5px solid #6655dd}
h1,h2,h3 {line-height:1.3;color:#202d47}
h1 {margin-top:0} a {color:#5141bc} code {overflow-wrap:anywhere}
table {border-collapse:collapse;width:100%;font-size:13px}
th {background:#eef0fa;text-align:left;padding:10px;position:sticky;top:0}
td {padding:10px;border-bottom:1px solid #e3e7ef;vertical-align:top}
tr:nth-child(even) {background:#fafbfe}
details {margin:12px 0;border:1px solid #e0e4ed;border-radius:8px;padding:10px}
summary {cursor:pointer;font-weight:600;color:#334366}
pre {background:#f4f6fa;border-radius:8px;padding:12px;white-space:pre-wrap;overflow-wrap:anywhere}
.facts {display:flex;flex-wrap:wrap;gap:14px}.facts span {padding:8px 14px;background:#eef0fa;border-radius:8px}
img {max-width:100%;height:auto;border:1px solid #dce2eb;border-radius:12px}
.observation-card {padding:16px 0;border-top:2px solid #e2e7f0;scroll-margin-top:20px}
.evidence-warning {background:#fff5dc;color:#704b08;padding:10px;border-radius:8px}
@media(max-width:700px) {main{padding:8px}header,section{padding:12px}th{position:static}}
@media print {body{background:white}main{padding:0}th{position:static}img{max-height:650px;width:auto}}
"""


def _partial_journal(report):
    """Expose retained host actions when no model-tool conversation survived."""
    receipts = report.get('runtime_receipts', [])
    if not receipts or report.get('tool_results'):
        return ''
    parts = ['<section><h2>Partial runtime journal</h2><p>These are retained host '
             'receipts, not a reconstructed LLM conversation. They may include '
             'internal actions and observation wrappers.</p>']
    for index, receipt in enumerate(receipts, 1):
        parts.append('<details><summary>Receipt ' + str(index) + ' · '
                     + escape(str(receipt.get('operation', 'unknown'))) + ' · '
                     + escape(str(receipt.get('status', 'unknown'))) + '</summary>'
                     + _pre({k: receipt[k] for k in ('status', 'reason', 'request', 'errors',
                        'observation_id', 'before_observation_id', 'receipt_persisted') if k in receipt})
                     + '</details>')
    parts.append('</section>')
    return ''.join(parts)


def render_test_report(report, *, artifact_root=None):
    """Render one report with screenshots embedded from the trusted evidence root.

    The report's own status is retained. A pretty report must not turn an
    acknowledgment, model answer, or partial assertion into an overall PASS.
    """
    root = (Path(artifact_root) if artifact_root is not None else
            Path(__file__).resolve().parents[2] / '.tools' / 'observations')
    observations = collect_report_observations(report, root)
    links = {item['observation'].get('observation_id'): item['anchor']
             for item in observations if item['observation'].get('observation_id')}
    title = 'Test run — ' + str(report.get('test_id', 'unnamed'))
    usage = report.get('usage') or {}
    facts = {
        'Status': report.get('status', 'Not recorded'),
        'Assessment source': report.get('assessment_source', 'Not recorded'),
        'Severity': report.get('severity', 'Not recorded'),
        'Tool requests': len(report.get('tool_requests', [])),
        'Unique observations': len(observations),
        'Model responses': usage.get('model_responses'),
        'Input tokens': usage.get('input_tokens'),
        'Output tokens': usage.get('output_tokens'),
    }
    facts_html = ''.join('<span><b>' + escape(k) + '</b><br>' + escape(str(v) if v is not None else 'Not available')
                         + '</span>' for k, v in facts.items())
    walkthrough = format_execution_walkthrough(saved_report=report,
                    error_type=report.get('error_type'), observation_links=links)
    gallery = render_observation_gallery(report, root)
    video = render_report_video(report.get('video_recording'))
    # Artifacts are embedded once in the gallery; tool rows link to those cards.
    # Full source JSON stays a separate companion file rather than being repeated
    # in the HTML or sent to another LLM to write a summary.
    return ('<!doctype html><html lang="en"><head><meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width,initial-scale=1">'
            '<title>' + escape(title) + '</title><style>' + _STYLE + '</style></head><body><main>'
            '<header><h1>' + escape(title) + '</h1><p>' + escape(str(report.get('human_message', '')))
            + '</p><div class="facts">' + facts_html + '</div><p>'
            + escape(str(report.get('reason', ''))) + '</p><p>'
            + 'Recorded: ' + escape(str(report.get('recorded_at', 'Not recorded')))
            + ' · Scope: ' + escape(str(report.get('execution_scope', 'Not recorded')))
            + '</p><nav><a href="#run-video">Test-run video</a> · <a href="#calls">Tool-call walkthrough</a> · '
            '<a href="#observations">Observations and screenshots</a></nav></header>'
            + video + '<div id="calls">' + walkthrough + _partial_journal(report) + '</div><div id="observations">' + gallery + '</div>'
            '</main></body></html>')
