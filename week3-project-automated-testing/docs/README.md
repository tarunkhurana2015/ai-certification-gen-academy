# Week 3 project documentation

This documentation follows the Week 2 capstone format and explains the current
agentic testing prototype, its Movies client, and the planned product direction.

- [Read the editable Markdown](WEEK_3_DOCUMENTATION.md).
- [Open the Word export](WEEK_3_DOCUMENTATION.docx); upload this file to Google Drive
  and open it with Google Docs for an editable document with headings, tables, and
  embedded diagrams.
- [Open the browser reading copy](WEEK_3_DOCUMENTATION.html).

The ten sections cover resources and value, the testing problem, architecture,
five technical pillars, the client, artifacts, stack, verification/readiness,
setup and two demos, and acknowledgments. Implemented features are distinguished
from the multi-agent, memory, MCP, and platform roadmap.

## Diagrams

| Diagram | PNG | Editable SVG |
| --- | --- | --- |
| Implemented architecture | [PNG](assets/current-implemented-architecture.png) | [SVG](assets/current-implemented-architecture.svg) |
| Observation and action loop | [PNG](assets/current-observe-act-loop.png) | [SVG](assets/current-observe-act-loop.svg) |

The Markdown and HTML use the neighboring image files. The Word export embeds
them. Keep the HTML and `assets/` directory together when sharing the browser copy.
Repository-relative links in the Word export target the corresponding GitHub
paths; new documentation links become available there after the changes are pushed.

## Refreshing exports

Edit `WEEK_3_DOCUMENTATION.md` first. Export helpers use `markdown`, `python-docx`,
and Pillow as optional documentation dependencies; they are not application
runtime dependencies and have not been added to the project manifests.

From this directory, using an environment with those packages installed:

```sh
python3 assets/generate_diagrams.py
python3 build_documentation.py
```

The diagram generator uses macOS Arial fonts. Adapt its font paths when rendering
on another operating system. The exporter regenerates the Word and HTML copies
from the Markdown and current PNGs. It makes no model or device calls.

## Verification snapshot

- November 9, 2026: all 145 offline automation-code tests passed.
- Word export validated for ten numbered sections, eight tables, two embedded
  images, and internal navigation links.
- Diagrams and browser layout visually checked; repository links validated.
- App journeys were not rerun for this documentation task. The source notebook's
  existing user edits were preserved.

See [KNOWN_GAPS.md](../server/sample_scenarios/KNOWN_GAPS.md) for current readiness
limitations and [ENHANCEMENTS.md](../server/sample_scenarios/ENHANCEMENTS.md) for
the execution improvement backlog.
