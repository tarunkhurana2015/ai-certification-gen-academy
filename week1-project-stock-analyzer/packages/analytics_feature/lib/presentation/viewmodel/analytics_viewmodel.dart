import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import '../../domain/entities/performance_metrics.dart';
import '../state/analytics_state.dart';

class AnalyticsViewModel extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    final summary = ref.watch(portfolioSummaryProvider);
    final holdings = ref.watch(holdingsProvider);

    final points = _generateEquityCurve(
      currentValuation: summary.currentValuation,
      totalInvested: summary.totalInvested,
      timeframe: '1Y',
    );

    final risk = _calculateRiskMetrics(holdings, summary);

    return AnalyticsState(
      selectedTimeframe: '1Y',
      historicalPoints: points,
      riskMetrics: risk,
    );
  }

  void setTimeframe(String timeframe) {
    final summary = ref.read(portfolioSummaryProvider);
    final points = _generateEquityCurve(
      currentValuation: summary.currentValuation,
      totalInvested: summary.totalInvested,
      timeframe: timeframe,
    );
    state = state.copyWith(
      selectedTimeframe: timeframe,
      historicalPoints: points,
    );
  }

  List<HistoricalDataPoint> _generateEquityCurve({
    required double currentValuation,
    required double totalInvested,
    required String timeframe,
  }) {
    if (currentValuation <= 0 && totalInvested <= 0) {
      return const [];
    }

    final int days = switch (timeframe) {
      '1M' => 30,
      '3M' => 90,
      '6M' => 180,
      '1Y' => 365,
      _ => 730, // ALL
    };

    final int pointCount = min(days, 50);
    final double startValuation = totalInvested > 0 ? totalInvested * 0.92 : currentValuation * 0.85;
    final double growthTotal = currentValuation - startValuation;
    final List<HistoricalDataPoint> list = [];
    final now = DateTime.now();

    for (int i = 0; i < pointCount; i++) {
      final progress = i / (pointCount - 1);
      final date = now.subtract(Duration(days: ((pointCount - 1 - i) * (days / pointCount)).round()));

      // Smooth compounding curve with realistic sinusoidal market noise
      final wave = sin(progress * pi * 3.5) * (currentValuation * 0.03);
      final portfolioVal = startValuation + (growthTotal * progress) + wave;

      // S&P 500 benchmark baseline (+12% annual market baseline)
      final benchmarkVal = startValuation * (1.0 + (0.12 * (days / 365.0) * progress));

      list.add(HistoricalDataPoint(
        timestamp: date,
        portfolioValue: max(0.0, portfolioVal),
        benchmarkValue: max(0.0, benchmarkVal),
      ));
    }

    // Ensure final point matches exactly currentValuation
    if (list.isNotEmpty && currentValuation > 0) {
      list[list.length - 1] = HistoricalDataPoint(
        timestamp: now,
        portfolioValue: currentValuation,
        benchmarkValue: list.last.benchmarkValue,
      );
    }

    return list;
  }

  RiskMetrics _calculateRiskMetrics(List<HoldingPosition> holdings, PortfolioSummary summary) {
    if (holdings.isEmpty) {
      return const RiskMetrics(
        beta: 1.0,
        sharpeRatio: 0.0,
        diversificationScore: 0,
        maxDrawdownPercentage: 0.0,
      );
    }

    // Sector entropy calculation for diversification score (0 - 100)
    final Set<String> sectors = holdings.map((h) => h.sector).toSet();
    final double sectorVarietyBonus = min(sectors.length * 15.0, 60.0);
    final double positionCountBonus = min(holdings.length * 5.0, 40.0);
    final int score = min(100, (sectorVarietyBonus + positionCountBonus).round());

    // Beta calculation based on sector weightings (Tech tends to be beta > 1.1)
    double totalWeight = 0.0;
    double weightedBeta = 0.0;
    for (final h in holdings) {
      final b = switch (h.sector) {
        'Technology' => 1.25,
        'Consumer Cyclical' => 1.15,
        'Communication Services' => 1.05,
        'Healthcare' => 0.85,
        'Financial Services' => 0.95,
        'Energy' => 0.90,
        _ => 1.0,
      };
      weightedBeta += b * h.totalMarketValue;
      totalWeight += h.totalMarketValue;
    }
    final double beta = totalWeight > 0 ? (weightedBeta / totalWeight) : 1.0;

    // Sharpe ratio approximation: (Return% - RiskFree 4.5%) / Volatility
    final double returnPct = summary.returnPercentage;
    final double volatility = 14.5 * beta; // annual volatility estimate
    final double sharpe = volatility > 0 ? ((returnPct - 4.5) / volatility) : 0.0;

    return RiskMetrics(
      beta: double.parse(beta.toStringAsFixed(2)),
      sharpeRatio: double.parse(sharpe.toStringAsFixed(2)),
      diversificationScore: score,
      maxDrawdownPercentage: 7.8,
    );
  }
}

final analyticsViewModelProvider =
    NotifierProvider<AnalyticsViewModel, AnalyticsState>(
  AnalyticsViewModel.new,
);
