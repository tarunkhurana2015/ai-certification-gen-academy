import 'package:flutter/foundation.dart';

@immutable
class HoldingPosition {
  final String id;
  final String symbol;
  final String companyName;
  final double shares;
  final double avgCostBasis;
  final double currentPrice;
  final String sector;
  final DateTime purchaseDate;
  final DateTime lastUpdated;

  const HoldingPosition({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.shares,
    required this.avgCostBasis,
    required this.currentPrice,
    required this.sector,
    required this.purchaseDate,
    required this.lastUpdated,
  });

  double get totalCost => shares * avgCostBasis;
  double get totalMarketValue => shares * currentPrice;
  double get unrealizedProfitLoss => totalMarketValue - totalCost;
  double get unrealizedReturnPercentage =>
      totalCost > 0 ? (unrealizedProfitLoss / totalCost) * 100 : 0.0;
  bool get isProfitable => unrealizedProfitLoss >= 0;

  HoldingPosition copyWith({
    String? id,
    String? symbol,
    String? companyName,
    double? shares,
    double? avgCostBasis,
    double? currentPrice,
    String? sector,
    DateTime? purchaseDate,
    DateTime? lastUpdated,
  }) {
    return HoldingPosition(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      shares: shares ?? this.shares,
      avgCostBasis: avgCostBasis ?? this.avgCostBasis,
      currentPrice: currentPrice ?? this.currentPrice,
      sector: sector ?? this.sector,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'company_name': companyName,
      'shares': shares,
      'avg_cost_basis': avgCostBasis,
      'current_price': currentPrice,
      'sector': sector,
      'purchase_date': purchaseDate.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory HoldingPosition.fromJson(Map<String, dynamic> json) {
    return HoldingPosition(
      id: json['id'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      companyName: json['company_name'] as String? ?? 'Unknown Asset',
      shares: (json['shares'] as num?)?.toDouble() ?? 0.0,
      avgCostBasis: (json['avg_cost_basis'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      sector: json['sector'] as String? ?? 'Other',
      purchaseDate:
          DateTime.tryParse(json['purchase_date'] as String? ?? '') ??
              DateTime.now(),
      lastUpdated: DateTime.tryParse(json['last_updated'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HoldingPosition &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          symbol == other.symbol &&
          shares == other.shares &&
          avgCostBasis == other.avgCostBasis &&
          currentPrice == other.currentPrice;

  @override
  int get hashCode => Object.hash(id, symbol, shares, avgCostBasis, currentPrice);
}
