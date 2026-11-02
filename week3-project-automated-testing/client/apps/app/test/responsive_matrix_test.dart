import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'support/app_dependencies.dart';
import 'remaining_journeys_test.dart' show saved, tab;

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(568, 320),
    const Size(393, 852),
    const Size(852, 393),
    const Size(599, 852),
    const Size(600, 852),
    const Size(839, 852),
    const Size(840, 852),
  ]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets(
        'MOV-A11Y-002 essential screens at ${size.width}x${size.height} text $scale',
        (t) async {
          t.view.physicalSize = size;
          t.view.devicePixelRatio = 1;
          t.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(() {
            t.view.resetPhysicalSize();
            t.view.resetDevicePixelRatio();
            t.platformDispatcher.clearTextScaleFactorTestValue();
            t.view.resetViewInsets();
          });
          await t.pumpWidget(
            MoviesApp(
              config: const AppConfig(mode: CatalogMode.fixture),
              dependencies: testDependencies(favorites: saved()),
            ),
          );
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          final router = GoRouter.of(t.element(find.byType(Scrollable).first));
          router.push('/home/movie/900001');
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          router.push('/home/person/910001');
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          router.push('/home/person/910001/filmography');
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          await tab(t, 'library');
          final remove = find.byKey(
            const ValueKey('movies.library.favorites.movie.900001.remove'),
          );
          await t.scrollUntilVisible(
            remove,
            100,
            scrollable: find
                .descendant(
                  of: find.byKey(const PageStorageKey('library.scroll')),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await t.pumpAndSettle();
          await t.ensureVisible(remove);
          await t.pumpAndSettle();
          await t.tap(remove);
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          await tab(t, 'search');
          final input = find.byKey(const ValueKey('movies.search.query.input'));
          await t.scrollUntilVisible(
            input,
            80,
            scrollable: find
                .descendant(
                  of: find.byKey(const PageStorageKey('movies.search.scroll')),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await t.pumpAndSettle();
          await t.tap(input);
          t.view.viewInsets = const FakeViewPadding(bottom: 180);
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          for (final branch in ['home', 'browse', 'search', 'library']) {
            final bounds = t.getRect(
              find.byKey(ValueKey('movies.shell.tab.$branch')),
            );
            expect(bounds.width, greaterThanOrEqualTo(48));
            expect(bounds.height, greaterThanOrEqualTo(48));
            expect(bounds.bottom, lessThanOrEqualTo(size.height - 180));
          }
          t.view.resetViewInsets();
          t.testTextInput.hide();
          await t.pumpAndSettle();
          await tab(t, 'home');
          router.push('/home/about');
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
        },
      );
    }
  }
}
