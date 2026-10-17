import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import 'package:analytics_feature/l10n/analytics_localizations.dart';
import '../viewmodel/analytics_viewmodel.dart';
import 'widgets/equity_curve_chart.dart';
import 'widgets/performance_summary_cards.dart';
import 'widgets/risk_indicators_grid.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsViewModelProvider);
    final portfolioSummary = ref.watch(portfolioSummaryProvider);
    final l10n = AnalyticsLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.tabTitle ?? 'Performance & Risk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Executive Performance Metrics Summary Cards
                PerformanceSummaryCards(summary: portfolioSummary),

                const SizedBox(height: 24),

                // 2. Historical Equity Growth Trajectory
                EquityCurveChart(
                  points: analyticsState.historicalPoints,
                  selectedTimeframe: analyticsState.selectedTimeframe,
                  onSelectTimeframe: (tf) =>
                      ref.read(analyticsViewModelProvider.notifier).setTimeframe(tf),
                ),

                const SizedBox(height: 24),

                // 3. Risk & Portfolio Health Indicators
                RiskIndicatorsGrid(metrics: analyticsState.riskMetrics),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
