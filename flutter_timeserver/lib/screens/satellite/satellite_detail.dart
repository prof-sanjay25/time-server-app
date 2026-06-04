import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/satellite_info.dart';

/// Per-satellite detail, ported from `SatelliteDetailFragment`.
class SatelliteDetail extends StatelessWidget {
  final SatelliteInfo satellite;
  const SatelliteDetail({super.key, required this.satellite});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = satellite;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.label,
              style: const TextStyle(fontSize: 28, color: AppColors.primaryDark)),
          const SizedBox(height: 16),
          _row(l.satelliteDetailSnr, '${s.cn0DbHz.toStringAsFixed(1)} dB-Hz'),
          _row(l.satelliteDetailElevation, '${s.elevationDegrees.toStringAsFixed(0)}°'),
          _row(l.satelliteDetailAzimuth, '${s.azimuthDegrees.toStringAsFixed(0)}°'),
          if (s.carrierMhz != null)
            _row(l.satelliteDetailCarrier,
                '${s.carrierMhz!.toStringAsFixed(3)} MHz${s.band != null ? ' (${s.band})' : ''}'),
          _row('Used in fix', s.usedInFix ? '✓' : '—'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, color: AppColors.grey)),
            Text(value, style: const TextStyle(fontSize: 18, color: AppColors.primaryDark)),
          ],
        ),
      );
}
