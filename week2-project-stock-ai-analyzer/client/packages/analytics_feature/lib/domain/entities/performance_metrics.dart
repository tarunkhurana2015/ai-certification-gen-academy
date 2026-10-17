import 'package:flutter/foundation.dart';

@immutable
class HistoricalDataPoint {
  final DateTime timestamp;
  final double portfolioValue;
  final double benchmarkValue;

  const HistoricalDataPoint({
    required this.timestamp,
    required this.portfolioValue,
    required this.benchmarkValue,
  });
}

@immutable
class RiskMetrics {
  final double beta;
  final double sharpeRatio;
  final int diversificationScore;
  final double maxDrawdownPercentage;

  const RiskMetrics({
    required this.beta,
    required this.sharpeRatio,
    required this.diversificationScore,
    required this.maxDrawdownPercentage,
  });
}
