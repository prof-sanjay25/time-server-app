import 'package:flutter/services.dart';

import '../models/ntp_server_status.dart';
import '../models/server_log.dart';
import 'channels.dart';

/// Dart facade over the native NTP foreground service.
class NtpPlatform {
  static const MethodChannel _method = MethodChannel(Channels.ntpMethod);
  static const EventChannel _statusEvents = EventChannel(Channels.ntpStatusEvent);
  static const EventChannel _logEvents = EventChannel(Channels.ntpLogsEvent);

  /// Start the foreground service + UDP server. Returns the resulting status.
  Future<NtpServerStatus> startServer({
    required int port,
    required int stratum,
    required int packetLimit,
    String? interfaceName,
  }) async {
    final res = await _method.invokeMethod<Map<dynamic, dynamic>>('startServer', {
      'port': port,
      'stratum': stratum,
      'packetLimit': packetLimit,
      'interface': interfaceName,
    });
    return NtpServerStatus.fromMap(res ?? const {});
  }

  Future<bool> stopServer() async =>
      (await _method.invokeMethod<bool>('stopServer')) ?? false;

  Future<NtpServerStatus> getStatus() async {
    final res = await _method.invokeMethod<Map<dynamic, dynamic>>('getStatus');
    return NtpServerStatus.fromMap(res ?? const {});
  }

  Future<void> setStratum(int stratum) =>
      _method.invokeMethod('setStratum', {'stratum': stratum});

  Future<void> setPacketLimit(int limit) =>
      _method.invokeMethod('setPacketLimit', {'limit': limit});

  Future<void> setInterface(String name) =>
      _method.invokeMethod('setInterface', {'name': name});

  /// Attempt the root `iptables` 123->1234 redirect. Returns {rooted, redirected}.
  Future<({bool rooted, bool redirected})> tryRootRedirect() async {
    final res = await _method.invokeMethod<Map<dynamic, dynamic>>('tryRootRedirect');
    return (
      rooted: (res?['rooted'] as bool?) ?? false,
      redirected: (res?['redirected'] as bool?) ?? false,
    );
  }

  Stream<NtpServerStatus> statusStream() => _statusEvents
      .receiveBroadcastStream()
      .map((e) => NtpServerStatus.fromMap(e as Map<dynamic, dynamic>));

  /// Stream of the last 60 one-minute summaries (most recent last).
  Stream<List<ServerLogMinute>> logStream() =>
      _logEvents.receiveBroadcastStream().map((e) {
        final list = (e as List).cast<Map<dynamic, dynamic>>();
        return list.map(ServerLogMinute.fromMap).toList();
      });
}
