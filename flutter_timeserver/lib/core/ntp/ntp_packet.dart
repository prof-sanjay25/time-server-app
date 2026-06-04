import 'dart:typed_data';

import '../../constants/ntp_constants.dart';
import 'ntp_time.dart';

/// A 48-byte NTP/SNTP v3 packet (RFC 2030 / RFC 5905), big-endian.
///
/// Pure-Dart port of the original `NtpMessage.java`, with the original's
/// random-low-byte bug fixed (the random byte is written at `offset + 7`,
/// not a fixed index). This is the canonical codec used by the Dart unit
/// tests and the optional Dart server.
class NtpPacket {
  int leapIndicator; // 0..3
  int version; // 3
  int mode; // 3 client, 4 server
  int stratum; // 0..255
  int poll;
  int precision; // signed
  int rootDelayRaw; // 16.16 fixed point, signed
  int rootDispersionRaw; // 16.16 fixed point, unsigned
  int referenceId; // 32-bit

  int referenceTimestamp; // 64-bit NTP
  int originateTimestamp; // 64-bit NTP (t1)
  int receiveTimestamp; // 64-bit NTP (t2)
  int transmitTimestamp; // 64-bit NTP (t3)

  NtpPacket({
    this.leapIndicator = 0,
    this.version = NtpConstants.versionV3,
    this.mode = 0,
    this.stratum = 0,
    this.poll = 0,
    this.precision = 0,
    this.rootDelayRaw = 0,
    this.rootDispersionRaw = 0,
    this.referenceId = 0,
    this.referenceTimestamp = 0,
    this.originateTimestamp = 0,
    this.receiveTimestamp = 0,
    this.transmitTimestamp = 0,
  });

  /// Parse a received datagram (must be >= 48 bytes).
  factory NtpPacket.parse(Uint8List data) {
    if (data.length < 48) {
      throw const FormatException('NTP packet shorter than 48 bytes');
    }
    final bd = ByteData.sublistView(data);
    final b0 = data[0];
    return NtpPacket(
      leapIndicator: (b0 >> 6) & 0x3,
      version: (b0 >> 3) & 0x7,
      mode: b0 & 0x7,
      stratum: data[1],
      poll: bd.getInt8(2),
      precision: bd.getInt8(3),
      rootDelayRaw: bd.getInt32(4),
      rootDispersionRaw: bd.getUint32(8),
      referenceId: bd.getUint32(12),
      referenceTimestamp: bd.getUint64(16),
      originateTimestamp: bd.getUint64(24),
      receiveTimestamp: bd.getUint64(32),
      transmitTimestamp: bd.getUint64(40),
    );
  }

  /// Serialize into a 48-byte datagram payload.
  Uint8List toBytes() {
    final out = Uint8List(48);
    final bd = ByteData.sublistView(out);
    out[0] = ((leapIndicator & 0x3) << 6) | ((version & 0x7) << 3) | (mode & 0x7);
    out[1] = stratum & 0xFF;
    bd.setInt8(2, poll);
    bd.setInt8(3, precision);
    bd.setInt32(4, rootDelayRaw);
    bd.setUint32(8, rootDispersionRaw & 0xFFFFFFFF);
    bd.setUint32(12, referenceId & 0xFFFFFFFF);
    bd.setUint64(16, referenceTimestamp);
    bd.setUint64(24, originateTimestamp);
    bd.setUint64(32, receiveTimestamp);
    bd.setUint64(40, transmitTimestamp);
    return out;
  }

  /// Build a server reply for a client [request].
  ///
  /// [receiveMillis] = Unix time the request arrived (t2);
  /// [transmitMillis] = Unix time the reply departs (t3);
  /// both should come from the GPS-disciplined clock.
  static NtpPacket buildServerResponse({
    required NtpPacket request,
    required int receiveMillis,
    required int transmitMillis,
    int stratum = NtpConstants.defaultStratum,
    int referenceId = NtpConstants.referenceIdGps,
  }) {
    final receiveTs = NtpTime.toNtp64(receiveMillis);
    return NtpPacket(
      leapIndicator: 0,
      version: NtpConstants.versionV3,
      mode: NtpConstants.modeServer,
      stratum: stratum,
      poll: NtpConstants.poll,
      precision: NtpConstants.precision,
      rootDelayRaw: NtpConstants.rootDelayRaw,
      rootDispersionRaw: NtpConstants.rootDispersionRaw,
      referenceId: referenceId,
      // t1: echo back the client's transmit timestamp.
      originateTimestamp: request.transmitTimestamp,
      // t2: request received.
      receiveTimestamp: receiveTs,
      referenceTimestamp: receiveTs,
      // t3: reply sent.
      transmitTimestamp: NtpTime.toNtp64(transmitMillis),
    );
  }

  String get referenceIdAscii {
    final b = ByteData(4)..setUint32(0, referenceId & 0xFFFFFFFF);
    final sb = StringBuffer();
    for (var i = 0; i < 4; i++) {
      final c = b.getUint8(i);
      if (c == 0) break;
      sb.writeCharCode(c);
    }
    return sb.toString();
  }
}
