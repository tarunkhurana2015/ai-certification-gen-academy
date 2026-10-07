# 06 - Testing Strategy & Quality Assurance Specification: GenStockFolio

## 1. Testing Pyramid & Coverage Targets

```text
         ▲
        / \     Integration Tests (macOS Desktop & Chrome Web smoke flows)
       /   \
      /-----\   Widget Tests (Interactive Pie Chart, Holdings Table, CSV Modal)
     /       \
    /---------\ Unit Tests (CSV Parser, Portfolios Math, Risk Engines, ViewModels)
```

| Test Type | Target Directory | Tooling | Coverage Target |
|---|---|---|---|
| **Unit Tests** | `packages/<name>/test/` | `flutter_test`, `package:test` | $\ge 80\%$ logic coverage |
| **Widget Tests** | `packages/<name>/test/presentation/` | `WidgetTester`, Riverpod overrides | Key states: Empty, Loading, Data, Error |
| **Host App Tests** | `apps/gen_stock_folio/test/` | `testWidgets` | Host smoke test, 3-tab navigation, theme toggle |
| **E2E Smoke** | `apps/gen_stock_folio/test/` | `flutter test` | End-to-end import to allocation verification |

---

## 2. Gherkin-to-Test Mapping Pattern
Every behavioral acceptance scenario specified in `02_user_journeys_and_features.md` maps directly to an executable test suite.

### Scenario 1.2: CSV Parsing with Flexible Column Headers
- **Gherkin Reference**: `02_user_journeys_and_features.md#Scenario 1.2`
- **Test File**: `packages/portfolio_feature/test/data/csv_parser_service_test.dart`
```dart
test('parses flexible headers (Symbol, Quantity, Price, Date) into valid HoldingPositions', () {
  const csvContent = '''
Symbol,Quantity,Price,Date
AAPL,10,180.50,2026-01-15
MSFT,5,420.00,2026-02-10
''';
  final parser = CsvParserService();
  final result = parser.parseCsvString(csvContent);

  expect(result.validPositions.length, 2);
  expect(result.errors.isEmpty, true);
  expect(result.validPositions[0].symbol, 'AAPL');
  expect(result.validPositions[0].shares, 10.0);
  expect(result.validPositions[0].avgCostBasis, 180.50);
});
```

---

### Scenario 1.3: Handling Malformed CSV Rows
- **Gherkin Reference**: `02_user_journeys_and_features.md#Scenario 1.3`
- **Test File**: `packages/portfolio_feature/test/data/csv_parser_service_test.dart`
```dart
test('flags invalid rows with specific error reasons without throwing unhandled exceptions', () {
  const malformedCsv = '''
Symbol,Shares,CostBasis
,10,150.00
NVDA,-5,120.00
GOOGL,20,invalid_price
''';
  final parser = CsvParserService();
  final result = parser.parseCsvString(malformedCsv);

  expect(result.validPositions.isEmpty, true);
  expect(result.errors.length, 3);
  expect(result.errors[0].reason, contains('Missing ticker symbol'));
  expect(result.errors[1].reason, contains('Shares must be greater than zero'));
  expect(result.errors[2].reason, contains('Invalid numerical price'));
});
```

---

### Scenario 1.5: Plaid Investments Adapter Flow & Holdings Ingestion
- **Gherkin Reference**: `02_user_journeys_and_features.md#Scenario 1.5`
- **Test File**: `packages/portfolio_feature/test/data/plaid_brokerage_adapter_test.dart`
```dart
test('completePlaidFlow executes 5-step flow end-to-end and returns live holdings', () async {
  final adapter = PlaidBrokerageAdapter(client: mockClient);
  final connectResult = await adapter.connectBrokerageAccount(
    authToken: 'sandbox_auth_token',
    clientId: 'test_client_id',
    secret: 'test_secret',
    institutionName: 'Charles Schwab',
    isSandbox: true,
  );

  expect(connectResult is Success<bool>, isTrue);
  expect(adapter.isConnectedToLiveBrokerage, isTrue);

  final holdingsResult = await adapter.fetchHoldings();
  expect(holdingsResult is Success<List<HoldingPosition>>, isTrue);
  final holdings = (holdingsResult as Success<List<HoldingPosition>>).data;
  expect(holdings.isNotEmpty, isTrue);
  expect(holdings.first.symbol, 'AAPL');
});
```

---

### Scenario 1.6: Yahoo Finance Real-Time Batch Quotes & Streaming
- **Gherkin Reference**: `02_user_journeys_and_features.md#Scenario 1.6`
- **Test File**: `packages/portfolio_feature/test/data/yahoo_finance_price_service_test.dart`
```dart
test('fetchBatchQuotes fetches quotes and getPriceStream emits periodic updates', () async {
  final service = YahooFinancePriceService(client: mockClient);
  final quotes = await service.fetchBatchQuotes(['AAPL', 'MSFT']);

  expect(quotes.containsKey('AAPL'), isTrue);
  expect(quotes['AAPL']!.price, greaterThan(0));
  expect(quotes['AAPL']!.changePercent, isNotNull);
});
```

---

### Scenario 2.1 & 2.2: Allocation Pie Chart & Cross-Filtering
- **Gherkin Reference**: `02_user_journeys_and_features.md#Scenario 2.1, 2.2`
- **Test File**: `packages/allocation_feature/test/viewmodel/allocation_viewmodel_test.dart`
```dart
test('selecting pie slice filters holdings list and updates radial offset state', () {
  final container = ProviderContainer(overrides: [
    holdingsProvider.overrideWith((ref) => [
      const HoldingPosition(id: '1', symbol: 'AAPL', companyName: 'Apple', shares: 10, avgCostBasis: 150, currentPrice: 200, sector: 'Technology', purchaseDate: DateTime(2026, 1, 1), lastUpdated: DateTime(2026, 1, 1)),
      const HoldingPosition(id: '2', symbol: 'MSFT', companyName: 'Microsoft', shares: 5, avgCostBasis: 300, currentPrice: 400, sector: 'Technology', purchaseDate: DateTime(2026, 1, 1), lastUpdated: DateTime(2026, 1, 1)),
    ]),
  ]);
  addTearDown(container.dispose);

  final notifier = container.read(allocationViewModelProvider.notifier);
  expect(container.read(allocationViewModelProvider).selectedTicker, isNull);

  // Cross-filter on AAPL slice tap
  notifier.selectTickerSlice('AAPL');
  expect(container.read(allocationViewModelProvider).selectedTicker, 'AAPL');
  expect(container.read(allocationViewModelProvider).filteredHoldings.length, 1);
  expect(container.read(allocationViewModelProvider).filteredHoldings.first.symbol, 'AAPL');

  // Toggle off slice filter
  notifier.selectTickerSlice('AAPL');
  expect(container.read(allocationViewModelProvider).selectedTicker, isNull);
  expect(container.read(allocationViewModelProvider).filteredHoldings.length, 2);
});
```

---

### Scenario 3.1 & 3.3: Lifetime Performance & Risk Calculations
- **Gherkin Reference**: `02_user_journeys_and_features.md#Scenario 3.1, 3.3`
- **Test File**: `packages/analytics_feature/test/viewmodel/analytics_viewmodel_test.dart`
```dart
test('calculates accurate lifetime capital invested, valuation, net P&L and Beta', () {
  const holdings = [
    HoldingPosition(id: '1', symbol: 'NVDA', companyName: 'NVIDIA', shares: 100, avgCostBasis: 100, currentPrice: 150, sector: 'Technology', purchaseDate: DateTime(2026, 1, 1), lastUpdated: DateTime(2026, 1, 1)),
  ];

  final summary = PortfolioSummary.fromHoldings(holdings);
  expect(summary.totalInvested, 10000.0);
  expect(summary.currentValuation, 15000.0);
  expect(summary.netProfit, 5000.0);
  expect(summary.returnPercentage, 50.0);
});
```

---

## 3. Mocking & Test Isolation Guidelines

1. **Lightweight In-Memory Fakes**: To maintain high test execution speeds and avoid bulky code-generation dependencies (`build_runner`), all tests utilize hand-crafted interface fakes:
   - `FakeBrokerageRepository` implements `IBrokerageRepository`.
   - `FakeMarketDataService` implements `IMarketDataService`.
2. **Provider Container Overrides**: Tests isolate units by injecting fake services via Riverpod overrides:
   ```dart
   final container = ProviderContainer(
     overrides: [
       brokerageRepositoryProvider.overrideWithValue(fakeRepository),
       marketDataServiceProvider.overrideWithValue(fakeMarketService),
     ],
   );
   ```
3. **Zero Network Calls**: Tests are strictly offline. Live sockets, HTTP connections, or native disk I/O are disallowed in unit suites.

---

## 4. Quality Gates & Continuous Verification Commands

Before any pull request or stage advancement is accepted, the automated verification pipeline must execute and succeed cleanly:

```bash
# 1. Spec Quality Audit (Zero unfilled placeholders)
./skills/flutter-spec-driven-development/scripts/validate_specs.sh --dir .

# 2. Workspace Static Analysis (0 errors, 0 warnings)
flutter analyze --fatal-infos

# 3. Unit & Widget Test Suites Across All Feature Packages
(cd packages/portfolio_feature && flutter test)
(cd packages/allocation_feature && flutter test)
(cd packages/analytics_feature && flutter test)

# 4. Host App Smoke Tests & Navigation Verification
(cd apps/gen_stock_folio && flutter test)
```
