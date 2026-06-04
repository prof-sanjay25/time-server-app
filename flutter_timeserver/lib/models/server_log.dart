/// Per-minute inbound/outbound packet counts, ported from
/// `ServerLogMinuteSummary`. Drives the server packets/min chart.
class ServerLogMinute {
  final int timeReceived;
  final int inbound;
  final int outbound;

  const ServerLogMinute({
    required this.timeReceived,
    required this.inbound,
    required this.outbound,
  });

  factory ServerLogMinute.fromMap(Map<dynamic, dynamic> m) => ServerLogMinute(
        timeReceived: (m['timeReceived'] as num).toInt(),
        inbound: (m['inbound'] as num?)?.toInt() ?? 0,
        outbound: (m['outbound'] as num?)?.toInt() ?? 0,
      );

  int get total => inbound + outbound;
}
