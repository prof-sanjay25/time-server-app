// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Time Server';

  @override
  String get tabTime => 'Heure';

  @override
  String get tabSatellites => 'Satellites';

  @override
  String get tabServer => 'Serveur';

  @override
  String get tabAbout => 'À propos';

  @override
  String get pntp => 'PublicNTP';

  @override
  String get optionsTitle => 'OPTIONS';

  @override
  String get done => 'Terminé';

  @override
  String get timeAccuracyUnits => 'sec';

  @override
  String get accuracyUnitsMeters => 'm';

  @override
  String get accuracyUnitsFeet => 'ft';

  @override
  String get measurementTitle => 'Système de mesure';

  @override
  String get measurementMetric => 'Metric / SI';

  @override
  String get measurementImperial => 'Imperial / US';

  @override
  String get timeStandardTitle => 'Standard horaire';

  @override
  String get timeStdUtc => 'UTC';

  @override
  String get timeStdLocal => 'Local Time';

  @override
  String get timeStdDecimal => 'Decimal Time';

  @override
  String get timeStdSwatch => 'Swatch Internet Time';

  @override
  String get coordinateTitle => 'Standard géographique';

  @override
  String get openInMaps => 'Ouvrir dans Maps';

  @override
  String get copyToClipboard => 'Copier';

  @override
  String get copied => 'Copied.';

  @override
  String get noLocationFound => 'No Location Found';

  @override
  String get mapsNotInstalled => 'Maps is not installed';

  @override
  String get inView => 'en vue';

  @override
  String get inUse => 'utilisés';

  @override
  String get satelliteDetailSnr => 'Signal-to-Noise';

  @override
  String get satelliteDetailElevation => 'Elevation';

  @override
  String get satelliteDetailAzimuth => 'Azimuth';

  @override
  String get satelliteDetailCarrier => 'Carrier';

  @override
  String get packetsPerMin => 'paquets/min';

  @override
  String get runningOn => 'Running on';

  @override
  String get portNote =>
      'Standard port 123 needs root; clients otherwise use 1234.';

  @override
  String get sntpServer => 'Serveur SNTP';

  @override
  String get noRootWarning => 'This feature works best with a rooted device.';

  @override
  String get rootRedirectSuccess => 'Port 123 redirect active (root).';

  @override
  String get minutesAgo => 'Minutes Ago';

  @override
  String get stratumTitle => 'Niveau de strate';

  @override
  String get networkTitle => 'Interface réseau';

  @override
  String get throttleTitle => 'Limite (paquets/min)';

  @override
  String get autoStart => 'Démarrage auto du serveur NTP';

  @override
  String get unlimited => 'Illimité';

  @override
  String get donateText => 'Find out more about PublicNTP.';

  @override
  String get visit => 'VISIT';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get buildVersion => 'Version';

  @override
  String get aboutOrganization =>
      'Time Server App is copyrighted by PublicNTP, Inc., open-sourced under the MIT License.';

  @override
  String get aboutContent =>
      'PublicNTP is a nonprofit that provides unrestricted access to no-cost, highly-accurate time sources for the public good. Help us help you. Donate and bring time to the world!';

  @override
  String get creditsTitle => 'Credits';
}
