import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/holding_position.dart';
import '../../domain/entities/investment_transaction.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/stock_quote.dart';
import '../../domain/repositories/brokerage_repository.dart';
import '../../data/datasources/csv_parser_service.dart';
import '../../data/datasources/yahoo_finance_price_service.dart';
import '../../data/repositories/plaid_brokerage_adapter.dart';
import '../state/portfolio_state.dart';

final plaidBrokerageAdapterProvider = Provider<PlaidBrokerageAdapter>((ref) {
  return PlaidBrokerageAdapter();
});

final brokerageRepositoryProvider = Provider<IBrokerageRepository>((ref) {
  return ref.watch(plaidBrokerageAdapterProvider);
});

final csvParserServiceProvider = Provider<ICsvParserService>((ref) {
  return const CsvParserService();
});

final stockPriceServiceProvider = Provider<IStockPriceService>((ref) {
  return YahooFinancePriceService();
});

class PortfolioViewModel extends Notifier<PortfolioState> {
  late final IBrokerageRepository _repository;
  late final ICsvParserService _csvParser;
  late final IStockPriceService _priceService;
  StreamSubscription<Map<String, StockQuote>>? _priceSubscription;

  @override
  PortfolioState build() {
    _repository = ref.watch(brokerageRepositoryProvider);
    _csvParser = ref.watch(csvParserServiceProvider);
    _priceService = ref.watch(stockPriceServiceProvider);

    ref.onDispose(() {
      _priceSubscription?.cancel();
    });

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

  Future<bool> connectPlaid({
    required String authToken,
    String? clientId,
    String? secret,
    String? accountIdentifier,
    String? institutionName,
    String environment = 'sandbox',
    bool isSandbox = false,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    final connectResult = await _repository.connectBrokerageAccount(
      authToken: authToken,
      clientId: clientId,
      secret: secret,
      accountIdentifier: accountIdentifier,
      institutionName: institutionName,
      environment: environment,
      isSandbox: isSandbox,
    );

    if (connectResult is Success && (connectResult as Success<bool>).data) {
      final holdingsResult = await _repository.fetchHoldings();
      final txResult = await _repository.fetchTransactions();
      if (holdingsResult is Success<List<HoldingPosition>>) {
        final summary = PortfolioSummary.fromHoldings(holdingsResult.data);
        final txs = (txResult is Success<List<InvestmentTransaction>>)
            ? txResult.data
            : const <InvestmentTransaction>[];
        state = state.copyWith(
          holdings: holdingsResult.data,
          transactions: txs,
          summary: summary,
          isBrokerageConnected: true,
          brokerageAccountName: _repository.accountIdentifier ?? accountIdentifier,
          brokerageInstitution: _repository.institutionName ?? institutionName,
          isBrokerageSandbox: isSandbox,
          lastBrokerageSync: _repository.lastSyncTime ?? DateTime.now(),
          isLoading: false,
          successMessage: 'Connected to ${institutionName ?? _repository.institutionName ?? 'Plaid'}!',
        );
        return true;
      }
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: connectResult.errorOrNull ?? 'Failed to connect Plaid account',
    );
    return false;
  }

  Future<bool> connectPlaidWithCredentials({
    required String clientId,
    required String secret,
    String? publicToken,
    String environment = 'sandbox',
    String? institutionName,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    final adapter = ref.read(plaidBrokerageAdapterProvider);
    final result = await adapter.completePlaidFlow(
      clientId: clientId,
      secret: secret,
      publicToken: publicToken,
      environment: environment,
      institutionName: institutionName,
    );

    if (result is Success<bool> && result.data) {
      final holdingsResult = await adapter.fetchHoldings();
      final txResult = await adapter.fetchTransactions();
      final holdings = (holdingsResult is Success<List<HoldingPosition>>)
          ? holdingsResult.data
          : <HoldingPosition>[];
      final txs = (txResult is Success<List<InvestmentTransaction>>)
          ? txResult.data
          : <InvestmentTransaction>[];

      state = state.copyWith(
        holdings: holdings,
        transactions: txs,
        summary: PortfolioSummary.fromHoldings(holdings),
        isBrokerageConnected: true,
        brokerageAccountName: adapter.accountIdentifier ?? 'Plaid Account',
        brokerageInstitution: adapter.institutionName ?? 'Plaid Institution',
        isBrokerageSandbox: adapter.isSandboxMode,
        lastBrokerageSync: adapter.lastSyncTime ?? DateTime.now(),
        isLoading: false,
        successMessage: 'Connected to ${adapter.institutionName ?? 'Plaid'}!',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorOrNull ?? 'Failed to connect via Plaid.',
      );
      return false;
    }
  }

  Future<void> syncPlaid() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    final result = await _repository.fetchHoldings();
    final txResult = await _repository.fetchTransactions();
    if (result is Success<List<HoldingPosition>>) {
      final summary = PortfolioSummary.fromHoldings(result.data);
      final txs = (txResult is Success<List<InvestmentTransaction>>)
          ? txResult.data
          : state.transactions;
      state = state.copyWith(
        holdings: result.data,
        transactions: txs,
        summary: summary,
        lastBrokerageSync: DateTime.now(),
        isLoading: false,
        successMessage: 'Plaid investment holdings updated!',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorOrNull ?? 'Failed to sync Plaid holdings',
      );
    }
  }

  Future<void> disconnectPlaid({bool clearPositions = false}) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    await _repository.disconnectBrokerageAccount();

    if (clearPositions) {
      await _repository.clearPortfolio();
      final emptySummary = PortfolioSummary.fromHoldings(const []);
      state = state.copyWith(
        holdings: const [],
        transactions: const [],
        summary: emptySummary,
        clearBrokerageConnection: true,
        isLoading: false,
        successMessage: 'Plaid account disconnected and holdings cleared',
      );
    } else {
      state = state.copyWith(
        transactions: const [],
        clearBrokerageConnection: true,
        isLoading: false,
        successMessage: 'Plaid account disconnected',
      );
    }
  }

  void startLivePrices({Duration interval = const Duration(seconds: 10)}) {
    _priceSubscription?.cancel();
    _priceSubscription = null;

    if (state.holdings.isEmpty) {
      state = state.copyWith(
        isLivePriceStreaming: false,
        livePriceStatus: 'No holdings available to stream',
      );
      return;
    }

    state = state.copyWith(
      isLivePriceStreaming: true,
      livePriceStatus: 'Live stream active (every ${interval.inSeconds}s)',
    );

    // Initial fetch immediately
    refreshLivePrices();

    _priceSubscription = _priceService
        .getPriceStream(
          symbolsProvider: () => state.holdings.map((h) => h.symbol).toList(),
          interval: interval,
        )
        .listen(
          (quotes) {
            _applyLiveQuotes(quotes);
          },
          onError: (error) {
            state = state.copyWith(
              livePriceStatus: 'Live stream error: $error',
            );
          },
        );
  }

  void stopLivePrices() {
    _priceSubscription?.cancel();
    _priceSubscription = null;
    state = state.copyWith(
      isLivePriceStreaming: false,
      livePriceStatus: 'Live stream paused',
    );
  }

  void toggleLivePrices({Duration interval = const Duration(seconds: 10)}) {
    if (state.isLivePriceStreaming) {
      stopLivePrices();
    } else {
      startLivePrices(interval: interval);
    }
  }

  Future<void> refreshLivePrices() async {
    final symbols = state.holdings.map((h) => h.symbol).toList();
    if (symbols.isEmpty) {
      state = state.copyWith(livePriceStatus: 'No holdings to update');
      return;
    }

    try {
      final quotes = await _priceService.fetchBatchQuotes(symbols);
      if (quotes.isNotEmpty) {
        _applyLiveQuotes(quotes);
      } else {
        state = state.copyWith(livePriceStatus: 'No quotes received from Yahoo Finance');
      }
    } catch (e) {
      state = state.copyWith(livePriceStatus: 'Failed to refresh prices: $e');
    }
  }

  void _applyLiveQuotes(Map<String, StockQuote> quotes) {
    if (quotes.isEmpty) return;

    final updated = state.holdings.map((pos) {
      final quote = quotes[pos.symbol.toUpperCase()];
      if (quote != null && quote.price > 0) {
        return pos.copyWith(
          currentPrice: quote.price,
          lastUpdated: quote.timestamp,
        );
      }
      return pos;
    }).toList();

    final newSummary = PortfolioSummary.fromHoldings(updated);
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    state = state.copyWith(
      holdings: updated,
      summary: newSummary,
      lastPriceUpdate: now,
      livePriceStatus: 'Updated ${quotes.length} tickers at $timeStr',
    );
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
