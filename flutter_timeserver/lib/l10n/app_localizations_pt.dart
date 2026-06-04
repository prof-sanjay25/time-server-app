// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Time Server';

  @override
  String get tabTime => 'Hora';

  @override
  String get tabSatellites => 'Satélites';

  @override
  String get tabServer => 'Servidor';

  @override
  String get tabAbout => 'Sobre';

  @override
  String get pntp => 'PublicNTP';

  @override
  String get optionsTitle => 'OPÇÕES';

  @override
  String get done => 'Concluído';

  @override
  String get timeAccuracyUnits => 'sec';

  @override
  String get accuracyUnitsMeters => 'm';

  @override
  String get accuracyUnitsFeet => 'ft';

  @override
  String get measurementTitle => 'Sistema de medida';

  @override
  String get measurementMetric => 'Metric / SI';

  @override
  String get measurementImperial => 'Imperial / US';

  @override
  String get timeStandardTitle => 'Padrão de hora';

  @override
  String get timeStdUtc => 'UTC';

  @override
  String get timeStdLocal => 'Local Time';

  @override
  String get timeStdDecimal => 'Decimal Time';

  @override
  String get timeStdSwatch => 'Swatch Internet Time';

  @override
  String get coordinateTitle => 'Padrão de coordenadas';

  @override
  String get openInMaps => 'Abrir no Maps';

  @override
  String get copyToClipboard => 'Copiar';

  @override
  String get copied => 'Copied.';

  @override
  String get noLocationFound => 'No Location Found';

  @override
  String get mapsNotInstalled => 'Maps is not installed';

  @override
  String get inView => 'à vista';

  @override
  String get inUse => 'em uso';

  @override
  String get satelliteDetailSnr => 'Signal-to-Noise';

  @override
  String get satelliteDetailElevation => 'Elevation';

  @override
  String get satelliteDetailAzimuth => 'Azimuth';

  @override
  String get satelliteDetailCarrier => 'Carrier';

  @override
  String get packetsPerMin => 'pacotes/min';

  @override
  String get runningOn => 'Running on';

  @override
  String get portNote =>
      'Standard port 123 needs root; clients otherwise use 1234.';

  @override
  String get sntpServer => 'Servidor SNTP';

  @override
  String get noRootWarning => 'This feature works best with a rooted device.';

  @override
  String get rootRedirectSuccess => 'Port 123 redirect active (root).';

  @override
  String get minutesAgo => 'Minutes Ago';

  @override
  String get stratumTitle => 'Nível de estrato';

  @override
  String get networkTitle => 'Interface de rede';

  @override
  String get throttleTitle => 'Limite (pacotes/min)';

  @override
  String get autoStart => 'Iniciar servidor NTP automaticamente';

  @override
  String get unlimited => 'Ilimitado';

  @override
  String get donateText => 'Find out more about PublicNTP.';

  @override
  String get visit => 'VISIT';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get buildVersion => 'Versão';

  @override
  String get aboutOrganization =>
      'Time Server App is copyrighted by PublicNTP, Inc., open-sourced under the MIT License.';

  @override
  String get aboutContent =>
      'PublicNTP is a nonprofit that provides unrestricted access to no-cost, highly-accurate time sources for the public good. Help us help you. Donate and bring time to the world!';

  @override
  String get creditsTitle => 'Credits';
}
