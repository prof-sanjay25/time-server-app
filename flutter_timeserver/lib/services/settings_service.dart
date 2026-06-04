import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/enums.dart';

/// Persists [AppSettings] in SharedPreferences (synchronous reads via the
/// cached [SharedPreferences] instance loaded at startup).
class SettingsService {
  final SharedPreferences _prefs;
  SettingsService(this._prefs);

  static const _kStratum = 'stratumChoice';
  static const _kInterface = 'networkChoice';
  static const _kPacket = 'packetChoice';
  static const _kAutoStart = 'autoStart';
  static const _kTimeStandard = 'timeStandard';
  static const _kMeasurement = 'measurement';
  static const _kCoordinate = 'coordinateType';

  AppSettings load() => AppSettings(
        stratum: _prefs.getInt(_kStratum) ?? 1,
        interfaceName: _prefs.getString(_kInterface) ?? 'wlan0',
        packetLimit: _prefs.getInt(_kPacket) ?? 0,
        autoStart: _prefs.getBool(_kAutoStart) ?? false,
        timeStandard: TimeStandardX.fromName(_prefs.getString(_kTimeStandard)),
        measurement: MeasurementSystemX.fromName(_prefs.getString(_kMeasurement)),
        coordinateType: CoordinateTypeX.fromName(_prefs.getString(_kCoordinate)),
      );

  Future<void> save(AppSettings s) async {
    await _prefs.setInt(_kStratum, s.stratum);
    await _prefs.setString(_kInterface, s.interfaceName);
    await _prefs.setInt(_kPacket, s.packetLimit);
    await _prefs.setBool(_kAutoStart, s.autoStart);
    await _prefs.setString(_kTimeStandard, s.timeStandard.name);
    await _prefs.setString(_kMeasurement, s.measurement.name);
    await _prefs.setString(_kCoordinate, s.coordinateType.name);
  }
}
