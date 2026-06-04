import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../models/gps_time_info.dart';
import '../../providers/providers.dart';

/// Time-tab options: measurement, time standard, coordinate standard, plus
/// open-in-maps and copy-to-clipboard. Ports `OptionsDialogFragment`.
class TimeOptionsSheet extends ConsumerWidget {
  const TimeOptionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);
    final gps = ref.read(gpsTimeProvider).valueOrNull;

    void snack(String msg) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(l.measurementTitle),
          DropdownButton<MeasurementSystem>(
            value: settings.measurement,
            isExpanded: true,
            onChanged: (v) => v == null ? null : ctrl.setMeasurement(v),
            items: [
              DropdownMenuItem(value: MeasurementSystem.metric, child: Text(l.measurementMetric)),
              DropdownMenuItem(value: MeasurementSystem.imperial, child: Text(l.measurementImperial)),
            ],
          ),
          const SizedBox(height: 16),
          _label(l.timeStandardTitle),
          DropdownButton<TimeStandard>(
            value: settings.timeStandard,
            isExpanded: true,
            onChanged: (v) => v == null ? null : ctrl.setTimeStandard(v),
            items: [
              DropdownMenuItem(value: TimeStandard.utc, child: Text(l.timeStdUtc)),
              DropdownMenuItem(value: TimeStandard.local, child: Text(l.timeStdLocal)),
              DropdownMenuItem(value: TimeStandard.decimal, child: Text(l.timeStdDecimal)),
              DropdownMenuItem(value: TimeStandard.swatch, child: Text(l.timeStdSwatch)),
            ],
          ),
          const SizedBox(height: 16),
          _label(l.coordinateTitle),
          DropdownButton<CoordinateType>(
            value: settings.coordinateType,
            isExpanded: true,
            onChanged: (v) => v == null ? null : ctrl.setCoordinateType(v),
            items: const [
              DropdownMenuItem(value: CoordinateType.wgs84, child: Text('WGS84 (Lat/Long)')),
              DropdownMenuItem(value: CoordinateType.utm, child: Text('UTM')),
              DropdownMenuItem(value: CoordinateType.mgrs, child: Text('MGRS')),
              DropdownMenuItem(value: CoordinateType.olc, child: Text('OLC (Plus Codes)')),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.openInMaps),
            leading: const Icon(Icons.map_outlined),
            onTap: () => _openMaps(context, gps, l, snack),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.copyToClipboard),
            leading: const Icon(Icons.copy),
            onTap: () => _copy(context, gps, l, snack),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark, minimumSize: const Size.fromHeight(52)),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.done),
          ),
        ],
      ),
    );
  }

  Future<void> _openMaps(BuildContext context, GpsTimeInfo? gps,
      AppLocalizations l, void Function(String) snack) async {
    if (gps == null || !gps.hasLocation) {
      snack(l.noLocationFound);
      return;
    }
    final uri = Uri.parse('geo:${gps.latitude},${gps.longitude}?q=${gps.latitude},${gps.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      snack(l.mapsNotInstalled);
    }
  }

  Future<void> _copy(BuildContext context, GpsTimeInfo? gps,
      AppLocalizations l, void Function(String) snack) async {
    if (gps == null || !gps.hasLocation) {
      snack(l.noLocationFound);
      return;
    }
    await Clipboard.setData(ClipboardData(text: '${gps.latitude}, ${gps.longitude}'));
    snack(l.copied);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 18, color: AppColors.black)),
      );
}
