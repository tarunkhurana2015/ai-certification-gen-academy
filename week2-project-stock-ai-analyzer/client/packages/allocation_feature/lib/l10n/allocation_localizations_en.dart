// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'allocation_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AllocationLocalizationsEn extends AllocationLocalizations {
  AllocationLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabTitle => 'Asset Allocation';

  @override
  String get allocationHeader => 'Portfolio Allocation & Breakdown';

  @override
  String get totalValuation => 'Total Valuation';

  @override
  String get allHoldings => 'All Holdings';

  @override
  String filteredBy(String ticker) {
    return 'Filtered by: $ticker';
  }

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get symbolHeader => 'Asset';

  @override
  String get sharesHeader => 'Quantity';

  @override
  String get costBasisHeader => 'Avg Cost';

  @override
  String get currentPriceHeader => 'Price';

  @override
  String get marketValueHeader => 'Market Value';

  @override
  String get unrealizedGainHeader => 'Profit / Gains';

  @override
  String get weightHeader => 'Weight';

  @override
  String get emptyAllocation =>
      'No holdings detected. Please load a demo portfolio or import a CSV file in Tab 1.';

  @override
  String get positionDetails => 'Position Details';

  @override
  String get totalInvested => 'Total Cost';

  @override
  String get returnPercent => 'Return Rate';

  @override
  String get priceTrend => '30-Day Simulated Trend';
}
