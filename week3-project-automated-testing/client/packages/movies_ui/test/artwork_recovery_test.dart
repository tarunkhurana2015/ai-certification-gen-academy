import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_ui/movies_ui.dart';

void main() {
  for (final source in [
    'https://example.invalid/poster.jpg',
    'asset:missing-poster.png',
    'javascript:invalid',
  ]) {
    testWidgets(
      'MOV-RECOVERY-006 failed artwork preserves identity and independent actions: $source',
      (tester) async {
        var opened = 0, favorited = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 180,
                  child: MovieCard(
                    movie: const MovieSummary(id: 1, title: 'Northbound'),
                    identifier: 'movie.1',
                    imageSource: source,
                    favorite: false,
                    onOpen: () => opened++,
                    onFavorite: () => favorited++,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.local_movies_outlined), findsOneWidget);
        expect(find.text('Northbound'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('movie.1.favorite')));
        await tester.tap(find.byKey(const ValueKey('movie.1.open')));
        expect(opened, 1);
        expect(favorited, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('resource loading and successful emptiness remain distinct', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ResourcePanel(loading: true))),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No titles available.'), findsNothing);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResourcePanel(emptyMessage: 'No upcoming movies.'),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No upcoming movies.'), findsOneWidget);
  });
}
