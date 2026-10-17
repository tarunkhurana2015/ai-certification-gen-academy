import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_analyst_feature/ai_analyst_feature.dart';

void main() {
  testWidgets('KpiDashboardView renders header, executive summary, and 3 KPI pillars', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KpiDashboardView(),
        ),
      ),
    );

    // Initial render
    await tester.pumpAndSettle();

    // Verify AI Analyst Copilot Header
    expect(find.text('AI Analyst Copilot'), findsOneWidget);
    expect(find.text('RAG Active'), findsOneWidget);

    // Verify Executive Summary Card
    expect(find.text('Executive Summary & Strategic Takeaways'), findsOneWidget);
    expect(find.textContaining('Total revenue expanded +2.1% YoY'), findsOneWidget);

    // Verify Pillar 1: Profitability & Descriptions
    expect(find.text('Profitability & Earnings Power'), findsOneWidget);
    expect(find.text('Total Revenue'), findsOneWidget);
    expect(find.textContaining('Gross receipts from automotive sales'), findsOneWidget);
    expect(find.text('\$25.50B'), findsOneWidget);
    expect(find.text('+2.1% YoY'), findsOneWidget);
    expect(find.text('Gross Margin'), findsOneWidget);
    expect(find.textContaining('Percentage of revenue retained after deducting'), findsOneWidget);
    expect(find.text('17.95%'), findsOneWidget);
    expect(find.text('Operating Margin'), findsOneWidget);
    expect(find.text('6.30%'), findsOneWidget);

    // Verify Margin Trend Chart is present
    expect(find.byType(MarginTrendChart), findsOneWidget);
    expect(find.text('Margin Efficiency Breakdown'), findsOneWidget);

    // Verify Pillar 2: Cash Flow & Descriptions
    expect(find.text('Cash Flow & Reinvestment'), findsOneWidget);
    expect(find.text('Free Cash Flow (FCF)'), findsOneWidget);
    expect(find.textContaining('Discretionary cash generated'), findsOneWidget);
    expect(find.text('\$1.34B'), findsOneWidget);

    // Verify Pillar 3: Balance Sheet & Solvency & Descriptions
    expect(find.text('Balance Sheet & Solvency'), findsOneWidget);
    expect(find.text('Cash & Equivalents'), findsOneWidget);
    expect(find.textContaining('Liquid reserves in bank accounts'), findsOneWidget);
    expect(find.text('\$30.72B'), findsOneWidget);

    // Verify Right-Side Chat Window is rendered
    expect(find.byType(AiAnalystChatWindow), findsOneWidget);
    expect(find.text('Earnings Copilot Q&A'), findsOneWidget);
    expect(find.textContaining('Active Scope: Tesla, Inc. (Q2 2026)'), findsOneWidget);

    // Verify Import PDF button opens ReportIngestionPanel
    expect(find.text('Import PDF'), findsOneWidget);
    await tester.tap(find.text('Import PDF'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportIngestionPanel), findsOneWidget);
    expect(find.text('Import Quarterly Earnings Report (PDF)'), findsOneWidget);
    expect(find.text('Choose PDF Earnings Report / Shareholder Deck'), findsOneWidget);
    expect(find.text('Stock Ticker *'), findsOneWidget);
  });
}
