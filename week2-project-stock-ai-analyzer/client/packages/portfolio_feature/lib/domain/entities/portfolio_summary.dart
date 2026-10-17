import 'package:flutter/foundation.dart';
import 'holding_position.dart';

@immutable
class PortfolioSummary {
  final double totalInvested;
  final double currentValuation;
  final double netProfit;
  final double returnPercentage;
  final int totalHoldingsCount;
  final DateTime lastCalculated;

  const PortfolioSummary({
    required this.totalInvested,
    required this.currentValuation,
    required this.netProfit,
    required this.returnPercentage,
    required this.totalHoldingsCount,
    required this.lastCalculated,
  });

  factory PortfolioSummary.fromHoldings(List<HoldingPosition> holdings) {
    if (holdings.isEmpty) {
      return PortfolioSummary(
        totalInvested: 0.0,
        currentValuation: 0.0,
        netProfit: 0.0,
        returnPercentage: 0.0,
        totalHoldingsCount: 0,
        lastCalculated: DateTime.now(),
      );
    }

    final double invested =
        holdings.fold(0.0, (acc, item) => acc + item.totalCost);
    final double valuation =
        holdings.fold(0.0, (acc, item) => acc + item.totalMarketValue);
    final double profit = valuation - invested;
    final double returnPct = invested > 0 ? (profit / invested) * 100 : 0.0;

    return PortfolioSummary(
      totalInvested: invested,
      currentValuation: valuation,
      netProfit: profit,
      returnPercentage: returnPct,
      totalHoldingsCount: holdings.length,
      lastCalculated: DateTime.now(),
    );
  }
}
