import 'package:flutter/services.dart';

import '../models/satellite_info.dart';
import 'channels.dart';

/// Streams the GNSS constellation from the native `GnssStatus.Callback`.
/// No Flutter plugin exposes Cn0/azimuth/elevation/usedInFix, so this is native.
class GnssPlatform {
  static const EventChannel _events = EventChannel(Channels.gnssEvent);

  Stream<List<SatelliteInfo>> satelliteStream() =>
      _events.receiveBroadcastStream().map((e) {
        final list = (e as List).cast<Map<dynamic, dynamic>>();
        return list.map(SatelliteInfo.fromMap).toList();
      });
}
