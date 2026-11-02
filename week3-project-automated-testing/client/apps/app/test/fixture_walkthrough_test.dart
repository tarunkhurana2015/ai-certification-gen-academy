import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'support/app_dependencies.dart';

void main() {
  testWidgets(
    'MOV-SEARCH-008 search, movie, favorite and Library preserve branch state',
    (tester) async {
      await tester.pumpWidget(
        MoviesApp(
          config: const AppConfig(mode: CatalogMode.fixture),
          dependencies: testDependencies(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Stay for the story.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('movies.shell.tab.search')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('movies.search.query.input')),
        'Northbound',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('movies.search.results.movie.900001.open')),
      );
      await tester.pumpAndSettle();
      final favorite = find.byKey(
        const ValueKey('movies.search.movie.900001.favorite'),
      );
      await tester.scrollUntilVisible(
        favorite,
        200,
        scrollable: find
            .descendant(
              of: find.byKey(
                const ValueKey('movies.search.movie.900001.scroll'),
              ),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(favorite);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('movies.shell.tab.library')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(
          const ValueKey('movies.library.favorites.movie.900001.open'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('movies.shell.tab.search')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.search.movie.900001.screen')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('movies.search.movie.900001.back')),
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Northbound'), findsOneWidget);
    },
  );
  testWidgets(
    'MOV-SEARCH-006 no matches is shown only after the search succeeds',
    (tester) async {
      await tester.pumpWidget(
        MoviesApp(
          config: const AppConfig(mode: CatalogMode.fixture),
          dependencies: testDependencies(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('movies.shell.tab.search')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('movies.search.query.input')),
        'No such fixture movie',
      );
      await tester.pump(const Duration(milliseconds: 349));
      expect(find.text('No movies match this title.'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('No movies match this title.'), findsOneWidget);
    },
  );
}
