import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_feature/portfolio_feature.dart';

class FakeBrokerageRepository implements IBrokerageRepository {
  List<HoldingPosition> _holdings = [];

  @override
  bool get isConnectedToLiveBrokerage => false;

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
  Future<Result<bool>> connectBrokerageAccount({required String authToken}) async =>
      const Success(true);
}

void main() {
  group('PortfolioViewModel (Gherkin Scenario 1.1 & Operations)', () {
    late FakeBrokerageRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeBrokerageRepository();
      container = ProviderContainer(
        overrides: [
          brokerageRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() {
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
  });
}
