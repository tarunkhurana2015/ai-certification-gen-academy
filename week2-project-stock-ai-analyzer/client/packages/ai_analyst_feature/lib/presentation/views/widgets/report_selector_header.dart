import 'package:flutter/material.dart';
import '../../../domain/entities/quarterly_kpis.dart';

class ReportSelectorHeader extends StatelessWidget {
  final QuarterlyKpis? selectedReport;
  final List<QuarterlyKpis> availableReports;
  final ValueChanged<QuarterlyKpis> onReportSelected;
  final VoidCallback? onIngestTap;

  const ReportSelectorHeader({
    super.key,
    required this.selectedReport,
    required this.availableReports,
    required this.onReportSelected,
    this.onIngestTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;

        final branding = Row(
          mainAxisSize: isCompact ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.psychology, color: colorScheme.onPrimaryContainer, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'AI Analyst Copilot',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'RAG Active',
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Deterministic KPI Scorecards & Layout-Aware Financial RAG',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (availableReports.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedReport?.documentId,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    borderRadius: BorderRadius.circular(12),
                    items: availableReports.map<DropdownMenuItem<String>>((report) {
                      return DropdownMenuItem<String>(
                        value: report.documentId,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                report.ticker,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${report.fiscalPeriodDisplay} Update',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newDocId) {
                      if (newDocId != null) {
                        final report = availableReports.firstWhere(
                          (r) => r.documentId == newDocId,
                        );
                        onReportSelected(report);
                      }
                    },
                  ),
                ),
              ),
            if (onIngestTap != null) ...[
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: onIngestTap,
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('Import PDF'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              branding,
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: actions,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: branding),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }
}
