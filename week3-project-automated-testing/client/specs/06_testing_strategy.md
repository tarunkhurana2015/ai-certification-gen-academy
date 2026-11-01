# Stage 6: Movies — Testing Strategy

Status: Approved by the developer.
Approval recorded: November 1, 2026 (America/Chicago), from the developer reply “approved”.
Date: November 1, 2026 (America/Chicago).
Prerequisites: [Stage 1 scope](01_product_scope.md), [Stage 2 acceptance criteria](02_user_journeys_and_features.md), [Stage 3 architecture](03_architecture_and_monorepo.md), [Stage 4 design](04_design_system_and_responsive.md), and [Stage 5 contracts](05_api_and_data_contracts.md), all approved.
Target: iOS Simulator client, with deterministic fast checks in CI and local Simulator verification before delivery.

## 1. Decisions and evidence boundaries

| Decision | Basis |
| --- | --- |
| At least 85% line coverage of handwritten business logic | Explicit Stage 6 discovery response. |
| Formatting, analysis, unit tests, and widget tests in CI; local iOS Simulator checks before delivery | Explicit Stage 6 discovery response. |
| Controlled data for behavioral acceptance; real TMDB checked separately | Approved Stages 2, 3, and 5. |
| Repository injection, real controller tests, real SQLite tests, and focused host integration journeys | Engineering strategy proposed for Stage 6 approval. |
| GitHub Actions for fast CI, using a Linux runner and the approved Flutter/Dart versions | Proposed CI implementation within the developer's selected fast-CI approach. |

Three approaches were considered: live end-to-end tests alone are sensitive to provider changes and cannot reproduce failures reliably; full Simulator CI on every pull request adds macOS infrastructure beyond the selected scope; the selected layered strategy runs deterministic checks in fast CI and requires a documented local Simulator delivery gate. No paid device service, HeadSpin, Patrol, Appium, MCP, or autonomous testing agent is required for this client release.

The strategy measures product behavior rather than test count alone. A coverage percentage cannot waive a missing search-race, persistence, navigation, recovery, or accessibility assertion. Tests must assert the relevant observable Then clauses; private implementation calls, generated Freezed methods, or screenshots without assertions do not establish acceptance.

This stage defines future tests and gates. No Flutter application, dependency resolution, test suite, Simulator run, or coverage result exists yet for Movies. Passing the specification audit is not a claim that the application passes these gates.

## 2. Test layers and ownership

| Layer | Location and real subject | Replaced boundaries / evidence |
| --- | --- | --- |
| Pure Dart unit | `packages/movies_core/test`: validators, date/URI conversions, request identity, domain invariants | No Flutter engine or real HTTP. Test meaningful application contracts, not generated equality/copyWith boilerplate. |
| Data adapter and storage | `packages/movies_data/test`: actual DTO mapping, Dio adapter/retry/cache, FIFO repository, Drift schema/DAO | Fake Dio transport returns controlled raw responses; injected clocks/delay/jitter. Real in-memory SQLite and owned temporary-file databases exercise storage. |
| Controller | Each feature's `test/viewmodel/`: actual Riverpod controllers and immutable state transitions | Repository, clock/scheduler, and launcher contracts replaced explicitly; never mock the controller under test. |
| Widget and semantics | `packages/movies_ui/test`, feature `test/views/`, and `apps/app/test` | Real views/controllers; fixture repositories and local images. Verify visible content, actions, state, semantics, and layout. Host tests use the real composed router. |
| App integration | `apps/app/integration_test`: real host, route composition, widgets, and plugin wiring on iOS Simulator | Fixture catalog and simulated launcher; real Drift with an isolated test database. Focus on five integration anchors listed below. |
| Local native/manual | An installed Movies build on the selected Simulator | Actual keyboard/insets, native back gesture, background/resume, app termination/relaunch, live external-browser return, Accessibility Inspector, and visual review. |
| Authenticated live smoke | Local live mode with a developer-provided token | Real TMDB endpoint shapes and available relationships. Separate from deterministic CI and never substitutes for it. |

Use the existing `test`, `flutter_test`, and SDK `integration_test` dependencies approved in Stage 3. Hand-written fakes, controlled completers, public Dio transport seams, and Drift injection are sufficient; no extra mocking library, Gherkin runner, golden library, or coverage dependency is required. Gherkin remains the behavior source; Dart test names carry its acceptance IDs.

## 3. Isolation, timing, and controlled data

- Create and dispose a fresh Riverpod container/ProviderScope for each isolated test. Subscribe to an auto-disposed provider while exercising it; release subscriptions, controllers, clocks, cancellation handles, and databases during cleanup. See [Riverpod testing](https://riverpod.dev/docs/how_to/testing).
- Use Stage 2's Northbound/Maya Reed/Afterlight fixture graph, formalized in Stage 5. Preserve source IDs and relationships. Fixture catalogue date is January 15, 2026; elapsed timers advance independently. Synthetic IDs never become assumed live TMDB records.
- Unit/widget tests must not contact TMDB, YouTube, or image hosts. Unexpected HTTP or launcher calls fail the test. Fixtures use local images or explicit image-loader failures; asynchronous image requests must not escape the harness.
- Adapter tests exercise the real mapping/retry/cache code through raw fake transport responses, including malformed JSON/schema cases. Controller tests may return already mapped domain outcomes. These are separate seams with different evidence.
- Use controlled success/failure completers to choose completion order. Test obsolete **success and failure**, not cancellation alone. Request generation checks must still work when cancellation arrives too late.
- For debounce, Undo, timeout, cache TTL, and backoff, inject clocks and scheduling/delay functions. Advance simulated time; do not sleep 350 ms, five seconds, or twenty-five seconds in unit/widget tests. Explicitly pump bounded frames/durations; avoid unconditional pumpAndSettle while a deliberate spinner or pending request is present.
- Real SQLite tests use injected `NativeDatabase.memory()` or a file under a unique test-owned temporary directory, not normal `path_provider` initialization. Close all connections. Native plugin initialization is checked on Simulator. See [Drift testing](https://drift.simonbinder.eu/testing/) and [Flutter plugin test boundaries](https://docs.flutter.dev/testing/plugins-in-tests).
- The normal fixture app uses its separate persistent `movies_fixture.sqlite`. Integration tests inject a uniquely owned test database through bootstrap, preserving real Drift behavior without erasing the developer's live or ordinary fixture Library. Never reset a normal database on launch to manufacture a clean test.
- No automatic retry of a failed test to make CI green. A failure requires diagnosis and a fresh intentional run. Do not hide a required scenario behind skip/solo or an unavailable credential; missing required evidence is reported as not run or blocked.

## 4. Acceptance traceability

Stage 2 contains **62 unique scenario definitions** across eleven families. The Search stale-response outline has success/failure rows; the empty-relationship outline has cast/filmography rows. Expanding these produces **64 baseline examples**, before additional contract/race cases. This is an inventory to implement, not a claim that 64 tests currently exist.

Each implemented test name starts with its concrete acceptance ID. Outline examples add a readable suffix such as `MOV-SEARCH-004 old failure` or `MOV-DEEP-004 empty cast`. The test manifest records ID, example, owning test path, test layer, and required supplemental native evidence. Grouped table rows below must expand to separate ID entries in that manifest.

Legend: **U** unit/controller, **W** widget/semantics, **I** app integration, **M** local native/manual. These are primary responsibility assignments. U-heavy behavior also has focused widget assertions for its visible Then clauses; M-heavy behavior has deterministic lower-level tests in addition to actual native evidence.

| Acceptance IDs | Primary layer and owner | Required evidence |
| --- | --- | --- |
| MOV-SHELL-001, MOV-SHELL-003 | W — host shell | Initial four tabs/no sign-in; offstage completion never steals active navigation. |
| MOV-SHELL-002 | I — host journeys | Deep retained branch, scroll context, tab switching, and correct Back destination. |
| MOV-HOME-001, MOV-HOME-002 | W — Home | Carousel content/action and shelf-to-listing navigation with actual source identity. |
| MOV-HOME-003, MOV-HOME-004 | W — Home | General picks label versus current favorite-seed label and opening a supplied result. |
| MOV-HOME-005, MOV-HOME-007 | W — Home | Exhausted empty seed gives labeled general fallback; empty fallback remains honest. |
| MOV-HOME-006 | W — Home | Failed shelf has Retry while other shelves remain usable. |
| MOV-HOME-008 | U — Home, plus W | Late old-seed success/failure never acquires a new seed's label/results. |
| MOV-BROWSE-001 | W — Browse | Initial Now Playing; Upcoming visibly distinct and correctly identified. |
| MOV-BROWSE-002, MOV-BROWSE-003 | W — Browse | Append/dedup, useful scroll retained, footer Retry, no skipped/duplicate page. |
| MOV-BROWSE-004 | U — Browse, plus W | Category replacement isolates old success/failure and continuation. |
| MOV-BROWSE-005, MOV-BROWSE-006 | W — Browse | Final page stops continuation; successful empty differs from failure. |
| MOV-SEARCH-001, MOV-SEARCH-002, MOV-SEARCH-003 | U — Search, plus W | 350 ms debounce, reset on edit, immediate keyboard submit without duplicate work. |
| MOV-SEARCH-004, MOV-SEARCH-005 | U — Search, plus W | Both outline outcomes; replacement and Clear invalidate old completions. |
| MOV-SEARCH-006, MOV-SEARCH-007 | W — Search | No matches versus failure; old-query results and new-query error remain separately labeled. |
| MOV-SEARCH-008 | I — host journeys | Search → movie → Back retains query, loaded results, and useful scroll. |
| MOV-SEARCH-009 | U — Search, plus W | Continuations append only to the correct displayed/requested identity. |
| MOV-DETAIL-001, MOV-DETAIL-002 | W — Catalog | Rich supplied content, TMDB scale/votes, honest missing fields and optional sections. |
| MOV-DETAIL-003 | W — Catalog | Supplemental error/Retry cannot discard successful core details. |
| MOV-DETAIL-004 | U — Catalog, plus W | Old movie success/failure cannot populate the current movie. |
| MOV-DETAIL-005, MOV-DETAIL-006, MOV-DETAIL-007 | W — Catalog | Images/reviews, navigable unavailable movie, and readable supplied person details. |
| MOV-DEEP-001, MOV-DEEP-002 | I — host journeys | Five additional route pushes after first movie and exact visited Back sequence. |
| MOV-DEEP-003, MOV-DEEP-004 | W — Catalog | Related path without collection; both empty cast/filmography outline rows. |
| MOV-DEEP-005 | I — host journeys | Revisited movie has shared favorite state and separate actual navigation path. |
| MOV-LIBRARY-001, MOV-LIBRARY-003 | W — Library/shared favorites | Shared state, no duplicates, immediate removal, reachable Undo, correct restored order. |
| MOV-LIBRARY-002, MOV-LIBRARY-004, MOV-LIBRARY-010 | M — persistence check N1, plus real DB tests | Genuine process restart after acknowledged add, removal expiry, and successful Undo restoration. |
| MOV-LIBRARY-005, MOV-LIBRARY-006 | U — shared favorites, plus W | Pending write/Undo order; latest offer only; tab changes do not reset its deadline. |
| MOV-LIBRARY-007, MOV-LIBRARY-011, MOV-LIBRARY-012 | U — shared favorites, plus W | Failed remove/add/restore rolls back affected intent correctly; actionable error and unrelated favorites preserved. |
| MOV-LIBRARY-008, MOV-LIBRARY-009 | W — Library | Failed read is recoverable and non-destructive; successful empty baseline alone shows empty state. |
| MOV-LIBRARY-013 | M — lifecycle check N2, plus U/W | Actual background/resume invalidates the offer immediately without restoring a saved removal. |
| MOV-RECOVERY-001, MOV-RECOVERY-002 | W — shared states and host | First-load Retry and retained-content refresh error under the correct source identity. |
| MOV-RECOVERY-003 | W — Library/Catalog, plus real DB tests | Saved identity and local mutations work without network; uncached details fail honestly. |
| MOV-RECOVERY-004 | U — data/controller, plus W | 429/cooldown, visible temporary failure, no fast retry loop or empty-result claim. |
| MOV-RECOVERY-005, MOV-RECOVERY-006 | W — host/UI | Missing/rejected configuration leaves local tabs/Library usable; broken art retains title/open action. |
| MOV-EXTERNAL-001 | M — link check N3, plus gateway tests | Real allowed live trailer opens outside Movies and returning preserves context. Fixture simulation is separate evidence. |
| MOV-EXTERNAL-002 | W — Catalog, plus gateway tests | Missing/unsupported/failed trailer leaves navigable movie and honest failure/unavailable state. |
| MOV-A11Y-001, MOV-A11Y-002 | M — accessibility/layout check N4, plus W | Stable identities, semantics states and separate actions; actual Simulator text/inset/landscape checks. VoiceOver speech limit below. |
| MOV-ABOUT-001 | W — Home/About | Reachable logo/source/exact approved notice and working approved-link intent. |

The five I assignments are the core automated Simulator journeys. The seven M assignments require the supplemental evidence below; lower-level tests cannot be reported as proof of an actual process/native transition. All 62 IDs, including A11Y IDs, must appear in traceability using the pattern `MOV-[A-Z0-9]+-` followed by three digits. The test audit rejects missing/unknown IDs and unexpanded outline rows.

## 5. Required contract and race cases beyond the baseline

These tests cover approved behavior that a happy-path scenario or coverage percentage can miss. Organize them by public responsibility rather than copying private implementation branches.

| Responsibility | Explicit cases |
| --- | --- |
| Search | No request at 349 ms, exactly one at 350; renewed typing restarts the window; whitespace-only input; trim without changing internal spaces/case; submit consumes debounce; late success and failure after replacement/Clear; duplicate continuation trigger; rendered old/new-query attribution. |
| Async ownership | Old success and failure for category, entity, recommendation seed, supplementary section, and continuation; request disposal cancels/releases work; offstage completion cannot navigate; a popped screen cannot overwrite another page. |
| Recommendations | General discovery before baseline/no favorites; projected newest seed; rollback reseeds; exhausted empty seed fallback; filtered-empty page with further pages retains seed and Load more; no unbounded draining; failed seed never becomes general/fixture fallback. |
| Pagination | One continuation at a time, expected-page matching, duplicate IDs, filtered/duplicate-only page advances provider cursor, true empty/final/page-500 termination, failed continuation preserves cards and cursor, complete resources and Trending issue no invented continuation. |
| Shared favorites | No mutations before successful rows-plus-metadata baseline; optimistic intent versus acknowledgement; FIFO remove/Undo while pending; remove/add/remove; newer same-movie intent invalidates old Undo; only newest removal offer; failed removal ends its irrelevant offer; failed writes preserve unrelated entries. |
| Ordering and restart storage | Remove highest order, add a different movie, Undo first removal; no reused order/collision and correct relative position. Normal re-add moves first; idempotent add retains order; high-water metadata survives delete and file reopening. |
| Storage failure | Read and migration errors never recreate/delete data; corrupt/missing existing metadata fails; transactions update row/metadata together; baseline read waits behind writes and stale read cannot overwrite newer projection. Real file-close/reopen checks accompany injected failures. |
| Data mapping | Calendar dates do not shift timezone; UTC timestamps/URIs round-trip; missing/blank optional fields; zero-vote rating; title fallback; malformed IDs/arrays/page structure; integer/decimal numeric forms; collection title/name variants; distinct credit roles retained; filmography/collection order. |
| Eligibility and provenance | Adult filtering on all applicable resources and direct details; unknown optional flags not fabricated; genuine empty differs from filtered page/failure; TMDB rating source/scale; no false streaming/theatrical-date or personalization claim. |
| Retry and limits | Absolute 25-second deadline includes queue/backoff and cancels a slow streaming response; at most four active API reads; cancelled queued work never starts; one retry only for allowed cases; injected jitter 300–800 ms; no automatic auth/invalid-data/write/cancel retry. |
| Rate limits | Retry-After seconds and HTTP date; absent/invalid fallback 30 seconds; shared cooldown prevents queued bursts; expiry enables explicit retry without an automatic loop. |
| Cache | Identity includes mode/source/query/page/filters; TTL boundaries and 128-entry eviction; Refresh/Retry bypass; errors not cached as successful empty; cancellation ownership separate; active page display survives eviction. |
| Link/image boundary | Strict YouTube candidate/key/URI selection, reject unsupported destination/port/authority/query; API token never reaches image/external requests; no automatic API redirect; placeholders preserve actions; image config failure does not erase text. |
| Fixture/live split | Live is default; invalid mode/config fails honestly; fixture app makes no live catalog/CDN calls and simulates links; normal databases isolated; synthetic IDs do not leak into live smoke; no silent failure fallback. |

## 6. Coverage definition and collection

The minimum is **85% line coverage in each owning member with handwritten business logic**, and at least 85% across the combined eligible lines. The combined figure uses total hit lines divided by total eligible executable lines, not an average of package percentages. Mandatory scenario/race assertions remain required even at 100% measured coverage.

Eligible scope:

- `movies_core`: handwritten domain validation, identity, mapping/converters, and other executable domain logic.
- `movies_data`: handwritten DTO mapping, response validation, failure mapping, request/retry/cache coordination, DAO/repository persistence and ordering behavior.
- Each feature: handwritten `lib/domain/`, `lib/presentation/viewmodel/`, and custom executable state logic under `lib/presentation/state/`.
- Host: executable config parsing, bootstrap selection, and external-link validation/coordination. Native platform calls are exercised through the injected boundary and Simulator evidence.

Exclude generated `.freezed.dart`, `.g.dart`, generated localization outputs, external packages, tests/fixtures, and declarative route/theme/view definitions from this **business-logic percentage**. UI/route/theme behavior still has required widget/integration checks. A handwritten helper containing business logic cannot escape coverage by being placed in a view or bootstrap file. Track these helpers in the scope manifest.

During implementation create a reviewed coverage-scope manifest with member ownership, included source paths, and explicit justified exclusions. A newly added eligible executable file must appear in the manifest and coverage input; an unimported file cannot silently shrink the denominator. A genuinely declarative/no-executable member reports N/A, never fabricated 100%. Missing/empty/unusable coverage for executable scope fails the gate. Generated files do not pad the denominator or numerator.

Collect reports from each owner, with paths relative to that member:

| Working directory | Command contract |
| --- | --- |
| `packages/movies_core` | `dart test --coverage-path=coverage/lcov.info --coverage-package='^movies_core$'` |
| Each Flutter member with its own `test/` | `flutter test test --coverage --coverage-path=coverage/lcov.info` |

The pinned test 1.30.0 supports direct LCOV; do not combine Dart's raw `--coverage` option with `--coverage-path`. No extra coverage package is needed. These flags were checked against the installed test_core/Flutter tool sources and the [pinned test changelog](https://pub.dev/packages/test/versions/1.30.0/changelog); actual Movies commands run only after scaffolding.

A small repository quality script normalizes LCOV source paths to workspace-relative files, merges duplicate file/line hits without double-counting, checks expected scope, and enforces per-member/combined thresholds. It emits machine-readable counts and the filtered report. Missing required source reports are failures, not zeros quietly omitted. The script needs focused checks for path normalization, zero-hit lines, missing files, exclusions, and threshold boundaries because it controls the quality gate.

## 7. Stable automation and semantics contract

Public identifiers use stable ASCII namespace segments: `movies`, branch, screen/section, entity or provider credit/image/review identity, and action. The branch token is one of home/browse/search/library; category tokens use now_playing/upcoming/popular/top_rated. The patterns below are normative examples using controlled fixture IDs; real data substitutes provider IDs.

| Surface | Identifier examples |
| --- | --- |
| Tabs and roots | `movies.shell.tab.home`, `.browse`, `.search`, `.library`; `movies.home.screen`, `movies.search.screen`. |
| Featured card and paging | `movies.home.carousel.featured.movie.900001.open`; `movies.home.carousel.previous`, `.next`. |
| Shelf card/actions | `movies.home.shelf.trending.movie.900001.open`, `.favorite`; `movies.home.shelf.trending.see_all`, `.retry`. |
| Browse | `movies.browse.category.now_playing`; `movies.browse.results.source`; `movies.browse.results.movie.900001.open`, `.favorite`; `movies.browse.results.load_more`, `.retry`. |
| Search | `movies.search.query.input`, `.clear`; `movies.search.results.source`, `.error`; `movies.search.results.movie.900005.open`, `.favorite`; `movies.search.results.load_more`, `.retry`. |
| Movie detail | `movies.home.movie.900001.screen`, `.back`, `.favorite`, `.cast.open`, `.images.open`, `.reviews.open`, `.trailer.open`, `.related.open`, `.collection.open`; section Retry uses `.reviews.retry` or equivalent section. |
| Cast and person | `movies.home.movie.900001.cast.credit.fixture-cast-001.open`; `movies.home.person.910001.screen`, `.back`, `.filmography.open`, `.images.open`. |
| Filmography/collection/related | `movies.home.person.910001.filmography.movie.900002.open`; `movies.home.collection.920001.movie.900002.open`; `movies.home.movie.900001.related.movie.900004.open`. |
| Gallery/review | `movies.home.movie.900001.images.asset.<encoded-file-path>.open`; `movies.home.movie.900001.reviews.review.fixture-review-001.open`. |
| Library | `movies.library.favorites.movie.900001.open`, `.remove`; `movies.library.favorites.retry`, `.error`. |
| Undo / About | `movies.shell.undo.movie.900001.restore`; `movies.home.about.open`, `.notice`, `.tmdb_link`. |

In a table cell, a suffix such as `.favorite` replaces the preceding terminal `.open`; it is not appended after `.open`. Use the equivalent branch prefix for catalog screens entered from another tab. Images/person galleries follow the corresponding owner kind. Actionable entries use provider credit IDs; when absent, the deterministic person/role/job composite from Stage 5 is encoded. Image identity uses a consistently percent-encoded file path; review identity uses its provider ID. Never rely solely on list index, translated text, raw search query, random revision, or page-entry key.

The same stable string may back a Flutter `ValueKey<String>` and native `Semantics.identifier`, but these are separate surfaces and must be tested independently. Human-readable labels describe the action/entity and semantic selected/toggled/enabled state. Displayed source/query is visible text and a semantic value, not encoded raw query text in the identifier.

Only the active branch's front page contributes actionable native semantics. Repeated occurrences in different shelves have section context; multiple retained page instances have separate internal branch/entry/entity keys while public identities remain stable. Tests scope Flutter finders to the active visible page when older pages remain mounted. Card Open and Favorite/Remove are independently reachable semantic actions; do not merge away the second action.

## 8. Responsive, accessibility, and visual verification

Fast widget checks cover Home, Search, movie details, a deep person/filmography screen, Library with Undo/error, and About. Check no framework exceptions/overflow, reachable essential actions, correct active semantics, and preserved source identity. Use explicit viewport/padding/keyboard/text-scaler settings and restore test view settings after each case.

| Widget matrix | Purpose |
| --- | --- |
| 320 × 568 portrait, 568 × 320 landscape | Small/short compact layout, long titles and wrapping. |
| 393 × 852 portrait, 852 × 393 landscape | Representative portrait and expanded-width landscape, safe-area handling. |
| Widths 599/600 and 839/840 | Breakpoint boundaries with normal and enlarged text, no navigation rail/drawer substitution. |
| Default text, 2× and 3× synthetic text scaling | Controls reachable without downscaling; metadata/errors wrap; screen scrolls. Real platform settings checked separately. |
| Keyboard inset plus Undo, reduced motion, missing/failed imagery | Bottom controls not covered; no persistent decorative animation; title/open/favorite remain usable. |

Use labeled-target and text-contrast guidance where the Flutter test API supports meaningful evaluation, plus direct semantic/hit-rectangle assertions. Stage 4 requires **48 × 48** targets; Flutter's built-in iOS guideline checks only 44 × 44, so it cannot establish the app's stronger requirement alone. Apply an explicit 48-unit minimum check for the app's visible actions. See [Flutter accessibility test APIs](https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html).

Solid color-token contrast checks supplement visual inspection of rendered artwork scrims and pressed/error/focus states. Pixel guidelines cannot prove every artwork/text combination or real screen-reader usability. Verify offstage exclusion, headings, favorite/selected/disabled state, independent card actions, and non-focus-stealing loading/error announcements in semantics tests and native inspection.

Required first-release visual evidence is Simulator screenshots and review against the selected After Hours reference, with native font, real safe areas, and platform text settings. Pixel golden comparisons are optional initially: native-font rendering differs across hosts/SDKs, and default widget-test fonts are not production iOS text. If goldens are later added, use a licensed test-only font and a fixed baseline platform; never compare a macOS native-font baseline directly on Linux or regenerate baselines merely to hide regressions. [Flutter golden/font guidance](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html).

**Simulator accessibility limit:** Apple's [accessibility-testing guidance](https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app) states that actual iOS VoiceOver requires a physical device. For this Simulator-only release, verify semantic labels/traits/actions, exposed structure, and usable text/layout with Flutter tests and Xcode Accessibility Inspector. Do not report spoken VoiceOver focus, speech, or gesture usability as tested. Those remain explicitly unverified until physical-device scope expands; no device/signing requirement is added here. Stage 4's intended accessibility behavior still guides implementation.

## 9. Local Simulator delivery gate

Use the installed iOS runtime and an available iPhone Simulator. Record its device model/UDID, iOS runtime, app revision, Flutter 3.41.6/Dart 3.11.4, data mode, and test database context. At least one real build/install/launch must succeed. Exercise both detected phone-size classes when available; synthetic widget sizes cover the smaller layout even if a small-phone runtime is unavailable.

The five automated host integration anchors use `apps/app/integration_test/client_journeys_test.dart`, the real composed router, fixture catalog, simulated links, and isolated real Drift storage. From `apps/app`, the planned invocation is `flutter test integration_test/client_journeys_test.dart -d "$MOVIES_SIMULATOR_ID" --dart-define=MOVIES_DATA_MODE=fixture`, with the variable resolved to an actual available Simulator UDID. A bounded wait failure is a test failure with context, not an indefinite hang.

Run native/manual checks against the installed app as separate evidence:

| Check | Required procedure and result |
| --- | --- |
| N1 — durable persistence | On one installation, add a movie and wait for storage acknowledgement; terminate the process and relaunch without reinstalling or clearing its container; verify Library. Repeat for saved removal with expiry and acknowledged Undo restoration. File-backed DB close/reopen tests are supporting evidence, not a substitute for these process transitions. |
| N2 — lifecycle | Remove a saved movie, background the actual app, and return before five seconds has elapsed when feasible. The prior offer is gone immediately and saved removal remains. Separately switch tabs within five seconds to prove navigation retains the offer without resetting its expiry. |
| N3 — external link | In live mode, choose a real supplied allowed YouTube trailer, open it through the native launcher, and return to the same movie context. Record unsupported/failed-launch recovery separately. Fixture mode visibly simulates links and cannot count as this native check. |
| N4 — native UI/accessibility | Portrait/landscape and default/largest available accessibility text settings; system keyboard with Search and Undo; safe areas, tabs, Back, Favorite, Remove, Retry; native back gesture and reduced motion; inspect accessibility structure/actions with Xcode tools and record any VoiceOver limitation. |

`integration_test` drives Flutter UI but does not itself drive arbitrary native browser/dialog surfaces or restart its own terminated process and continue assertions. Host/native automation could be added later; it is not assumed here. See [Flutter integration testing](https://docs.flutter.dev/testing/integration-tests) and [testing limitations](https://docs.flutter.dev/testing/overview). Recreating ProviderScope, injecting lifecycle messages, or invoking a recording launcher is not reported as a native transition.

Save screenshots of Home, rich movie details, the depth-five destination, Search retained-query/error state, Library/Undo, and enlarged-text landscape. On failures, capture the active screen, step/action, expected versus actual state, test/acceptance ID, and redacted log/exception when available. A failed build/crashed process may have no app screenshot; report its absence and cause rather than inventing one. This is deterministic client validation, not the later AI testing agent.

## 10. Authenticated live TMDB smoke

Run locally outside fast CI using the ignored live token configuration. The smoke uses actual provider IDs discovered from current responses; it never assumes Northbound's synthetic IDs exist or that a current ranking is stable. Verify status/structure and usable mapping, not exact popularity, rating, movie count, or response wording.

- Exercise every consumed endpoint family from Stage 5, including image configuration, genres, four discovery feeds, Trending, search, movie details/credits/images/reviews/videos/recommendations/similar, person/details/movie credits/images, and collection when membership is supplied.
- Confirm Recommendations' expected page envelope and collection title/name compatibility. Record actual empty/missing optional content honestly; an empty fixture-independent relationship does not prove an unavailable rich-content path. Find a data-backed alternative for the relevant live check when needed.
- Use a bounded number of safe reads; respect 429/cooldown. Do not deliberately stress rate limits, damage storage, or change real accounts to force failure cases. Deterministic fakes provide those failures.
- Confirm live artwork works and the configured image/genre failure behavior does not erase metadata. Confirm the app never substitutes Demo data on live failure and local Library remains available without a working token/network.

No token means this gate is **not run**, not passed or silently switched to fixtures. Deterministic CI can still complete; delivery cannot claim live integration until authenticated evidence exists. Record failed provider/network checks with their safe category and retry outcome; do not store authorization headers or the local config file in artifacts.

## 11. Fast CI and quality-gate commands

The later implementation adds GitHub Actions checks for pull requests and pushes touching the client or its quality workflow. Use the approved SDK and one workspace lockfile; dependency download/setup is allowed, but the test cases themselves remain independent of external services. No iOS build, paid macOS runner, or live credential is required in this fast job.

Execute these gates sequentially from the documented owner directories, failing on a nonzero result:

1. Resolve the workspace from `client` with `flutter pub get`; require no unexplained lockfile change and fail if the pinned SDK cannot be provisioned. Do not auto-upgrade SDK/dependencies to clear a test failure.
2. Generate package-local localizations, then Freezed/JSON/Drift outputs in each owning member using Stage 3/5's commands. Check tracked generated/lock outputs for differences and unexpected untracked generated files; generation is not an excuse to discard authored changes.
3. From `client`, run `dart format --output=none --set-exit-if-changed apps packages tool`. These paths are created during implementation; do not apply the app formatter to unrelated parent projects.
4. From `packages/movies_core`, run `dart analyze --fatal-infos`; for each Flutter member run `flutter analyze --no-pub --fatal-infos --fatal-warnings`. Require no remaining analyzer errors, warnings, or infos; include tests and tooling in appropriate analysis coverage.
5. Run the per-member test/coverage commands in section 6. Pure core uses Dart test; data/UI/feature/host members use Flutter test. Do not assume one workspace-root test invocation discovers all member suites. Every member has meaningful isolated checks required by Stage 3; a missing suite cannot quietly become a pass.
6. Run the repository acceptance-inventory and coverage checkers, then verify that tests/generation left no unexpected tracked-source changes. Required skipped/solo tests, missing scenario mappings, incomplete outlines, absent coverage, or thresholds below 85% fail the job.

The implementation supplies a root quality runner with a fixed list of the app and eight package members, recording command, working directory, exit code, and artifact path. Its small coverage/inventory checks are tooling, not additional application packages. Linux/native SQLite or font differences must be resolved or reported; they must not trigger a fake passing result or silently drop storage/UI tests. Simulator commands remain the local gate in section 9.

CI success establishes the fast gates only. Before client delivery, require fast gates, local Simulator build/journeys/native checks, and authenticated live smoke; report any explicit scope limitation separately. Publishing, merging, App Store delivery, and an agent backend are outside this stage.

## 12. Results, failure artifacts, and exit criteria

The later quality runner writes an ignored `artifacts/quality/<run-id>/` bundle containing a structured result, test logs, per-member LCOV and filtered coverage summary, acceptance-example results, toolchain metadata, and any Simulator screenshots/native checklist. Its result records gate/test ID, status (`passed`, `failed`, `notRun`, or `blocked`), duration, safe failure reason, and relative artifact paths. CI uploads failed-run diagnostics when available without changing the exit code.

Use runner-native structured test events where available rather than parsing prose as truth. Test names/manifest connect each result to acceptance IDs; a planned mapping is not an executed pass. Missing screenshots, unavailable Simulator, missing credentials, failed build, and unsupported native VoiceOver are recorded accurately. Keep config/token files, runtime browser keys, headers, database dumps, and unrelated developer data out of the bundle. An explicit known native limitation is not mislabeled a passed test.

Stage 6 approval accepts the test layers, at-least-85% measurement, mapping for all 62 definitions/64 baseline examples, critical contract cases, stable automation identifiers, fast-CI/local-Simulator split, live-smoke boundary, and the stated native-accessibility limitation. The detailed implementation milestones and final delivery checklist are Stage 7 work.

**Approval record:** the developer reviewed this document and replied “approved” on November 1, 2026. Stage 7 discovery is unlocked. Flutter scaffolding and application implementation remain pending until all specification gates and the full audit pass.
