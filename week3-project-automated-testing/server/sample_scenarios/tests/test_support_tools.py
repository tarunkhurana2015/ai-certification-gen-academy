"""Offline support boundaries; these are not real-device acceptance results."""
from io import BytesIO
from pathlib import Path
from threading import RLock
from types import SimpleNamespace
from unittest.mock import patch
import json
import sys
import unittest
import urllib.error

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools import find_test_data, inspect_network_condition, inspect_storage_condition
from tools import inspect_external_link, return_to_app, relaunch_app
from tools import wait_for_request_started


class Driver:
    def __init__(self):
        self.calls = []
        self.source = ('<AppiumAUT><Other visible="true"><Text visible="true" '
                       'label="External trailer"/><Text visible="false" '
                       'label="https://hidden.example/"/><Text visible="true" '
                       'value="https://video.example/watch?id=23"/></Other></AppiumAUT>')
    def execute_script(self, command):
        self.calls.append(('execute', command))
        return {'bundleId': 'com.example.browser', 'name': 'Browser', 'pid': 34}
    @property
    def page_source(self):
        self.calls.append(('source',))
        return self.source
    def activate_app(self, bundle):
        self.calls.append(('activate', bundle))
        return self  # Appium fluent command acknowledgments must not enter JSON receipts.
    def terminate_app(self, bundle): self.calls.append(('terminate', bundle))


class Runtime:
    def __init__(self):
        self.session = SimpleNamespace(driver=Driver(), session_id='offline-support-session')
        self.lock = RLock()
        self.active = True
        self.tmdb_token = None
        self.bundle_id = 'com.example.movies'
        self.prepared_conditions = {}
        self.external_handoff = {'bundleId': 'com.example.browser', 'source_receipt_id': 'receipt-ui-action'}
        self.request_probe = None
        self.receipts = []
        self.mutations = []
        self.mutation_costs = []
    def require_active(self):
        if not self.active: raise RuntimeError('inactive fixture')
    def record(self, receipt):
        self.receipts.append(receipt)
        return receipt
    def blocked(self, operation, reason):
        return self.record({'operation': operation, 'status': 'BLOCKED', 'reason': reason})
    def timeout_seconds_remaining(self): return 15.0
    def mutate(self, operation, callback, *, action_cost=1, details=None):
        self.mutations.append(operation)
        self.mutation_costs.append(action_cost)
        self.require_active()
        dispatch_result = callback()
        receipt = {'operation': operation, 'status': 'ACKNOWLEDGED',
                   'after_observation': {'status': 'COMPLETE'}}
        if dispatch_result is not None: receipt['dispatch_result'] = dispatch_result
        return receipt


class SupportToolsTests(unittest.TestCase):
    def setUp(self): self.runtime = Runtime()

    def test_tmdb_token_is_host_only_and_missing_token_makes_no_request(self):
        tool = find_test_data.build_tool(self.runtime)
        self.assertNotIn('token', tool.args)
        with patch.object(find_test_data.urllib.request, 'urlopen') as request:
            result = tool.invoke({'query': 'sample'})
        self.assertEqual(result['status'], 'BLOCKED')
        request.assert_not_called()
        self.assertEqual(self.runtime.session.driver.calls, [])

    def test_tmdb_results_have_observed_ids_provenance_and_no_secret(self):
        self.runtime.tmdb_token = 'host-secret-token'
        search = {'results': [{'id': 42, 'title': 'Observed title'}], 'total_pages': 1}
        detail = {'id': 42, 'title': 'Observed title', 'release_date': '2024-06-03',
                  'belongs_to_collection': {'id': 84, 'name': 'Observed series'},
                  'poster_path': '/poster.jpg', 'backdrop_path': None}
        responses = [BytesIO(json.dumps(item).encode()) for item in (search, detail)]
        with patch.object(find_test_data.urllib.request, 'urlopen', side_effect=responses) as request:
            result = find_test_data.build_tool(self.runtime).invoke(
                {'query': 'Observed title', 'desired_content': 'collection'})
        self.assertEqual(result['status'], 'COMPLETE')
        self.assertEqual(result['candidates'][0]['id'], 42)
        self.assertEqual(result['candidates'][0]['collection']['id'], 84)
        self.assertIn('checked_at_utc', result['candidates'][0]['provenance'])
        self.assertTrue(all(item.startswith('https://api.themoviedb.org/3/')
                            for item in result['api_urls']))
        self.assertNotIn(self.runtime.tmdb_token, json.dumps(result))
        sent = request.call_args_list[0].args[0]
        self.assertEqual(sent.get_header('Authorization'), 'Bearer host-secret-token')
        self.assertNotIn('api_key=', sent.full_url)
        self.assertGreater(request.call_args_list[0].kwargs['timeout'], 0)
        self.assertLessEqual(request.call_args_list[0].kwargs['timeout'], 15)

    def test_tmdb_inspects_at_most_five_and_reports_bounded_absence(self):
        self.runtime.tmdb_token = 'host-secret-token'
        search = {'results': [{'id': item} for item in range(1, 21)], 'total_pages': 300}
        details = [{'id': item, 'title': f'Candidate {item}', 'reviews': {'results': []}}
                   for item in range(1, 6)]
        responses = [BytesIO(json.dumps(item).encode()) for item in [search, *details]]
        with patch.object(find_test_data.urllib.request, 'urlopen', side_effect=responses) as request:
            result = find_test_data.build_tool(self.runtime).invoke(
                {'query': 'candidate', 'desired_content': 'reviews'})
        self.assertEqual(request.call_count, 6)
        self.assertEqual(result['inspected_count'], 5)
        self.assertEqual(result['candidates'], [])
        self.assertIn('bounded', result['search_scope'])

    def test_tmdb_auth_errors_never_expose_headers_body_or_exception_text(self):
        self.runtime.tmdb_token = 'host-secret-token'
        error = urllib.error.HTTPError('https://api.themoviedb.org/3/search/movie', 401,
                                      'host-secret-token', {'Authorization': 'host-secret-token'}, None)
        with patch.object(find_test_data.urllib.request, 'urlopen', side_effect=error):
            result = find_test_data.build_tool(self.runtime).invoke({'query': 'candidate'})
        self.assertEqual(result['status'], 'BLOCKED')
        self.assertEqual(result['error_type'], 'HTTPError')
        self.assertEqual(result['http_status'], 401)
        self.assertNotIn('host-secret-token', json.dumps(self.runtime.receipts))

    def test_tmdb_search_pages_are_bounded_even_without_usable_ids(self):
        self.runtime.tmdb_token = 'host-secret-token'
        search = {'results': [{'id': None}], 'total_pages': 300}
        responses = [BytesIO(json.dumps(search).encode()) for _ in range(3)]
        with patch.object(find_test_data.urllib.request, 'urlopen', side_effect=responses) as request:
            result = find_test_data.build_tool(self.runtime).invoke({'query': 'candidate'})
        self.assertEqual(request.call_count, 3)
        self.assertEqual(result['candidates'], [])
        self.assertEqual(result['inspected_count'], 0)

    def test_inactive_session_blocks_live_data_lookup_before_http(self):
        self.runtime.tmdb_token = 'host-secret-token'
        self.runtime.active = False
        with patch.object(find_test_data.urllib.request, 'urlopen') as request:
            result = find_test_data.build_tool(self.runtime).invoke({'query': 'candidate'})
        self.assertEqual(result['status'], 'BLOCKED')
        request.assert_not_called()

    def test_tmdb_content_proof_comes_from_returned_subresources(self):
        self.runtime.tmdb_token = 'host-secret-token'
        for content, section, facts in [
                ('images', 'images', {'posters': [{'file_path': '/observed.jpg'}]}),
                ('reviews', 'reviews', {'results': [{'id': 'review-17', 'author': 'Observed author'}]}),
                ('trailer', 'videos', {'results': [{'id': 'video-17', 'type': 'Trailer',
                                                   'key': 'observed-key', 'site': 'YouTube'}]})]:
            search = {'results': [{'id': 17}], 'total_pages': 1}
            detail = {'id': 17, 'title': 'Observed candidate', section: facts}
            responses = [BytesIO(json.dumps(item).encode()) for item in [search, detail]]
            with patch.object(find_test_data.urllib.request, 'urlopen', side_effect=responses):
                result = find_test_data.build_tool(self.runtime).invoke(
                    {'query': 'candidate', 'desired_content': content})
            self.assertEqual([item['id'] for item in result['candidates']], [17])
            self.assertFalse(result['app_ui_verified'])

    def test_missing_artwork_requires_explicit_null_not_an_absent_field(self):
        self.runtime.tmdb_token = 'host-secret-token'
        search = {'results': [{'id': 1}, {'id': 2}], 'total_pages': 1}
        details = [{'id': 1, 'title': 'Unknown artwork'},
                   {'id': 2, 'title': 'Explicit absence', 'poster_path': None,
                    'backdrop_path': '/backdrop.jpg'}]
        responses = [BytesIO(json.dumps(item).encode()) for item in [search, *details]]
        with patch.object(find_test_data.urllib.request, 'urlopen', side_effect=responses):
            result = find_test_data.build_tool(self.runtime).invoke(
                {'query': 'candidate', 'desired_content': 'missing_artwork'})
        self.assertEqual([item['id'] for item in result['candidates']], [2])
        self.assertEqual(result['candidates'][0]['missing_artwork_fields'], ['poster_path'])

    def test_network_and_storage_require_session_scoped_prepared_evidence(self):
        for name, module in [('network', inspect_network_condition),
                             ('storage', inspect_storage_condition)]:
            with self.subTest(condition=name):
                tool = module.build_tool(self.runtime)
                self.assertEqual(tool.invoke({})['status'], 'BLOCKED')
                self.runtime.prepared_conditions[name] = {
                    'session_id': 'another-session', 'state': 'offline',
                    'evidence': {'note': 'human preparation'}}
                self.assertEqual(tool.invoke({})['status'], 'BLOCKED')
                self.runtime.prepared_conditions[name]['session_id'] = self.runtime.session.session_id
                result = tool.invoke({})
                self.assertEqual(result['status'], 'COMPLETE')
                self.assertEqual(result['state'], 'offline')
                self.assertFalse(result['verified_by_tool'])
                self.assertIn('human', result['source'])
                self.assertEqual(self.runtime.session.driver.calls, [])

    def test_explicit_unknown_state_and_empty_evidence_remain_blocked(self):
        for name, module in [('network', inspect_network_condition),
                             ('storage', inspect_storage_condition)]:
            for state, evidence in [('unknown', {'note': 'unknown'}), ('low', {})]:
                self.runtime.prepared_conditions[name] = {
                    'session_id': self.runtime.session.session_id, 'state': state,
                    'evidence': evidence}
                self.assertEqual(module.build_tool(self.runtime).invoke({})['status'], 'BLOCKED')
        self.assertEqual(self.runtime.session.driver.calls, [])

    def test_external_link_reads_active_app_and_visible_native_evidence(self):
        result = inspect_external_link.build_tool(self.runtime).invoke({})
        self.assertEqual(result['status'], 'COMPLETE')
        self.assertEqual(result['active_app']['bundle_id'], 'com.example.browser')
        self.assertIn('External trailer', result['visible_text'])
        self.assertEqual(result['exposed_urls'], ['https://video.example/watch?id=23'])
        self.assertEqual(self.runtime.session.driver.calls,
                         [('execute', 'mobile: activeAppInfo'), ('source',)])
        self.assertNotIn('hidden.example', json.dumps(result))

    def test_external_link_cannot_read_inactive_session_or_hidden_subtree(self):
        self.runtime.active = False
        self.assertEqual(inspect_external_link.build_tool(self.runtime).invoke({})['status'], 'BLOCKED')
        self.assertEqual(self.runtime.session.driver.calls, [])
        self.runtime.active = True
        self.runtime.session.driver.source = ('<Root><Other visible="false"><Text visible="true" '
                                              'label="https://hidden-parent.example"/></Other></Root>')
        result = inspect_external_link.build_tool(self.runtime).invoke({})
        self.assertEqual(result['exposed_urls'], [])

    def test_external_inspection_failure_does_not_launch_an_app(self):
        self.runtime.session.driver.source = '<malformed'
        result = inspect_external_link.build_tool(self.runtime).invoke({})
        self.assertEqual(result['status'], 'FAILED')
        self.assertFalse(any(call[0] in ('activate', 'terminate')
                             for call in self.runtime.session.driver.calls))

    def test_external_inspection_blocks_an_unrelated_foreground_app_before_source(self):
        self.runtime.external_handoff = None
        result = inspect_external_link.build_tool(self.runtime).invoke({})
        self.assertEqual(result['status'], 'BLOCKED')
        self.assertEqual(self.runtime.session.driver.calls, [('execute', 'mobile: activeAppInfo')])

    def test_request_started_requires_host_instrumentation_without_any_ui_reads(self):
        result = wait_for_request_started.build_tool(self.runtime).invoke({'query': 'sample'})
        self.assertEqual(result['status'], 'BLOCKED')
        self.assertEqual(self.runtime.session.driver.calls, [])

    def test_request_started_accepts_only_matching_explicit_inflight_instrumentation(self):
        probes = iter([
            {'session_id': 'another-session', 'query': 'sample', 'started_at': '2026-11-03T12:00:00Z', 'completed': False},
            {'session_id': self.runtime.session.session_id, 'query': 'other', 'started_at': '2026-11-03T12:00:00Z', 'completed': False},
            {'session_id': self.runtime.session.session_id, 'query': 'sample', 'started_at': '2026-11-03T12:00:00Z', 'completed': False}])
        self.runtime.request_probe = lambda query: next(probes)
        with patch.object(wait_for_request_started.time, 'sleep'):
            result = wait_for_request_started.build_tool(self.runtime).invoke({'query': 'sample'})
        self.assertEqual(result['status'], 'COMPLETE')
        self.assertEqual(result['source'], 'external_instrumentation')
        self.assertEqual(result['evidence']['query'], 'sample')
        self.assertEqual(result['poll_count'], 3)
        self.assertEqual(self.runtime.session.driver.calls, [])

    def test_completed_or_ambiguous_request_evidence_is_not_inferred_to_be_inflight(self):
        base = {'session_id': self.runtime.session.session_id, 'query': 'sample',
                'started_at': '2026-11-03T12:00:00Z'}
        for completion in ({}, {'completed': True}, {'completed': False, 'completed_at': '2026-11-03T12:00:01Z'}):
            self.runtime.request_probe = lambda query: {**base, **completion}
            with patch.object(wait_for_request_started.time, 'monotonic', side_effect=[1.0, 1.0, 1.0, 1.0, 3.0]), \
                    patch.object(wait_for_request_started.time, 'sleep'):
                result = wait_for_request_started.build_tool(self.runtime).invoke(
                    {'query': 'sample', 'timeout_seconds': 1.0})
            self.assertEqual(result['status'], 'BLOCKED')

    def test_request_probe_errors_omit_raw_exception_details(self):
        def probe(query): raise RuntimeError('credential-secret')
        self.runtime.request_probe = probe
        result = wait_for_request_started.build_tool(self.runtime).invoke({'query': 'sample'})
        self.assertEqual(result['status'], 'FAILED')
        self.assertEqual(result['error_type'], 'RuntimeError')
        self.assertNotIn('credential-secret', json.dumps(result))

    def test_inactive_session_blocks_probe_before_instrumentation_call(self):
        self.runtime.active = False
        with patch.object(self.runtime, 'request_probe') as probe:
            result = wait_for_request_started.build_tool(self.runtime).invoke({'query': 'sample'})
        self.assertEqual(result['status'], 'BLOCKED')
        probe.assert_not_called()

    def test_return_and_relaunch_use_only_configured_bundle_through_mutate(self):
        result = return_to_app.build_tool(self.runtime).invoke({})
        self.assertEqual(result['status'], 'ACKNOWLEDGED')
        self.assertIn('after_observation', result)
        self.assertNotIn('dispatch_result', result)
        json.dumps(result)
        self.assertEqual(self.runtime.mutations, ['return_to_app'])
        self.assertEqual(self.runtime.session.driver.calls, [('activate', self.runtime.bundle_id)])
        self.runtime.session.driver.calls.clear()
        result = relaunch_app.build_tool(self.runtime).invoke({})
        self.assertEqual(result['status'], 'ACKNOWLEDGED')
        self.assertEqual(self.runtime.mutations[-1], 'relaunch_app')
        self.assertEqual(self.runtime.mutation_costs[-1], 2)
        self.assertEqual(self.runtime.session.driver.calls,
                         [('terminate', self.runtime.bundle_id), ('activate', self.runtime.bundle_id)])

    def test_missing_bundle_blocks_without_mutation(self):
        self.runtime.bundle_id = ''
        for module in (return_to_app, relaunch_app):
            self.assertEqual(module.build_tool(self.runtime).invoke({})['status'], 'BLOCKED')
        self.assertEqual(self.runtime.mutations, [])
        self.assertEqual(self.runtime.session.driver.calls, [])


if __name__ == '__main__': unittest.main()
