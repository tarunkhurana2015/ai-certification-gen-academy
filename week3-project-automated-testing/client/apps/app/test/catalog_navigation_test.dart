import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'support/app_dependencies.dart';

Future<void> tapCatalog(
  WidgetTester tester,
  String key,
  String scrollBase,
) async {
  final finder = find.byKey(ValueKey(key));
  final scroll = find
      .descendant(
        of: find.byKey(ValueKey('$scrollBase.scroll')),
        matching: find.byType(Scrollable),
      )
      .first;
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: scroll,
      maxScrolls: 30,
    );
  } else {
    await tester.ensureVisible(finder);
  }
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'MOV-DEEP-001 reaches collection five steps after the first movie',
    (tester) async {
      await tester.pumpWidget(
        MoviesApp(
          config: const AppConfig(mode: CatalogMode.fixture),
          dependencies: testDependencies(),
        ),
      );
      await tester.pumpAndSettle();
      GoRouter.of(
        tester.element(find.text('Movies')),
      ).push('/home/movie/900001');
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
      await tapCatalog(
        tester,
        'movies.home.person.910001.filmography.open',
        'movies.home.person.910001',
      );
      await tapCatalog(
        tester,
        'movies.home.person.910001.filmography.movie.900002.open',
        'movies.home.person.910001.filmography',
      );
      await tapCatalog(
        tester,
        'movies.home.movie.900002.collection.open',
        'movies.home.movie.900002',
      );
      expect(
        find.byKey(const ValueKey('movies.home.collection.920001.screen')),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'MOV-DEEP-002 movie cast person filmography traversal keeps the visited Back path',
    (tester) async {
      await tester.pumpWidget(
        MoviesApp(
          config: const AppConfig(mode: CatalogMode.fixture),
          dependencies: testDependencies(),
        ),
      );
      await tester.pumpAndSettle();
      GoRouter.of(
        tester.element(find.text('Movies')),
      ).push('/home/movie/900001');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.home.movie.900001.screen')),
        findsOneWidget,
      );
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
      await tapCatalog(
        tester,
        'movies.home.person.910001.filmography.open',
        'movies.home.person.910001',
      );
      await tapCatalog(
        tester,
        'movies.home.person.910001.filmography.movie.900002.open',
        'movies.home.person.910001.filmography',
      );
      expect(
        find.byKey(const ValueKey('movies.home.movie.900002.screen')),
        findsOneWidget,
      );
      await tapCatalog(
        tester,
        'movies.home.movie.900002.collection.open',
        'movies.home.movie.900002',
      );
      final visited = [
        'movies.home.collection.920001',
        'movies.home.movie.900002',
        'movies.home.person.910001.filmography',
        'movies.home.person.910001',
        'movies.home.movie.900001.cast',
        'movies.home.movie.900001',
      ];
      for (var step = 0; step < 5; step++) {
        await tester.tap(find.byKey(ValueKey('${visited[step]}.back')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(ValueKey('${visited[step + 1]}.screen')),
          findsOneWidget,
        );
      }
    },
  );
}
