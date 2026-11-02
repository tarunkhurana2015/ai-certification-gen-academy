import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:catalog_feature/presentation/views/catalog_view.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'catalog_navigation_test.dart' show tapCatalog;
import 'support/app_dependencies.dart';

Future<void> boot(WidgetTester tester) async {
  await tester.pumpWidget(
    MoviesApp(
      config: const AppConfig(mode: CatalogMode.fixture),
      dependencies: testDependencies(),
    ),
  );
  await tester.pumpAndSettle();
}

Finder scroll(String base) => find
    .descendant(
      of: find.byKey(ValueKey('$base.scroll')),
      matching: find.byType(Scrollable),
    )
    .first;
void main() {
  testWidgets(
    'MOV-SHELL-002 deep branch retains its page and useful scroll position',
    (tester) async {
      await boot(tester);
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
      await tester.drag(
        scroll('movies.home.person.910001.filmography'),
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();
      final position = tester
          .state<ScrollableState>(
            scroll('movies.home.person.910001.filmography'),
          )
          .position
          .pixels;
      expect(position, greaterThan(0));
      await tester.tap(find.byKey(const ValueKey('movies.shell.tab.search')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('movies.shell.tab.home')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(
          const ValueKey('movies.home.person.910001.filmography.screen'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .state<ScrollableState>(
              scroll('movies.home.person.910001.filmography'),
            )
            .position
            .pixels,
        closeTo(position, 1),
      );
    },
  );
  testWidgets(
    'MOV-DEEP-005 revisiting a movie creates a distinct page with shared favorites',
    (tester) async {
      await boot(tester);
      GoRouter.of(
        tester.element(find.text('Movies')),
      ).push('/home/movie/900001');
      await tester.pumpAndSettle();
      final firstEntry = tester
          .widget<CatalogView>(find.byType(CatalogView))
          .identity
          .entry;
      await tapCatalog(
        tester,
        'movies.home.movie.900001.favorite',
        'movies.home.movie.900001',
      );
      await tapCatalog(
        tester,
        'movies.home.movie.900001.related.open',
        'movies.home.movie.900001',
      );
      await tapCatalog(
        tester,
        'movies.home.movie.900001.related.movie.900004.open',
        'movies.home.movie.900001.related',
      );
      await tapCatalog(
        tester,
        'movies.home.movie.900004.related.open',
        'movies.home.movie.900004',
      );
      await tapCatalog(
        tester,
        'movies.home.movie.900004.related.movie.900001.open',
        'movies.home.movie.900004.related',
      );
      expect(
        tester.widget<CatalogView>(find.byType(CatalogView)).identity.entry,
        isNot(firstEntry),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('movies.home.movie.900001.favorite')),
        200,
        scrollable: scroll('movies.home.movie.900001'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Remove favorite'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('movies.home.movie.900001.back')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.home.movie.900004.related.screen')),
        findsOneWidget,
      );
    },
  );
}
