/// Channel names shared with the native Kotlin side. Keep in sync with
/// `android/app/src/main/kotlin/app/timeserver/bridge/Channels.kt`.
class Channels {
  Channels._();

  static const String ntpMethod = 'app.timeserver/ntp';
  static const String ntpStatusEvent = 'app.timeserver/ntp/status';
  static const String ntpLogsEvent = 'app.timeserver/ntp/logs';

  static const String gpsMethod = 'app.timeserver/gps';
  static const String gpsTimeEvent = 'app.timeserver/gps/time';

  static const String gnssEvent = 'app.timeserver/gnss/satellites';

  static const String powerMethod = 'app.timeserver/power';

  static const String networkMethod = 'app.timeserver/network';
  static const String networkEvent = 'app.timeserver/network/changes';

  static const String compassEvent = 'app.timeserver/compass';
}
