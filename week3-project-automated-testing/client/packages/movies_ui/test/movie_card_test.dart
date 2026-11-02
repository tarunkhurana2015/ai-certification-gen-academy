import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_ui/movies_ui.dart';

void main() {
  testWidgets('movie has independent accessible open and favorite actions', (
    tester,
  ) async {
    var opens = 0;
    var favorites = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 170,
            child: MovieCard(
              movie: const MovieSummary(id: 900001, title: 'Northbound'),
              identifier: 'test.movie.900001',
              onOpen: () => opens++,
              onFavorite: () => favorites++,
              favorite: false,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Northbound'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('test.movie.900001.favorite')));
    expect(favorites, 1);
    expect(opens, 0);
    await tester.tap(find.byKey(const ValueKey('test.movie.900001.open')));
    expect(opens, 1);
  });
}
