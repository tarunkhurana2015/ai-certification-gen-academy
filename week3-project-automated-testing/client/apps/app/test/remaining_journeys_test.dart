import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies/app.dart';
import 'package:movies/core/router/app_router.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'package:movies/bootstrap/dependency_bindings.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';
import 'support/app_dependencies.dart';
import 'support/scenario_catalog.dart';

Future<void> tab(WidgetTester t, String name) async {
  await t.tap(find.byKey(ValueKey('movies.shell.tab.$name')));
  await t.pumpAndSettle();
}

MemoryFavorites saved() => MemoryFavorites()
  ..order = 1
  ..entries[900001] = FavoriteEntry(
    movie: const FavoriteMovieSnapshot(movieId: 900001, title: 'Northbound'),
    addedOrder: 1,
    addedAtUtc: DateTime.utc(2026),
  );
Future<void> boot(
  WidgetTester t, {
  AppDependencies? dependencies,
  AppConfig config = const AppConfig(mode: CatalogMode.fixture),
}) async {
  await t.pumpWidget(
    MoviesApp(config: config, dependencies: dependencies ?? testDependencies()),
  );
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'MOV-BROWSE-002 scrolling to the end requests the next provider page',
    (t) async {
      final c = ScenarioCatalog();
      final pages = <int>[];
      c.upcoming = (page, options) async {
        pages.add(page);
        final rows = c.movies.values.take(4).toList();
        return Outcome.success(
          PageResult(
            items: rows,
            page: page,
            totalPages: 2,
            totalResults: 8,
            requestKey: RequestKey(
              mode: 'fixture',
              operation: 'upcoming',
              page: page,
            ),
          ),
        );
      };
      await boot(t, dependencies: testDependencies(discovery: c));
      pages.clear();
      await tab(t, 'browse');
      await t.tap(
        find.byKey(const ValueKey('movies.browse.category.upcoming')),
      );
      await t.pumpAndSettle();
      final scroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('movies.browse.scroll')),
            matching: find.byType(Scrollable),
          )
          .first;
      await t.drag(scroll, const Offset(0, -3000));
      await t.pumpAndSettle();
      expect(pages, [1, 2]);
    },
  );

  testWidgets(
    'MOV-BROWSE-005 final provider page shows the end and stops continuations',
    (t) async {
      await boot(t);
      await tab(t, 'browse');
      final scroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('movies.browse.scroll')),
            matching: find.byType(Scrollable),
          )
          .first;
      while (find
          .byKey(const ValueKey('movies.browse.results.load_more'))
          .evaluate()
          .isNotEmpty) {
        await t.scrollUntilVisible(
          find.byKey(const ValueKey('movies.browse.results.load_more')),
          300,
          scrollable: scroll,
        );
        await t.pumpAndSettle();
        await t.tap(
          find.byKey(const ValueKey('movies.browse.results.load_more')),
        );
        await t.pumpAndSettle();
      }
      await t.drag(scroll, const Offset(0, -1000));
      await t.pumpAndSettle();
      expect(find.text('You’re all caught up.'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('movies.browse.results.load_more')),
        findsNothing,
      );
    },
  );
  testWidgets(
    'MOV-BROWSE-006 successful empty Upcoming is distinguishable from failure',
    (t) async {
      final c = ScenarioCatalog()
        ..upcoming = (page, options) async => Outcome.success(
          const PageResult(
            items: [],
            page: 1,
            totalPages: 0,
            totalResults: 0,
            requestKey: RequestKey(
              mode: 'fixture',
              operation: 'upcoming',
              page: 1,
            ),
          ),
        );
      await boot(t, dependencies: testDependencies(discovery: c));
      await tab(t, 'browse');
      await t.tap(
        find.byKey(const ValueKey('movies.browse.category.upcoming')),
      );
      await t.pumpAndSettle();
      expect(find.text('No movies were found.'), findsOneWidget);
      expect(find.text('Upcoming'), findsNWidgets(2));
      expect(
        find.byKey(const ValueKey('movies.browse.results.retry')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('movies.browse.category.popular')),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'MOV-RECOVERY-003 offline details leave saved Library removal and Undo usable',
    (t) async {
      final c = ScenarioCatalog()
        ..movie = (id, options) async =>
            Outcome.failure(networkFailure('movie'));
      final f = saved();
      await boot(
        t,
        dependencies: testDependencies(movies: c, favorites: f),
      );
      await tab(t, 'library');
      await t.tap(
        find.byKey(
          const ValueKey('movies.library.favorites.movie.900001.open'),
        ),
      );
      await t.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.library.movie.900001.retry')),
        findsOneWidget,
      );
      expect(find.text('No overview has been supplied.'), findsNothing);
      await t.tap(
        find.byKey(const ValueKey('movies.library.movie.900001.back')),
      );
      await t.pumpAndSettle();
      await t.tap(
        find.byKey(
          const ValueKey('movies.library.favorites.movie.900001.remove'),
        ),
      );
      await t.pumpAndSettle();
      expect(f.entries, isEmpty);
      await t.tap(
        find.byKey(const ValueKey('movies.shell.undo.movie.900001.restore')),
      );
      await t.pumpAndSettle();
      expect(f.entries.keys, [900001]);
    },
  );
  testWidgets(
    'MOV-RECOVERY-005 missing live configuration offers no secret-entry flow and Library stays usable',
    (t) async {
      final dependencies = createDependencies(
        const AppConfig(),
        favoritesDatabase: MoviesDatabase.inMemory(),
      );
      await boot(t, config: const AppConfig(), dependencies: dependencies);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Demo data'), findsNothing);
      expect(find.text('Northbound'), findsNothing);
      expect(find.textContaining('unavailable'), findsWidgets);
      await tab(t, 'library');
      expect(find.text('Your Library'), findsOneWidget);
      await tab(t, 'search');
      expect(
        find.byKey(const ValueKey('movies.search.query.input')),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'MOV-LIBRARY-013 tab navigation preserves Undo and injected background dismisses it',
    (t) async {
      final f = saved();
      await boot(t, dependencies: testDependencies(favorites: f));
      await tab(t, 'library');
      await t.tap(
        find.byKey(
          const ValueKey('movies.library.favorites.movie.900001.remove'),
        ),
      );
      await t.pumpAndSettle();
      await tab(t, 'search');
      expect(
        find.byKey(const ValueKey('movies.shell.undo.movie.900001.restore')),
        findsOneWidget,
      );
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await t.pump();
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.shell.undo.movie.900001.restore')),
        findsNothing,
      );
      expect(f.entries, isEmpty);
      final container = ProviderScope.containerOf(
        t.element(find.byType(MoviesShell)),
      );
      expect(container.read(favoritesViewModelProvider).undo, isNull);
    },
  );
}
