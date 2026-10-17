import 'package:flutter/material.dart';

class ExecutiveSummaryCard extends StatelessWidget {
  final List<String> summaryBullets;
  final String companyName;
  final String fiscalPeriod;

  const ExecutiveSummaryCard({
    super.key,
    required this.summaryBullets,
    required this.companyName,
    required this.fiscalPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(Icons.auto_awesome, color: colorScheme.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Executive Summary & Strategic Takeaways',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      Text(
                        '$companyName · $fiscalPeriod Earnings Disclosures',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: const Text('Audited KPIs'),
                  backgroundColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...summaryBullets.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;

              IconData bulletIcon;
              Color iconColor;

              if (index == 0) {
                bulletIcon = Icons.trending_up;
                iconColor = Colors.green;
              } else if (index == 1) {
                bulletIcon = Icons.priority_high;
                iconColor = Colors.amber;
              } else {
                bulletIcon = Icons.account_balance_wallet;
                iconColor = Colors.blue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(bulletIcon, color: iconColor, size: 14),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
