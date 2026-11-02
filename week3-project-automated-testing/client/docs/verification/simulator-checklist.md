# Simulator evidence

Flutter 3.41.6 / Dart 3.11.4; Xcode 27; iPhone 18 Pro Max / iOS 27 Simulator, UDID `4F0707AE-45BC-464D-9099-6EE76C3740A9`.

Five automatic fixture journeys passed via `flutter drive` using `integration_test/client_journeys_test.dart`: retained branch, Search return with scroll, five additional navigation levels, exact visited Back chain, and repeated movie/shared favorite. Each uses a unique real test-owned SQLite file. Screenshots/report: ignored `apps/app/artifacts/native-demo/`.

The full native checklist is **deferred for demo handoff**. Initial XCUITest attempts failed; do not count the added test target as completed verification. N1/N2 are pending; N3 is notRun without live credentials; N4 is partial. See delivery-checklist.md for the exact limitations.

For a later native verification attempt, configure the dedicated entrypoint with a fresh test-owned name:

```sh
# From apps/app
flutter build ios --simulator --debug --config-only \
  -t integration_test/native_app.dart \
  --dart-define=MOVIES_DATA_MODE=fixture \
  --dart-define=MOVIES_TEST_DATABASE=movies_test_native_unique_run
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=<simulator-id>' \
  -only-testing:MoviesNativeChecks -parallel-testing-enabled NO \
  -resultBundlePath artifacts/native-unique-run.xcresult \
  ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

XCUITest acknowledgement/hardware-keyboard setup still needs diagnosis before these commands can establish N1/N2/N4. Launch the normal Demo afterward using `flutter run -t lib/main.dart --dart-define=MOVIES_DATA_MODE=fixture -d <simulator-id>`.

No physical VoiceOver speech/gesture verification is claimed for a Simulator-only demo.
