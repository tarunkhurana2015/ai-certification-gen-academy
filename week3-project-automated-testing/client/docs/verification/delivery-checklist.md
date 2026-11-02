# Demo handoff — November 2, 2026

The developer clarified that Movies is a demo substrate for the later agentic testing system, and requested a faster handoff. Remaining production-style verification is deferred; the original full-delivery definition is not represented as complete.

Implemented: four tabs; After Hours theme; real TMDB adapters and explicit fictional Demo mode; five-plus navigation levels; movie/person/credits/filmography/collections/related/images/reviews/trailer affordances; local transactional favorites, immediate removal and Undo; search debounce and stale-response ownership; recovery states; stable automation identifiers.

Executed evidence:

- Five isolated Flutter Simulator journeys passed on iPhone 18 Pro Max, UDID `4F0707AE-45BC-464D-9099-6EE76C3740A9`, before the final reviewed pagination/recovery changes. Those changes subsequently passed focused widget/viewmodel regressions.
- All 24 viewport/text-scale widget matrix cases passed, including keyboard plus Undo. The subsequent combined recovery/matrix run passed 30 tests.
- Review regressions: unchanged-query debounce, recommendation Retry fallback, exhausted-filtered-page fallback, and real scroll pagination were reproduced then corrected. Search and Home suites passed 10 tests each.
- A measured coverage run reported 91.53% combined, all owning members above 85%. This is an intermediate measurement, not a final clean quality-gate claim after subsequent changes.
- All 64 acceptance examples have mappings to concrete test references. Full final acceptance/coverage gate remains deferred; a mapping alone is not pass evidence.

Deferred / not passed:

- N1 actual process-restart add/removal/Undo and N2 native background verification: XCUITest harness was added, but initial execution failed its acknowledgement assertions. File-backed persistence and deterministic lifecycle checks pass; they are not substituted for native proof.
- N4 actual largest system text, reduced motion, native back/keyboard/accessibility matrix is incomplete. Synthetic widget checks pass. Accessibility Inspector and physical VoiceOver are unverified.
- Authenticated TMDB smoke and N3 real trailer/browser return: **notRun**, no local token configured.
- Minor independent-review finding: detail movie summaries do not yet derive `genreIds` from provider detail `genres` objects, although the displayed detail genre chips are correct.

The normal app entrypoint is `apps/app/lib/main.dart`. Native verification entrypoints are development-only, use restricted test-owned database names, and do not reset or modify the ordinary Demo Library. No backend, automated testing agent, merge or publication has been performed.
