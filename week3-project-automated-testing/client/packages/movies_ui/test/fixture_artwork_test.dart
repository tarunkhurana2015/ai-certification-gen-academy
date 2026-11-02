import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_ui/movies_ui.dart';

void main() {
  testWidgets('Demo artwork is local and never creates a network image', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 200,
          height: 300,
          child: Artwork(source: 'fixture:Northbound', title: 'Northbound'),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('artwork.fixture')), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
