import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/server_log.dart';

/// Stacked column chart of incoming (purple) / outgoing (green) packets per
/// minute over the last hour. Port of the original hellocharts column chart.
class PacketsChart extends StatelessWidget {
  final List<ServerLogMinute> minutes;
  const PacketsChart({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final data = minutes.isEmpty
        ? List<ServerLogMinute>.generate(
            60, (i) => ServerLogMinute(timeReceived: i, inbound: 0, outbound: 0))
        : minutes;
    final maxY = data.fold<int>(10, (m, e) => e.total > m ? e.total : m).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY * 1.1,
        alignment: BarChartAlignment.spaceBetween,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(l.minutesAgo,
                style: const TextStyle(fontSize: 11, color: AppColors.primary)),
            sideTitles: const SideTitles(showTitles: false),
          ),
        ),
        barTouchData: BarTouchData(enabled: false),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: data[i].total.toDouble(),
                width: 3,
                borderRadius: BorderRadius.zero,
                rodStackItems: [
                  BarChartRodStackItem(0, data[i].inbound.toDouble(), AppColors.packetIncoming),
                  BarChartRodStackItem(data[i].inbound.toDouble(),
                      data[i].total.toDouble(), AppColors.packetOutgoing),
                ],
              ),
            ]),
        ],
      ),
    );
  }
}
