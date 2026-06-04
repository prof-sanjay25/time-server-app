import 'package:flutter/services.dart';

import 'channels.dart';

/// Device heading in degrees (0 = north), from the native rotation-vector
/// sensor. Used to rotate the satellite sky-plot.
class CompassPlatform {
  static const EventChannel _events = EventChannel(Channels.compassEvent);

  Stream<double> headingStream() =>
      _events.receiveBroadcastStream().map((e) => (e as num).toDouble());
}
