"""Inspect the foreground app and exposed native accessibility evidence."""
# Regular expressions extract URL-shaped text; no extracted URL is opened.
import re
# Native Appium page_source is XML, so parse it into a navigable element tree.
from xml.etree import ElementTree
from langchain_core.tools import tool


# Bind the host's runtime into a closure. The model never supplies a driver,
# app identity, or URL here; it can only request this zero-argument inspection.
def build_tool(runtime):
    # @tool builds a wrapper with the function's docstring and empty argument
    # schema. The host later passes returned tools to create_agent for model
    # access; constructing the wrapper does not execute an inspection.
    @tool
    def inspect_external_link() -> dict:
        """Read active app identity and bounded visible text or URLs, without launching another app."""
        # This context manager acquires the shared lock while reading session
        # state and Appium evidence. It is not a Session context manager and
        # does not start or stop the host-owned Appium session.
        with runtime.lock:
            try:
                # Require an open run, the same live session, and time remaining.
                runtime.require_active()
            except Exception:
                return runtime.blocked('inspect_external_link', 'An active owned session is required.')

            # This receipt collects app identity plus small lists of native
            # text and URL-shaped strings. COMPLETE means the inspection ran,
            # not that a destination loaded or that media playback succeeded.
            receipt = {
                'operation': 'inspect_external_link',
                'status': 'COMPLETE',
                'active_app': {},
                'visible_text': [],
                'exposed_urls': [],
                'source': 'Appium activeAppInfo and native page_source',
                'limitation': 'Only native exposed text is inspected; destination playback is not verified.'
            }
            try:
                # Ask Appium which app is currently in front; this command
                # reads identity and does not activate a different app.
                info = runtime.session.driver.execute_script('mobile: activeAppInfo')
                # bundleId must be a nonempty string before it can establish
                # which app's accessibility tree is about to be inspected.
                if not isinstance(info, dict) or not isinstance(info.get('bundleId'), str) or not info['bundleId']:
                    raise ValueError('Active app identity unavailable')

                # Bound identity strings in the receipt to 256 characters each.
                receipt['active_app'] = {'bundle_id': info['bundleId'][:256]}
                if isinstance(info.get('name'), str):
                    receipt['active_app']['name'] = info['name'][:256]

                # A previous guarded action may have recorded an external app
                # handoff: {'bundleId': ..., 'source_receipt_id': ...}.
                handoff = getattr(runtime, 'external_handoff', None)
                # Only inspect the owned app or that specifically recorded
                # destination; an unrelated foreground app is not sufficient.
                if (info['bundleId'] != runtime.bundle_id
                        and (not isinstance(handoff, dict) or handoff.get('bundleId') != info['bundleId'])):
                    return runtime.blocked('inspect_external_link',
                        'Foreground app does not match the owned app or a recorded external handoff.')

                # Link this inspection back to the action that observed the
                # handoff, preserving where the external-app evidence came from.
                if isinstance(handoff, dict) and info['bundleId'] == handoff.get('bundleId'):
                    receipt['handoff_source_receipt_id'] = handoff.get('source_receipt_id')

                # Read the native accessibility hierarchy, not a browser's DOM.
                source = runtime.session.driver.page_source
                # Refuse malformed/oversized source before parsing its XML.
                if not isinstance(source, str) or len(source.encode('utf-8')) > 2_000_000:
                    raise ValueError('Native source size limit exceeded')
                root = ElementTree.fromstring(source)

                # pending is a stack of (XML node, ancestor-is-hidden) tuples.
                # Keeping the ancestor flag avoids treating descendants of a
                # hidden container as visible just because they say "true".
                pending = [(root, False)]
                inspected_nodes = 0
                # Cap traversal work even when the hierarchy contains many nodes.
                while pending and inspected_nodes < 5000:
                    node, parent_hidden = pending.pop()
                    inspected_nodes += 1

                    # Native sources may express visibility as visible/displayed.
                    # Any explicit false hides a node; at least one true is
                    # required before its text is accepted as visible evidence.
                    flags = [node.attrib.get(key, '').lower() for key in ('visible', 'displayed')]
                    hidden = parent_hidden or 'false' in flags
                    if not hidden and 'true' in flags:
                        # These accessibility attributes can hold visible text
                        # or URLs, but their contents are evidence, not commands.
                        for key in ('label', 'value', 'name'):
                            value = node.attrib.get(key, '').strip()
                            # Store at most 40 text entries, each at most 300
                            # characters; avoid repeating an already stored value.
                            if value and value not in receipt['visible_text'] and len(receipt['visible_text']) < 40:
                                receipt['visible_text'].append(value[:300])

                                # Look for HTTP(S) strings only inside that
                                # bounded text; finding one does not visit it.
                                for url in re.findall(r'https?://[^\s<>"\x27]+', value[:300]):
                                    # Remove punctuation often following a link
                                    # in prose rather than belonging to the URL.
                                    url = url.rstrip('.,);]')
                                    if url not in receipt['exposed_urls'] and len(receipt['exposed_urls']) < 20:
                                        receipt['exposed_urls'].append(url)

                    # Reverse the children before pushing them so stack pop()
                    # visits the original left-to-right XML order next.
                    pending.extend((child, hidden) for child in reversed(list(node)))

                # Signal that the traversal or text limit may have omitted data.
                receipt['evidence_truncated'] = bool(pending) or len(receipt['visible_text']) >= 40
            except Exception as error:
                # Preserve a structured failure result without exposing an
                # arbitrary Appium exception message or claiming verification.
                receipt.update(status='FAILED', error_type=type(error).__name__,
                               reason='Foreground app inspection did not complete.')

            # Attach receipt/session IDs and timestamp, and try to save it.
            return runtime.record(receipt)

    # Return the registered tool object; the host still controls invocation.
    return inspect_external_link
