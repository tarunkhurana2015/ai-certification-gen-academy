import 'package:flutter/foundation.dart';
import '../../domain/entities/holding_position.dart';
import '../../domain/entities/investment_transaction.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/csv_parse_result.dart';

@immutable
class PortfolioState {
  final List<HoldingPosition> holdings;
  final List<InvestmentTransaction> transactions;
  final PortfolioSummary summary;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final CsvParseResult? pendingCsvResult;
  final bool isBrokerageConnected;
  final String? brokerageAccountName;
  final String? brokerageInstitution;
  final bool isBrokerageSandbox;
  final DateTime? lastBrokerageSync;
  final bool isLivePriceStreaming;
  final DateTime? lastPriceUpdate;
  final String? livePriceStatus;

  const PortfolioState({
    this.holdings = const [],
    this.transactions = const [],
    required this.summary,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.pendingCsvResult,
    this.isBrokerageConnected = false,
    this.brokerageAccountName,
    this.brokerageInstitution,
    this.isBrokerageSandbox = false,
    this.lastBrokerageSync,
    this.isLivePriceStreaming = false,
    this.lastPriceUpdate,
    this.livePriceStatus,
  });

  bool get isEmpty => holdings.isEmpty;

  PortfolioState copyWith({
    List<HoldingPosition>? holdings,
    List<InvestmentTransaction>? transactions,
    PortfolioSummary? summary,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    CsvParseResult? pendingCsvResult,
    bool? isBrokerageConnected,
    String? brokerageAccountName,
    String? brokerageInstitution,
    bool? isBrokerageSandbox,
    DateTime? lastBrokerageSync,
    bool? isLivePriceStreaming,
    DateTime? lastPriceUpdate,
    String? livePriceStatus,
    bool clearPendingCsv = false,
    bool clearMessages = false,
    bool clearBrokerageConnection = false,
  }) {
    return PortfolioState(
      holdings: holdings ?? this.holdings,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      pendingCsvResult: clearPendingCsv ? null : (pendingCsvResult ?? this.pendingCsvResult),
      isBrokerageConnected: clearBrokerageConnection ? false : (isBrokerageConnected ?? this.isBrokerageConnected),
      brokerageAccountName: clearBrokerageConnection ? null : (brokerageAccountName ?? this.brokerageAccountName),
      brokerageInstitution: clearBrokerageConnection ? null : (brokerageInstitution ?? this.brokerageInstitution),
      isBrokerageSandbox: clearBrokerageConnection ? false : (isBrokerageSandbox ?? this.isBrokerageSandbox),
      lastBrokerageSync: clearBrokerageConnection ? null : (lastBrokerageSync ?? this.lastBrokerageSync),
      isLivePriceStreaming: isLivePriceStreaming ?? this.isLivePriceStreaming,
      lastPriceUpdate: lastPriceUpdate ?? this.lastPriceUpdate,
      livePriceStatus: livePriceStatus ?? this.livePriceStatus,
    );
  }
}

