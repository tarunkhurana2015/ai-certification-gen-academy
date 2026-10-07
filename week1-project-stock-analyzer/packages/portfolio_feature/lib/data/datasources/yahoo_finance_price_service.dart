import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/result.dart';
import '../../domain/entities/stock_quote.dart';

abstract interface class IStockPriceService {
  Future<Result<StockQuote>> fetchQuote(String symbol);
  Future<Map<String, StockQuote>> fetchBatchQuotes(List<String> symbols);
  Stream<Map<String, StockQuote>> getPriceStream({
    required List<String> Function() symbolsProvider,
    Duration interval,
  });
}

class YahooFinancePriceService implements IStockPriceService {
  final http.Client _client;

  YahooFinancePriceService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart';
  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko)',
    'Accept': 'application/json',
  };

  @override
  Future<Result<StockQuote>> fetchQuote(String symbol) async {
    final cleanSymbol = symbol.trim().toUpperCase();
    if (cleanSymbol.isEmpty) {
      return const Failure('Ticker symbol cannot be empty.');
    }

    final uri = Uri.parse('$_baseUrl/$cleanSymbol?interval=1m&range=1d');

    try {
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        return Failure(
          'Yahoo Finance error for $cleanSymbol (HTTP ${response.statusCode})',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final chart = data['chart'] as Map<String, dynamic>?;
      final results = chart?['result'] as List<dynamic>?;

      if (results == null || results.isEmpty) {
        final error = chart?['error'] as Map<String, dynamic>?;
        final description = error?['description']?.toString() ?? 'No chart data found';
        return Failure('Yahoo Finance API: $description');
      }

      final first = results.first as Map<String, dynamic>;
      final meta = first['meta'] as Map<String, dynamic>?;

      if (meta == null) {
        return Failure('Invalid quote metadata returned for $cleanSymbol');
      }

      final quote = StockQuote.fromYahooChartMeta(meta);
      if (quote.price <= 0) {
        return Failure('Received non-positive price for $cleanSymbol');
      }

      return Success(quote);
    } catch (e, st) {
      return Failure('Network error fetching $cleanSymbol quote: $e', e, st);
    }
  }

  @override
  Future<Map<String, StockQuote>> fetchBatchQuotes(List<String> symbols) async {
    final uniqueSymbols = symbols
        .map((s) => s.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    if (uniqueSymbols.isEmpty) return {};

    final Map<String, StockQuote> quotes = {};
    const batchSize = 5;

    for (int i = 0; i < uniqueSymbols.length; i += batchSize) {
      final end = (i + batchSize).clamp(0, uniqueSymbols.length);
      final batch = uniqueSymbols.sublist(i, end);

      final futures = batch.map((sym) => fetchQuote(sym));
      final batchResults = await Future.wait(futures);

      for (final result in batchResults) {
        if (result is Success<StockQuote>) {
          quotes[result.data.symbol] = result.data;
        }
      }
    }

    return quotes;
  }

  @override
  Stream<Map<String, StockQuote>> getPriceStream({
    required List<String> Function() symbolsProvider,
    Duration interval = const Duration(seconds: 10),
  }) async* {
    while (true) {
      final symbols = symbolsProvider();
      if (symbols.isNotEmpty) {
        final quotes = await fetchBatchQuotes(symbols);
        if (quotes.isNotEmpty) {
          yield quotes;
        }
      }
      await Future.delayed(interval);
    }
  }
}
