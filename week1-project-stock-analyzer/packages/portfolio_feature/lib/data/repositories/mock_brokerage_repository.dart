import '../../domain/entities/holding_position.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/brokerage_repository.dart';
import '../datasources/local_portfolio_storage.dart';

class MockBrokerageRepository implements IBrokerageRepository {
  final LocalPortfolioStorage _storage;

  MockBrokerageRepository({LocalPortfolioStorage? storage})
      : _storage = storage ?? const LocalPortfolioStorage();

  static List<HoldingPosition> get defaultDemoPositions => [
        HoldingPosition(
          id: 'demo_aapl',
          symbol: 'AAPL',
          companyName: 'Apple Inc.',
          shares: 25.0,
          avgCostBasis: 185.20,
          currentPrice: 232.50,
          sector: 'Technology',
          purchaseDate: DateTime(2025, 3, 15),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'demo_msft',
          symbol: 'MSFT',
          companyName: 'Microsoft Corporation',
          shares: 15.0,
          avgCostBasis: 380.00,
          currentPrice: 448.20,
          sector: 'Technology',
          purchaseDate: DateTime(2025, 4, 10),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'demo_nvda',
          symbol: 'NVDA',
          companyName: 'NVIDIA Corporation',
          shares: 40.0,
          avgCostBasis: 88.50,
          currentPrice: 124.80,
          sector: 'Technology',
          purchaseDate: DateTime(2025, 1, 20),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'demo_googl',
          symbol: 'GOOGL',
          companyName: 'Alphabet Inc.',
          shares: 20.0,
          avgCostBasis: 155.00,
          currentPrice: 182.10,
          sector: 'Communication Services',
          purchaseDate: DateTime(2025, 5, 2),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'demo_amzn',
          symbol: 'AMZN',
          companyName: 'Amazon.com, Inc.',
          shares: 30.0,
          avgCostBasis: 168.00,
          currentPrice: 188.40,
          sector: 'Consumer Cyclical',
          purchaseDate: DateTime(2025, 2, 14),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'demo_tsla',
          symbol: 'TSLA',
          companyName: 'Tesla, Inc.',
          shares: 18.0,
          avgCostBasis: 215.00,
          currentPrice: 254.30,
          sector: 'Consumer Cyclical',
          purchaseDate: DateTime(2025, 6, 8),
          lastUpdated: DateTime.now(),
        ),
      ];

  @override
  bool get isConnectedToLiveBrokerage => false;

  @override
  Future<Result<List<HoldingPosition>>> fetchHoldings() async {
    try {
      final stored = await _storage.loadPositions();
      return Success(stored);
    } catch (e, st) {
      return Failure('Failed to load stored holdings: $e', e, st);
    }
  }

  @override
  Future<Result<PortfolioSummary>> fetchPortfolioSummary() async {
    try {
      final holdingsResult = await fetchHoldings();
      if (holdingsResult is Success<List<HoldingPosition>>) {
        return Success(PortfolioSummary.fromHoldings(holdingsResult.data));
      } else {
        return Failure(holdingsResult.errorOrNull ?? 'Failed to compute portfolio summary');
      }
    } catch (e, st) {
      return Failure('Summary calculation error: $e', e, st);
    }
  }

  @override
  Future<Result<void>> saveCustomPositions(List<HoldingPosition> positions) async {
    try {
      await _storage.savePositions(positions);
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to persist positions: $e', e, st);
    }
  }

  @override
  Future<Result<void>> clearPortfolio() async {
    try {
      await _storage.clearAll();
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to clear portfolio: $e', e, st);
    }
  }

  @override
  Future<Result<List<HoldingPosition>>> generateDemoPortfolio() async {
    try {
      final demo = defaultDemoPositions;
      await _storage.savePositions(demo);
      return Success(demo);
    } catch (e, st) {
      return Failure('Failed to generate demo portfolio: $e', e, st);
    }
  }

  @override
  Future<Result<bool>> connectBrokerageAccount({required String authToken}) async {
    // Phase 2 stub interface: In MVP mock mode, informs user of mock status
    return const Success(false);
  }
}
