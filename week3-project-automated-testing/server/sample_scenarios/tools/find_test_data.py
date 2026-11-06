"""Live, bounded TMDB lookup using a host-owned read access token."""
# UTC timestamps record when these live API facts were checked.
from datetime import datetime, timezone
# Convert JSON response bytes into ordinary Python dictionaries and lists.
import json
# Literal lists the accepted desired_content choices in the tool's schema.
from typing import Literal
# urllib supplies HTTP error types, safe query encoding, and HTTP requests.
import urllib.error
import urllib.parse
import urllib.request

# @tool constructs LangChain's tool wrapper and its argument schema.
from langchain_core.tools import tool

# Keep requests on TMDB's fixed API base, rather than accepting a model URL.
_BASE = 'https://api.themoviedb.org/3'
# Limit the search to three result pages and five distinct movie detail reads.
# Not finding a match inside these limits cannot prove no match exists at all.
_MAX_PAGES = 3
_MAX_CANDIDATES = 5
# A single response body may contain at most two million bytes.
_MAX_BYTES = 2_000_000


# Reduce one movie detail response to selected fields, and return it only when
# the response explicitly supports the requested kind of test data.
def _candidate(details, desired_content):
    # A dictionary comprehension keeps these known keys when they are present;
    # it does not copy the entire API response into the agent's tool result.
    candidate = {key: details[key] for key in ('id', 'title', 'release_date',
                  'poster_path', 'backdrop_path') if key in details}
    # 'any' needs no special content. Other choices must find their own evidence.
    matched = desired_content == 'any'
    if desired_content == 'collection':
        collection = details.get('belongs_to_collection')
        # Require a nested collection object with an actual integer ID.
        # type(...) is int also excludes booleans, which subclass int in Python.
        if isinstance(collection, dict) and type(collection.get('id')) is int:
            candidate['collection'] = {key: collection[key] for key in ('id', 'name') if key in collection}
            matched = True
    elif desired_content == 'missing_artwork':
        # Only a present field explicitly set to None counts as missing artwork.
        # An omitted field is not enough evidence to make that claim.
        fields = [key for key in ('poster_path', 'backdrop_path')
                  if key in details and details[key] is None]
        candidate['missing_artwork_fields'] = fields
        # bool(list) is true when at least one qualifying field was found.
        matched = bool(fields)
    elif desired_content == 'images':
        images = details.get('images', {})
        if isinstance(images, dict):
            # Flatten the three image groups into their nonempty path strings.
            # The nested for clauses visit every item in each selected group.
            paths = [item['file_path'] for kind in ('backdrops', 'posters', 'logos')
                     for item in images.get(kind, []) if isinstance(item, dict)
                     and isinstance(item.get('file_path'), str) and item['file_path']]
            # Report the full count but return only three example paths.
            candidate['returned_image_count'] = len(paths)
            candidate['image_paths'] = paths[:3]
            matched = bool(paths)
    elif desired_content in ('reviews', 'trailer'):
        # TMDB stores trailers in its videos section, not a trailer section.
        field = 'reviews' if desired_content == 'reviews' else 'videos'
        section = details.get(field, {})
        results = section.get('results', []) if isinstance(section, dict) else []
        if isinstance(results, list):
            # Drop malformed entries and entries without an ID.
            entries = [item for item in results if isinstance(item, dict)
                       and item.get('id') is not None]
            if desired_content == 'trailer':
                # A usable trailer record needs its type, a nonempty external
                # video key, and a nonempty hosting site. This is API metadata;
                # it does not demonstrate that the trailer actually plays.
                entries = [item for item in entries if item.get('type') == 'Trailer'
                           and isinstance(item.get('key'), str) and item['key']
                           and isinstance(item.get('site'), str) and item['site']]
                keys = ('id', 'key', 'site', 'type', 'name')
            else:
                # Review bodies are not needed; keep only identity/source fields.
                keys = ('id', 'author', 'url')
            # Return up to three entries, each reduced to the selected keys.
            candidate[field] = [{key: item[key] for key in keys if key in item}
                                for item in entries[:3]]
            matched = bool(entries)
    # None tells the caller that this inspected movie did not match the filter.
    return candidate if matched else None


# The host constructs the tool with its shared runtime. The inner function
# remembers that runtime through a closure; credentials/session/driver are not
# model arguments. The model supplies only query and desired_content.
def build_tool(runtime):
    # Construct a tool wrapper/schema now. The host later gives the returned
    # tools to create_agent, which makes their schemas available to the model.
    @tool
    def find_test_data(query: str, desired_content: Literal[
            'any', 'collection', 'images', 'reviews', 'trailer', 'missing_artwork'] = 'any') -> dict:
        """Find currently reported TMDB movie candidates; API facts do not prove app UI or playback."""
        # Read the API credential from host configuration, never from the model.
        token = runtime.tmdb_token
        if not isinstance(token, str) or not token.strip():
            # blocked() records a structured explanation without making requests.
            return runtime.blocked('find_test_data', 'Host TMDB read access token is not configured.')
        # Reject empty/whitespace queries and bound the original argument length.
        if not query.strip() or len(query) > 200:
            return runtime.blocked('find_test_data', 'Query must contain 1 to 200 characters.')

        # Walk nested receipt values before returning or persisting them. This
        # local helper knows the host token through the same enclosing scope.
        def redact(value):
            if isinstance(value, dict):
                # Preserve dictionary keys while recursively cleaning the values.
                return {key: redact(item) for key, item in value.items()}
            if isinstance(value, list):
                return [redact(item) for item in value]
            if isinstance(value, str):
                # Remove raw, percent-encoded, and form-encoded token strings
                # wherever they appear inside a string value in this receipt.
                for secret in (token, urllib.parse.quote(token, safe=''), urllib.parse.quote_plus(token)):
                    value = value.replace(secret, '[REDACTED]')
            # Numbers, booleans, None, and cleaned strings retain their values.
            return value

        # candidates contains matching reduced detail records; inspected_count
        # counts all distinct detail candidates attempted, including nonmatches.
        # api_urls records the requests attempted for review of their source.
        # COMPLETE means the bounded lookup ran, even if candidates stays empty.
        receipt = {
            'operation': 'find_test_data',
            'status': 'COMPLETE',
            'query': query,
            'desired_content': desired_content,
            'candidates': [],
            'api_urls': [],
            'inspected_count': 0,
            'source': 'live_tmdb_api',
            'search_scope': 'bounded search: at most 3 pages and 5 candidates; '
                            'no match does not prove global unavailability',
            # API facts alone establish neither app rendering nor playback.
            'app_ui_verified': False
        }

        # Shared request helper for both search pages and movie details. It
        # closes over token and receipt; neither is a new model-facing input.
        def get_json(url):
            # Recheck the remaining run time before each HTTP request.
            remaining = runtime.timeout_seconds_remaining()
            if remaining <= 0:
                raise TimeoutError()
            # Record the attempted URL before dispatch, including failed attempts.
            receipt['api_urls'].append(url)
            # Put the credential in the Authorization header, not the URL.
            # The receipt records URLs but never records these request headers.
            request = urllib.request.Request(url, headers={
                'Authorization': f'Bearer {token}', 'Accept': 'application/json'})

            # This with block closes the HTTP response when its block ends;
            # unlike runtime.lock below, it manages a network resource.
            # A request uses at most a 10-second socket timeout, reduced to the
            # current remaining run time when that amount is smaller.
            with urllib.request.urlopen(request, timeout=min(10.0, remaining)) as response:
                # Read one extra byte so an oversized body can be detected
                # without reading an arbitrarily large response into memory.
                body = response.read(_MAX_BYTES + 1)
            if len(body) > _MAX_BYTES:
                raise ValueError('Response size limit exceeded')

            # JSON may describe many types, but these API endpoints must return
            # an object (a Python dict), not a list or a scalar.
            data = json.loads(body)
            if not isinstance(data, dict):
                raise ValueError('Response is not an object')
            return data

        try:
            # Hold the shared lock across the lookup so protected runtime
            # operations do not overlap this session-bound search. This with
            # block acquires/releases a Python lock; it does not enter or close
            # the existing Appium Session context manager owned by the host.
            with runtime.lock:
                try:
                    # Require an open, unchanged live session with time left.
                    runtime.require_active()
                except Exception:
                    return runtime.blocked('find_test_data', 'An active owned session is required.')

                # A set records movie IDs already inspected, preventing repeated
                # search results from consuming multiple detail requests.
                inspected = set()
                for page in range(1, _MAX_PAGES + 1):
                    # urlencode treats the query as a query parameter, not as
                    # URL syntax. Search the stripped query and exclude adults.
                    search_url = _BASE + '/search/movie?' + urllib.parse.urlencode({
                        'query': query.strip(), 'page': page, 'include_adult': 'false'})
                    search = get_json(search_url)
                    results = search.get('results')
                    if not isinstance(results, list):
                        raise ValueError('Missing search results')

                    for item in results:
                        # Ignore malformed rows, invalid IDs, and duplicates.
                        movie_id = item.get('id') if isinstance(item, dict) else None
                        if type(movie_id) is not int or movie_id <= 0 or movie_id in inspected:
                            continue
                        if len(inspected) >= _MAX_CANDIDATES:
                            break

                        # Count this candidate before fetching its details, so
                        # a failed request is still shown as an inspection attempt.
                        inspected.add(movie_id)
                        receipt['inspected_count'] = len(inspected)
                        detail_url = f'{_BASE}/movie/{movie_id}'

                        # Fetch optional content alongside the movie details
                        # only when this desired_content value needs it.
                        append = {'images': 'images', 'reviews': 'reviews', 'trailer': 'videos'}.get(desired_content)
                        if append:
                            detail_url += '?' + urllib.parse.urlencode({'append_to_response': append})
                        details = get_json(detail_url)

                        # Confirm the response describes the exact movie we
                        # requested before attaching its fields as evidence.
                        if type(details.get('id')) is not int or details['id'] != movie_id:
                            raise ValueError('Movie detail identity mismatch')
                        candidate = _candidate(details, desired_content)
                        if candidate is not None:
                            # Provenance links this match to both the search
                            # and detail URLs and the UTC time it was checked.
                            candidate['provenance'] = {
                                'api_urls': [search_url, detail_url],
                                'checked_at_utc': datetime.now(timezone.utc).isoformat()}
                            receipt['candidates'].append(candidate)

                    # Stop when the candidate budget is spent, a page is empty,
                    # or TMDB explicitly reports that this is its final page.
                    total_pages = search.get('total_pages')
                    if (len(inspected) >= _MAX_CANDIDATES or not results
                            or (type(total_pages) is int and page >= total_pages)):
                        break
        except urllib.error.HTTPError as error:
            # Authentication/authorization rejections block this lookup. Other
            # HTTP failures mark it failed; never copy response bodies/headers,
            # which could contain credentials or unrelated service details.
            receipt.update(status='BLOCKED' if error.code in (401, 403) else 'FAILED',
                           error_type=type(error).__name__, http_status=error.code,
                           reason='TMDB HTTP request was rejected; response headers and body are omitted.')
        except Exception as error:
            # Timeout, JSON, size, and shape errors all return a bounded failure
            # explanation. Existing candidate evidence may be partial, so the
            # receipt must not assert facts about items that were never checked.
            receipt.update(status='FAILED', error_type=type(error).__name__,
                           reason='TMDB lookup did not complete; no unobserved availability is asserted.')

        # Timestamp the overall outcome, redact nested result values, and let
        # record() add receipt metadata and attempt to persist the safe result.
        receipt['checked_at_utc'] = datetime.now(timezone.utc).isoformat()
        return runtime.record(redact(receipt))

    # The host later includes this returned wrapper in create_agent's tool list.
    # Building the tool itself sends no TMDB requests and controls no device.
    return find_test_data
