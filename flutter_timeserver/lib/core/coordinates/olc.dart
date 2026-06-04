import 'dart:math' as math;

/// Open Location Code (Plus Codes) encoder — integer reference algorithm.
/// Ports the behaviour of the bundled `com.google.openlocationcode`.
class Olc {
  Olc._();

  static const String _alphabet = '23456789CFGHJMPQRVWX';
  static const int _base = 20;
  static const int _latMax = 90;
  static const int _lngMax = 180;
  static const int _maxDigits = 15;
  static const int _pairLen = 10;
  static const int _gridLen = _maxDigits - _pairLen; // 5
  static const int _gridCols = 4;
  static const int _gridRows = 5;
  static const int _sepPos = 8;

  static const int _latMult = 8000 * 3125; // 25,000,000
  static const int _lngMult = 8000 * 1024; // 8,192,000

  static double _clipLat(double lat) => lat.clamp(-90.0, 90.0);

  static double _normLng(double lng) {
    var l = lng;
    while (l < -180) {
      l += 360;
    }
    while (l >= 180) {
      l -= 360;
    }
    return l;
  }

  static double _latPrecision(int codeLength) {
    if (codeLength <= 10) {
      return math.pow(_base, (codeLength ~/ -2) + 2).toDouble();
    }
    return math.pow(_base, -3) / math.pow(_gridRows, codeLength - 10);
  }

  /// Encode [lat]/[lng] to a Plus Code of [codeLength] digits (default 11).
  static String encode(double lat, double lng, {int codeLength = 11}) {
    codeLength = math.min(codeLength, _maxDigits);
    lat = _clipLat(lat);
    lng = _normLng(lng);
    if (lat == 90) {
      lat = lat - _latPrecision(codeLength);
    }

    var latVal = (lat * _latMult).round() + _latMax * _latMult;
    var lngVal = (lng * _lngMult).round() + _lngMax * _lngMult;

    final chars = List<String>.filled(_maxDigits, '0');

    // Grid digits (positions 10..14).
    var lv = latVal;
    var gv = lngVal;
    for (var i = 0; i < _gridLen; i++) {
      final latDigit = lv % _gridRows;
      final lngDigit = gv % _gridCols;
      chars[_maxDigits - 1 - i] = _alphabet[latDigit * _gridCols + lngDigit];
      lv = lv ~/ _gridRows;
      gv = gv ~/ _gridCols;
    }

    // Pair digits (positions 0..9): collapse the grid resolution first.
    latVal = latVal ~/ math.pow(_gridRows, _gridLen).toInt();
    lngVal = lngVal ~/ math.pow(_gridCols, _gridLen).toInt();
    for (var i = 0; i < _pairLen ~/ 2; i++) {
      chars[_pairLen - 1 - (i * 2)] = _alphabet[lngVal % _base];
      chars[_pairLen - 2 - (i * 2)] = _alphabet[latVal % _base];
      latVal = latVal ~/ _base;
      lngVal = lngVal ~/ _base;
    }

    final raw = chars.join();
    final withSep = '${raw.substring(0, _sepPos)}+${raw.substring(_sepPos)}';
    if (codeLength >= _sepPos) {
      return withSep.substring(0, codeLength + 1);
    }
    return '${raw.substring(0, codeLength).padRight(_sepPos, '0')}+';
  }
}
