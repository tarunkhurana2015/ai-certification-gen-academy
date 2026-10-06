import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_feature/l10n/portfolio_localizations.dart';
import '../viewmodel/portfolio_viewmodel.dart';
import 'widgets/csv_preview_dialog.dart';
import 'widgets/manual_position_dialog.dart';

class PortfolioIngestView extends ConsumerWidget {
  const PortfolioIngestView({super.key});

  Future<void> _handlePickCsv(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content = '';
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        }
        if (content.isNotEmpty) {
          ref.read(portfolioViewModelProvider.notifier).processRawCsv(content);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioViewModelProvider);
    final theme = Theme.of(context);
    final l10n = PortfolioLocalizations.of(context);

    // Listen for state messages and show SnackBars
    ref.listen(portfolioViewModelProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.tabTitle ?? 'Portfolio Ingestion'),
        actions: [
          if (state.holdings.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: l10n?.clearPortfolio ?? 'Clear Portfolio',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n?.clearPortfolio ?? 'Clear Portfolio'),
                    content: const Text('Are you sure you want to clear all current holdings?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(l10n?.cancel ?? 'Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(portfolioViewModelProvider.notifier).clearPortfolio();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome & Onboarding Hero Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.auto_graph, color: theme.colorScheme.primary, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n?.welcomeTitle ?? 'Welcome to GenStockFolio',
                                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n?.welcomeSubtitle ??
                                            'Import your holdings via CSV or start immediately with realistic mock market data.',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  onPressed: state.isLoading
                                      ? null
                                      : () => ref.read(portfolioViewModelProvider.notifier).loadDemoPortfolio(),
                                  icon: const Icon(Icons.flash_on),
                                  label: Text(l10n?.loadDemoButton ?? 'Load Demo Portfolio'),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: state.isLoading ? null : () => _handlePickCsv(context, ref),
                                  icon: const Icon(Icons.upload_file),
                                  label: Text(l10n?.uploadCsvButton ?? 'Upload CSV File'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => ManualPositionDialog(
                                              onSave: (pos) => ref
                                                  .read(portfolioViewModelProvider.notifier)
                                                  .addOrUpdatePosition(pos),
                                            ),
                                          );
                                        },
                                  icon: const Icon(Icons.add),
                                  label: Text(l10n?.addPositionButton ?? 'Add Position Manually'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // CSV Drag-and-Drop / Browse Dropzone Area
                    InkWell(
                      onTap: () => _handlePickCsv(context, ref),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 36, color: theme.colorScheme.primary),
                              const SizedBox(height: 8),
                              Text(
                                l10n?.dropZonePrompt ?? 'Click to browse or drop a .csv file',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Supports Symbol, Quantity, Price, Date headers',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Active Positions Ledger Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Ingested Holdings',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          l10n?.positionsCount(state.holdings.length) ?? '${state.holdings.length} positions',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (state.holdings.isEmpty)
                      Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
                        child: const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'No stocks imported yet. Use the buttons above to load demo data or upload a CSV.',
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.holdings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final p = state.holdings[index];
                          return Card(
                            elevation: 1,
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: Text(
                                  p.symbol.length > 2 ? p.symbol.substring(0, 2) : p.symbol,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(p.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      p.sector,
                                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${p.companyName} • ${p.shares.toStringAsFixed(2)} shares @ \$${p.avgCostBasis.toStringAsFixed(2)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${p.totalMarketValue.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${p.isProfitable ? "+" : ""}\$${p.unrealizedProfitLoss.toStringAsFixed(2)} (${p.unrealizedReturnPercentage.toStringAsFixed(1)}%)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: p.isProfitable ? Colors.green[700] : theme.colorScheme.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => ManualPositionDialog(
                                          initialPosition: p,
                                          onSave: (updated) => ref
                                              .read(portfolioViewModelProvider.notifier)
                                              .addOrUpdatePosition(updated),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    onPressed: () => ref
                                        .read(portfolioViewModelProvider.notifier)
                                        .deletePosition(p.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 36),

                    // Brokerage Connection Bridge (Phase 2 Preview)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: theme.colorScheme.surfaceContainerLow,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance, color: Colors.green),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n?.robinhoodSectionTitle ?? 'Brokerage Connection',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Link your Robinhood account via secure OAuth to fetch real holdings in Phase 2.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Robinhood OAuth connection bridge ready for Phase 2.'),
                                  ),
                                );
                              },
                              child: const Text('Connect'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CSV Validation Preview Dialog Overlay
          if (state.pendingCsvResult != null)
            CsvPreviewDialog(
              result: state.pendingCsvResult!,
              onConfirm: () =>
                  ref.read(portfolioViewModelProvider.notifier).confirmPendingCsvImport(),
              onDismiss: () =>
                  ref.read(portfolioViewModelProvider.notifier).dismissPendingCsv(),
            ),

          if (state.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
