import 'package:flutter/material.dart';

/// Maps a satellite's Cn0 (dB-Hz) signal strength to a grey shade — stronger
/// signal is darker. Port of the original `GreyLevelHelper`.
class GreyLevel {
  GreyLevel._();

  /// Cn0 roughly spans 0..45 dB-Hz in practice.
  static Color color(double cn0DbHz) {
    final t = (cn0DbHz.clamp(0.0, 45.0)) / 45.0; // 0 weak .. 1 strong
    final v = (225 - (t * 205)).round().clamp(20, 230);
    return Color.fromARGB(255, v, v, v);
  }
}
