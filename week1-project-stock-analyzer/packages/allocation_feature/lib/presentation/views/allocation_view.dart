import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import 'package:allocation_feature/l10n/allocation_localizations.dart';
import '../viewmodel/allocation_viewmodel.dart';
import 'widgets/allocation_pie_chart.dart';
import 'widgets/holdings_breakdown_table.dart';
import 'widgets/position_detail_sheet.dart';

class AllocationView extends ConsumerWidget {
  const AllocationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allocState = ref.watch(allocationViewModelProvider);
    final filteredHoldings = ref.watch(filteredHoldingsProvider);
    final portfolioSummary = ref.watch(portfolioSummaryProvider);
    final theme = Theme.of(context);
    final l10n = AllocationLocalizations.of(context);

    final hasFilter = allocState.selectedSector != null || allocState.selectedTicker != null;
    final activeFilterText = allocState.selectedSector ?? allocState.selectedTicker ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.tabTitle ?? 'Asset Allocation'),
        actions: [
          if (hasFilter)
            TextButton.icon(
              onPressed: () => ref.read(allocationViewModelProvider.notifier).clearFilters(),
              icon: const Icon(Icons.filter_alt_off, size: 18),
              label: Text(l10n?.clearFilter ?? 'Clear Filter'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isExpanded = constraints.maxWidth >= 840;

                final chartCard = Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.allocationHeader ?? 'Portfolio Allocation',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        AllocationPieChart(
                          allocations: allocState.sectorAllocations,
                          totalValuation: portfolioSummary.currentValuation,
                          selectedSector: allocState.selectedSector,
                          onSelectSector: (sec) =>
                              ref.read(allocationViewModelProvider.notifier).selectSectorSlice(sec),
                        ),
                      ],
                    ),
                  ),
                );

                final breakdownCard = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasFilter)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list, size: 18, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.filteredBy(activeFilterText) ?? 'Filtered by: $activeFilterText',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () =>
                                  ref.read(allocationViewModelProvider.notifier).clearFilters(),
                            ),
                          ],
                        ),
                      ),
                    HoldingsBreakdownTable(
                      holdings: filteredHoldings,
                      totalPortfolioValuation: portfolioSummary.currentValuation,
                      sortCriteria: allocState.sortCriteria,
                      isAscending: allocState.isAscending,
                      onSortChange: (criteria) =>
                          ref.read(allocationViewModelProvider.notifier).setSortCriteria(criteria),
                      onSelectPosition: (pos) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => PositionDetailSheet(
                            position: pos,
                            onClose: () => Navigator.of(ctx).pop(),
                          ),
                        );
                      },
                    ),
                  ],
                );

                if (isExpanded) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: chartCard),
                      const SizedBox(width: 24),
                      Expanded(flex: 7, child: breakdownCard),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      chartCard,
                      const SizedBox(height: 24),
                      breakdownCard,
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
