import 'package:flutter/material.dart';
import 'package:analytics_feature/domain/entities/performance_metrics.dart';
import 'package:analytics_feature/l10n/analytics_localizations.dart';

class RiskIndicatorsGrid extends StatelessWidget {
  final RiskMetrics metrics;

  const RiskIndicatorsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AnalyticsLocalizations.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  l10n?.riskSection ?? 'Risk & Portfolio Health',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;

                final tileBeta = _RiskTile(
                  title: l10n?.betaLabel ?? 'Portfolio Beta',
                  value: metrics.beta.toStringAsFixed(2),
                  badge: metrics.beta > 1.15
                      ? 'High Volatility'
                      : (metrics.beta < 0.9 ? 'Defensive' : 'Market Neutral'),
                  badgeColor: metrics.beta > 1.15 ? Colors.orange : Colors.green,
                  description: l10n?.betaDesc ?? 'Sensitivity to S&P 500 swings',
                );

                final tileSharpe = _RiskTile(
                  title: l10n?.sharpeLabel ?? 'Sharpe Ratio',
                  value: metrics.sharpeRatio.toStringAsFixed(2),
                  badge: metrics.sharpeRatio > 1.5
                      ? 'Excellent'
                      : (metrics.sharpeRatio > 1.0 ? 'Good' : 'Sub-Optimal'),
                  badgeColor: metrics.sharpeRatio > 1.0 ? Colors.green : Colors.orange,
                  description: l10n?.sharpeDesc ?? 'Risk-adjusted excess return',
                );

                final tileDiversification = _RiskTile(
                  title: l10n?.diversificationScore ?? 'Diversification Score',
                  value: '${metrics.diversificationScore} / 100',
                  badge: metrics.diversificationScore >= 75
                      ? 'Well Diversified'
                      : (metrics.diversificationScore >= 50 ? 'Moderate' : 'Concentrated'),
                  badgeColor: metrics.diversificationScore >= 75 ? Colors.green : Colors.amber,
                  description: l10n?.diversificationDesc ?? 'Asset & sector balance index',
                );

                if (isCompact) {
                  return Column(
                    children: [
                      tileBeta,
                      const Divider(height: 24),
                      tileSharpe,
                      const Divider(height: 24),
                      tileDiversification,
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(child: tileBeta),
                      const SizedBox(width: 16),
                      Expanded(child: tileSharpe),
                      const SizedBox(width: 16),
                      Expanded(child: tileDiversification),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskTile extends StatelessWidget {
  final String title;
  final String value;
  final String badge;
  final Color badgeColor;
  final String description;

  const _RiskTile({
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
