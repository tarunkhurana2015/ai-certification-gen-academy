import '../../domain/entities/holding_position.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/brokerage_repository.dart';

/// Phase 2 Brokerage Adapter for Robinhood OAuth & REST sync.
/// Implements [IBrokerageRepository] to allow plug-and-play live syncing
/// without UI refactoring once brokerage API keys are configured.
class RobinhoodBrokerageAdapter implements IBrokerageRepository {
  String? _authToken;

  RobinhoodBrokerageAdapter({String? authToken}) : _authToken = authToken;

  @override
  bool get isConnectedToLiveBrokerage => _authToken != null && _authToken!.isNotEmpty;

  @override
  Future<Result<List<HoldingPosition>>> fetchHoldings() async {
    if (!isConnectedToLiveBrokerage) {
      return const Failure('Robinhood account not linked. Connect via OAuth in Settings.');
    }
    // Phase 2 implementation will call GET https://api.robinhood.com/positions/
    return const Success([]);
  }

  @override
  Future<Result<PortfolioSummary>> fetchPortfolioSummary() async {
    if (!isConnectedToLiveBrokerage) {
      return const Failure('Robinhood account not linked.');
    }
    // Phase 2 implementation will call GET https://api.robinhood.com/portfolios/
    return Success(PortfolioSummary.fromHoldings(const []));
  }

  @override
  Future<Result<void>> saveCustomPositions(List<HoldingPosition> positions) async {
    return const Failure('Modifying live brokerage positions directly is disabled.');
  }

  @override
  Future<Result<void>> clearPortfolio() async {
    return const Failure('Clearing live brokerage positions is disabled.');
  }

  @override
  Future<Result<List<HoldingPosition>>> generateDemoPortfolio() async {
    return const Failure('Demo generation is only available in Mock mode.');
  }

  @override
  Future<Result<bool>> connectBrokerageAccount({required String authToken}) async {
    _authToken = authToken;
    return const Success(true);
  }
}
