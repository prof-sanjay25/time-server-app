import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_no.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('nb'),
    Locale('no'),
    Locale('pt'),
    Locale('sv')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Time Server'**
  String get appName;

  /// No description provided for @tabTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get tabTime;

  /// No description provided for @tabSatellites.
  ///
  /// In en, this message translates to:
  /// **'Satellites'**
  String get tabSatellites;

  /// No description provided for @tabServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get tabServer;

  /// No description provided for @tabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tabAbout;

  /// No description provided for @pntp.
  ///
  /// In en, this message translates to:
  /// **'PublicNTP'**
  String get pntp;

  /// No description provided for @optionsTitle.
  ///
  /// In en, this message translates to:
  /// **'OPTIONS'**
  String get optionsTitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @timeAccuracyUnits.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get timeAccuracyUnits;

  /// No description provided for @accuracyUnitsMeters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get accuracyUnitsMeters;

  /// No description provided for @accuracyUnitsFeet.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get accuracyUnitsFeet;

  /// No description provided for @measurementTitle.
  ///
  /// In en, this message translates to:
  /// **'System of Measurement'**
  String get measurementTitle;

  /// No description provided for @measurementMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric / SI'**
  String get measurementMetric;

  /// No description provided for @measurementImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial / US'**
  String get measurementImperial;

  /// No description provided for @timeStandardTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Standard'**
  String get timeStandardTitle;

  /// No description provided for @timeStdUtc.
  ///
  /// In en, this message translates to:
  /// **'UTC'**
  String get timeStdUtc;

  /// No description provided for @timeStdLocal.
  ///
  /// In en, this message translates to:
  /// **'Local Time'**
  String get timeStdLocal;

  /// No description provided for @timeStdDecimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal Time'**
  String get timeStdDecimal;

  /// No description provided for @timeStdSwatch.
  ///
  /// In en, this message translates to:
  /// **'Swatch Internet Time'**
  String get timeStdSwatch;

  /// No description provided for @coordinateTitle.
  ///
  /// In en, this message translates to:
  /// **'Geocoordinate Standard'**
  String get coordinateTitle;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get copied;

  /// No description provided for @noLocationFound.
  ///
  /// In en, this message translates to:
  /// **'No Location Found'**
  String get noLocationFound;

  /// No description provided for @mapsNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Maps is not installed'**
  String get mapsNotInstalled;

  /// No description provided for @inView.
  ///
  /// In en, this message translates to:
  /// **'in view'**
  String get inView;

  /// No description provided for @inUse.
  ///
  /// In en, this message translates to:
  /// **'in use'**
  String get inUse;

  /// No description provided for @satelliteDetailSnr.
  ///
  /// In en, this message translates to:
  /// **'Signal-to-Noise'**
  String get satelliteDetailSnr;

  /// No description provided for @satelliteDetailElevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get satelliteDetailElevation;

  /// No description provided for @satelliteDetailAzimuth.
  ///
  /// In en, this message translates to:
  /// **'Azimuth'**
  String get satelliteDetailAzimuth;

  /// No description provided for @satelliteDetailCarrier.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get satelliteDetailCarrier;

  /// No description provided for @packetsPerMin.
  ///
  /// In en, this message translates to:
  /// **'packets/min'**
  String get packetsPerMin;

  /// No description provided for @runningOn.
  ///
  /// In en, this message translates to:
  /// **'Running on'**
  String get runningOn;

  /// No description provided for @portNote.
  ///
  /// In en, this message translates to:
  /// **'Standard port 123 needs root; clients otherwise use 1234.'**
  String get portNote;

  /// No description provided for @sntpServer.
  ///
  /// In en, this message translates to:
  /// **'SNTP Server'**
  String get sntpServer;

  /// No description provided for @noRootWarning.
  ///
  /// In en, this message translates to:
  /// **'This feature works best with a rooted device.'**
  String get noRootWarning;

  /// No description provided for @rootRedirectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Port 123 redirect active (root).'**
  String get rootRedirectSuccess;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Minutes Ago'**
  String get minutesAgo;

  /// No description provided for @stratumTitle.
  ///
  /// In en, this message translates to:
  /// **'Stratum Level'**
  String get stratumTitle;

  /// No description provided for @networkTitle.
  ///
  /// In en, this message translates to:
  /// **'Network Interface'**
  String get networkTitle;

  /// No description provided for @throttleTitle.
  ///
  /// In en, this message translates to:
  /// **'Throttle (Packets/min)'**
  String get throttleTitle;

  /// No description provided for @autoStart.
  ///
  /// In en, this message translates to:
  /// **'Auto-Start NTP Server'**
  String get autoStart;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @donateText.
  ///
  /// In en, this message translates to:
  /// **'Find out more about PublicNTP.'**
  String get donateText;

  /// No description provided for @visit.
  ///
  /// In en, this message translates to:
  /// **'VISIT'**
  String get visit;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @buildVersion.
  ///
  /// In en, this message translates to:
  /// **'Build Version'**
  String get buildVersion;

  /// No description provided for @aboutOrganization.
  ///
  /// In en, this message translates to:
  /// **'Time Server App is copyrighted by PublicNTP, Inc., open-sourced under the MIT License.'**
  String get aboutOrganization;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'PublicNTP is a nonprofit that provides unrestricted access to no-cost, highly-accurate time sources for the public good. Help us help you. Donate and bring time to the world!'**
  String get aboutContent;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'da',
        'de',
        'en',
        'es',
        'fr',
        'ja',
        'nb',
        'no',
        'pt',
        'sv'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'nb':
      return AppLocalizationsNb();
    case 'no':
      return AppLocalizationsNo();
    case 'pt':
      return AppLocalizationsPt();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
