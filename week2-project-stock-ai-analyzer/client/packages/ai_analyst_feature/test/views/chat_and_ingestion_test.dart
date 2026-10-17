import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_analyst_feature/ai_analyst_feature.dart';

void main() {
  final sampleReport = MockKpiDataSource.benchmarkReports.first;

  group('AiAnalystChatWindow Widget Tests', () {
    testWidgets('Renders chat header, scope, welcome message, and suggested prompts', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiAnalystChatWindow(report: sampleReport),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Earnings Copilot Q&A'), findsOneWidget);
      expect(find.textContaining('Active Scope: Tesla, Inc. (Q2 2026)'), findsOneWidget);
      expect(find.textContaining('Hello! I am your AI Earnings Analyst Copilot'), findsOneWidget);
      expect(find.text('Why did operating margin compress this quarter?'), findsOneWidget);
    });

    testWidgets('Tapping suggested prompt sends question and receives grounded answer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiAnalystChatWindow(report: sampleReport),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap prompt chip
      await tester.tap(find.text('Why did operating margin compress this quarter?'));
      await tester.pump();
      expect(find.widgetWithText(ActionChip, 'Why did operating margin compress this quarter?'), findsOneWidget);
      expect(find.text('Why did operating margin compress this quarter?'), findsNWidgets(2));

      // Wait for assistant response timer (600ms simulated LLM latency)
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.textContaining('TSLA reported a Gross Margin of 17.95%'), findsOneWidget);
      expect(find.textContaining('Shareholder Deck Pg. 4, Item 1'), findsOneWidget);
    });
  });

  group('ReportIngestionPanel Widget Tests', () {
    testWidgets('Renders form fields and triggers onReportIngested with extracted data', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      QuarterlyKpis? ingestedReport;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReportIngestionPanel(
                onReportIngested: (r) => ingestedReport = r,
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Import Quarterly Earnings Report (PDF)'), findsOneWidget);
      expect(find.text('Extract KPIs & Ingest RAG'), findsOneWidget);

      // Click Ingest button
      await tester.tap(find.text('Extract KPIs & Ingest RAG'));
      await tester.pump();

      // Pump through progress intervals
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(ingestedReport, isNotNull);
      expect(ingestedReport?.ticker, equals('TSLA'));
      expect(ingestedReport?.fiscalPeriodDisplay, equals('Q2 2026'));
      expect(ingestedReport?.profitability.grossMarginPct, equals(17.95));
    });
  });
}
