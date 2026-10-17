import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'analytics_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AnalyticsLocalizations
/// returned by `AnalyticsLocalizations.of(context)`.
///
/// Applications need to include `AnalyticsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/analytics_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AnalyticsLocalizations.localizationsDelegates,
///   supportedLocales: AnalyticsLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AnalyticsLocalizations.supportedLocales
/// property.
abstract class AnalyticsLocalizations {
  AnalyticsLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AnalyticsLocalizations? of(BuildContext context) {
    return Localizations.of<AnalyticsLocalizations>(
      context,
      AnalyticsLocalizations,
    );
  }

  static const LocalizationsDelegate<AnalyticsLocalizations> delegate =
      _AnalyticsLocalizationsDelegate();

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
  /// **'Performance & Risk'**
  String get tabTitle;

  /// No description provided for @performanceHeader.
  ///
  /// In en, this message translates to:
  /// **'Historical Trajectory & Lifetime Analytics'**
  String get performanceHeader;

  /// No description provided for @lifetimeInvested.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Invested'**
  String get lifetimeInvested;

  /// No description provided for @currentValuation.
  ///
  /// In en, this message translates to:
  /// **'Current Valuation'**
  String get currentValuation;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Lifetime Profit'**
  String get netProfit;

  /// No description provided for @totalReturn.
  ///
  /// In en, this message translates to:
  /// **'Cumulative Return'**
  String get totalReturn;

  /// No description provided for @equityGrowth.
  ///
  /// In en, this message translates to:
  /// **'Equity Growth Trajectory'**
  String get equityGrowth;

  /// No description provided for @timeframe1M.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get timeframe1M;

  /// No description provided for @timeframe3M.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get timeframe3M;

  /// No description provided for @timeframe6M.
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get timeframe6M;

  /// No description provided for @timeframe1Y.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get timeframe1Y;

  /// No description provided for @timeframeAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get timeframeAll;

  /// No description provided for @riskSection.
  ///
  /// In en, this message translates to:
  /// **'Risk & Portfolio Health'**
  String get riskSection;

  /// No description provided for @betaLabel.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Beta'**
  String get betaLabel;

  /// No description provided for @betaDesc.
  ///
  /// In en, this message translates to:
  /// **'Market volatility sensitivity (vs S&P 500)'**
  String get betaDesc;

  /// No description provided for @sharpeLabel.
  ///
  /// In en, this message translates to:
  /// **'Sharpe Ratio'**
  String get sharpeLabel;

  /// No description provided for @sharpeDesc.
  ///
  /// In en, this message translates to:
  /// **'Risk-adjusted performance indicator'**
  String get sharpeDesc;

  /// No description provided for @diversificationScore.
  ///
  /// In en, this message translates to:
  /// **'Diversification Score'**
  String get diversificationScore;

  /// No description provided for @diversificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Sector concentration and balance rating (0-100)'**
  String get diversificationDesc;
}

class _AnalyticsLocalizationsDelegate
    extends LocalizationsDelegate<AnalyticsLocalizations> {
  const _AnalyticsLocalizationsDelegate();

  @override
  Future<AnalyticsLocalizations> load(Locale locale) {
    return SynchronousFuture<AnalyticsLocalizations>(
      lookupAnalyticsLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AnalyticsLocalizationsDelegate old) => false;
}

AnalyticsLocalizations lookupAnalyticsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AnalyticsLocalizationsEn();
  }

  throw FlutterError(
    'AnalyticsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
