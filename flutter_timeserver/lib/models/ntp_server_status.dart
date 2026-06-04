import '../constants/ntp_constants.dart';

/// Current state of the native NTP foreground service.
class NtpServerStatus {
  final bool running;
  final String ip;
  final int port;
  final String? interfaceName;
  final int stratum;
  final bool rootRedirected;
  final int packetsPerMin;

  const NtpServerStatus({
    required this.running,
    required this.ip,
    required this.port,
    this.interfaceName,
    this.stratum = NtpConstants.defaultStratum,
    this.rootRedirected = false,
    this.packetsPerMin = 0,
  });

  static const NtpServerStatus stopped = NtpServerStatus(
    running: false,
    ip: '0.0.0.0',
    port: NtpConstants.unrestrictedPort,
  );

  factory NtpServerStatus.fromMap(Map<dynamic, dynamic> m) => NtpServerStatus(
        running: (m['running'] as bool?) ?? false,
        ip: (m['ip'] as String?) ?? '0.0.0.0',
        port: (m['port'] as num?)?.toInt() ?? NtpConstants.unrestrictedPort,
        interfaceName: m['interface'] as String?,
        stratum: (m['stratum'] as num?)?.toInt() ?? NtpConstants.defaultStratum,
        rootRedirected: (m['rootRedirected'] as bool?) ?? false,
        packetsPerMin: (m['packetsPerMin'] as num?)?.toInt() ?? 0,
      );

  /// e.g. "wlan0, 192.168.1.50:1234" or "192.168.1.50:1234".
  String get endpointLabel {
    final base = '$ip:$port';
    return (interfaceName == null || interfaceName!.isEmpty) ? base : '$interfaceName, $base';
  }

  NtpServerStatus copyWith({int? packetsPerMin}) => NtpServerStatus(
        running: running,
        ip: ip,
        port: port,
        interfaceName: interfaceName,
        stratum: stratum,
        rootRedirected: rootRedirected,
        packetsPerMin: packetsPerMin ?? this.packetsPerMin,
      );
}
