import '../entities/holding_position.dart';
import '../entities/portfolio_summary.dart';
import '../entities/result.dart';

abstract interface class IBrokerageRepository {
  Future<Result<List<HoldingPosition>>> fetchHoldings();
  Future<Result<PortfolioSummary>> fetchPortfolioSummary();
  Future<Result<void>> saveCustomPositions(List<HoldingPosition> positions);
  Future<Result<void>> clearPortfolio();
  Future<Result<List<HoldingPosition>>> generateDemoPortfolio();
  Future<Result<bool>> connectBrokerageAccount({required String authToken});
  bool get isConnectedToLiveBrokerage;
}
