"""Deliver a registered saved screenshot to the calling model for visual review."""
# Base64 makes binary PNG bytes transportable inside the image content block.
import base64
# JSON serializes the evidence receipt into the tool's text content block.
import json
# struct reads PNG's fixed-width, big-endian integer fields from binary bytes.
import struct
# zlib provides the CRC32 checksum used to check each PNG chunk's integrity.
import zlib

# The decorator builds a wrapper/schema for later agent setup. It also supports
# separate model-facing content and a host-visible structured artifact.
from langchain_core.tools import tool

# Shared helpers restrict reads to this host's registered same-session artifacts.
from ._evidence import _EvidenceUnavailable, _artifact_path, _observation


# Bound the actual image payload to 2 MiB, not merely the encoded text length.
_MAX_IMAGE_BYTES = 2 * 1024 * 1024


def _valid_png(png):
    """Check complete PNG framing/checksums before attaching image content."""
    # A PNG starts with this exact eight-byte signature; an extension or an
    # artifact's declared MIME type alone is insufficient to identify its bytes.
    if not png.startswith(b"\x89PNG\r\n\x1a\n"):
        return False
    # Skip the signature. Track whether the required header and any compressed
    # image-data chunk have appeared while walking the file's chunk structure.
    offset, has_header, has_data = 8, False, False
    # Every chunk needs at least 12 bytes: length (4), kind (4), and CRC (4).
    while offset + 12 <= len(png):
        # ">I" means an unsigned four-byte integer in big-endian byte order.
        # The final [0] extracts its value from struct's returned tuple.
        size = struct.unpack_from(">I", png, offset)[0]
        # size counts the body bytes; the framing adds the other 12 bytes.
        end = offset + 12 + size
        # Reject a chunk whose declared length extends past the available file.
        if end > len(png):
            return False
        # Slice out the four-byte kind and body, then read the stored checksum.
        kind = png[offset + 4:offset + 8]
        body = png[offset + 8:offset + 8 + size]
        checksum = struct.unpack_from(">I", png, offset + 8 + size)[0]
        # PNG checksums cover kind + body, not the leading length field.
        # The mask keeps the computed value in the unsigned 32-bit range.
        if zlib.crc32(kind + body) & 0xFFFFFFFF != checksum:
            return False
        if not has_header:
            # IHDR must be first and must contain its fixed 13-byte header.
            if kind != b"IHDR" or size != 13:
                return False
            # The first two header fields are width and height, each four bytes.
            width, height = struct.unpack_from(">II", body)
            # Zero-sized PNG dimensions are invalid.
            if not width or not height:
                return False
            has_header = True
        elif kind == b"IHDR":
            # A second image header would violate this framing check.
            return False
        if kind == b"IDAT":
            # Record that image data exists without decompressing its pixels.
            has_data = True
        if kind == b"IEND":
            # An empty end chunk must be the actual end of the byte stream,
            # and at least one image-data chunk must have been seen.
            return size == 0 and has_data and end == len(png)
        # Continue at the following chunk rather than scanning inside its body.
        offset = end
    # Running out of complete chunks before IEND is not a complete PNG frame.
    return False


def build_tool(runtime):
    """Bind a bounded multimodal evidence tool without calling an image model."""

    # The host binds runtime through this closure. The LLM supplies only the
    # observation ID, not a screenshot path, session, or image-model client.
    # content_and_artifact means the return tuple contains model-facing tool
    # content first and a structured artifact second. In a tool-call workflow,
    # LangChain puts these on the ToolMessage content and artifact fields.
    @tool(response_format="content_and_artifact")
    def review_visual_evidence(observation_id: str) -> tuple[list[dict], dict]:
        """Show the screenshot from a registered observation to the calling model.

        Only host-registered same-session PNG artifacts may be returned, up to
        2 MiB. The response includes actual image content, plus a recorded
        REVIEW_REQUIRED receipt with artifact references. The calling model must
        assess the image and distinguish visible facts from uncertainty; this
        tool makes no deterministic visual PASS claim and invokes no vision API.
        The screenshot represents its saved capture, not current or future UI.
        """
        # Hold the reentrant runtime lock across registry lookup, file reading,
        # and receipt creation so other tools cannot interleave session state.
        with runtime.lock:
            try:
                # Require the currently bound host session and run deadline.
                runtime.require_active()
                # Reject missing, unregistered, or different-session captures.
                observation = _observation(runtime, observation_id)
                # Resolve only the valid screenshot path registered by the host;
                # the helper confines the file to this session's artifact root.
                path = _artifact_path(runtime, observation, "screenshot")
                # Binary mode preserves the exact image bytes. Read one byte
                # beyond the limit so an oversized image can be detected while
                # keeping memory use bounded instead of loading the whole file.
                with path.open("rb") as image_file:
                    png = image_file.read(_MAX_IMAGE_BYTES + 1)
                if len(png) > _MAX_IMAGE_BYTES:
                    raise _EvidenceUnavailable("The registered screenshot exceeds the 2 MiB image payload limit.")
                # Check PNG framing and checksums before attaching content.
                # This does not decode pixels or assess what the UI depicts.
                if not _valid_png(png):
                    raise _EvidenceUnavailable("The registered screenshot is not a PNG image.")
                # REVIEW_REQUIRED requests assessment by the model that called
                # this tool; it is not a deterministic visual PASS or FAIL.
                # record() adds metadata and attempts to persist the receipt.
                receipt = runtime.record({
                    "operation": "review_visual_evidence", "status": "REVIEW_REQUIRED",
                    "reason": "The screenshot is attached for assessment by the calling model.",
                    # Identify the capture and who must assess its image.
                    "observation_id": observation_id, "assessment_source": "calling_model",
                    "deterministic_visual_assertion": False,
                    # Keep provenance beside size/type and the saved-image scope.
                    "evidence": {"observation_manifest": observation.get("manifest_path"), "screenshot": str(path)},
                    "image_bytes": len(png), "mime_type": "image/png", "scope": "saved_screenshot_only",
                })
                # Supply both readable receipt text and actual image content.
                # The framework can deliver this multimodal ToolMessage to the
                # calling model; this function makes no additional model/API call.
                content = [
                    {"type": "text", "text": json.dumps(receipt)},
                    # Base64 yields bytes; decode("ascii") makes the transport
                    # string expected by this image content block.
                    {"type": "image", "mime_type": "image/png",
                     "base64": base64.b64encode(png).decode("ascii")},
                ]
                # The same structured receipt is retained as the artifact so
                # host code can inspect provenance without parsing the text.
                return content, receipt
            except (OSError, RuntimeError, _EvidenceUnavailable) as error:
                # Avoid exposing raw filesystem error details in the tool
                # response; evidence/session validation errors retain their reason.
                reason = "The registered screenshot could not be read." if isinstance(error, OSError) else str(error)
                # BLOCKED signals unavailable evidence, not a negative visual
                # finding. Return text plus artifact, with no image attached.
                receipt = runtime.blocked("review_visual_evidence", reason)
                return [{"type": "text", "text": json.dumps(receipt)}], receipt

    # Return the decorated tool bound to the host-owned runtime.
    return review_visual_evidence
