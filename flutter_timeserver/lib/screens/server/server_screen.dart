import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../core/time/time_standards.dart';
import '../../l10n/app_localizations.dart';
import '../../models/gps_time_info.dart';
import '../../models/server_log.dart';
import '../../providers/providers.dart';
import 'packets_chart.dart';
import 'server_options_sheet.dart';

/// Server tab: on/off switch, live packets/min chart, server time, and the
/// interface/IP/port the server is reachable on. Ports `ServerFragment`.
class ServerScreen extends ConsumerStatefulWidget {
  const ServerScreen({super.key});

  @override
  ConsumerState<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends ConsumerState<ServerScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _toggle(bool on) async {
    final l = AppLocalizations.of(context)!;
    final ctrl = ref.read(serverControllerProvider.notifier);
    if (on) {
      await ctrl.start();
      final r = await ctrl.tryRoot();
      if (!r.rooted) {
        _snack(l.noRootWarning);
      } else if (r.redirected) {
        _snack(l.rootRedirectSuccess);
      }
    } else {
      await ctrl.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final status = ref.watch(serverControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final logs = ref.watch(serverLogProvider).valueOrNull ?? const <ServerLogMinute>[];
    final gps = ref.watch(gpsTimeProvider).valueOrNull ?? GpsTimeInfo.empty;

    final perMin = logs.isNotEmpty ? logs.last.total : status.packetsPerMin;
    final serverTime = status.running && gps.hasFix
        ? TimeStandards.format(settings.timeStandard, _extrapolated(gps))
        : '--:--:--.--';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 200, child: PacketsChart(minutes: logs)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$perMin',
                    style: const TextStyle(fontSize: 40, color: AppColors.primaryDark)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(l.packetsPerMin,
                      style: const TextStyle(fontSize: 18, color: AppColors.primaryDark)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$serverTime ${TimeStandards.suffix(settings.timeStandard)}',
                style: const TextStyle(fontSize: 32, color: AppColors.primaryDark)),
            const Spacer(),
            // Endpoint + port note
            Text(status.running ? '${l.runningOn} ${status.endpointLabel}' : '',
                style: const TextStyle(fontSize: 16, color: AppColors.primary)),
            Text(l.portNote,
                style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            const Divider(),
            Row(
              children: [
                Switch(value: status.running, onChanged: _toggle),
                Text(l.sntpServer,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.blue),
                  tooltip: l.optionsTitle,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const ServerOptionsSheet(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime _extrapolated(GpsTimeInfo gps) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(
        gps.gpsMillis + (nowMs - gps.systemMillis),
        isUtc: true);
  }
}
