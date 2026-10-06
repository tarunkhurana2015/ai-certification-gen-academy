import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'portfolio_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of PortfolioLocalizations
/// returned by `PortfolioLocalizations.of(context)`.
///
/// Applications need to include `PortfolioLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/portfolio_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: PortfolioLocalizations.localizationsDelegates,
///   supportedLocales: PortfolioLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the PortfolioLocalizations.supportedLocales
/// property.
abstract class PortfolioLocalizations {
  PortfolioLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static PortfolioLocalizations? of(BuildContext context) {
    return Localizations.of<PortfolioLocalizations>(
      context,
      PortfolioLocalizations,
    );
  }

  static const LocalizationsDelegate<PortfolioLocalizations> delegate =
      _PortfolioLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @tabTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Ingestion'**
  String get tabTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to GenStockFolio'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get started by loading a mock diversified portfolio, uploading your CSV holdings, or adding positions manually.'**
  String get welcomeSubtitle;

  /// No description provided for @loadDemoButton.
  ///
  /// In en, this message translates to:
  /// **'Load Demo Portfolio'**
  String get loadDemoButton;

  /// No description provided for @uploadCsvButton.
  ///
  /// In en, this message translates to:
  /// **'Upload CSV File'**
  String get uploadCsvButton;

  /// No description provided for @addPositionButton.
  ///
  /// In en, this message translates to:
  /// **'Add Position Manually'**
  String get addPositionButton;

  /// No description provided for @clearPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Clear Portfolio'**
  String get clearPortfolio;

  /// No description provided for @dropZonePrompt.
  ///
  /// In en, this message translates to:
  /// **'Drag & drop your CSV file here, or click to browse'**
  String get dropZonePrompt;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'CSV Import Preview'**
  String get previewTitle;

  /// No description provided for @validRows.
  ///
  /// In en, this message translates to:
  /// **'Valid Rows'**
  String get validRows;

  /// No description provided for @flaggedIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues Flagged'**
  String get flaggedIssues;

  /// No description provided for @confirmImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get confirmImport;

  /// No description provided for @importValidOnly.
  ///
  /// In en, this message translates to:
  /// **'Import Valid Rows Only'**
  String get importValidOnly;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @symbol.
  ///
  /// In en, this message translates to:
  /// **'Ticker Symbol'**
  String get symbol;

  /// No description provided for @shares.
  ///
  /// In en, this message translates to:
  /// **'Shares Quantity'**
  String get shares;

  /// No description provided for @costBasis.
  ///
  /// In en, this message translates to:
  /// **'Average Cost Basis'**
  String get costBasis;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @sector.
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get sector;

  /// No description provided for @positionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No positions} =1{1 position} other{{count} positions}}'**
  String positionsCount(int count);

  /// No description provided for @robinhoodSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Brokerage Connection'**
  String get robinhoodSectionTitle;

  /// No description provided for @robinhoodConnectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Connect Robinhood Account (Phase 2 Preview)'**
  String get robinhoodConnectPrompt;

  /// No description provided for @robinhoodStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Offline / Local Mock Active'**
  String get robinhoodStatusDisconnected;
}

class _PortfolioLocalizationsDelegate
    extends LocalizationsDelegate<PortfolioLocalizations> {
  const _PortfolioLocalizationsDelegate();

  @override
  Future<PortfolioLocalizations> load(Locale locale) {
    return SynchronousFuture<PortfolioLocalizations>(
      lookupPortfolioLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_PortfolioLocalizationsDelegate old) => false;
}

PortfolioLocalizations lookupPortfolioLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return PortfolioLocalizationsEn();
  }

  throw FlutterError(
    'PortfolioLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
