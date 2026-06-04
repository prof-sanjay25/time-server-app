import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../constants/ntp_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/network_interface_info.dart';
import '../../providers/providers.dart';

/// Server configuration: stratum, network interface, throttle, auto-start.
/// Ports `ServerDialogFragment`. Changes persist and apply live if running.
class ServerOptionsSheet extends ConsumerWidget {
  const ServerOptionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsControllerProvider);
    final settingsCtrl = ref.read(settingsControllerProvider.notifier);
    final ntp = ref.read(ntpPlatformProvider);
    final running = ref.watch(serverControllerProvider).running;
    final ifaces = ref.watch(interfacesProvider).valueOrNull ?? const <NetworkInterfaceInfo>[];

    final ifaceNames = <String>{
      ...ifaces.map((e) => e.name),
      'wlan0', 'eth0', 'usb0',
      settings.interfaceName,
    }.toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(l.stratumTitle),
          DropdownButton<int>(
            value: settings.stratum,
            isExpanded: true,
            onChanged: (v) {
              if (v == null) return;
              settingsCtrl.setStratum(v);
              if (running) ntp.setStratum(v);
            },
            items: [
              for (final s in NtpConstants.stratumChoices)
                DropdownMenuItem(value: s, child: Text('$s')),
            ],
          ),
          const SizedBox(height: 16),
          _label(l.networkTitle),
          DropdownButton<String>(
            value: ifaceNames.contains(settings.interfaceName)
                ? settings.interfaceName
                : ifaceNames.first,
            isExpanded: true,
            onChanged: (v) {
              if (v == null) return;
              settingsCtrl.setInterface(v);
              if (running) ntp.setInterface(v);
            },
            items: [
              for (final n in ifaceNames) DropdownMenuItem(value: n, child: Text(n)),
            ],
          ),
          const SizedBox(height: 16),
          _label(l.throttleTitle),
          DropdownButton<int>(
            value: settings.packetLimit,
            isExpanded: true,
            onChanged: (v) {
              if (v == null) return;
              settingsCtrl.setPacketLimit(v);
              if (running) ntp.setPacketLimit(v);
            },
            items: [
              for (final p in NtpConstants.packetChoices)
                DropdownMenuItem(value: p, child: Text(p == 0 ? l.unlimited : '$p')),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.autoStart),
            value: settings.autoStart,
            onChanged: settingsCtrl.setAutoStart,
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                minimumSize: const Size.fromHeight(52)),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.done),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 18, color: AppColors.black)),
      );
}
