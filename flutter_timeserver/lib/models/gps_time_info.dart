/// Snapshot of the GPS-disciplined clock vs the device clock, plus the last
/// known location (both arrive from the native `onLocationChanged` callback).
///
/// Ported from `TimeStorage`/`LocationStorage`: [gpsMillis] is the satellite
/// time adjusted by elapsed system time since the last fix; falls back to
/// system time when no fix has been seen.
class GpsTimeInfo {
  final int gpsMillis;
  final int systemMillis;
  final int offsetMillis;
  final bool hasFix;

  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  const GpsTimeInfo({
    required this.gpsMillis,
    required this.systemMillis,
    required this.offsetMillis,
    required this.hasFix,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  static final GpsTimeInfo empty = GpsTimeInfo(
    gpsMillis: DateTime.now().millisecondsSinceEpoch,
    systemMillis: DateTime.now().millisecondsSinceEpoch,
    offsetMillis: 0,
    hasFix: false,
  );

  factory GpsTimeInfo.fromMap(Map<dynamic, dynamic> m) => GpsTimeInfo(
        gpsMillis: (m['gpsMillis'] as num).toInt(),
        systemMillis: (m['systemMillis'] as num).toInt(),
        offsetMillis: (m['offsetMillis'] as num).toInt(),
        hasFix: (m['hasFix'] as bool?) ?? false,
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        accuracyMeters: (m['accuracy'] as num?)?.toDouble(),
      );

  bool get hasLocation => latitude != null && longitude != null;

  DateTime gpsUtc() => DateTime.fromMillisecondsSinceEpoch(gpsMillis, isUtc: true);

  /// Offset as "±x.xx" seconds, matching the original UI formatting.
  String get offsetSecondsString => '±${(offsetMillis / 1000.0).toStringAsFixed(2)}';
}
