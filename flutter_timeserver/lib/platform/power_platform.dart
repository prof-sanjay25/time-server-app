import 'package:flutter/services.dart';

import 'channels.dart';

/// Battery-optimization exemption (wake lock itself is held inside the service).
class PowerPlatform {
  static const MethodChannel _method = MethodChannel(Channels.powerMethod);

  Future<bool> isIgnoringBatteryOptimizations() async =>
      (await _method.invokeMethod<bool>('isIgnoringBatteryOptimizations')) ?? false;

  /// Opens the system dialog requesting battery-optimization exemption.
  Future<void> requestIgnoreBatteryOptimizations() =>
      _method.invokeMethod('requestIgnoreBatteryOptimizations');
}
