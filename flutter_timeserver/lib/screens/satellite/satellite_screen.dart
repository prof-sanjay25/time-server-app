import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/satellite_info.dart';
import '../../providers/providers.dart';
import 'radial_sky_plot.dart';
import 'satellite_detail.dart';
import 'signal_graph.dart';

/// Satellites tab: in-view/in-use counts, sky plot, and signal bars.
class SatelliteScreen extends ConsumerStatefulWidget {
  const SatelliteScreen({super.key});

  @override
  ConsumerState<SatelliteScreen> createState() => _SatelliteScreenState();
}

class _SatelliteScreenState extends ConsumerState<SatelliteScreen> {
  int? _selectedSvid;

  void _select(SatelliteInfo s) {
    setState(() => _selectedSvid = s.svid);
    showModalBottomSheet(
      context: context,
      builder: (_) => SatelliteDetail(satellite: s),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sats = ref.watch(satellitesProvider).valueOrNull ?? const <SatelliteInfo>[];
    final heading = ref.watch(compassProvider).valueOrNull ?? 0.0;
    final inUse = sats.where((s) => s.usedInFix).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _counter('${sats.length}', l.inView),
                _counter('$inUse', l.inUse),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 3,
              child: RadialSkyPlot(
                satellites: sats,
                headingDegrees: heading,
                selectedSvid: _selectedSvid,
                onTap: _select,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: SignalGraph(
                satellites: sats,
                selectedSvid: _selectedSvid,
                onTap: _select,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counter(String value, String label) => Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 40, color: AppColors.primaryDark)),
          Text(label, style: const TextStyle(fontSize: 16, color: AppColors.primary)),
        ],
      );
}
