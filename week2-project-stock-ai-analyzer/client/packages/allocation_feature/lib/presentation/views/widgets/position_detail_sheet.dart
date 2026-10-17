import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import 'package:allocation_feature/l10n/allocation_localizations.dart';

class PositionDetailSheet extends StatelessWidget {
  final HoldingPosition position;
  final VoidCallback onClose;

  const PositionDetailSheet({
    super.key,
    required this.position,
    required this.onClose,
  });

  List<FlSpot> _generateSimulatedTrend() {
    // Deterministic 30-day mini price curve based on symbol hash
    final basePrice = position.avgCostBasis;
    final spots = <FlSpot>[];
    for (int i = 0; i < 30; i++) {
      final noise = ((i * position.symbol.codeUnitAt(0) % 17) - 8) / 100.0;
      final price = basePrice * (1.0 + (i / 30.0) * (position.isProfitable ? 0.2 : -0.15) + noise);
      spots.add(FlSpot(i.toDouble(), price));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AllocationLocalizations.of(context);
    final spots = _generateSimulatedTrend();
    final isProfitable = position.isProfitable;
    final trendColor = isProfitable ? const Color(0xFF00C805) : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      position.symbol.length > 2 ? position.symbol.substring(0, 2) : position.symbol,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position.symbol,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        position.companyName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Price and Return Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Price', style: theme.textTheme.bodySmall),
                  Text(
                    '\$${position.currentPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isProfitable ? "+" : ""}\$${position.unrealizedProfitLoss.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: trendColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${isProfitable ? "+" : ""}${position.unrealizedReturnPercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Mini Sparkline Trend
          Text(l10n?.priceTrend ?? '30-Day Simulated Trend', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: trendColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: trendColor.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Metrics Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricTile(label: l10n?.sharesHeader ?? 'Shares', value: position.shares.toStringAsFixed(2)),
              _MetricTile(label: l10n?.costBasisHeader ?? 'Avg Cost', value: '\$${position.avgCostBasis.toStringAsFixed(2)}'),
              _MetricTile(label: l10n?.totalInvested ?? 'Total Cost', value: '\$${position.totalCost.toStringAsFixed(2)}'),
              _MetricTile(label: l10n?.marketValueHeader ?? 'Market Value', value: '\$${position.totalMarketValue.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
