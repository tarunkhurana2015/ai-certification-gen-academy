# 05 - Data Models & API Contracts Specification: GenStockFolio

## 1. Domain Entities & Data Models

### Entity: `HoldingPosition`
- **Location**: `packages/portfolio_feature/lib/domain/entities/holding_position.dart`
- **Definition**:
```dart
class HoldingPosition {
  final String id;
  final String symbol;
  final String companyName;
  final double shares;
  final double avgCostBasis;
  final double currentPrice;
  final String sector;
  final DateTime purchaseDate;
  final DateTime lastUpdated;

  const HoldingPosition({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.shares,
    required this.avgCostBasis,
    required this.currentPrice,
    required this.sector,
    required this.purchaseDate,
    required this.lastUpdated,
  });

  double get totalCost => shares * avgCostBasis;
  double get totalMarketValue => shares * currentPrice;
  double get unrealizedProfitLoss => totalMarketValue - totalCost;
  double get unrealizedReturnPercentage => totalCost > 0 ? (unrealizedProfitLoss / totalCost) * 100 : 0.0;
  bool get isProfitable => unrealizedProfitLoss >= 0;

  HoldingPosition copyWith({
    String? id,
    String? symbol,
    String? companyName,
    double? shares,
    double? avgCostBasis,
    double? currentPrice,
    String? sector,
    DateTime? purchaseDate,
    DateTime? lastUpdated,
  }) {
    return HoldingPosition(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      shares: shares ?? this.shares,
      avgCostBasis: avgCostBasis ?? this.avgCostBasis,
      currentPrice: currentPrice ?? this.currentPrice,
      sector: sector ?? this.sector,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
```

---

### Entity: `PortfolioSummary`
- **Location**: `packages/portfolio_feature/lib/domain/entities/portfolio_summary.dart`
- **Definition**:
```dart
class PortfolioSummary {
  final double totalInvested;
  final double currentValuation;
  final double netProfit;
  final double returnPercentage;
  final int totalHoldingsCount;
  final DateTime lastCalculated;

  const PortfolioSummary({
    required this.totalInvested,
    required this.currentValuation,
    required this.netProfit,
    required this.returnPercentage,
    required this.totalHoldingsCount,
    required this.lastCalculated,
  });

  factory PortfolioSummary.fromHoldings(List<HoldingPosition> holdings) {
    if (holdings.isEmpty) {
      return PortfolioSummary(
        totalInvested: 0.0,
        currentValuation: 0.0,
        netProfit: 0.0,
        returnPercentage: 0.0,
        totalHoldingsCount: 0,
        lastCalculated: DateTime.now(),
      );
    }

    final double invested = holdings.fold(0.0, (acc, item) => acc + item.totalCost);
    final double valuation = holdings.fold(0.0, (acc, item) => acc + item.totalMarketValue);
    final double profit = valuation - invested;
    final double returnPct = invested > 0 ? (profit / invested) * 100 : 0.0;

    return PortfolioSummary(
      totalInvested: invested,
      currentValuation: valuation,
      netProfit: profit,
      returnPercentage: returnPct,
      totalHoldingsCount: holdings.length,
      lastCalculated: DateTime.now(),
    );
  }
}
```

---

### Entity: `SectorAllocation`
- **Location**: `packages/allocation_feature/lib/domain/entities/sector_allocation.dart`
- **Definition**:
```dart
class SectorAllocation {
  final String sector;
  final double dollarValue;
  final double percentage;
  final int holdingCount;
  final String colorHex;

  const SectorAllocation({
    required this.sector,
    required this.dollarValue,
    required this.percentage,
    required this.holdingCount,
    required this.colorHex,
  });
}
```

---

### Entity: `HistoricalDataPoint` & `RiskMetrics`
- **Location**: `packages/analytics_feature/lib/domain/entities/performance_metrics.dart`
- **Definition**:
```dart
class HistoricalDataPoint {
  final DateTime timestamp;
  final double portfolioValue;
  final double benchmarkValue;

  const HistoricalDataPoint({
    required this.timestamp,
    required this.portfolioValue,
    required this.benchmarkValue,
  });
}

class RiskMetrics {
  final double beta;
  final double sharpeRatio;
  final int diversificationScore;
  final double maxDrawdownPercentage;

  const RiskMetrics({
    required this.beta,
    required this.sharpeRatio,
    required this.diversificationScore,
    required this.maxDrawdownPercentage,
  });
}
```

---

### Ingestion Models: `CsvParseResult` & `CsvRowError`
- **Location**: `packages/portfolio_feature/lib/domain/entities/csv_parse_result.dart`
- **Definition**:
```dart
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
```

---

### Entity: `InvestmentTransaction`
- **Location**: `packages/portfolio_feature/lib/domain/entities/investment_transaction.dart`
- **Definition**:
```dart
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
}
```

---

### Entity: `PlaidInstitution`
- **Location**: `packages/portfolio_feature/lib/domain/entities/plaid_institution.dart`
- **Definition**:
```dart
@immutable
class PlaidInstitution {
  final String id;
  final String name;
  final List<String> products;
  final List<String> countryCodes;
  final String? url;
  final String? primaryColor;
  final String? logo;
  final bool oauth;
  final List<String> routingNumbers;
  final List<String> dtcNumbers;
  final String connectionAvailability;

  const PlaidInstitution({
    required this.id,
    required this.name,
    this.products = const [],
    this.countryCodes = const ['US'],
    this.url,
    this.primaryColor,
    this.logo,
    this.oauth = false,
    this.routingNumbers = const [],
    this.dtcNumbers = const [],
    this.connectionAvailability = 'SUPPORTED',
  });
}
```

---

### Entity: `StockQuote`
- **Location**: `packages/portfolio_feature/lib/domain/entities/stock_quote.dart`
- **Definition**:
```dart
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
}
```

---

## 2. Market Data Contracts & Schemas

### Pluggable Market Engine Contract
The built-in mock market generator seeds real-world equity tickers with realistic baseline pricing and micro-volatility:

```json
{
  "status": "success",
  "as_of": "2026-10-05T19:40:00Z",
  "quotes": [
    {
      "symbol": "AAPL",
      "company_name": "Apple Inc.",
      "price": 232.50,
      "change": 2.15,
      "change_percent": 0.93,
      "sector": "Technology"
    },
    {
      "symbol": "MSFT",
      "company_name": "Microsoft Corporation",
      "price": 448.20,
      "change": -1.40,
      "change_percent": -0.31,
      "sector": "Technology"
    },
    {
      "symbol": "NVDA",
      "company_name": "NVIDIA Corporation",
      "price": 124.80,
      "change": 4.10,
      "change_percent": 3.40,
      "sector": "Technology"
    },
    {
      "symbol": "GOOGL",
      "company_name": "Alphabet Inc.",
      "price": 182.10,
      "change": 0.85,
      "change_percent": 0.47,
      "sector": "Communication Services"
    },
    {
      "symbol": "AMZN",
      "company_name": "Amazon.com, Inc.",
      "price": 188.40,
      "change": 1.25,
      "change_percent": 0.67,
      "sector": "Consumer Cyclical"
    },
    {
      "symbol": "TSLA",
      "company_name": "Tesla, Inc.",
      "price": 254.30,
      "change": -3.80,
      "change_percent": -1.47,
      "sector": "Consumer Cyclical"
    }
  ]
}
```

---

### Plaid Investments API Contracts
GenStockFolio implements the official Plaid Investments product endpoints:

#### Endpoint: `POST /link/token/create`
Request to initialize Link session:
```json
{
  "client_id": "PLAID_CLIENT_ID",
  "secret": "PLAID_SECRET",
  "client_name": "GenStockFolio Stock Analyzer",
  "country_codes": ["US"],
  "language": "en",
  "user": { "client_user_id": "user_unique_id" },
  "products": ["investments"]
}
```
Response:
```json
{
  "link_token": "link-sandbox-12345-abcdef",
  "expiration": "2026-10-06T20:00:00Z",
  "request_id": "req_123"
}
```

#### Endpoint: `POST /item/public_token/exchange`
Request exchanging public token for session access token:
```json
{
  "client_id": "PLAID_CLIENT_ID",
  "secret": "PLAID_SECRET",
  "public_token": "public-sandbox-demo-token"
}
```
Response (persisted strictly in-memory):
```json
{
  "access_token": "access-sandbox-perm-token",
  "item_id": "item-id-12345",
  "request_id": "req_456"
}
```

#### Endpoint: `POST /investments/holdings/get`
Retrieves live holdings and securities:
```json
{
  "holdings": [
    {
      "account_id": "acc_1",
      "cost_basis": 150.00,
      "institution_price": 230.50,
      "quantity": 25.0,
      "security_id": "sec_aapl"
    }
  ],
  "securities": [
    {
      "security_id": "sec_aapl",
      "ticker_symbol": "AAPL",
      "name": "Apple Inc.",
      "type": "equity",
      "close_price": 230.50
    }
  ]
}
```

#### Endpoint: `POST /investments/transactions/get`
Retrieves investment transaction logs:
```json
{
  "investment_transactions": [
    {
      "investment_transaction_id": "txn_001",
      "account_id": "acc_1",
      "security_id": "sec_aapl",
      "date": "2026-02-15",
      "name": "Buy 10 AAPL",
      "quantity": 10.0,
      "amount": 1500.0,
      "price": 150.0,
      "fees": 0.0,
      "type": "buy",
      "subtype": "buy"
    }
  ]
}
```

---

### Yahoo Finance Real-Time Market Data Contract
Endpoint: `GET /v8/finance/chart/{symbol}?interval=1m&range=1d`
```json
{
  "chart": {
    "result": [
      {
        "meta": {
          "currency": "USD",
          "symbol": "AAPL",
          "regularMarketPrice": 232.50,
          "chartPreviousClose": 230.35,
          "regularMarketChangePercent": 0.93,
          "regularMarketTime": 1770334800
        }
      }
    ],
    "error": null
  }
}
```

---

## 3. Serialization Strategy & Type Safety

All entity models enforce defensive type casting and explicit JSON serialization:

```dart
Map<String, dynamic> holdingToJson(HoldingPosition position) {
  return {
    'id': position.id,
    'symbol': position.symbol,
    'company_name': position.companyName,
    'shares': position.shares,
    'avg_cost_basis': position.avgCostBasis,
    'current_price': position.currentPrice,
    'sector': position.sector,
    'purchase_date': position.purchaseDate.toIso8601String(),
    'last_updated': position.lastUpdated.toIso8601String(),
  };
}

HoldingPosition holdingFromJson(Map<String, dynamic> json) {
  return HoldingPosition(
    id: json['id'] as String? ?? '',
    symbol: (json['symbol'] as String? ?? '').toUpperCase(),
    companyName: json['company_name'] as String? ?? 'Unknown Asset',
    shares: (json['shares'] as num?)?.toDouble() ?? 0.0,
    avgCostBasis: (json['avg_cost_basis'] as num?)?.toDouble() ?? 0.0,
    currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
    sector: json['sector'] as String? ?? 'Other',
    purchaseDate: DateTime.tryParse(json['purchase_date'] as String? ?? '') ?? DateTime.now(),
    lastUpdated: DateTime.tryParse(json['last_updated'] as String? ?? '') ?? DateTime.now(),
  );
}
```

---

## 4. Standardized Result Envelope Pattern

To provide predictable, compile-time exhaustive error handling across asynchronous operations:

```dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String errorMessage;
  final Object? error;
  final StackTrace? stackTrace;
  const Failure(this.errorMessage, [this.error, this.stackTrace]);
}
```

---

## 5. Repository & Service Interface Contracts

### `IBrokerageRepository`
```dart
abstract interface class IBrokerageRepository {
  Future<Result<List<HoldingPosition>>> fetchHoldings();
  Future<Result<PortfolioSummary>> fetchPortfolioSummary();
  Future<Result<List<InvestmentTransaction>>> fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Result<void>> saveCustomPositions(List<HoldingPosition> positions);
  Future<Result<void>> clearPortfolio();
  Future<Result<List<HoldingPosition>>> generateDemoPortfolio();
  Future<Result<bool>> connectBrokerageAccount({
    required String authToken,
    String? clientId,
    String? secret,
    String? accountIdentifier,
    String? institutionName,
    String environment = 'sandbox',
    bool isSandbox = false,
  });
  Future<Result<void>> disconnectBrokerageAccount();
  bool get isConnectedToLiveBrokerage;
  String? get accountIdentifier;
  String? get institutionName;
  bool get isSandboxMode;
  DateTime? get lastSyncTime;
}
```

### `IStockPriceService`
```dart
abstract interface class IStockPriceService {
  Future<Result<StockQuote>> fetchQuote(String symbol);
  Future<Map<String, StockQuote>> fetchBatchQuotes(List<String> symbols);
  Stream<Map<String, StockQuote>> getPriceStream({
    required List<String> Function() symbolsProvider,
    Duration interval,
  });
}
```

### `ICsvParserService`
```dart
abstract interface class ICsvParserService {
  Result<CsvParseResult> parseCsvString(String rawCsv);
}
```

### `IMarketDataService`
```dart
abstract interface class IMarketDataService {
  Future<Result<double>> fetchLatestPrice(String symbol);
  Future<Result<List<HistoricalDataPoint>>> fetchHistoricalTrajectory(String timeframe);
  Future<Result<RiskMetrics>> calculateRiskMetrics(List<HoldingPosition> holdings);
}
```
