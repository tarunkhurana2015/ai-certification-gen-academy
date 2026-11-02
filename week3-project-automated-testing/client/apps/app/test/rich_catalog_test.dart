import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'support/app_dependencies.dart';

Future<void> open(WidgetTester tester, String route) async {
  await tester.pumpWidget(
    MoviesApp(
      config: const AppConfig(mode: CatalogMode.fixture),
      dependencies: testDependencies(),
    ),
  );
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.text('Movies'))).push(route);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'MOV-DEEP-003 related movies preserve the movie title and open a supplied movie',
    (tester) async {
      await open(tester, '/home/movie/900004/related');
      expect(find.text('Quiet Harbor'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('movies.home.movie.900004.related.movie.900001.open'),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(
          const ValueKey('movies.home.movie.900004.related.movie.900001.open'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('movies.home.movie.900001.screen')),
        findsOneWidget,
      );
    },
  );
  testWidgets('MOV-DETAIL-002 absent artwork, score and trailer stay honest', (
    tester,
  ) async {
    await open(tester, '/home/movie/900004');
    final scroll = find
        .descendant(
          of: find.byKey(const ValueKey('movies.home.movie.900004.scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('TMDB · Not rated'),
      200,
      scrollable: scroll,
    );
    await tester.pumpAndSettle();
    expect(find.text('TMDB · Not rated'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('No supported trailer has been supplied.'),
      200,
      scrollable: scroll,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('movies.home.movie.900004.collection.open')),
      findsNothing,
    );
  });
  testWidgets(
    'MOV-DETAIL-005 person gallery retains parent context and tabs remain usable',
    (tester) async {
      await open(tester, '/home/person/910001/images');
      expect(find.text('Maya Reed'), findsOneWidget);
      final image = find.byKey(
        const ValueKey(
          'movies.home.person.910001.images.asset.fixture%3APortrait.open',
        ),
      );
      await tester.tapAt(tester.getTopLeft(image) + const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.text('Close'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('movies.shell.tab.library')));
      await tester.pumpAndSettle();
      expect(find.text('Your Library'), findsOneWidget);
    },
  );
  testWidgets(
    'MOV-DETAIL-005 full review opens readable plain text with parent context',
    (tester) async {
      await open(tester, '/home/movie/900001/reviews');
      expect(find.text('Northbound'), findsOneWidget);
      final action = find.byKey(
        const ValueKey(
          'movies.home.movie.900001.reviews.review.fixture-review-900001.open',
        ),
      );
      await tester.scrollUntilVisible(
        action,
        200,
        scrollable: find
            .descendant(
              of: find.byKey(
                const ValueKey('movies.home.movie.900001.reviews.scroll'),
              ),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    },
  );
}
