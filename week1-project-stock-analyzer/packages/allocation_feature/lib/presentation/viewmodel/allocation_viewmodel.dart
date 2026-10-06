import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import '../../domain/entities/sector_allocation.dart';
import '../state/allocation_state.dart';

final sectorColors = <String, Color>{
  'Technology': const Color(0xFF00C805),
  'Communication Services': const Color(0xFF0A84FF),
  'Consumer Cyclical': const Color(0xFFFF9500),
  'Healthcare': const Color(0xFFAF52DE),
  'Financial Services': const Color(0xFFFF2D55),
  'Energy': const Color(0xFF5AC8FA),
  'Other': const Color(0xFF8E8E93),
};

class AllocationViewModel extends Notifier<AllocationState> {
  @override
  AllocationState build() {
    final holdings = ref.watch(holdingsProvider);
    final allocations = _computeSectorAllocations(holdings);

    return AllocationState(
      sectorAllocations: allocations,
    );
  }

  List<SectorAllocation> _computeSectorAllocations(List<HoldingPosition> holdings) {
    if (holdings.isEmpty) return const [];

    final double totalValuation =
        holdings.fold(0.0, (acc, item) => acc + item.totalMarketValue);
    if (totalValuation <= 0) return const [];

    final Map<String, List<HoldingPosition>> sectorGroups = {};
    for (final pos in holdings) {
      sectorGroups.putIfAbsent(pos.sector, () => []).add(pos);
    }

    final List<SectorAllocation> results = [];
    sectorGroups.forEach((sector, positions) {
      final dollar =
          positions.fold(0.0, (acc, item) => acc + item.totalMarketValue);
      final pct = (dollar / totalValuation) * 100;
      final color = sectorColors[sector] ?? const Color(0xFF8E8E93);

      results.add(SectorAllocation(
        sector: sector,
        dollarValue: dollar,
        percentage: pct,
        holdingCount: positions.length,
        colorValue: color.toARGB32(),
      ));
    });

    results.sort((a, b) => b.dollarValue.compareTo(a.dollarValue));
    return results;
  }

  void selectTickerSlice(String ticker) {
    if (state.selectedTicker == ticker) {
      state = state.copyWith(clearSelectedTicker: true);
    } else {
      state = state.copyWith(
        selectedTicker: ticker,
        clearSelectedSector: true,
      );
    }
  }

  void selectSectorSlice(String sector) {
    if (state.selectedSector == sector) {
      state = state.copyWith(clearSelectedSector: true);
    } else {
      state = state.copyWith(
        selectedSector: sector,
        clearSelectedTicker: true,
      );
    }
  }

  void clearFilters() {
    state = state.copyWith(
      clearSelectedTicker: true,
      clearSelectedSector: true,
    );
  }

  void setSortCriteria(AllocationSortCriteria criteria) {
    if (state.sortCriteria == criteria) {
      state = state.copyWith(isAscending: !state.isAscending);
    } else {
      state = state.copyWith(sortCriteria: criteria, isAscending: false);
    }
  }

  void inspectPosition(HoldingPosition? position) {
    if (position == null) {
      state = state.copyWith(clearInspectedPosition: true);
    } else {
      state = state.copyWith(inspectedPosition: position);
    }
  }
}

final allocationViewModelProvider =
    NotifierProvider<AllocationViewModel, AllocationState>(
  AllocationViewModel.new,
);

final filteredHoldingsProvider = Provider<List<HoldingPosition>>((ref) {
  final holdings = ref.watch(holdingsProvider);
  final allocState = ref.watch(allocationViewModelProvider);

  List<HoldingPosition> list = List.from(holdings);

  // Filter
  if (allocState.selectedTicker != null) {
    list = list.where((p) => p.symbol == allocState.selectedTicker).toList();
  } else if (allocState.selectedSector != null) {
    list = list.where((p) => p.sector == allocState.selectedSector).toList();
  }

  // Sort
  list.sort((a, b) {
    int cmp;
    switch (allocState.sortCriteria) {
      case AllocationSortCriteria.marketValue:
        cmp = a.totalMarketValue.compareTo(b.totalMarketValue);
      case AllocationSortCriteria.profitDollar:
        cmp = a.unrealizedProfitLoss.compareTo(b.unrealizedProfitLoss);
      case AllocationSortCriteria.returnPercentage:
        cmp = a.unrealizedReturnPercentage.compareTo(b.unrealizedReturnPercentage);
      case AllocationSortCriteria.symbol:
        cmp = a.symbol.compareTo(b.symbol);
    }
    return allocState.isAscending ? cmp : -cmp;
  });

  return list;
});
