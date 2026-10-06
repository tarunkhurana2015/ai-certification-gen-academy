import 'package:flutter/foundation.dart';
import '../../domain/entities/performance_metrics.dart';

@immutable
class AnalyticsState {
  final String selectedTimeframe;
  final List<HistoricalDataPoint> historicalPoints;
  final RiskMetrics riskMetrics;
  final bool isLoading;

  const AnalyticsState({
    this.selectedTimeframe = '1Y',
    this.historicalPoints = const [],
    this.riskMetrics = const RiskMetrics(
      beta: 1.05,
      sharpeRatio: 1.82,
      diversificationScore: 82,
      maxDrawdownPercentage: 8.4,
    ),
    this.isLoading = false,
  });

  AnalyticsState copyWith({
    String? selectedTimeframe,
    List<HistoricalDataPoint>? historicalPoints,
    RiskMetrics? riskMetrics,
    bool? isLoading,
  }) {
    return AnalyticsState(
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      historicalPoints: historicalPoints ?? this.historicalPoints,
      riskMetrics: riskMetrics ?? this.riskMetrics,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
