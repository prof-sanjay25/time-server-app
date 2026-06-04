import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../core/coordinates/coordinate_formatter.dart';
import '../../core/time/time_standards.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../models/gps_time_info.dart';
import '../../providers/providers.dart';
import '../../widgets/gif_logo.dart';
import 'time_options_sheet.dart';

/// Time tab: GPS-disciplined clock, offset vs device clock, and location.
class TimeScreen extends ConsumerStatefulWidget {
  const TimeScreen({super.key});

  @override
  ConsumerState<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends ConsumerState<TimeScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  DateTime _extrapolatedUtc(GpsTimeInfo gps) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(
      gps.gpsMillis + (nowMs - gps.systemMillis),
      isUtc: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsControllerProvider);
    final gps = ref.watch(gpsTimeProvider).valueOrNull ?? GpsTimeInfo.empty;

    final timeStr = gps.hasFix
        ? TimeStandards.format(settings.timeStandard, _extrapolatedUtc(gps))
        : '--:--:--.--';

    final locationStr = gps.hasLocation
        ? CoordinateFormatter.format(settings.coordinateType, gps.latitude!, gps.longitude!)
        : '--';

    final imperial = settings.measurement == MeasurementSystem.imperial;
    final accVal = gps.accuracyMeters;
    final accStr = accVal == null
        ? '--'
        : (imperial ? (accVal * 3.28084).toStringAsFixed(1) : accVal.toStringAsFixed(1));
    final accUnit = imperial ? l.accuracyUnitsFeet : l.accuracyUnitsMeters;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: logo + PublicNTP + options
            Row(
              children: [
                const GifLogo(size: 64),
                const SizedBox(width: 8),
                Text(l.pntp,
                    style: const TextStyle(
                        fontSize: 26,
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.blue),
                  tooltip: l.optionsTitle,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const TimeOptionsSheet(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Time + standard suffix
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(timeStr,
                      style: const TextStyle(fontSize: 40, color: AppColors.primaryDark)),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(TimeStandards.suffix(settings.timeStandard),
                      style: const TextStyle(fontSize: 20, color: AppColors.primaryDark)),
                ),
              ],
            ),
            // Offset
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(gps.hasFix ? gps.offsetSecondsString : '±--',
                    style: const TextStyle(fontSize: 32, color: AppColors.primary)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(l.timeAccuracyUnits,
                      style: const TextStyle(fontSize: 20, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Location
            Text(locationStr,
                style: const TextStyle(fontSize: 34, color: AppColors.primaryDark)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(accStr, style: const TextStyle(fontSize: 32, color: AppColors.primary)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(accUnit,
                      style: const TextStyle(fontSize: 20, color: AppColors.primary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
