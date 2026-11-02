import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_ui/movies_ui.dart';

class ControlledClock implements Clock {
  Duration time = Duration.zero;
  @override
  Duration get elapsed => time;
  @override
  DateTime utcNow() => DateTime.utc(2026).add(time);
}

void main() {
  testWidgets(
    'rate-limit Retry becomes available without automatically requesting',
    (tester) async {
      final clock = ControlledClock();
      var requests = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorNotice(
              message: 'Catalog is busy',
              clock: clock,
              retryNotBeforeUtc: clock.utcNow().add(const Duration(seconds: 2)),
              onRetry: () => requests++,
            ),
          ),
        ),
      );
      expect(
        tester
            .widget<TextButton>(find.byKey(const ValueKey('resource.retry')))
            .onPressed,
        isNull,
      );
      clock.time = const Duration(seconds: 2);
      await tester.pump(const Duration(seconds: 2));
      expect(requests, 0);
      await tester.tap(find.text('Retry'));
      expect(requests, 1);
    },
  );
}
