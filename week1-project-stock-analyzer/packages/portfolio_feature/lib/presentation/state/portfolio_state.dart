import 'package:flutter/foundation.dart';
import '../../domain/entities/holding_position.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/csv_parse_result.dart';

@immutable
class PortfolioState {
  final List<HoldingPosition> holdings;
  final PortfolioSummary summary;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final CsvParseResult? pendingCsvResult;

  const PortfolioState({
    this.holdings = const [],
    required this.summary,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.pendingCsvResult,
  });

  bool get isEmpty => holdings.isEmpty;

  PortfolioState copyWith({
    List<HoldingPosition>? holdings,
    PortfolioSummary? summary,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    CsvParseResult? pendingCsvResult,
    bool clearPendingCsv = false,
    bool clearMessages = false,
  }) {
    return PortfolioState(
      holdings: holdings ?? this.holdings,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      pendingCsvResult: clearPendingCsv ? null : (pendingCsvResult ?? this.pendingCsvResult),
    );
  }
}
