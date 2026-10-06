import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import 'package:analytics_feature/analytics_feature.dart';

void main() {
  group('AnalyticsViewModel (Gherkin Scenario 3.1 & 3.3)', () {
    final sampleHoldings = [
      HoldingPosition(
        id: '1',
        symbol: 'NVDA',
        companyName: 'NVIDIA Corporation',
        shares: 100.0,
        avgCostBasis: 100.0,
        currentPrice: 150.0,
        sector: 'Technology',
        purchaseDate: DateTime(2026, 1, 1),
        lastUpdated: DateTime.now(),
      ),
      HoldingPosition(
        id: '2',
        symbol: 'UNH',
        companyName: 'UnitedHealth Group',
        shares: 20.0,
        avgCostBasis: 450.0,
        currentPrice: 500.0,
        sector: 'Healthcare',
        purchaseDate: DateTime(2026, 1, 1),
        lastUpdated: DateTime.now(),
      ),
    ];

    late ProviderContainer container;

    setUp(() {
      final summary = PortfolioSummary.fromHoldings(sampleHoldings);
      container = ProviderContainer(
        overrides: [
          holdingsProvider.overrideWithValue(sampleHoldings),
          portfolioSummaryProvider.overrideWithValue(summary),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('calculates accurate portfolio summary math', () {
      final summary = container.read(portfolioSummaryProvider);
      // Invested: 100*100 + 20*450 = 10,000 + 9,000 = $19,000
      // Valuation: 100*150 + 20*500 = 15,000 + 10,000 = $25,000
      // Net profit: $6,000
      // Return: (6000 / 19000) * 100 = 31.58%
      expect(summary.totalInvested, 19000.0);
      expect(summary.currentValuation, 25000.0);
      expect(summary.netProfit, 6000.0);
      expect(summary.returnPercentage, closeTo(31.58, 0.05));
    });

    test('generates equity curve points and supports timeframe switching', () {
      final state = container.read(analyticsViewModelProvider);
      expect(state.historicalPoints.isNotEmpty, true);
      expect(state.selectedTimeframe, '1Y');

      final notifier = container.read(analyticsViewModelProvider.notifier);
      notifier.setTimeframe('1M');
      final updated = container.read(analyticsViewModelProvider);
      expect(updated.selectedTimeframe, '1M');
      expect(updated.historicalPoints.isNotEmpty, true);
    });

    test('computes risk metrics (Beta, Sharpe, Diversification)', () {
      final state = container.read(analyticsViewModelProvider);
      expect(state.riskMetrics.beta, greaterThan(0));
      expect(state.riskMetrics.diversificationScore, greaterThan(0));
      expect(state.riskMetrics.diversificationScore, lessThanOrEqualTo(100));
      expect(state.riskMetrics.sharpeRatio, greaterThan(0));
    });
  });
}
