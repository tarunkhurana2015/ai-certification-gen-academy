import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_ui/movies_ui.dart';

void main() {
  testWidgets('MOV-A11Y-002 large text keeps favorite and Retry reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(3),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: 170,
                    child: MovieCard(
                      movie: const MovieSummary(
                        id: 1,
                        title:
                            'A very long movie title that must remain readable',
                      ),
                      identifier: 'large',
                      onOpen: () {},
                      onFavorite: () {},
                      favorite: false,
                    ),
                  ),
                  ErrorNotice(
                    message:
                        'The request failed. Existing content is preserved.',
                    onRetry: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byKey(const ValueKey('large.favorite')));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    await tester.ensureVisible(find.text('Retry'));
    await tester.pump();
    expect(find.text('Retry').hitTestable(), findsOneWidget);
  });
}
