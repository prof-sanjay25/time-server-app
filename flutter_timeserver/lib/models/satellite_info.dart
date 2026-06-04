import 'dart:math' as math;

/// One GNSS satellite, ported from the original `SatelliteModel`.
class SatelliteInfo {
  final int svid;
  final int constellation;
  final String constellationName;
  final double cn0DbHz;
  final double azimuthDegrees;
  final double elevationDegrees;
  final bool usedInFix;
  final bool hasEphemeris;
  final bool hasAlmanac;
  final double? carrierMhz;
  final String? band;

  const SatelliteInfo({
    required this.svid,
    required this.constellation,
    required this.constellationName,
    required this.cn0DbHz,
    required this.azimuthDegrees,
    required this.elevationDegrees,
    required this.usedInFix,
    this.hasEphemeris = false,
    this.hasAlmanac = false,
    this.carrierMhz,
    this.band,
  });

  factory SatelliteInfo.fromMap(Map<dynamic, dynamic> m) => SatelliteInfo(
        svid: (m['svid'] as num).toInt(),
        constellation: (m['constellation'] as num?)?.toInt() ?? 0,
        constellationName: (m['constellationName'] as String?) ?? 'UNKNOWN',
        cn0DbHz: (m['cn0DbHz'] as num?)?.toDouble() ?? 0.0,
        azimuthDegrees: (m['azimuth'] as num?)?.toDouble() ?? 0.0,
        elevationDegrees: (m['elevation'] as num?)?.toDouble() ?? 0.0,
        usedInFix: (m['usedInFix'] as bool?) ?? false,
        hasEphemeris: (m['hasEphemeris'] as bool?) ?? false,
        hasAlmanac: (m['hasAlmanac'] as bool?) ?? false,
        carrierMhz: (m['carrierMhz'] as num?)?.toDouble(),
        band: m['band'] as String?,
      );

  /// Polar position on a unit sky-plot (radius 1 at horizon, 0 at zenith).
  /// Returns (dx, dy) with north up, clockwise.
  math.Point<double> unitPosition() {
    final r = (90.0 - elevationDegrees.clamp(0, 90)) / 90.0;
    final a = (azimuthDegrees - 90.0) * math.pi / 180.0;
    return math.Point(r * math.cos(a), r * math.sin(a));
  }

  String get label => '$constellationName $svid';
}
