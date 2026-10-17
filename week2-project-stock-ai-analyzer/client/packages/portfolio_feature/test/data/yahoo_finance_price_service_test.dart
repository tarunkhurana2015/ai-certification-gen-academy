import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:portfolio_feature/domain/entities/result.dart';
import 'package:portfolio_feature/domain/entities/stock_quote.dart';
import 'package:portfolio_feature/data/datasources/yahoo_finance_price_service.dart';

void main() {
  group('StockQuote Model', () {
    test('fromYahooChartMeta parses valid response metadata correctly', () {
      final meta = {
        'symbol': 'AAPL',
        'regularMarketPrice': 242.50,
        'chartPreviousClose': 240.00,
        'regularMarketChangePercent': 1.04,
        'currency': 'USD',
        'regularMarketTime': 1728240000,
      };

      final quote = StockQuote.fromYahooChartMeta(meta);

      expect(quote.symbol, 'AAPL');
      expect(quote.price, 242.50);
      expect(quote.previousClose, 240.00);
      expect(quote.change, closeTo(2.50, 0.001));
      expect(quote.changePercent, 1.04);
      expect(quote.currency, 'USD');
      expect(quote.timestamp.year, 2024);
    });

    test('toJson and equality', () {
      final quote = StockQuote(
        symbol: 'MSFT',
        price: 430.25,
        previousClose: 425.0,
        change: 5.25,
        changePercent: 1.23,
        currency: 'USD',
        timestamp: DateTime(2025, 1, 1),
      );

      final json = quote.toJson();
      expect(json['symbol'], 'MSFT');
      expect(json['price'], 430.25);
      expect(json['previous_close'], 425.0);

      final identicalQuote = StockQuote(
        symbol: 'MSFT',
        price: 430.25,
        timestamp: DateTime(2025, 1, 1),
      );
      expect(quote, equals(identicalQuote));
    });
  });

  group('YahooFinancePriceService', () {
    test('fetchQuote returns Success<StockQuote> on 200 response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('NVDA'));
        expect(request.headers['User-Agent'], isNotEmpty);

        final mockBody = jsonEncode({
          'chart': {
            'result': [
              {
                'meta': {
                  'symbol': 'NVDA',
                  'regularMarketPrice': 135.50,
                  'chartPreviousClose': 130.00,
                  'regularMarketChangePercent': 4.23,
                  'currency': 'USD',
                  'regularMarketTime': 1728240000,
                }
              }
            ],
            'error': null,
          }
        });

        return http.Response(mockBody, 200);
      });

      final service = YahooFinancePriceService(client: mockClient);
      final result = await service.fetchQuote('nvda');

      expect(result, isA<Success<StockQuote>>());
      final quote = (result as Success<StockQuote>).data;
      expect(quote.symbol, 'NVDA');
      expect(quote.price, 135.50);
      expect(quote.changePercent, 4.23);
    });

    test('fetchQuote returns Failure on 404 or non-200 HTTP code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = YahooFinancePriceService(client: mockClient);
      final result = await service.fetchQuote('INVALIDTICKER');

      expect(result, isA<Failure<StockQuote>>());
      expect(result.errorOrNull, contains('HTTP 404'));
    });

    test('fetchQuote handles API error payload gracefully', () async {
      final mockClient = MockClient((request) async {
        final mockBody = jsonEncode({
          'chart': {
            'result': null,
            'error': {
              'code': 'Not Found',
              'description': 'No data found for symbol XYZ',
            }
          }
        });
        return http.Response(mockBody, 200);
      });

      final service = YahooFinancePriceService(client: mockClient);
      final result = await service.fetchQuote('XYZ');

      expect(result, isA<Failure<StockQuote>>());
      expect(result.errorOrNull, contains('No data found for symbol XYZ'));
    });

    test('fetchBatchQuotes returns mapped quotes for multiple tickers', () async {
      final mockClient = MockClient((request) async {
        final symbol = request.url.pathSegments.last;
        final price = symbol == 'AAPL' ? 240.0 : (symbol == 'GOOGL' ? 180.0 : 100.0);

        final mockBody = jsonEncode({
          'chart': {
            'result': [
              {
                'meta': {
                  'symbol': symbol,
                  'regularMarketPrice': price,
                  'chartPreviousClose': price - 2.0,
                  'regularMarketChangePercent': 1.0,
                  'currency': 'USD',
                  'regularMarketTime': 1728240000,
                }
              }
            ],
            'error': null,
          }
        });

        return http.Response(mockBody, 200);
      });

      final service = YahooFinancePriceService(client: mockClient);
      final quotes = await service.fetchBatchQuotes(['AAPL', 'GOOGL']);

      expect(quotes.length, 2);
      expect(quotes['AAPL']?.price, 240.0);
      expect(quotes['GOOGL']?.price, 180.0);
    });

    test('getPriceStream emits periodic quotes', () async {
      final mockClient = MockClient((request) async {
        final mockBody = jsonEncode({
          'chart': {
            'result': [
              {
                'meta': {
                  'symbol': 'TSLA',
                  'regularMarketPrice': 250.0,
                  'chartPreviousClose': 245.0,
                  'regularMarketChangePercent': 2.04,
                  'currency': 'USD',
                  'regularMarketTime': 1728240000,
                }
              }
            ],
            'error': null,
          }
        });
        return http.Response(mockBody, 200);
      });

      final service = YahooFinancePriceService(client: mockClient);
      final stream = service.getPriceStream(
        symbolsProvider: () => ['TSLA'],
        interval: const Duration(milliseconds: 50),
      );

      // Take first emitted value
      final firstEmission = await stream.first;
      expect(firstEmission.containsKey('TSLA'), true);
      expect(firstEmission['TSLA']?.price, 250.0);
    });
  });
}
