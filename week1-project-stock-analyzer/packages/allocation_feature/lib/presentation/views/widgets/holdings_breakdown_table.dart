import 'package:flutter/material.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import 'package:allocation_feature/l10n/allocation_localizations.dart';
import 'package:allocation_feature/presentation/state/allocation_state.dart';

class HoldingsBreakdownTable extends StatelessWidget {
  final List<HoldingPosition> holdings;
  final double totalPortfolioValuation;
  final AllocationSortCriteria sortCriteria;
  final bool isAscending;
  final ValueChanged<AllocationSortCriteria> onSortChange;
  final ValueChanged<HoldingPosition> onSelectPosition;

  const HoldingsBreakdownTable({
    super.key,
    required this.holdings,
    required this.totalPortfolioValuation,
    required this.sortCriteria,
    required this.isAscending,
    required this.onSortChange,
    required this.onSelectPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AllocationLocalizations.of(context);

    if (holdings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            l10n?.emptyAllocation ?? 'No holdings match current criteria.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWidescreen = constraints.maxWidth >= 700;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Header Bar with Sort Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${holdings.length} Positions',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<AllocationSortCriteria>(
                  initialValue: sortCriteria,
                  icon: const Icon(Icons.sort, size: 20),
                  tooltip: 'Sort positions',
                  onSelected: onSortChange,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: AllocationSortCriteria.marketValue,
                      child: Text('Sort by Market Value'),
                    ),
                    PopupMenuItem(
                      value: AllocationSortCriteria.profitDollar,
                      child: Text('Sort by Profit / Gain (\$)'),
                    ),
                    PopupMenuItem(
                      value: AllocationSortCriteria.returnPercentage,
                      child: Text('Sort by Return Rate (%)'),
                    ),
                    PopupMenuItem(
                      value: AllocationSortCriteria.symbol,
                      child: Text('Sort by Ticker Symbol'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Card or Data Table
            if (isWidescreen)
              Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(label: Text(l10n?.symbolHeader ?? 'Ticker')),
                      DataColumn(label: Text(l10n?.sharesHeader ?? 'Quantity'), numeric: true),
                      DataColumn(label: Text(l10n?.costBasisHeader ?? 'Avg Cost'), numeric: true),
                      DataColumn(label: Text(l10n?.currentPriceHeader ?? 'Price'), numeric: true),
                      DataColumn(label: Text(l10n?.marketValueHeader ?? 'Market Value'), numeric: true),
                      DataColumn(label: Text(l10n?.unrealizedGainHeader ?? 'Profit / Gain'), numeric: true),
                      DataColumn(label: Text(l10n?.weightHeader ?? 'Weight'), numeric: true),
                    ],
                    rows: holdings.map((p) {
                      final weight = totalPortfolioValuation > 0
                          ? (p.totalMarketValue / totalPortfolioValuation) * 100
                          : 0.0;
                      final isProfitable = p.isProfitable;
                      final profitColor = isProfitable ? const Color(0xFF00C805) : theme.colorScheme.error;

                      return DataRow(
                        onSelectChanged: (_) => onSelectPosition(p),
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  child: Text(
                                    p.symbol.length > 2 ? p.symbol.substring(0, 2) : p.symbol,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(p.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          DataCell(Text(p.shares.toStringAsFixed(2))),
                          DataCell(Text('\$${p.avgCostBasis.toStringAsFixed(2)}')),
                          DataCell(Text('\$${p.currentPrice.toStringAsFixed(2)}')),
                          DataCell(Text('\$${p.totalMarketValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(
                            Text(
                              '${isProfitable ? "+" : ""}\$${p.unrealizedProfitLoss.toStringAsFixed(2)} (${p.unrealizedReturnPercentage.toStringAsFixed(1)}%)',
                              style: TextStyle(color: profitColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataCell(Text('${weight.toStringAsFixed(1)}%')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: holdings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = holdings[index];
                  final weight = totalPortfolioValuation > 0
                      ? (p.totalMarketValue / totalPortfolioValuation) * 100
                      : 0.0;
                  final isProfitable = p.isProfitable;
                  final profitColor = isProfitable ? const Color(0xFF00C805) : theme.colorScheme.error;

                  return Card(
                    elevation: 1,
                    child: ListTile(
                      onTap: () => onSelectPosition(p),
                      leading: CircleAvatar(
                        child: Text(
                          p.symbol.length > 2 ? p.symbol.substring(0, 2) : p.symbol,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(p.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('${weight.toStringAsFixed(1)}% weight', style: theme.textTheme.bodySmall),
                        ],
                      ),
                      subtitle: Text('${p.shares.toStringAsFixed(2)} shs @ \$${p.avgCostBasis.toStringAsFixed(2)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${p.totalMarketValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${isProfitable ? "+" : ""}\$${p.unrealizedProfitLoss.toStringAsFixed(2)} (${p.unrealizedReturnPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(color: profitColor, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
