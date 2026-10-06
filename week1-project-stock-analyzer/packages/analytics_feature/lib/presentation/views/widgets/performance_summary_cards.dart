import 'package:flutter/material.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import 'package:analytics_feature/l10n/analytics_localizations.dart';

class PerformanceSummaryCards extends StatelessWidget {
  final PortfolioSummary summary;

  const PerformanceSummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AnalyticsLocalizations.of(context);
    final isProfitable = summary.netProfit >= 0;
    final profitColor = isProfitable ? const Color(0xFF00C805) : theme.colorScheme.error;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        final cardInvested = _SummaryMetricCard(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: Colors.blueAccent,
          label: l10n?.lifetimeInvested ?? 'Lifetime Invested',
          value: '\$${summary.totalInvested.toStringAsFixed(2)}',
          subtitle: '${summary.totalHoldingsCount} active holdings',
        );

        final cardValuation = _SummaryMetricCard(
          icon: Icons.show_chart,
          iconColor: Colors.purpleAccent,
          label: l10n?.currentValuation ?? 'Current Valuation',
          value: '\$${summary.currentValuation.toStringAsFixed(2)}',
          subtitle: 'Live mark-to-market',
        );

        final cardProfit = _SummaryMetricCard(
          icon: isProfitable ? Icons.trending_up : Icons.trending_down,
          iconColor: profitColor,
          label: l10n?.netProfit ?? 'Net Lifetime Profit',
          value: '${isProfitable ? "+" : ""}\$${summary.netProfit.toStringAsFixed(2)}',
          valueColor: profitColor,
          subtitle: isProfitable ? 'Positive capital gains' : 'Unrealized loss',
        );

        final cardReturn = _SummaryMetricCard(
          icon: Icons.percent,
          iconColor: profitColor,
          label: l10n?.totalReturn ?? 'Cumulative Return',
          value: '${isProfitable ? "+" : ""}${summary.returnPercentage.toStringAsFixed(2)}%',
          valueColor: profitColor,
          subtitle: 'Internal rate of return',
        );

        if (isCompact) {
          return Column(
            children: [
              Row(children: [Expanded(child: cardInvested), const SizedBox(width: 12), Expanded(child: cardValuation)]),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: cardProfit), const SizedBox(width: 12), Expanded(child: cardReturn)]),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: cardInvested),
              const SizedBox(width: 12),
              Expanded(child: cardValuation),
              const SizedBox(width: 12),
              Expanded(child: cardProfit),
              const SizedBox(width: 12),
              Expanded(child: cardReturn),
            ],
          );
        }
      },
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final String subtitle;

  const _SummaryMetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
