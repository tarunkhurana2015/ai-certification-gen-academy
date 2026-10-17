import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import 'package:allocation_feature/allocation_feature.dart';

void main() {
  group('AllocationViewModel (Gherkin Scenario 2.1, 2.2, 2.4)', () {
    final sampleHoldings = [
      HoldingPosition(
        id: '1',
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        shares: 10.0,
        avgCostBasis: 150.0,
        currentPrice: 200.0, // value: $2,000, profit: +$500
        sector: 'Technology',
        purchaseDate: DateTime(2026, 1, 1),
        lastUpdated: DateTime.now(),
      ),
      HoldingPosition(
        id: '2',
        symbol: 'MSFT',
        companyName: 'Microsoft Corporation',
        shares: 10.0,
        avgCostBasis: 250.0,
        currentPrice: 300.0, // value: $3,000, profit: +$500
        sector: 'Technology',
        purchaseDate: DateTime(2026, 1, 1),
        lastUpdated: DateTime.now(),
      ),
      HoldingPosition(
        id: '3',
        symbol: 'JPM',
        companyName: 'JPMorgan Chase',
        shares: 20.0,
        avgCostBasis: 200.0,
        currentPrice: 250.0, // value: $5,000, profit: +$1,000
        sector: 'Financial Services',
        purchaseDate: DateTime(2026, 1, 1),
        lastUpdated: DateTime.now(),
      ),
    ];

    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          holdingsProvider.overrideWithValue(sampleHoldings),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('calculates accurate sector allocation weights', () {
      final state = container.read(allocationViewModelProvider);
      // Total value: 2000 + 3000 + 5000 = $10,000
      // Financial Services: $5,000 (50%)
      // Technology: $5,000 (50%)
      expect(state.sectorAllocations.length, 2);

      final fin = state.sectorAllocations.firstWhere((s) => s.sector == 'Financial Services');
      final tech = state.sectorAllocations.firstWhere((s) => s.sector == 'Technology');

      expect(fin.dollarValue, 5000.0);
      expect(fin.percentage, 50.0);
      expect(tech.dollarValue, 5000.0);
      expect(tech.percentage, 50.0);
    });

    test('selectSectorSlice filters holdings list', () {
      final notifier = container.read(allocationViewModelProvider.notifier);

      notifier.selectSectorSlice('Financial Services');
      var state = container.read(allocationViewModelProvider);
      expect(state.selectedSector, 'Financial Services');

      var filtered = container.read(filteredHoldingsProvider);
      expect(filtered.length, 1);
      expect(filtered.first.symbol, 'JPM');

      // Toggling off restores all holdings
      notifier.selectSectorSlice('Financial Services');
      state = container.read(allocationViewModelProvider);
      expect(state.selectedSector, isNull);

      filtered = container.read(filteredHoldingsProvider);
      expect(filtered.length, 3);
    });

    test('selectTickerSlice filters holdings to single asset', () {
      final notifier = container.read(allocationViewModelProvider.notifier);

      notifier.selectTickerSlice('AAPL');
      final filtered = container.read(filteredHoldingsProvider);
      expect(filtered.length, 1);
      expect(filtered.first.symbol, 'AAPL');
    });

    test('sorting holdings: default marketValue descending and toggling to ascending', () {
      var filtered = container.read(filteredHoldingsProvider);
      // Default: JPM ($5000) -> MSFT ($3000) -> AAPL ($2000)
      expect(filtered[0].symbol, 'JPM');
      expect(filtered[1].symbol, 'MSFT');
      expect(filtered[2].symbol, 'AAPL');

      // Toggling same criteria flips to ascending
      final notifier = container.read(allocationViewModelProvider.notifier);
      notifier.setSortCriteria(AllocationSortCriteria.marketValue);
      filtered = container.read(filteredHoldingsProvider);
      expect(filtered[0].symbol, 'AAPL');
      expect(filtered[1].symbol, 'MSFT');
      expect(filtered[2].symbol, 'JPM');
    });
  });
}
