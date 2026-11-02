import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_ui/movies_ui.dart';

void main() {
  testWidgets(
    'retained data keeps its source and the attempted request error',
    (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResourcePanel(
              displayedSource: 'Showing results for Northbound',
              errorText: 'Could not search Ember',
              onRetry: () => retries++,
              content: const Text('Northbound result'),
            ),
          ),
        ),
      );
      expect(find.text('Showing results for Northbound'), findsOneWidget);
      expect(find.text('Northbound result'), findsOneWidget);
      expect(find.text('Could not search Ember'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    },
  );
}
