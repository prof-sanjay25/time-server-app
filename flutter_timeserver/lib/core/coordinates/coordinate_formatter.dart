import '../../models/enums.dart';
import 'olc.dart';
import 'utm.dart';

/// Formats a lat/long pair according to the selected [CoordinateType],
/// matching the original WGS84 / UTM / MGRS / OLC options.
class CoordinateFormatter {
  CoordinateFormatter._();

  static String format(CoordinateType type, double lat, double lon) {
    switch (type) {
      case CoordinateType.wgs84:
        return _wgs84(lat, lon);
      case CoordinateType.utm:
        return Utm.fromLatLon(lat, lon).toString();
      case CoordinateType.mgrs:
        return Utm.mgrs(lat, lon);
      case CoordinateType.olc:
        return Olc.encode(lat, lon, codeLength: 11);
    }
  }

  static String _wgs84(double lat, double lon) {
    final ns = lat >= 0 ? 'N' : 'S';
    final ew = lon >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(5)}°$ns ${lon.abs().toStringAsFixed(5)}°$ew';
  }
}
