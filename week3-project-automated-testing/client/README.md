# Movies

A cinematic Flutter movie browser for iOS Simulator: Home, Browse, debounced Search, a persistent local Library, and independent navigation stacks. Explore movie → cast → person → filmography → another movie → collection, plus related titles, biographies, images, reviews, and supplied trailer links.

The source is in this directory, not the temporary implementation worktree:

- `apps/app/lib/main.dart`: application entrypoint and composition.
- `apps/app/lib/core/router/app_router.dart`: retained tab navigation.
- `packages/{home,browse,search,library}_feature`: tab views and viewmodels.
- `packages/catalog_feature`: shared movie/person/deep screens and favorites coordination.
- `packages/movies_data`: real TMDB/Dio adapters, deterministic Demo catalog, Drift storage/cache.
- `packages/movies_core` and `packages/movies_ui`: typed contracts and After Hours design system.

## Run the credential-free Demo

Use Flutter **3.41.6**, Dart **3.11.4**, Xcode and CocoaPods. The selected installation uses iOS 15 as its deployment floor; the app runs on the installed current Simulator runtime.

```sh
# From week3-project-automated-testing/client
flutter pub get
flutter devices
cd apps/app
flutter run -d <ios-simulator-id> --dart-define=MOVIES_DATA_MODE=fixture
```

Demo mode is explicit and visibly labeled. Its fictional movies, people, local artwork and simulated browser links require no TMDB account. Favorites persist in a separate `movies_fixture` SQLite database. Normal live mode uses `movies`; neither is reset on launch. There is no sign-in.

## Use real TMDB data

Copy `config/dev.example.json` to ignored `config/dev.local.json`, set `MOVIES_DATA_MODE` to `live`, and configure `TMDB_READ_ACCESS_TOKEN` locally with a TMDB API Read Access Token. From `apps/app`:

```sh
flutter run -d <ios-simulator-id> --dart-define-from-file=../../config/dev.local.json
```

Live is the default. Missing configuration shows an unavailable catalog while keeping Library usable; failed API calls never substitute Demo content. The token is a development configuration, compiled into a client binary; it is not an enterprise server-side secret store. Do not distribute a build containing a privileged personal credential. No production proxy is part of this client milestone.

The live adapter is implemented and covered with controlled raw responses. Authenticated provider checks and native live trailer opening remain **notRun** until the local token is configured. See `docs/verification/live-smoke.md`.

## Quality checks

From `client` with the pinned SDK on PATH:

```sh
dart run tool/quality.dart fast
```

This resolves the workspace, checks generated code/lockfile stability, generates localizations, verifies formatting/analysis, runs all nine member suites, merges business-logic coverage, enforces at least 85% per owner and combined, and verifies 64 acceptance examples against actual structured test events. Reports are under ignored `artifacts/quality/`. GitHub Actions runs the fast gate; it does not claim Simulator or authenticated live evidence.

From `apps/app`, run the five isolated Simulator journeys and capture screenshots:

```sh
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/client_journeys_test.dart \
  -d <ios-simulator-id> --dart-define=MOVIES_DATA_MODE=fixture \
  --keep-app-running
```

These use unique test-owned real SQLite files. Native process/lifecycle checks use the dedicated `integration_test/native_app.dart` entrypoint and `MoviesNativeChecks` XCUITest target; they never open the ordinary Demo Library. See `docs/verification/simulator-checklist.md` for commands and recorded evidence.

Specifications in `specs/` remain the approved authority. The later AI testing agent, server, MCP tools and deployment are outside this client implementation.
