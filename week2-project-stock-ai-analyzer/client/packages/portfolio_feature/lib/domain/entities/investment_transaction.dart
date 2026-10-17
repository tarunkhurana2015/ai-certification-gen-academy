import 'package:flutter/foundation.dart';

@immutable
class InvestmentTransaction {
  final String id;
  final String accountId;
  final String? securityId;
  final String? symbol;
  final String name;
  final DateTime date;
  final double quantity;
  final double amount;
  final double price;
  final double fees;
  final String type; // 'buy', 'sell', 'cancel', 'cash', 'fee', 'transfer'
  final String? subtype;
  final String isoCurrencyCode;

  const InvestmentTransaction({
    required this.id,
    required this.accountId,
    this.securityId,
    this.symbol,
    required this.name,
    required this.date,
    required this.quantity,
    required this.amount,
    required this.price,
    this.fees = 0.0,
    required this.type,
    this.subtype,
    this.isoCurrencyCode = 'USD',
  });

  factory InvestmentTransaction.fromJson(
    Map<String, dynamic> json, [
    Map<String, Map<String, dynamic>>? securitiesMap,
  ]) {
    final secId = json['security_id']?.toString();
    final sec = (secId != null && securitiesMap != null) ? securitiesMap[secId] : null;
    final symbol = sec != null ? (sec['ticker_symbol']?.toString() ?? '') : '';

    return InvestmentTransaction(
      id: json['investment_transaction_id']?.toString() ??
          json['id']?.toString() ??
          '',
      accountId: json['account_id']?.toString() ?? '',
      securityId: secId,
      symbol: symbol.isNotEmpty ? symbol : null,
      name: json['name']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toDouble()
          : (double.tryParse(json['quantity']?.toString() ?? '') ?? 0.0),
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '') ?? 0.0),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price']?.toString() ?? '') ?? 0.0),
      fees: (json['fees'] is num)
          ? (json['fees'] as num).toDouble()
          : (double.tryParse(json['fees']?.toString() ?? '') ?? 0.0),
      type: json['type']?.toString() ?? 'other',
      subtype: json['subtype']?.toString(),
      isoCurrencyCode: json['iso_currency_code']?.toString() ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        if (securityId != null) 'securityId': securityId,
        if (symbol != null) 'symbol': symbol,
        'name': name,
        'date': date.toIso8601String(),
        'quantity': quantity,
        'amount': amount,
        'price': price,
        'fees': fees,
        'type': type,
        if (subtype != null) 'subtype': subtype,
        'isoCurrencyCode': isoCurrencyCode,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
