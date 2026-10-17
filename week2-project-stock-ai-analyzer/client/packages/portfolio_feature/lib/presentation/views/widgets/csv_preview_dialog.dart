import 'package:flutter/material.dart';
import 'package:portfolio_feature/domain/entities/csv_parse_result.dart';
import 'package:portfolio_feature/l10n/portfolio_localizations.dart';

class CsvPreviewDialog extends StatelessWidget {
  final CsvParseResult result;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const CsvPreviewDialog({
    super.key,
    required this.result,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = PortfolioLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.table_chart, color: Colors.green),
          const SizedBox(width: 8),
          Text(l10n?.previewTitle ?? 'CSV Import Preview'),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  label: Text('${result.validPositions.length} ${l10n?.validRows ?? "Valid"}'),
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 8),
                if (result.hasErrors)
                  Chip(
                    avatar: const Icon(Icons.warning, color: Colors.red, size: 18),
                    label: Text('${result.errors.length} ${l10n?.flaggedIssues ?? "Issues"}'),
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  if (result.validPositions.isNotEmpty) ...[
                    Text(
                      'Ready to Import:',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    ...result.validPositions.map(
                      (p) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          child: Text(
                            p.symbol.length > 2 ? p.symbol.substring(0, 2) : p.symbol,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text('${p.symbol} • ${p.shares} shares @ \$${p.avgCostBasis.toStringAsFixed(2)}'),
                        subtitle: Text(p.companyName),
                        trailing: Text(
                          '\$${p.totalCost.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                  if (result.hasErrors) ...[
                    const Divider(height: 24),
                    Text(
                      'Issues Flagged (Will Be Skipped):',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...result.errors.map(
                      (err) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Line ${err.lineNumber}: ${err.reason} (${err.rawContent})',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton.icon(
          onPressed: result.hasValidPositions ? onConfirm : null,
          icon: const Icon(Icons.file_download_done),
          label: Text(l10n?.confirmImport ?? 'Confirm Import'),
        ),
      ],
    );
  }
}
