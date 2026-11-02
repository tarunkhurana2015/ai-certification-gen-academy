import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'package:catalog_feature/presentation/views/catalog_view.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'package:movies_core/movies_core.dart';
import 'catalog_navigation_test.dart' show tapCatalog;
import 'support/app_dependencies.dart';
import 'support/scenario_catalog.dart';

Future<GoRouter> boot(WidgetTester tester, ScenarioCatalog catalog) async {
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

Finder scroll(String base) => find
    .descendant(
      of: find.byKey(ValueKey('$base.scroll')),
      matching: find.byType(Scrollable),
    )
    .first;
Future<void> reveal(WidgetTester tester, Finder target, String base) async {
  if (target.evaluate().isEmpty) {
    tester.state<ScrollableState>(scroll(base)).position.jumpTo(0);
    await tester.pump();
    await tester.scrollUntilVisible(target, 200, scrollable: scroll(base));
  } else {
    await tester.ensureVisible(target);
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'MOV-DETAIL-001 rich details show supplied metadata and the TMDB scale',
    (tester) async {
      final catalog = ScenarioCatalog();
      final router = await boot(tester, catalog);
      router.push('/home/movie/900001');
      await tester.pumpAndSettle();
      expect(find.text('Northbound'), findsWidgets);
      expect(find.byKey(const ValueKey('artwork.fixture')), findsWidgets);
      await reveal(
        tester,
        find.text('TMDB 7.8 / 10 · 1250 votes'),
        'movies.home.movie.900001',
      );
      final runtime = (await catalog.getMovie(
        900001,
      )).dataOrNull!.runtimeMinutes!;
      await reveal(
        tester,
        find.text('${runtime ~/ 60}h ${runtime % 60}m'),
        'movies.home.movie.900001',
      );
      expect(find.text('${runtime ~/ 60}h ${runtime % 60}m'), findsOneWidget);
      await reveal(tester, find.text('Drama'), 'movies.home.movie.900001');
      expect(find.text('Drama'), findsOneWidget);
      await reveal(tester, find.text('2026'), 'movies.home.movie.900001');
      expect(find.text('2026'), findsOneWidget);
      await reveal(
        tester,
        find.text(catalog.movies[900001]!.overview!),
        'movies.home.movie.900001',
      );
      expect(find.text(catalog.movies[900001]!.overview!), findsOneWidget);
      expect(find.textContaining('IMDb'), findsNothing);
    },
  );
  testWidgets(
    'MOV-DETAIL-007 cast opens supplied biography and career context',
    (tester) async {
      final catalog = ScenarioCatalog();
      final details = (await catalog.getPerson(910001)).dataOrNull!;
      final router = await boot(tester, catalog);
      router.push('/home/movie/900001');
      await tester.pumpAndSettle();
      await tapCatalog(
        tester,
        'movies.home.movie.900001.cast.open',
        'movies.home.movie.900001',
      );
      await tapCatalog(
        tester,
        'movies.home.movie.900001.cast.credit.fixture-cast-001.open',
        'movies.home.movie.900001.cast',
      );
      expect(find.text('Maya Reed'), findsWidgets);
      expect(find.text('Acting'), findsOneWidget);
      await reveal(
        tester,
        find.text(details.biography!),
        'movies.home.person.910001',
      );
      expect(find.text(details.biography!), findsOneWidget);
      await reveal(
        tester,
        find.byKey(
          const ValueKey('movies.home.person.910001.filmography.open'),
        ),
        'movies.home.person.910001',
      );
      expect(
        find.byKey(
          const ValueKey('movies.home.person.910001.filmography.open'),
        ),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'MOV-DETAIL-003 reviews failure and Retry preserve core movie and cast',
    (tester) async {
      final catalog = ScenarioCatalog()
        ..reviews = (id, page, options) async =>
            Outcome.failure(networkFailure('reviews'));
      final router = await boot(tester, catalog);
      router.push('/home/movie/900001');
      await tester.pumpAndSettle();
      await tapCatalog(
        tester,
        'movies.home.movie.900001.reviews.open',
        'movies.home.movie.900001',
      );
      expect(
        find.byKey(const ValueKey('movies.home.movie.900001.reviews.retry')),
        findsOneWidget,
      );
      expect(find.text('No reviews have been supplied.'), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('movies.home.movie.900001.reviews.back')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.home.movie.900001.screen')),
        findsOneWidget,
      );
      await reveal(
        tester,
        find.byKey(
          const ValueKey(
            'movies.home.movie.900001.cast.preview.fixture-cast-001.open',
          ),
        ),
        'movies.home.movie.900001',
      );
      expect(find.text('Maya Reed'), findsOneWidget);
      await tapCatalog(
        tester,
        'movies.home.movie.900001.reviews.open',
        'movies.home.movie.900001',
      );
      catalog.reviews = null;
      await tester.tap(
        find.byKey(const ValueKey('movies.home.movie.900001.reviews.retry')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Demo reviewer'), findsOneWidget);
    },
  );
  testWidgets(
    'MOV-RECOVERY-002 refresh failure keeps correctly identified content and Retry',
    (tester) async {
      final catalog = ScenarioCatalog();
      final router = await boot(tester, catalog);
      router.push('/home/movie/900001');
      await tester.pumpAndSettle();
      final finder = find.byType(CatalogView);
      final identity = tester.widget<CatalogView>(finder).identity;
      final container = ProviderScope.containerOf(tester.element(finder));
      catalog.movie = (id, options) async =>
          Outcome.failure(networkFailure('movie'));
      await container
          .read(catalogPageProvider(identity).notifier)
          .load(refresh: true);
      await tester.pumpAndSettle();
      expect(find.text('Northbound'), findsWidgets);
      expect(
        find.byKey(const ValueKey('movies.home.movie.900001.retry')),
        findsOneWidget,
      );
      expect(
        container.read(catalogPageProvider(identity)).displayed!.entityId,
        900001,
      );
      catalog.movie = null;
      await tester.tap(
        find.byKey(const ValueKey('movies.home.movie.900001.retry')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.home.movie.900001.retry')),
        findsNothing,
      );
    },
  );
}
