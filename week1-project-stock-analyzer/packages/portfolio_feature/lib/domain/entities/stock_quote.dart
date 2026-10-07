import 'package:flutter/foundation.dart';

@immutable
class StockQuote {
  final String symbol;
  final double price;
  final double? previousClose;
  final double? change;
  final double? changePercent;
  final String? currency;
  final DateTime timestamp;

  const StockQuote({
    required this.symbol,
    required this.price,
    this.previousClose,
    this.change,
    this.changePercent,
    this.currency,
    required this.timestamp,
  });

  factory StockQuote.fromYahooChartMeta(Map<String, dynamic> meta) {
    final rawPrice = meta['regularMarketPrice'] ?? meta['fulldayPrice'];
    final price = (rawPrice is num)
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '') ?? 0.0);

    final rawPrev = meta['chartPreviousClose'] ?? meta['previousClose'];
    final prevClose = (rawPrev is num)
        ? rawPrev.toDouble()
        : double.tryParse(rawPrev?.toString() ?? '');

    final rawChangePct = meta['regularMarketChangePercent'];
    final changePercent = (rawChangePct is num)
        ? rawChangePct.toDouble()
        : double.tryParse(rawChangePct?.toString() ?? '');

    final symbol = (meta['symbol']?.toString() ?? '').toUpperCase();
    final currency = meta['currency']?.toString();

    final change = (prevClose != null && price > 0)
        ? (price - prevClose)
        : null;

    final rawTime = meta['regularMarketTime'];
    final timestamp = (rawTime is int)
        ? DateTime.fromMillisecondsSinceEpoch(rawTime * 1000)
        : DateTime.now();

    return StockQuote(
      symbol: symbol,
      price: price,
      previousClose: prevClose,
      change: change,
      changePercent: changePercent,
      currency: currency,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'price': price,
        if (previousClose != null) 'previous_close': previousClose,
        if (change != null) 'change': change,
        if (changePercent != null) 'change_percent': changePercent,
        if (currency != null) 'currency': currency,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockQuote &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol &&
          price == other.price;

  @override
  int get hashCode => Object.hash(symbol, price);

  @override
  String toString() =>
      'StockQuote(symbol: $symbol, price: \$$price, changePct: $changePercent%)';
}
