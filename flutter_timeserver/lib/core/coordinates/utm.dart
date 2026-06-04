import 'dart:math' as math;

/// UTM coordinate (WGS84).
class UtmCoord {
  final int zone;
  final String hemisphere; // 'N' or 'S'
  final double easting;
  final double northing;
  const UtmCoord(this.zone, this.hemisphere, this.easting, this.northing);

  @override
  String toString() =>
      '$zone$hemisphere ${easting.round()}E ${northing.round()}N';
}

/// WGS84 lat/long → UTM → MGRS conversions (Snyder series, k0 = 0.9996).
class Utm {
  Utm._();

  static const double _a = 6378137.0; // WGS84 semi-major axis
  static const double _f = 1 / 298.257223563;
  static const double _k0 = 0.9996;

  static double _deg2rad(double d) => d * math.pi / 180.0;

  static int zoneFor(double lat, double lon) {
    var zone = ((lon + 180) / 6).floor() + 1;
    // Norway / Svalbard exceptions.
    if (lat >= 56 && lat < 64 && lon >= 3 && lon < 12) zone = 32;
    if (lat >= 72 && lat < 84) {
      if (lon >= 0 && lon < 9) {
        zone = 31;
      } else if (lon >= 9 && lon < 21) {
        zone = 33;
      } else if (lon >= 21 && lon < 33) {
        zone = 35;
      } else if (lon >= 33 && lon < 42) {
        zone = 37;
      }
    }
    return zone;
  }

  static UtmCoord fromLatLon(double lat, double lon) {
    const e2 = _f * (2 - _f);
    const ep2 = e2 / (1 - e2);
    final zone = zoneFor(lat, lon);
    final lonOrigin = (zone - 1) * 6 - 180 + 3.0;

    final latR = _deg2rad(lat);
    final lonR = _deg2rad(lon);
    final lonOriginR = _deg2rad(lonOrigin);

    final n = _a / math.sqrt(1 - e2 * math.sin(latR) * math.sin(latR));
    final t = math.tan(latR) * math.tan(latR);
    final c = ep2 * math.cos(latR) * math.cos(latR);
    final aa = math.cos(latR) * (lonR - lonOriginR);

    final m = _a *
        ((1 - e2 / 4 - 3 * e2 * e2 / 64 - 5 * e2 * e2 * e2 / 256) * latR -
            (3 * e2 / 8 + 3 * e2 * e2 / 32 + 45 * e2 * e2 * e2 / 1024) *
                math.sin(2 * latR) +
            (15 * e2 * e2 / 256 + 45 * e2 * e2 * e2 / 1024) * math.sin(4 * latR) -
            (35 * e2 * e2 * e2 / 3072) * math.sin(6 * latR));

    final easting = _k0 *
            n *
            (aa +
                (1 - t + c) * math.pow(aa, 3) / 6 +
                (5 - 18 * t + t * t + 72 * c - 58 * ep2) * math.pow(aa, 5) / 120) +
        500000.0;

    var northing = _k0 *
        (m +
            n *
                math.tan(latR) *
                (aa * aa / 2 +
                    (5 - t + 9 * c + 4 * c * c) * math.pow(aa, 4) / 24 +
                    (61 - 58 * t + t * t + 600 * c - 330 * ep2) *
                        math.pow(aa, 6) /
                        720));
    if (lat < 0) northing += 10000000.0;

    return UtmCoord(zone, lat >= 0 ? 'N' : 'S', easting, northing);
  }

  static const String _latBands = 'CDEFGHJKLMNPQRSTUVWXX';

  static String latBand(double lat) {
    if (lat >= 84) return 'X';
    if (lat < -80) return 'C';
    return _latBands[((lat + 80) / 8).floor()];
  }

  /// MGRS string, e.g. "12S YH 12345 67890" (1 m precision).
  static String mgrs(double lat, double lon) {
    final u = fromLatLon(lat, lon);
    final band = latBand(lat);

    const colSets = ['ABCDEFGH', 'JKLMNPQR', 'STUVWXYZ'];
    const rowOdd = 'ABCDEFGHJKLMNPQRSTUV';
    const rowEven = 'FGHJKLMNPQRSTUVABCDE';

    final e100k = (u.easting / 100000).floor(); // 1..8
    final n100k = (u.northing / 100000).floor() % 20;

    final colSet = colSets[(u.zone - 1) % 3];
    final colLetter = colSet[(e100k - 1).clamp(0, 7)];
    final rowSet = u.zone.isOdd ? rowOdd : rowEven;
    final rowLetter = rowSet[n100k];

    final eRem = (u.easting % 100000).floor().toString().padLeft(5, '0');
    final nRem = (u.northing % 100000).floor().toString().padLeft(5, '0');

    return '${u.zone}$band $colLetter$rowLetter $eRem $nRem';
  }
}
