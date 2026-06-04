import '../constants/ntp_constants.dart';
import 'enums.dart';

/// All persisted user preferences (server config + display options).
class AppSettings {
  final int stratum;
  final String interfaceName;
  final int packetLimit; // 0 = unlimited
  final bool autoStart;
  final TimeStandard timeStandard;
  final MeasurementSystem measurement;
  final CoordinateType coordinateType;

  const AppSettings({
    this.stratum = NtpConstants.defaultStratum,
    this.interfaceName = 'wlan0',
    this.packetLimit = 0,
    this.autoStart = false,
    this.timeStandard = TimeStandard.utc,
    this.measurement = MeasurementSystem.metric,
    this.coordinateType = CoordinateType.wgs84,
  });

  AppSettings copyWith({
    int? stratum,
    String? interfaceName,
    int? packetLimit,
    bool? autoStart,
    TimeStandard? timeStandard,
    MeasurementSystem? measurement,
    CoordinateType? coordinateType,
  }) =>
      AppSettings(
        stratum: stratum ?? this.stratum,
        interfaceName: interfaceName ?? this.interfaceName,
        packetLimit: packetLimit ?? this.packetLimit,
        autoStart: autoStart ?? this.autoStart,
        timeStandard: timeStandard ?? this.timeStandard,
        measurement: measurement ?? this.measurement,
        coordinateType: coordinateType ?? this.coordinateType,
      );
}
