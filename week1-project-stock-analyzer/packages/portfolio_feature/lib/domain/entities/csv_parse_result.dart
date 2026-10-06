import 'package:flutter/foundation.dart';
import 'holding_position.dart';

@immutable
class CsvRowError {
  final int lineNumber;
  final String rawContent;
  final String reason;

  const CsvRowError({
    required this.lineNumber,
    required this.rawContent,
    required this.reason,
  });
}

@immutable
class CsvParseResult {
  final List<HoldingPosition> validPositions;
  final List<CsvRowError> errors;
  final int totalRowsProcessed;

  const CsvParseResult({
    required this.validPositions,
    required this.errors,
    required this.totalRowsProcessed,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasValidPositions => validPositions.isNotEmpty;
}
