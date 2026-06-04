import '../../constants/ntp_constants.dart';

/// Conversions between Unix milliseconds and the 64-bit NTP timestamp format
/// (seconds since 1900-01-01 in the high 32 bits, fractional seconds in the
/// low 32 bits).
class NtpTime {
  NtpTime._();

  /// Encode Unix [millis] into a 64-bit NTP timestamp value (as an unsigned
  /// 64-bit quantity held in a Dart [int], which is 64-bit on the VM).
  static int toNtp64(int millis) {
    final int seconds = millis ~/ 1000;
    final int ms = millis % 1000;
    final int ntpSeconds = seconds + NtpConstants.ntpEpochOffsetSeconds;
    final int fraction = ((ms / 1000.0) * NtpConstants.twoPow32).round() & 0xFFFFFFFF;
    return ((ntpSeconds & 0xFFFFFFFF) << 32) | fraction;
  }

  /// Decode a 64-bit NTP timestamp back into Unix milliseconds.
  static int fromNtp64(int ntp64) {
    final int ntpSeconds = (ntp64 >> 32) & 0xFFFFFFFF;
    final int fraction = ntp64 & 0xFFFFFFFF;
    final int unixSeconds = ntpSeconds - NtpConstants.ntpEpochOffsetSeconds;
    final int ms = ((fraction / NtpConstants.twoPow32) * 1000.0).round();
    return unixSeconds * 1000 + ms;
  }
}
