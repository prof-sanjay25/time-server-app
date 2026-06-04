import 'package:flutter/services.dart';

import '../models/gps_time_info.dart';
import 'channels.dart';

/// Native GPS time source (Location.getTime + drift adjustment), which also
/// feeds the NTP server's reply timestamps.
class GpsPlatform {
  static const MethodChannel _method = MethodChannel(Channels.gpsMethod);
  static const EventChannel _timeEvents = EventChannel(Channels.gpsTimeEvent);

  Future<bool> startLocation() async =>
      (await _method.invokeMethod<bool>('startLocation')) ?? false;

  Future<bool> stopLocation() async =>
      (await _method.invokeMethod<bool>('stopLocation')) ?? false;

  Future<GpsTimeInfo> getTime() async {
    final res = await _method.invokeMethod<Map<dynamic, dynamic>>('getTime');
    return GpsTimeInfo.fromMap(res ?? const {});
  }

  Stream<GpsTimeInfo> timeStream() => _timeEvents
      .receiveBroadcastStream()
      .map((e) => GpsTimeInfo.fromMap(e as Map<dynamic, dynamic>));
}
