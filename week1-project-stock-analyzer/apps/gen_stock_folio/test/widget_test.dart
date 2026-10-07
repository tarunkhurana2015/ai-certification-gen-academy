import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gen_stock_folio/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GenStockFolio smoke test launches and displays tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: GenStockFolioApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Verify Tab 1 is visible
    expect(find.text('Portfolio Ingestion'), findsOneWidget);
    expect(find.text('Welcome to GenStockFolio'), findsOneWidget);
    expect(find.text('Load Demo Portfolio'), findsOneWidget);
    expect(find.text('Yahoo Finance Live Stream'), findsOneWidget);
  });

  testWidgets('GenStockFolio navigates between tabs and displays respective views', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: GenStockFolioApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Navigate to Allocation tab
    await tester.tap(find.text('Allocation'));
    await tester.pumpAndSettle();
    expect(find.text('Asset Allocation'), findsOneWidget);

    // Navigate to Performance tab
    await tester.tap(find.text('Performance'));
    await tester.pumpAndSettle();
    expect(find.text('Performance & Risk'), findsOneWidget);
  });

  testWidgets('GenStockFolio loads demo portfolio and populates summary cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: GenStockFolioApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Click Load Demo Portfolio
    final demoBtn = find.text('Load Demo Portfolio');
    expect(demoBtn, findsOneWidget);
    await tester.tap(demoBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Check that positions appeared (e.g. AAPL, NVDA, TSLA)
    expect(find.text('AAPL'), findsWidgets);
    expect(find.text('NVDA'), findsWidgets);

    // Verify live stream controller is active and ready
    expect(find.text('Yahoo Finance Live Stream'), findsOneWidget);
  });

  testWidgets('GenStockFolio opens Plaid dialog and connects account in sandbox mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: GenStockFolioApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Find and scroll to Connect button in Plaid Financial Integration section
    final connectBtn = find.widgetWithText(FilledButton, 'Connect');
    await tester.scrollUntilVisible(connectBtn, 200);
    expect(connectBtn, findsOneWidget);
    await tester.tap(connectBtn);
    await tester.pumpAndSettle();

    // Plaid dialog is visible
    expect(find.text('Link Brokerage via Plaid'), findsOneWidget);

    // Tap Connect Account in dialog
    final submitBtn = find.widgetWithText(FilledButton, 'Connect Account');
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Dialog closed and Plaid is connected
    expect(find.text('Connected via Plaid'), findsOneWidget);
    expect(find.text('Sync Now'), findsOneWidget);
    expect(find.text('VOO'), findsWidgets);
  });
}
