import '../../models/enums.dart';

/// Formats a UTC instant according to the selected time standard
/// (UTC / Local / Decimal / Swatch Internet Time), matching the original
/// timezone spinner.
class TimeStandards {
  TimeStandards._();

  static String format(TimeStandard std, DateTime utc) {
    switch (std) {
      case TimeStandard.utc:
        return _hms(utc);
      case TimeStandard.local:
        return _hms(utc.toLocal());
      case TimeStandard.decimal:
        return _decimal(utc);
      case TimeStandard.swatch:
        return _swatch(utc);
    }
  }

  static String suffix(TimeStandard std) {
    switch (std) {
      case TimeStandard.utc:
        return 'UTC';
      case TimeStandard.local:
        return 'Local';
      case TimeStandard.decimal:
        return 'dec';
      case TimeStandard.swatch:
        return '.beats';
    }
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// HH:mm:ss.SS (hundredths of a second), like the original display.
  static String _hms(DateTime t) {
    final cs = (t.millisecond ~/ 10);
    return '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}.${_two(cs)}';
  }

  /// French decimal time: 10 h/day, 100 min/h, 100 s/min.
  static String _decimal(DateTime utc) {
    final local = utc.toLocal();
    final secondsOfDay = local.hour * 3600 +
        local.minute * 60 +
        local.second +
        local.millisecond / 1000.0;
    final dayFraction = secondsOfDay / 86400.0;
    final decTotal = dayFraction * 100000.0; // decimal seconds in a day
    final dh = (decTotal ~/ 10000) % 10;
    final dm = (decTotal ~/ 100) % 100;
    final ds = decTotal.toInt() % 100;
    return '$dh:${_two(dm)}:${_two(ds)}';
  }

  /// Swatch Internet Time (.beats), based on UTC+1 (Biel Mean Time).
  static String _swatch(DateTime utc) {
    final bmt = utc.add(const Duration(hours: 1));
    final secondsOfDay =
        bmt.hour * 3600 + bmt.minute * 60 + bmt.second + bmt.millisecond / 1000.0;
    final beats = secondsOfDay / 86.4;
    return '@${beats.toStringAsFixed(2)}';
  }
}
