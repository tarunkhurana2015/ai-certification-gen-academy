import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';
import 'support/app_dependencies.dart';
import 'support/scenario_catalog.dart';

Future<GoRouter> start(WidgetTester tester, ScenarioCatalog catalog) async {
  await tester.pumpWidget(
    MoviesApp(
      config: const AppConfig(mode: CatalogMode.fixture),
      dependencies: testDependencies(
        discovery: catalog,
        movies: catalog,
        people: catalog,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return GoRouter.of(tester.element(find.text('Movies')));
}

void main() {
  testWidgets(
    'MOV-SEARCH-007 old query content and new query failure keep separate labels',
    (tester) async {
      final catalog = ScenarioCatalog();
      await start(tester, catalog);
      await tester.tap(find.byKey(const ValueKey('movies.shell.tab.search')));
      await tester.pumpAndSettle();
      final input = find.byKey(const ValueKey('movies.search.query.input'));
      await tester.enterText(input, 'Northbound');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      catalog.search = (query, page, options) async =>
          Outcome.failure(networkFailure('search'));
      await tester.enterText(input, 'Ember');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(
        find.text('Still showing Results for “Northbound”'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('movies.search.results.movie.900001.open')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('movies.search.results.retry')),
        findsOneWidget,
      );
      catalog.search = null;
      await tester.tap(
        find.byKey(const ValueKey('movies.search.results.retry')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.search.results.movie.900005.open')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('movies.search.results.movie.900001.open')),
        findsNothing,
      );
    },
  );
  testWidgets(
    'MOV-RECOVERY-001 first-load failure is recoverable and never an empty success',
    (tester) async {
      final catalog = ScenarioCatalog()
        ..movie = (id, options) async =>
            Outcome.failure(networkFailure('movie'));
      final router = await start(tester, catalog);
      router.push('/home/movie/900001');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.home.movie.900001.retry')),
        findsOneWidget,
      );
      expect(find.text('No overview has been supplied.'), findsNothing);
      catalog.movie = null;
      await tester.tap(
        find.byKey(const ValueKey('movies.home.movie.900001.retry')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Northbound'), findsWidgets);
    },
  );
  testWidgets('MOV-DETAIL-006 not-found details leave Back and tabs usable', (
    tester,
  ) async {
    final router = await start(tester, ScenarioCatalog());
    router.push('/home/movie/999999');
    await tester.pumpAndSettle();
    expect(
      find.text('This information is no longer available.'),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('movies.home.movie.999999.back')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Stay for the story.'), findsOneWidget);
  });
  for (final relationship in ['cast', 'filmography']) {
    testWidgets(
      'MOV-DEEP-004 empty $relationship has context and a working Back path',
      (tester) async {
        final catalog = ScenarioCatalog();
        if (relationship == 'cast') {
          catalog.credits = (id, options) async =>
              Outcome.success(MovieCredits(movieId: id));
        } else {
          catalog.filmography = (id, options) async =>
              Outcome.success(PersonFilmography(personId: id));
        }
        final router = await start(tester, catalog);
        router.push(
          relationship == 'cast' ? '/home/movie/900001' : '/home/person/910001',
        );
        await tester.pumpAndSettle();
        router.push(
          relationship == 'cast'
              ? '/home/movie/900001/cast'
              : '/home/person/910001/filmography',
        );
        await tester.pumpAndSettle();
        expect(
          find.text(
            relationship == 'cast'
                ? 'No cast has been supplied.'
                : 'No movie credits have been supplied.',
          ),
          findsOneWidget,
        );
        final base = relationship == 'cast'
            ? 'movies.home.movie.900001.cast'
            : 'movies.home.person.910001.filmography';
        await tester.tap(find.byKey(ValueKey('$base.back')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(
            ValueKey(
              relationship == 'cast'
                  ? 'movies.home.movie.900001.screen'
                  : 'movies.home.person.910001.screen',
            ),
          ),
          findsOneWidget,
        );
      },
    );
  }
  testWidgets('MOV-SHELL-003 completed Home work cannot steal the active tab', (
    tester,
  ) async {
    final deferred = Completer<Outcome<TrendingSelection>>();
    final catalog = ScenarioCatalog()..trending = (_) => deferred.future;
    await tester.pumpWidget(
      MoviesApp(
        config: const AppConfig(mode: CatalogMode.fixture),
        dependencies: testDependencies(
          discovery: catalog,
          movies: catalog,
          people: catalog,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('movies.shell.tab.library')));
    await tester.pumpAndSettle();
    deferred.complete(await FixtureCatalog().getTrending());
    await tester.pumpAndSettle();
    expect(find.text('Your Library'), findsOneWidget);
    expect(find.text('Stay for the story.'), findsNothing);
  });
  testWidgets('MOV-LIBRARY-009 empty Library explains the heart action', (
    tester,
  ) async {
    await start(tester, ScenarioCatalog());
    await tester.tap(find.byKey(const ValueKey('movies.shell.tab.library')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'A place for your favorites. Tap a heart on any movie to save it here.',
      ),
      findsOneWidget,
    );
  });
}
