import 'package:flutter_test/flutter_test.dart';
import 'dart:ui' show SemanticsAction;
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'support/app_dependencies.dart';

void main() {
  testWidgets(
    'MOV-A11Y-001 native tab semantics exposes an activation action',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MoviesApp(
            config: const AppConfig(mode: CatalogMode.fixture),
            dependencies: testDependencies(),
          ),
        );
        await tester.pumpAndSettle();
        final semantics = tester.getSemantics(find.bySemanticsLabel('Browse'));
        expect(
          semantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
      } finally {
        handle.dispose();
      }
    },
  );
  testWidgets('MOV-SHELL-001 starts with all four Movies destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MoviesApp(
        config: const AppConfig(mode: CatalogMode.fixture),
        dependencies: testDependencies(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Browse'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
  });
}
