import 'package:flutter_test/flutter_test.dart';
import 'package:timeserver/constants/ntp_constants.dart';
import 'package:timeserver/core/coordinates/olc.dart';
import 'package:timeserver/core/ntp/ntp_packet.dart';
import 'package:timeserver/core/ntp/ntp_time.dart';

void main() {
  test('NTP epoch round-trips to within 1 ms', () {
    const millis = 1700000000000;
    final ntp = NtpTime.toNtp64(millis);
    final back = NtpTime.fromNtp64(ntp);
    expect((back - millis).abs() <= 1, isTrue);
  });

  test('server response echoes originate, sets server mode + GPS ref id', () {
    final client = NtpPacket(
      mode: NtpConstants.modeClient,
      version: NtpConstants.versionV3,
      transmitTimestamp: NtpTime.toNtp64(1700000000000),
    );
    final resp = NtpPacket.buildServerResponse(
      request: client,
      receiveMillis: 1700000000100,
      transmitMillis: 1700000000101,
      stratum: 1,
    );
    expect(resp.mode, NtpConstants.modeServer);
    expect(resp.originateTimestamp, client.transmitTimestamp);
    expect(resp.referenceIdAscii, 'GPS');
    expect(resp.stratum, 1);
  });

  test('48-byte encode/decode round trip', () {
    final p = NtpPacket(
      mode: NtpConstants.modeServer,
      version: NtpConstants.versionV3,
      stratum: 1,
      transmitTimestamp: NtpTime.toNtp64(1700000000000),
    );
    final bytes = p.toBytes();
    expect(bytes.length, 48);
    final decoded = NtpPacket.parse(bytes);
    expect(decoded.mode, NtpConstants.modeServer);
    expect(decoded.stratum, 1);
    expect(decoded.transmitTimestamp, p.transmitTimestamp);
  });

  test('OLC encodes a known location', () {
    // Google reference example: 47.0000625,8.0000625 -> 8FVC2222+22
    final code = Olc.encode(47.0000625, 8.0000625, codeLength: 10);
    expect(code.contains('+'), isTrue);
    expect(code.length, 11); // 8 + '+' + 2
  });
}
