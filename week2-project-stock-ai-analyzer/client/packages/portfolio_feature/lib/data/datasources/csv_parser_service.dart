import 'package:csv/csv.dart';
import '../../domain/entities/holding_position.dart';
import '../../domain/entities/csv_parse_result.dart';

abstract interface class ICsvParserService {
  CsvParseResult parseCsvString(String rawCsv);
}

class CsvParserService implements ICsvParserService {
  const CsvParserService();

  static const Map<String, String> _companyNames = {
    // Technology
    'AAPL': 'Apple Inc.',
    'MSFT': 'Microsoft Corporation',
    'NVDA': 'NVIDIA Corporation',
    'AVGO': 'Broadcom Inc.',
    'ORCL': 'Oracle Corporation',
    'CRM': 'Salesforce, Inc.',
    'AMD': 'Advanced Micro Devices, Inc.',
    'ADBE': 'Adobe Inc.',
    // Communication Services
    'GOOGL': 'Alphabet Inc. (Class A)',
    'GOOG': 'Alphabet Inc. (Class C)',
    'META': 'Meta Platforms, Inc.',
    'NFLX': 'Netflix, Inc.',
    'DIS': 'The Walt Disney Company',
    'CMCSA': 'Comcast Corporation',
    // Consumer Cyclical
    'AMZN': 'Amazon.com, Inc.',
    'TSLA': 'Tesla, Inc.',
    'HD': 'The Home Depot, Inc.',
    'MCD': "McDonald's Corporation",
    'NKE': 'NIKE, Inc.',
    'SBUX': 'Starbucks Corporation',
    // Financial Services
    'JPM': 'JPMorgan Chase & Co.',
    'V': 'Visa Inc.',
    'MA': 'Mastercard Incorporated',
    'BAC': 'Bank of America Corporation',
    'GS': 'The Goldman Sachs Group, Inc.',
    'MS': 'Morgan Stanley',
    'BLK': 'BlackRock, Inc.',
    // Healthcare
    'LLY': 'Eli Lilly and Company',
    'UNH': 'UnitedHealth Group Incorporated',
    'JNJ': 'Johnson & Johnson',
    'ABBV': 'AbbVie Inc.',
    'MRK': 'Merck & Co., Inc.',
    'TMO': 'Thermo Fisher Scientific Inc.',
    // Industrials
    'CAT': 'Caterpillar Inc.',
    'GE': 'GE Aerospace',
    'HON': 'Honeywell International Inc.',
    'UNP': 'Union Pacific Corporation',
    'BA': 'The Boeing Company',
    // Consumer Defensive
    'WMT': 'Walmart Inc.',
    'PG': 'The Procter & Gamble Company',
    'COST': 'Costco Wholesale Corporation',
    'KO': 'The Coca-Cola Company',
    // Energy
    'XOM': 'Exxon Mobil Corporation',
    'CVX': 'Chevron Corporation',
    'COP': 'ConocoPhillips',
    'SLB': 'SLB (Schlumberger)',
    // Utilities
    'NEE': 'NextEra Energy, Inc.',
    'SO': 'The Southern Company',
    // Real Estate
    'PLD': 'Prologis, Inc.',
    'AMT': 'American Tower Corporation',
    // Basic Materials
    'LIN': 'Linde plc',
  };

  static const Map<String, String> _sectors = {
    // Technology
    'AAPL': 'Technology',
    'MSFT': 'Technology',
    'NVDA': 'Technology',
    'AVGO': 'Technology',
    'ORCL': 'Technology',
    'CRM': 'Technology',
    'AMD': 'Technology',
    'ADBE': 'Technology',
    // Communication Services
    'GOOGL': 'Communication Services',
    'GOOG': 'Communication Services',
    'META': 'Communication Services',
    'NFLX': 'Communication Services',
    'DIS': 'Communication Services',
    'CMCSA': 'Communication Services',
    // Consumer Cyclical
    'AMZN': 'Consumer Cyclical',
    'TSLA': 'Consumer Cyclical',
    'HD': 'Consumer Cyclical',
    'MCD': 'Consumer Cyclical',
    'NKE': 'Consumer Cyclical',
    'SBUX': 'Consumer Cyclical',
    // Financial Services
    'JPM': 'Financial Services',
    'V': 'Financial Services',
    'MA': 'Financial Services',
    'BAC': 'Financial Services',
    'GS': 'Financial Services',
    'MS': 'Financial Services',
    'BLK': 'Financial Services',
    // Healthcare
    'LLY': 'Healthcare',
    'UNH': 'Healthcare',
    'JNJ': 'Healthcare',
    'ABBV': 'Healthcare',
    'MRK': 'Healthcare',
    'TMO': 'Healthcare',
    // Industrials
    'CAT': 'Industrials',
    'GE': 'Industrials',
    'HON': 'Industrials',
    'UNP': 'Industrials',
    'BA': 'Industrials',
    // Consumer Defensive
    'WMT': 'Consumer Defensive',
    'PG': 'Consumer Defensive',
    'COST': 'Consumer Defensive',
    'KO': 'Consumer Defensive',
    // Energy
    'XOM': 'Energy',
    'CVX': 'Energy',
    'COP': 'Energy',
    'SLB': 'Energy',
    // Utilities
    'NEE': 'Utilities',
    'SO': 'Utilities',
    // Real Estate
    'PLD': 'Real Estate',
    'AMT': 'Real Estate',
    // Basic Materials
    'LIN': 'Basic Materials',
  };

  static const Map<String, double> _currentPrices = {
    // Technology
    'AAPL': 232.50,
    'MSFT': 448.20,
    'NVDA': 124.80,
    'AVGO': 168.50,
    'ORCL': 175.00,
    'CRM': 288.50,
    'AMD': 158.20,
    'ADBE': 512.00,
    // Communication Services
    'GOOGL': 182.10,
    'GOOG': 183.40,
    'META': 585.00,
    'NFLX': 710.00,
    'DIS': 96.50,
    'CMCSA': 42.00,
    // Consumer Cyclical
    'AMZN': 188.40,
    'TSLA': 254.30,
    'HD': 412.00,
    'MCD': 302.50,
    'NKE': 83.40,
    'SBUX': 96.50,
    // Financial Services
    'JPM': 222.00,
    'V': 282.50,
    'MA': 496.00,
    'BAC': 42.80,
    'GS': 508.00,
    'MS': 106.50,
    'BLK': 945.00,
    // Healthcare
    'LLY': 895.00,
    'UNH': 590.00,
    'JNJ': 162.50,
    'ABBV': 194.00,
    'MRK': 114.50,
    'TMO': 588.00,
    // Industrials
    'CAT': 392.00,
    'GE': 188.00,
    'HON': 212.00,
    'UNP': 244.00,
    'BA': 154.00,
    // Consumer Defensive
    'WMT': 81.20,
    'PG': 172.50,
    'COST': 915.00,
    'KO': 70.50,
    // Energy
    'XOM': 118.00,
    'CVX': 152.00,
    'COP': 108.50,
    'SLB': 43.50,
    // Utilities
    'NEE': 83.50,
    'SO': 91.00,
    // Real Estate
    'PLD': 124.00,
    'AMT': 228.00,
    // Basic Materials
    'LIN': 465.00,
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
    int nameCol = -1;
    int sectorCol = -1;
    int currentPriceCol = -1;

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
      } else if (h == 'name' || h == 'company' || h == 'company_name' || h == 'companyname') {
        nameCol = i;
      } else if (h == 'sector' || h == 'industry' || h == 'category') {
        sectorCol = i;
      } else if (h == 'currentprice' || h == 'current_price' || h == 'marketprice' || h == 'market_price') {
        currentPriceCol = i;
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

      final companyName = (nameCol != -1 && nameCol < row.length && row[nameCol].toString().trim().isNotEmpty)
          ? row[nameCol].toString().trim()
          : (_companyNames[rawSymbol] ?? '$rawSymbol Corp.');

      final sector = (sectorCol != -1 && sectorCol < row.length && row[sectorCol].toString().trim().isNotEmpty)
          ? row[sectorCol].toString().trim()
          : (_sectors[rawSymbol] ?? 'Other');

      double currentPrice = _currentPrices[rawSymbol] ?? (price * 1.15);
      if (currentPriceCol != -1 && currentPriceCol < row.length) {
        final cpStr = row[currentPriceCol].toString().replaceAll('\$', '').replaceAll(',', '').trim();
        final parsedCp = double.tryParse(cpStr);
        if (parsedCp != null && parsedCp > 0) {
          currentPrice = parsedCp;
        }
      }

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
