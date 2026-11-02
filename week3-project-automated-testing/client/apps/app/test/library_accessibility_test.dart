import 'dart:ui' show SemanticsAction;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'package:movies_core/movies_core.dart';
import 'support/app_dependencies.dart';

void main() {
  testWidgets(
    'MOV-A11Y-001 Library Open exposes its independent native activation',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        final favorites = MemoryFavorites()
          ..order = 1
          ..entries[900001] = FavoriteEntry(
            movie: const FavoriteMovieSnapshot(
              movieId: 900001,
              title: 'Northbound',
            ),
            addedOrder: 1,
            addedAtUtc: DateTime.utc(2026),
          );
        await tester.pumpWidget(
          MoviesApp(
            config: const AppConfig(mode: CatalogMode.fixture),
            dependencies: testDependencies(favorites: favorites),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('movies.shell.tab.library')),
        );
        await tester.pumpAndSettle();
        final semantics = tester
            .getSemantics(
              find.byKey(
                const ValueKey('movies.library.favorites.movie.900001.open'),
              ),
            )
            .getSemanticsData();
        expect(
          semantics.identifier,
          'movies.library.favorites.movie.900001.open',
        );
        expect(semantics.hasAction(SemanticsAction.tap), true);
        expect(
          find.byKey(
            const ValueKey('movies.library.favorites.movie.900001.remove'),
          ),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    },
  );
}
