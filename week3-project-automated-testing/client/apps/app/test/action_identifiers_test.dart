import 'dart:ui' show SemanticsAction;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'support/app_dependencies.dart';

void main() {
  testWidgets(
    'MOV-A11Y-001 featured and search actions expose stable native identifiers',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MoviesApp(
            config: const AppConfig(mode: CatalogMode.fixture),
            dependencies: testDependencies(),
          ),
        );
        await tester.pumpAndSettle();
        const open = 'movies.home.carousel.featured.movie.900001.open';
        await tester.ensureVisible(find.byKey(const ValueKey(open)));
        await tester.pumpAndSettle();
        expect(
          tester
              .getSemantics(find.byKey(const ValueKey(open)))
              .getSemanticsData()
              .identifier,
          open,
        );
        await tester.tap(find.byKey(const ValueKey(open)));
        await tester.pumpAndSettle();
        const cast = 'movies.home.movie.900001.cast.open';
        final castFinder = find.byKey(const ValueKey(cast));
        await tester.scrollUntilVisible(
          castFinder,
          200,
          scrollable: find
              .descendant(
                of: find.byKey(
                  const ValueKey('movies.home.movie.900001.scroll'),
                ),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        final castSemantics = tester
            .getSemantics(castFinder)
            .getSemanticsData();
        expect(castSemantics.identifier, cast);
        expect(castSemantics.hasAction(SemanticsAction.tap), true);
        await tester.tap(find.byKey(const ValueKey('movies.shell.tab.search')));
        await tester.pumpAndSettle();
        const input = 'movies.search.query.input';
        expect(
          tester
              .getSemantics(find.byKey(const ValueKey(input)))
              .getSemanticsData()
              .identifier,
          input,
        );
        const clear = 'movies.search.query.clear';
        expect(
          tester
              .getSemantics(find.byKey(const ValueKey(clear)))
              .getSemanticsData()
              .identifier,
          clear,
        );
      } finally {
        handle.dispose();
      }
    },
  );
}
