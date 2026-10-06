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

### Phase 2 Robinhood Brokerage REST Contract (Future Bridge)
The repository abstraction supports mapping future upstream Robinhood endpoints:

#### Endpoint: `POST /oauth2/token`
```json
{
  "grant_type": "password",
  "client_id": "c82SH0WZOsabOXGP2sxqcj34FxkvfnWRZBKPhMBd",
  "device_token": "device_uuid_v4",
  "scope": "internal"
}
```

#### Endpoint: `GET /portfolios/`
```json
{
  "results": [
    {
      "account": "https://api.robinhood.com/accounts/12345678/",
      "equity": "128450.25",
      "extended_hours_equity": "128520.10",
      "market_value": "125100.00",
      "total_cash": "3350.25"
    }
  ]
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

## 5. Repository Interface Contracts

### `IBrokerageRepository`
```dart
abstract interface class IBrokerageRepository {
  Future<Result<List<HoldingPosition>>> fetchHoldings();
  Future<Result<PortfolioSummary>> fetchPortfolioSummary();
  Future<Result<void>> saveCustomPositions(List<HoldingPosition> positions);
  Future<Result<void>> clearPortfolio();
  Future<Result<List<HoldingPosition>>> generateDemoPortfolio();
  Future<Result<bool>> connectBrokerageAccount({required String authToken});
  bool get isConnectedToLiveBrokerage;
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
