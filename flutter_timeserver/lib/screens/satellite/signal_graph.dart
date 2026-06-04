import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../core/gnss/grey_level.dart';
import '../../models/satellite_info.dart';

/// Signal-strength (Cn0) bar chart, sorted strongest-first; tap a bar to select
/// a satellite. Port of the original `SignalGraphFragment` (hellocharts).
class SignalGraph extends StatelessWidget {
  final List<SatelliteInfo> satellites;
  final int? selectedSvid;
  final void Function(SatelliteInfo) onTap;

  const SignalGraph({
    super.key,
    required this.satellites,
    required this.onTap,
    this.selectedSvid,
  });

  @override
  Widget build(BuildContext context) {
    final sats = [...satellites]..sort((a, b) => b.cn0DbHz.compareTo(a.cn0DbHz));
    if (sats.isEmpty) {
      return const Center(child: Text('—'));
    }

    return BarChart(
      BarChartData(
        maxY: 50,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 10),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= sats.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${sats[i].svid}',
                      style: const TextStyle(fontSize: 9, color: AppColors.greyDark)),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response?.spot != null) {
              final i = response!.spot!.touchedBarGroupIndex;
              if (i >= 0 && i < sats.length) onTap(sats[i]);
            }
          },
        ),
        barGroups: [
          for (var i = 0; i < sats.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: sats[i].cn0DbHz.clamp(0, 50),
                width: 10,
                color: sats[i].svid == selectedSvid
                    ? AppColors.blue
                    : GreyLevel.color(sats[i].cn0DbHz),
                borderRadius: BorderRadius.zero,
              ),
            ]),
        ],
      ),
    );
  }
}
