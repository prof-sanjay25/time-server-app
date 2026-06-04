/// NTP / SNTP protocol and server constants.
///
/// Mirrors the original `app.timeserver.service.ntp.NtpService` values.
class NtpConstants {
  NtpConstants._();

  /// Standard NTP port. Binding to this (a privileged port < 1024) requires
  /// root on Android; otherwise the server uses [unrestrictedPort].
  static const int defaultPort = 123;

  /// Default port the UDP server actually binds to on a non-rooted device.
  static const int unrestrictedPort = 1234;

  /// Seconds between the NTP epoch (1900-01-01) and the Unix epoch (1970-01-01).
  static const int ntpEpochOffsetSeconds = 2208988800;

  /// 2^32, used for the fractional part of a 64-bit NTP timestamp.
  static const double twoPow32 = 4294967296.0;

  /// Reference identifier for a GPS-sourced stratum-1 server: ASCII "GPS\0".
  static const int referenceIdGps = 0x47505300;

  /// Reference identifier used when serving the local fallback clock: "LOCL".
  static const int referenceIdLocal = 0x4C4F434C;

  // NTP modes
  static const int modeClient = 3;
  static const int modeServer = 4;

  static const int versionV3 = 3;

  // Default advertised quality fields (match original SimpleNTPServer).
  static const int defaultStratum = 1;
  static const int precision = -20; // ~2^-20 s
  static const int poll = 0;
  static const int rootDelayRaw = 62; // 16.16 fixed point
  static const int rootDispersionRaw = 1082; // (int)(16.51 * 65.536)

  static const List<int> stratumChoices = [1, 2, 3, 4];

  /// Throttle choices (packets/min). 0 == unlimited.
  static const List<int> packetChoices = [0, 9000, 4800, 2400, 1200, 600];
}
