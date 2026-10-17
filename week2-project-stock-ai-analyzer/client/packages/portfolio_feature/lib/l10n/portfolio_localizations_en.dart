// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'portfolio_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class PortfolioLocalizationsEn extends PortfolioLocalizations {
  PortfolioLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabTitle => 'Portfolio Ingestion';

  @override
  String get welcomeTitle => 'Welcome to GenStockFolio';

  @override
  String get welcomeSubtitle =>
      'Get started by loading a mock diversified portfolio, uploading your CSV holdings, or adding positions manually.';

  @override
  String get loadDemoButton => 'Load Demo Portfolio';

  @override
  String get uploadCsvButton => 'Upload CSV File';

  @override
  String get addPositionButton => 'Add Position Manually';

  @override
  String get clearPortfolio => 'Clear Portfolio';

  @override
  String get dropZonePrompt =>
      'Drag & drop your CSV file here, or click to browse';

  @override
  String get previewTitle => 'CSV Import Preview';

  @override
  String get validRows => 'Valid Rows';

  @override
  String get flaggedIssues => 'Issues Flagged';

  @override
  String get confirmImport => 'Confirm Import';

  @override
  String get importValidOnly => 'Import Valid Rows Only';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get symbol => 'Ticker Symbol';

  @override
  String get shares => 'Shares Quantity';

  @override
  String get costBasis => 'Average Cost Basis';

  @override
  String get companyName => 'Company Name';

  @override
  String get sector => 'Sector';

  @override
  String positionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count positions',
      one: '1 position',
      zero: 'No positions',
    );
    return '$_temp0';
  }

  @override
  String get plaidSectionTitle => 'Plaid Financial Integration';

  @override
  String get plaidConnectPrompt =>
      'Link your brokerage via Plaid (Fidelity, Schwab, Vanguard, etc.) to automatically sync investment holdings.';

  @override
  String get plaidStatusDisconnected => 'No Brokerage Linked';

  @override
  String get plaidConnectedStatus => 'Connected via Plaid';

  @override
  String get plaidConnectTitle => 'Link Brokerage via Plaid';

  @override
  String get plaidModeSandbox => 'Plaid Sandbox';

  @override
  String get plaidModeLive => 'API Credentials';

  @override
  String get plaidConnectAction => 'Connect Account';

  @override
  String get plaidSyncButton => 'Sync Now';

  @override
  String get plaidDisconnectButton => 'Disconnect';

  @override
  String get cancelButton => 'Cancel';
}
