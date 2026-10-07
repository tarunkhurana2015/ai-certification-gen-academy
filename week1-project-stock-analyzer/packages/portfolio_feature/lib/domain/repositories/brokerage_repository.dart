import '../entities/holding_position.dart';
import '../entities/investment_transaction.dart';
import '../entities/portfolio_summary.dart';
import '../entities/result.dart';

abstract interface class IBrokerageRepository {
  Future<Result<List<HoldingPosition>>> fetchHoldings();
  Future<Result<PortfolioSummary>> fetchPortfolioSummary();
  Future<Result<List<InvestmentTransaction>>> fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Result<void>> saveCustomPositions(List<HoldingPosition> positions);
  Future<Result<void>> clearPortfolio();
  Future<Result<List<HoldingPosition>>> generateDemoPortfolio();
  Future<Result<bool>> connectBrokerageAccount({
    required String authToken,
    String? clientId,
    String? secret,
    String? accountIdentifier,
    String? institutionName,
    String environment = 'sandbox',
    bool isSandbox = false,
  });
  Future<Result<void>> disconnectBrokerageAccount();
  bool get isConnectedToLiveBrokerage;
  String? get accountIdentifier;
  String? get institutionName;
  bool get isSandboxMode;
  DateTime? get lastSyncTime;
}
