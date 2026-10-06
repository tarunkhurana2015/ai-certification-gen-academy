import 'package:flutter/foundation.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import '../../domain/entities/sector_allocation.dart';

enum AllocationSortCriteria {
  marketValue,
  profitDollar,
  returnPercentage,
  symbol,
}

@immutable
class AllocationState {
  final List<SectorAllocation> sectorAllocations;
  final String? selectedTicker;
  final String? selectedSector;
  final AllocationSortCriteria sortCriteria;
  final bool isAscending;
  final HoldingPosition? inspectedPosition;

  const AllocationState({
    this.sectorAllocations = const [],
    this.selectedTicker,
    this.selectedSector,
    this.sortCriteria = AllocationSortCriteria.marketValue,
    this.isAscending = false,
    this.inspectedPosition,
  });

  AllocationState copyWith({
    List<SectorAllocation>? sectorAllocations,
    String? selectedTicker,
    bool clearSelectedTicker = false,
    String? selectedSector,
    bool clearSelectedSector = false,
    AllocationSortCriteria? sortCriteria,
    bool? isAscending,
    HoldingPosition? inspectedPosition,
    bool clearInspectedPosition = false,
  }) {
    return AllocationState(
      sectorAllocations: sectorAllocations ?? this.sectorAllocations,
      selectedTicker: clearSelectedTicker ? null : (selectedTicker ?? this.selectedTicker),
      selectedSector: clearSelectedSector ? null : (selectedSector ?? this.selectedSector),
      sortCriteria: sortCriteria ?? this.sortCriteria,
      isAscending: isAscending ?? this.isAscending,
      inspectedPosition: clearInspectedPosition ? null : (inspectedPosition ?? this.inspectedPosition),
    );
  }
}
