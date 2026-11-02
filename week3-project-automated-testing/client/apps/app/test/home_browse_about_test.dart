import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
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

void main() {
  testWidgets('MOV-HOME-002 Trending See all opens the matching source', (
    tester,
  ) async {
    await boot(tester);
    final action = find.byKey(
      const ValueKey('movies.home.shelf.trending.see_all'),
    );
    await tester.scrollUntilVisible(
      action,
      250,
      scrollable: find
          .descendant(
            of: find.byKey(const PageStorageKey('movies.home.scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('movies.home.list.trending.movie.900001.open')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('movies.home.list.trending.load_more')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const ValueKey('movies.home.list.trending.movie.900001.open')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('movies.home.movie.900001.screen')),
      findsOneWidget,
    );
  });
  testWidgets('MOV-BROWSE-001 Upcoming is a distinct selectable catalog', (
    tester,
  ) async {
    await boot(tester);
    await tester.tap(find.byKey(const ValueKey('movies.shell.tab.browse')));
    await tester.pumpAndSettle();
    expect(find.text('Now Playing'), findsNWidgets(2));
    await tester.tap(
      find.byKey(const ValueKey('movies.browse.category.upcoming')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Upcoming'), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey('movies.browse.results.movie.900003.open')),
      findsOneWidget,
    );
  });
  testWidgets('MOV-ABOUT-001 displays the bundled logo and exact attribution', (
    tester,
  ) async {
    await boot(tester);
    final about = find.byKey(const ValueKey('movies.home.about.open'));
    await tester.scrollUntilVisible(
      about,
      500,
      scrollable: find
          .descendant(
            of: find.byKey(const PageStorageKey('movies.home.scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(about);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('TMDB logo'), findsOneWidget);
    expect(
      find.text(
        'This product uses the TMDB API but is not endorsed or certified by TMDB.',
      ),
      findsOneWidget,
    );
    final link = find.byKey(const ValueKey('movies.home.about.tmdb_link'));
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.text('Demo: link opening simulated'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('movies.home.about.open')),
      findsOneWidget,
    );
  });
}
