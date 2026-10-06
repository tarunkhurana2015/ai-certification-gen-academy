import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_feature/portfolio_feature.dart';

void main() {
  group('CsvParserService (Gherkin Scenario 1.2 & 1.3)', () {
    const parser = CsvParserService();

    test('parses flexible headers (Symbol, Quantity, Price, Date) into valid positions', () {
      const csv = '''
Symbol,Quantity,Price,Date
AAPL,10,180.50,2026-01-15
MSFT,5,420.00,2026-02-10
''';
      final result = parser.parseCsvString(csv);

      expect(result.validPositions.length, 2);
      expect(result.errors.isEmpty, true);
      expect(result.validPositions[0].symbol, 'AAPL');
      expect(result.validPositions[0].shares, 10.0);
      expect(result.validPositions[0].avgCostBasis, 180.50);
      expect(result.validPositions[1].symbol, 'MSFT');
      expect(result.validPositions[1].shares, 5.0);
    });

    test('parses alternative header aliases (Ticker, Shares, CostBasis)', () {
      const csv = '''
Ticker,Shares,CostBasis
NVDA,50,115.00
GOOGL,15,175.25
''';
      final result = parser.parseCsvString(csv);

      expect(result.validPositions.length, 2);
      expect(result.errors.isEmpty, true);
      expect(result.validPositions[0].symbol, 'NVDA');
      expect(result.validPositions[1].symbol, 'GOOGL');
    });

    test('flags malformed rows with specific errors without unhandled exceptions', () {
      const malformedCsv = '''
Symbol,Shares,CostBasis
,10,150.00
NVDA,-5,120.00
GOOGL,20,invalid_price
''';
      final result = parser.parseCsvString(malformedCsv);

      expect(result.validPositions.isEmpty, true);
      expect(result.errors.length, 3);
      expect(result.errors[0].reason, contains('Missing ticker symbol'));
      expect(result.errors[1].reason, contains('Shares must be greater than zero'));
      expect(result.errors[2].reason, contains('Invalid numerical price'));
    });

    test('returns empty result on empty input', () {
      final result = parser.parseCsvString('');
      expect(result.validPositions.isEmpty, true);
      expect(result.errors.isEmpty, true);
      expect(result.totalRowsProcessed, 0);
    });
  });
}
