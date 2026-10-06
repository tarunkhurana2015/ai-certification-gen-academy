import 'package:csv/csv.dart';
import '../../domain/entities/holding_position.dart';
import '../../domain/entities/csv_parse_result.dart';

abstract interface class ICsvParserService {
  CsvParseResult parseCsvString(String rawCsv);
}

class CsvParserService implements ICsvParserService {
  const CsvParserService();

  static const Map<String, String> _companyNames = {
    'AAPL': 'Apple Inc.',
    'MSFT': 'Microsoft Corporation',
    'NVDA': 'NVIDIA Corporation',
    'GOOGL': 'Alphabet Inc.',
    'GOOG': 'Alphabet Inc.',
    'AMZN': 'Amazon.com, Inc.',
    'TSLA': 'Tesla, Inc.',
    'META': 'Meta Platforms, Inc.',
    'JPM': 'JPMorgan Chase & Co.',
    'V': 'Visa Inc.',
    'UNH': 'UnitedHealth Group',
    'XOM': 'Exxon Mobil Corp.',
  };

  static const Map<String, String> _sectors = {
    'AAPL': 'Technology',
    'MSFT': 'Technology',
    'NVDA': 'Technology',
    'GOOGL': 'Communication Services',
    'GOOG': 'Communication Services',
    'AMZN': 'Consumer Cyclical',
    'TSLA': 'Consumer Cyclical',
    'META': 'Communication Services',
    'JPM': 'Financial Services',
    'V': 'Financial Services',
    'UNH': 'Healthcare',
    'XOM': 'Energy',
  };

  static const Map<String, double> _currentPrices = {
    'AAPL': 232.50,
    'MSFT': 448.20,
    'NVDA': 124.80,
    'GOOGL': 182.10,
    'GOOG': 183.40,
    'AMZN': 188.40,
    'TSLA': 254.30,
    'META': 585.00,
    'JPM': 222.00,
    'V': 282.50,
    'UNH': 590.00,
    'XOM': 118.00,
  };

  @override
  CsvParseResult parseCsvString(String rawCsv) {
    if (rawCsv.trim().isEmpty) {
      return const CsvParseResult(
        validPositions: [],
        errors: [],
        totalRowsProcessed: 0,
      );
    }

    final normalized = rawCsv.replaceAll('\r\n', '\n');
    const converter = CsvToListConverter(eol: '\n', shouldParseNumbers: false);
    final rows = converter.convert(normalized);

    if (rows.isEmpty) {
      return const CsvParseResult(
        validPositions: [],
        errors: [],
        totalRowsProcessed: 0,
      );
    }

    // Identify header row
    final headerRow = rows.first.map((cell) => cell.toString().trim().toLowerCase()).toList();
    int symbolCol = -1;
    int sharesCol = -1;
    int priceCol = -1;
    int dateCol = -1;

    for (int i = 0; i < headerRow.length; i++) {
      final h = headerRow[i];
      if (h == 'symbol' || h == 'ticker' || h == 'stock' || h == 'asset') {
        symbolCol = i;
      } else if (h == 'shares' || h == 'quantity' || h == 'qty' || h == 'count') {
        sharesCol = i;
      } else if (h == 'price' || h == 'costbasis' || h == 'cost_basis' || h == 'avgcost' || h == 'purchase_price') {
        priceCol = i;
      } else if (h == 'date' || h == 'purchase_date' || h == 'purchasedate') {
        dateCol = i;
      }
    }

    // Default fallback if headers missing standard names
    if (symbolCol == -1 && headerRow.isNotEmpty) symbolCol = 0;
    if (sharesCol == -1 && headerRow.length > 1) sharesCol = 1;
    if (priceCol == -1 && headerRow.length > 2) priceCol = 2;

    final List<HoldingPosition> valid = [];
    final List<CsvRowError> errors = [];
    int totalProcessed = 0;

    for (int lineIndex = 1; lineIndex < rows.length; lineIndex++) {
      final row = rows[lineIndex];
      if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
        continue;
      }
      totalProcessed++;
      final lineNumber = lineIndex + 1;
      final rawLine = row.join(',');

      if (symbolCol >= row.length || sharesCol >= row.length || priceCol >= row.length) {
        errors.add(CsvRowError(
          lineNumber: lineNumber,
          rawContent: rawLine,
          reason: 'Row has fewer columns than required headers',
        ));
        continue;
      }

      final rawSymbol = row[symbolCol].toString().trim().toUpperCase();
      if (rawSymbol.isEmpty) {
        errors.add(CsvRowError(
          lineNumber: lineNumber,
          rawContent: rawLine,
          reason: 'Missing ticker symbol',
        ));
        continue;
      }

      final rawSharesStr = row[sharesCol].toString().replaceAll('\$', '').replaceAll(',', '').trim();
      final shares = double.tryParse(rawSharesStr);
      if (shares == null) {
        errors.add(CsvRowError(
          lineNumber: lineNumber,
          rawContent: rawLine,
          reason: 'Invalid numerical shares: "$rawSharesStr"',
        ));
        continue;
      }
      if (shares <= 0) {
        errors.add(CsvRowError(
          lineNumber: lineNumber,
          rawContent: rawLine,
          reason: 'Shares must be greater than zero ($shares)',
        ));
        continue;
      }

      final rawPriceStr = row[priceCol].toString().replaceAll('\$', '').replaceAll(',', '').trim();
      final price = double.tryParse(rawPriceStr);
      if (price == null) {
        errors.add(CsvRowError(
          lineNumber: lineNumber,
          rawContent: rawLine,
          reason: 'Invalid numerical price: "$rawPriceStr"',
        ));
        continue;
      }
      if (price <= 0) {
        errors.add(CsvRowError(
          lineNumber: lineNumber,
          rawContent: rawLine,
          reason: 'Price must be greater than zero ($price)',
        ));
        continue;
      }

      DateTime purchaseDate = DateTime.now();
      if (dateCol != -1 && dateCol < row.length) {
        final dateStr = row[dateCol].toString().trim();
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) {
          purchaseDate = parsed;
        }
      }

      final companyName = _companyNames[rawSymbol] ?? '$rawSymbol Corp.';
      final sector = _sectors[rawSymbol] ?? 'Other';
      final currentPrice = _currentPrices[rawSymbol] ?? (price * 1.15); // default simulated gain if unknown

      valid.add(HoldingPosition(
        id: 'csv_${rawSymbol}_$lineNumber',
        symbol: rawSymbol,
        companyName: companyName,
        shares: shares,
        avgCostBasis: price,
        currentPrice: currentPrice,
        sector: sector,
        purchaseDate: purchaseDate,
        lastUpdated: DateTime.now(),
      ));
    }

    return CsvParseResult(
      validPositions: valid,
      errors: errors,
      totalRowsProcessed: totalProcessed,
    );
  }
}
