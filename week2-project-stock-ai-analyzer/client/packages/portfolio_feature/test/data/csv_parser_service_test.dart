import 'dart:io';
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

    test('parses optional Company, Sector, and CurrentPrice columns when provided', () {
      const csv = '''
Symbol,Company,Shares,Price,Date,Sector,CurrentPrice
LLY,Eli Lilly and Company,8,740.00,2024-01-12,Healthcare,895.00
CAT,Caterpillar Inc.,12,320.00,2024-01-30,Industrials,392.00
''';
      final result = parser.parseCsvString(csv);

      expect(result.validPositions.length, 2);
      expect(result.errors.isEmpty, true);
      expect(result.validPositions[0].symbol, 'LLY');
      expect(result.validPositions[0].companyName, 'Eli Lilly and Company');
      expect(result.validPositions[0].sector, 'Healthcare');
      expect(result.validPositions[0].currentPrice, 895.00);
      expect(result.validPositions[1].symbol, 'CAT');
      expect(result.validPositions[1].companyName, 'Caterpillar Inc.');
      expect(result.validPositions[1].sector, 'Industrials');
      expect(result.validPositions[1].currentPrice, 392.00);
    });

    test('parses sample_portfolio_50_stocks.csv with all 50 stocks and multiple sectors', () {
      final file = File('../../sample_portfolio_50_stocks.csv');
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final result = parser.parseCsvString(content);

        expect(result.validPositions.length, 50);
        expect(result.errors.isEmpty, true);
        expect(result.totalRowsProcessed, 50);

        // Verify sectors are properly distributed across multiple categories
        final sectors = result.validPositions.map((p) => p.sector).toSet();
        expect(sectors.length, greaterThanOrEqualTo(10));
        expect(sectors.contains('Technology'), true);
        expect(sectors.contains('Healthcare'), true);
        expect(sectors.contains('Financial Services'), true);
        expect(sectors.contains('Consumer Cyclical'), true);
        expect(sectors.contains('Energy'), true);
        expect(sectors.contains('Industrials'), true);
        expect(sectors.contains('Consumer Defensive'), true);
        expect(sectors.contains('Utilities'), true);
        expect(sectors.contains('Real Estate'), true);
        expect(sectors.contains('Basic Materials'), true);
      }
    });

    test('parses sample_portfolio_50_stocks_simple.csv with 4 columns into 50 valid positions', () {
      final file = File('../../sample_portfolio_50_stocks_simple.csv');
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final result = parser.parseCsvString(content);

        expect(result.validPositions.length, 50);
        expect(result.errors.isEmpty, true);
        expect(result.totalRowsProcessed, 50);

        // Even with 4 columns, internal mappings should resolve sectors
        final sectors = result.validPositions.map((p) => p.sector).toSet();
        expect(sectors.length, greaterThanOrEqualTo(10));
      }
    });

    test('returns empty result on empty input', () {
      final result = parser.parseCsvString('');
      expect(result.validPositions.isEmpty, true);
      expect(result.errors.isEmpty, true);
      expect(result.totalRowsProcessed, 0);
    });
  });
}


