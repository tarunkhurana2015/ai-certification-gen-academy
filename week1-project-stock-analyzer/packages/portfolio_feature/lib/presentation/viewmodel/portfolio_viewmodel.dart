import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/holding_position.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/brokerage_repository.dart';
import '../../data/datasources/csv_parser_service.dart';
import '../../data/repositories/mock_brokerage_repository.dart';
import '../state/portfolio_state.dart';

final brokerageRepositoryProvider = Provider<IBrokerageRepository>((ref) {
  return MockBrokerageRepository();
});

final csvParserServiceProvider = Provider<ICsvParserService>((ref) {
  return const CsvParserService();
});

class PortfolioViewModel extends Notifier<PortfolioState> {
  late final IBrokerageRepository _repository;
  late final ICsvParserService _csvParser;

  @override
  PortfolioState build() {
    _repository = ref.watch(brokerageRepositoryProvider);
    _csvParser = ref.watch(csvParserServiceProvider);

    final emptySummary = PortfolioSummary.fromHoldings(const []);
    state = PortfolioState(summary: emptySummary, isLoading: true);

    // Initial async hydration
    Future.microtask(() => loadInitialHoldings());

    return state;
  }

  Future<void> loadInitialHoldings() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    final result = await _repository.fetchHoldings();
    if (result is Success<List<HoldingPosition>>) {
      final summary = PortfolioSummary.fromHoldings(result.data);
      state = state.copyWith(
        holdings: result.data,
        summary: summary,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorOrNull ?? 'Failed to load portfolio',
      );
    }
  }

  Future<void> loadDemoPortfolio() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    final result = await _repository.generateDemoPortfolio();
    if (result is Success<List<HoldingPosition>>) {
      final summary = PortfolioSummary.fromHoldings(result.data);
      state = state.copyWith(
        holdings: result.data,
        summary: summary,
        isLoading: false,
        successMessage: 'Successfully loaded demo tech portfolio!',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorOrNull ?? 'Failed to generate demo portfolio',
      );
    }
  }

  void processRawCsv(String rawCsv) {
    state = state.copyWith(clearMessages: true);
    final parseResult = _csvParser.parseCsvString(rawCsv);
    if (!parseResult.hasValidPositions && parseResult.hasErrors) {
      state = state.copyWith(
        pendingCsvResult: parseResult,
        errorMessage: 'CSV file contains format errors. Review preview.',
      );
    } else if (!parseResult.hasValidPositions && !parseResult.hasErrors) {
      state = state.copyWith(
        errorMessage: 'CSV file appears empty or contains no recognized data.',
      );
    } else {
      state = state.copyWith(pendingCsvResult: parseResult);
    }
  }

  Future<void> confirmPendingCsvImport({bool validOnly = true}) async {
    final pending = state.pendingCsvResult;
    if (pending == null || pending.validPositions.isEmpty) {
      state = state.copyWith(
        clearPendingCsv: true,
        errorMessage: 'No valid positions to import',
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    // Merge strategy: combine existing positions with newly imported positions
    final Map<String, HoldingPosition> positionMap = {};
    for (final pos in state.holdings) {
      positionMap[pos.symbol] = pos;
    }

    for (final newPos in pending.validPositions) {
      if (positionMap.containsKey(newPos.symbol)) {
        // Weighted average cost basis calculation
        final existing = positionMap[newPos.symbol]!;
        final totalShares = existing.shares + newPos.shares;
        final totalCost = existing.totalCost + newPos.totalCost;
        final weightedCost = totalShares > 0 ? totalCost / totalShares : newPos.avgCostBasis;

        positionMap[newPos.symbol] = existing.copyWith(
          shares: totalShares,
          avgCostBasis: weightedCost,
          lastUpdated: DateTime.now(),
        );
      } else {
        positionMap[newPos.symbol] = newPos;
      }
    }

    final updatedList = positionMap.values.toList();
    final saveResult = await _repository.saveCustomPositions(updatedList);

    if (saveResult is Success) {
      final summary = PortfolioSummary.fromHoldings(updatedList);
      state = state.copyWith(
        holdings: updatedList,
        summary: summary,
        isLoading: false,
        clearPendingCsv: true,
        successMessage: 'Successfully imported ${pending.validPositions.length} positions!',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        clearPendingCsv: true,
        errorMessage: saveResult.errorOrNull ?? 'Failed to save imported positions',
      );
    }
  }

  void dismissPendingCsv() {
    state = state.copyWith(clearPendingCsv: true);
  }

  Future<void> addOrUpdatePosition(HoldingPosition position) async {
    final List<HoldingPosition> current = List.from(state.holdings);
    final index = current.indexWhere((p) => p.symbol == position.symbol);

    if (index >= 0) {
      current[index] = position;
    } else {
      current.add(position);
    }

    state = state.copyWith(isLoading: true, clearMessages: true);
    final saveResult = await _repository.saveCustomPositions(current);
    if (saveResult is Success) {
      final summary = PortfolioSummary.fromHoldings(current);
      state = state.copyWith(
        holdings: current,
        summary: summary,
        isLoading: false,
        successMessage: 'Position for ${position.symbol} saved!',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: saveResult.errorOrNull ?? 'Failed to save position',
      );
    }
  }

  Future<void> deletePosition(String id) async {
    final updated = state.holdings.where((p) => p.id != id).toList();
    state = state.copyWith(isLoading: true, clearMessages: true);
    final saveResult = await _repository.saveCustomPositions(updated);
    if (saveResult is Success) {
      final summary = PortfolioSummary.fromHoldings(updated);
      state = state.copyWith(
        holdings: updated,
        summary: summary,
        isLoading: false,
        successMessage: 'Position removed',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: saveResult.errorOrNull ?? 'Failed to delete position',
      );
    }
  }

  Future<void> clearPortfolio() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    final result = await _repository.clearPortfolio();
    if (result is Success) {
      final emptySummary = PortfolioSummary.fromHoldings(const []);
      state = state.copyWith(
        holdings: const [],
        summary: emptySummary,
        isLoading: false,
        successMessage: 'Portfolio cleared',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorOrNull ?? 'Failed to clear portfolio',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }
}

final portfolioViewModelProvider =
    NotifierProvider<PortfolioViewModel, PortfolioState>(
  PortfolioViewModel.new,
);

final holdingsProvider = Provider<List<HoldingPosition>>((ref) {
  return ref.watch(portfolioViewModelProvider).holdings;
});

final portfolioSummaryProvider = Provider<PortfolioSummary>((ref) {
  return ref.watch(portfolioViewModelProvider).summary;
});
