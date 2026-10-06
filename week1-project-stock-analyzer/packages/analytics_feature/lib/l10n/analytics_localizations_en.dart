// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'analytics_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AnalyticsLocalizationsEn extends AnalyticsLocalizations {
  AnalyticsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabTitle => 'Performance & Risk';

  @override
  String get performanceHeader => 'Historical Trajectory & Lifetime Analytics';

  @override
  String get lifetimeInvested => 'Lifetime Invested';

  @override
  String get currentValuation => 'Current Valuation';

  @override
  String get netProfit => 'Net Lifetime Profit';

  @override
  String get totalReturn => 'Cumulative Return';

  @override
  String get equityGrowth => 'Equity Growth Trajectory';

  @override
  String get timeframe1M => '1M';

  @override
  String get timeframe3M => '3M';

  @override
  String get timeframe6M => '6M';

  @override
  String get timeframe1Y => '1Y';

  @override
  String get timeframeAll => 'ALL';

  @override
  String get riskSection => 'Risk & Portfolio Health';

  @override
  String get betaLabel => 'Portfolio Beta';

  @override
  String get betaDesc => 'Market volatility sensitivity (vs S&P 500)';

  @override
  String get sharpeLabel => 'Sharpe Ratio';

  @override
  String get sharpeDesc => 'Risk-adjusted performance indicator';

  @override
  String get diversificationScore => 'Diversification Score';

  @override
  String get diversificationDesc =>
      'Sector concentration and balance rating (0-100)';
}
