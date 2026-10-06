import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'allocation_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AllocationLocalizations
/// returned by `AllocationLocalizations.of(context)`.
///
/// Applications need to include `AllocationLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/allocation_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AllocationLocalizations.localizationsDelegates,
///   supportedLocales: AllocationLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AllocationLocalizations.supportedLocales
/// property.
abstract class AllocationLocalizations {
  AllocationLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AllocationLocalizations? of(BuildContext context) {
    return Localizations.of<AllocationLocalizations>(
      context,
      AllocationLocalizations,
    );
  }

  static const LocalizationsDelegate<AllocationLocalizations> delegate =
      _AllocationLocalizationsDelegate();

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
  /// **'Asset Allocation'**
  String get tabTitle;

  /// No description provided for @allocationHeader.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Allocation & Breakdown'**
  String get allocationHeader;

  /// No description provided for @totalValuation.
  ///
  /// In en, this message translates to:
  /// **'Total Valuation'**
  String get totalValuation;

  /// No description provided for @allHoldings.
  ///
  /// In en, this message translates to:
  /// **'All Holdings'**
  String get allHoldings;

  /// No description provided for @filteredBy.
  ///
  /// In en, this message translates to:
  /// **'Filtered by: {ticker}'**
  String filteredBy(String ticker);

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// No description provided for @symbolHeader.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get symbolHeader;

  /// No description provided for @sharesHeader.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get sharesHeader;

  /// No description provided for @costBasisHeader.
  ///
  /// In en, this message translates to:
  /// **'Avg Cost'**
  String get costBasisHeader;

  /// No description provided for @currentPriceHeader.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get currentPriceHeader;

  /// No description provided for @marketValueHeader.
  ///
  /// In en, this message translates to:
  /// **'Market Value'**
  String get marketValueHeader;

  /// No description provided for @unrealizedGainHeader.
  ///
  /// In en, this message translates to:
  /// **'Profit / Gains'**
  String get unrealizedGainHeader;

  /// No description provided for @weightHeader.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightHeader;

  /// No description provided for @emptyAllocation.
  ///
  /// In en, this message translates to:
  /// **'No holdings detected. Please load a demo portfolio or import a CSV file in Tab 1.'**
  String get emptyAllocation;

  /// No description provided for @positionDetails.
  ///
  /// In en, this message translates to:
  /// **'Position Details'**
  String get positionDetails;

  /// No description provided for @totalInvested.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalInvested;

  /// No description provided for @returnPercent.
  ///
  /// In en, this message translates to:
  /// **'Return Rate'**
  String get returnPercent;

  /// No description provided for @priceTrend.
  ///
  /// In en, this message translates to:
  /// **'30-Day Simulated Trend'**
  String get priceTrend;
}

class _AllocationLocalizationsDelegate
    extends LocalizationsDelegate<AllocationLocalizations> {
  const _AllocationLocalizationsDelegate();

  @override
  Future<AllocationLocalizations> load(Locale locale) {
    return SynchronousFuture<AllocationLocalizations>(
      lookupAllocationLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AllocationLocalizationsDelegate old) => false;
}

AllocationLocalizations lookupAllocationLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AllocationLocalizationsEn();
  }

  throw FlutterError(
    'AllocationLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
