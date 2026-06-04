// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appName => 'Time Server';

  @override
  String get tabTime => 'Tid';

  @override
  String get tabSatellites => 'Satellitter';

  @override
  String get tabServer => 'Server';

  @override
  String get tabAbout => 'Om';

  @override
  String get pntp => 'PublicNTP';

  @override
  String get optionsTitle => 'ALTERNATIVER';

  @override
  String get done => 'Ferdig';

  @override
  String get timeAccuracyUnits => 'sec';

  @override
  String get accuracyUnitsMeters => 'm';

  @override
  String get accuracyUnitsFeet => 'ft';

  @override
  String get measurementTitle => 'Målesystem';

  @override
  String get measurementMetric => 'Metric / SI';

  @override
  String get measurementImperial => 'Imperial / US';

  @override
  String get timeStandardTitle => 'Tidsstandard';

  @override
  String get timeStdUtc => 'UTC';

  @override
  String get timeStdLocal => 'Local Time';

  @override
  String get timeStdDecimal => 'Decimal Time';

  @override
  String get timeStdSwatch => 'Swatch Internet Time';

  @override
  String get coordinateTitle => 'Koordinatstandard';

  @override
  String get openInMaps => 'Åpne i Maps';

  @override
  String get copyToClipboard => 'Kopier';

  @override
  String get copied => 'Copied.';

  @override
  String get noLocationFound => 'No Location Found';

  @override
  String get mapsNotInstalled => 'Maps is not installed';

  @override
  String get inView => 'i sikte';

  @override
  String get inUse => 'i bruk';

  @override
  String get satelliteDetailSnr => 'Signal-to-Noise';

  @override
  String get satelliteDetailElevation => 'Elevation';

  @override
  String get satelliteDetailAzimuth => 'Azimuth';

  @override
  String get satelliteDetailCarrier => 'Carrier';

  @override
  String get packetsPerMin => 'pakker/min';

  @override
  String get runningOn => 'Running on';

  @override
  String get portNote =>
      'Standard port 123 needs root; clients otherwise use 1234.';

  @override
  String get sntpServer => 'SNTP-server';

  @override
  String get noRootWarning => 'This feature works best with a rooted device.';

  @override
  String get rootRedirectSuccess => 'Port 123 redirect active (root).';

  @override
  String get minutesAgo => 'Minutes Ago';

  @override
  String get stratumTitle => 'Stratum-nivå';

  @override
  String get networkTitle => 'Nettverksgrensesnitt';

  @override
  String get throttleTitle => 'Begrensning (pakker/min)';

  @override
  String get autoStart => 'Auto-start NTP-server';

  @override
  String get unlimited => 'Ubegrenset';

  @override
  String get donateText => 'Find out more about PublicNTP.';

  @override
  String get visit => 'VISIT';

  @override
  String get aboutTitle => 'Om';

  @override
  String get buildVersion => 'Versjon';

  @override
  String get aboutOrganization =>
      'Time Server App is copyrighted by PublicNTP, Inc., open-sourced under the MIT License.';

  @override
  String get aboutContent =>
      'PublicNTP is a nonprofit that provides unrestricted access to no-cost, highly-accurate time sources for the public good. Help us help you. Donate and bring time to the world!';

  @override
  String get creditsTitle => 'Credits';
}
