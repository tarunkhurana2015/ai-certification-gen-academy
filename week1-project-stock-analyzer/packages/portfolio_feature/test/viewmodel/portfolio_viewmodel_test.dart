import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_feature/portfolio_feature.dart';

class FakeStockPriceService implements IStockPriceService {
  Map<String, StockQuote> _batchQuotes = {};
  final StreamController<Map<String, StockQuote>> _streamController =
      StreamController<Map<String, StockQuote>>.broadcast();

  void setBatchQuotes(Map<String, StockQuote> quotes) {
    _batchQuotes = Map.from(quotes);
  }

  void emitQuotes(Map<String, StockQuote> quotes) {
    _streamController.add(quotes);
  }

  void dispose() {
    _streamController.close();
  }

  @override
  Future<Result<StockQuote>> fetchQuote(String symbol) async {
    final quote = _batchQuotes[symbol.toUpperCase()];
    if (quote != null) {
      return Success(quote);
    }
    return Failure('No quote for $symbol');
  }

  @override
  Future<Map<String, StockQuote>> fetchBatchQuotes(List<String> symbols) async {
    final Map<String, StockQuote> result = {};
    for (final s in symbols) {
      final q = _batchQuotes[s.toUpperCase()];
      if (q != null) result[s.toUpperCase()] = q;
    }
    return result;
  }

  @override
  Stream<Map<String, StockQuote>> getPriceStream({
    required List<String> Function() symbolsProvider,
    Duration interval = const Duration(seconds: 10),
  }) {
    return _streamController.stream;
  }
}

class FakeBrokerageRepository implements IBrokerageRepository {
  List<HoldingPosition> _holdings = [];
  bool _connected = false;
  String? _accountIdentifier;
  String? _institutionName;
  bool _isSandbox = false;
  DateTime? _lastSync;

  @override
  bool get isConnectedToLiveBrokerage => _connected;

  @override
  String? get accountIdentifier => _accountIdentifier;

  @override
  String? get institutionName => _institutionName;

  @override
  bool get isSandboxMode => _isSandbox;

  @override
  DateTime? get lastSyncTime => _lastSync;

  @override
  Future<Result<List<HoldingPosition>>> fetchHoldings() async => Success(_holdings);

  @override
  Future<Result<PortfolioSummary>> fetchPortfolioSummary() async =>
      Success(PortfolioSummary.fromHoldings(_holdings));

  @override
  Future<Result<void>> saveCustomPositions(List<HoldingPosition> positions) async {
    _holdings = List.from(positions);
    return const Success(null);
  }

  @override
  Future<Result<void>> clearPortfolio() async {
    _holdings = [];
    return const Success(null);
  }

  @override
  Future<Result<List<HoldingPosition>>> generateDemoPortfolio() async {
    _holdings = MockBrokerageRepository.defaultDemoPositions;
    return Success(_holdings);
  }

  @override
  Future<Result<List<InvestmentTransaction>>> fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return Success(PlaidBrokerageAdapter.simulatedPlaidTransactions);
  }

  @override
  Future<Result<bool>> connectBrokerageAccount({
    required String authToken,
    String? clientId,
    String? secret,
    String? accountIdentifier,
    String? institutionName,
    String environment = 'sandbox',
    bool isSandbox = false,
  }) async {
    _connected = true;
    _accountIdentifier = accountIdentifier ?? 'PLD-TEST-001';
    _institutionName = institutionName ?? 'First Platypus Bank';
    _isSandbox = isSandbox;
    _lastSync = DateTime.now();
    _holdings = PlaidBrokerageAdapter.simulatedPlaidHoldings;
    return const Success(true);
  }

  @override
  Future<Result<void>> disconnectBrokerageAccount() async {
    _connected = false;
    _accountIdentifier = null;
    _institutionName = null;
    _lastSync = null;
    return const Success(null);
  }
}

void main() {
  group('PortfolioViewModel (Gherkin Scenario 1.1 & Operations)', () {
    late FakeBrokerageRepository fakeRepo;
    late FakeStockPriceService fakePriceService;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeBrokerageRepository();
      fakePriceService = FakeStockPriceService();
      container = ProviderContainer(
        overrides: [
          brokerageRepositoryProvider.overrideWithValue(fakeRepo),
          stockPriceServiceProvider.overrideWithValue(fakePriceService),
        ],
      );
    });

    tearDown(() {
      fakePriceService.dispose();
      container.dispose();
    });

    test('initial state begins loading then resolves empty portfolio', () async {
      final state = container.read(portfolioViewModelProvider);
      expect(state.holdings.isEmpty, true);
    });

    test('loadDemoPortfolio populates 6 diversified positions and updates summary', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      await notifier.loadDemoPortfolio();

      final state = container.read(portfolioViewModelProvider);
      expect(state.holdings.length, 6);
      expect(state.summary.totalHoldingsCount, 6);
      expect(state.summary.totalInvested, greaterThan(0));
      expect(state.summary.currentValuation, greaterThan(0));
      expect(state.successMessage, contains('demo'));
    });

    test('addOrUpdatePosition adds new position or updates existing', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      final newPos = HoldingPosition(
        id: 'pos_1',
        symbol: 'NVDA',
        companyName: 'NVIDIA Corporation',
        shares: 10.0,
        avgCostBasis: 120.0,
        currentPrice: 130.0,
        sector: 'Technology',
        purchaseDate: DateTime(2026, 1, 1),
        lastUpdated: DateTime.now(),
      );

      await notifier.addOrUpdatePosition(newPos);
      var state = container.read(portfolioViewModelProvider);
      expect(state.holdings.length, 1);
      expect(state.holdings.first.symbol, 'NVDA');

      // Update position
      final updatedPos = newPos.copyWith(shares: 20.0);
      await notifier.addOrUpdatePosition(updatedPos);
      state = container.read(portfolioViewModelProvider);
      expect(state.holdings.length, 1);
      expect(state.holdings.first.shares, 20.0);
    });

    test('deletePosition removes holding', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      await notifier.loadDemoPortfolio();
      var state = container.read(portfolioViewModelProvider);
      expect(state.holdings.length, 6);

      final firstId = state.holdings.first.id;
      await notifier.deletePosition(firstId);
      state = container.read(portfolioViewModelProvider);
      expect(state.holdings.length, 5);
      expect(state.holdings.any((p) => p.id == firstId), false);
    });

    test('clearPortfolio resets all positions', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      await notifier.loadDemoPortfolio();
      await notifier.clearPortfolio();

      final state = container.read(portfolioViewModelProvider);
      expect(state.holdings.isEmpty, true);
      expect(state.summary.totalInvested, 0.0);
    });

    test('connectPlaid links account and populates live positions', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      final success = await notifier.connectPlaid(
        authToken: 'test_token',
        accountIdentifier: 'my_plaid_account',
        institutionName: 'First Platypus Bank',
        isSandbox: true,
      );

      expect(success, true);
      final state = container.read(portfolioViewModelProvider);
      expect(state.isBrokerageConnected, true);
      expect(state.brokerageAccountName, 'my_plaid_account');
      expect(state.brokerageInstitution, 'First Platypus Bank');
      expect(state.isBrokerageSandbox, true);
      expect(state.holdings.length, 6);
      expect(state.holdings.any((h) => h.symbol == 'VOO'), true);
      expect(state.successMessage, contains('Connected to First Platypus Bank'));
    });

    test('syncPlaid refreshes positions', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      await notifier.connectPlaid(
        authToken: 'test_token',
        institutionName: 'First Platypus Bank',
        isSandbox: true,
      );
      await notifier.syncPlaid();

      final state = container.read(portfolioViewModelProvider);
      expect(state.isBrokerageConnected, true);
      expect(state.successMessage, contains('updated'));
    });

    test('disconnectPlaid unlinks account', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      await notifier.connectPlaid(
        authToken: 'test_token',
        isSandbox: true,
      );
      await notifier.disconnectPlaid(clearPositions: true);

      final state = container.read(portfolioViewModelProvider);
      expect(state.isBrokerageConnected, false);
      expect(state.holdings.isEmpty, true);
      expect(state.brokerageAccountName, isNull);
    });

    test('startLivePrices starts stream and updates holdings currentPrice and summary', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      await notifier.loadDemoPortfolio();
      var state = container.read(portfolioViewModelProvider);
      expect(state.holdings.isNotEmpty, true);
      final initialValuation = state.summary.currentValuation;

      notifier.startLivePrices();
      state = container.read(portfolioViewModelProvider);
      expect(state.isLivePriceStreaming, true);

      // Emit new quote for AAPL
      fakePriceService.emitQuotes({
        'AAPL': StockQuote(
          symbol: 'AAPL',
          price: 500.0,
          timestamp: DateTime.now(),
        ),
      });

      await Future.delayed(Duration.zero);
      state = container.read(portfolioViewModelProvider);
      final aapl = state.holdings.firstWhere((h) => h.symbol == 'AAPL');
      expect(aapl.currentPrice, 500.0);
      expect(state.summary.currentValuation, isNot(equals(initialValuation)));
      expect(state.lastPriceUpdate, isNotNull);
      expect(state.livePriceStatus, contains('Updated 1 tickers'));
    });

    test('stopLivePrices and toggleLivePrices control streaming state', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      await notifier.loadDemoPortfolio();

      notifier.startLivePrices();
      expect(container.read(portfolioViewModelProvider).isLivePriceStreaming, true);

      notifier.stopLivePrices();
      expect(container.read(portfolioViewModelProvider).isLivePriceStreaming, false);
      expect(container.read(portfolioViewModelProvider).livePriceStatus, 'Live stream paused');

      notifier.toggleLivePrices();
      expect(container.read(portfolioViewModelProvider).isLivePriceStreaming, true);

      notifier.toggleLivePrices();
      expect(container.read(portfolioViewModelProvider).isLivePriceStreaming, false);
    });

    test('refreshLivePrices updates quotes via one-time batch fetch', () async {
      final notifier = container.read(portfolioViewModelProvider.notifier);
      await notifier.loadDemoPortfolio();

      fakePriceService.setBatchQuotes({
        'MSFT': StockQuote(
          symbol: 'MSFT',
          price: 600.0,
          timestamp: DateTime.now(),
        ),
      });

      await notifier.refreshLivePrices();

      final state = container.read(portfolioViewModelProvider);
      final msft = state.holdings.firstWhere((h) => h.symbol == 'MSFT');
      expect(msft.currentPrice, 600.0);
    });
  });
}
