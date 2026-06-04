import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../core/gnss/grey_level.dart';
import '../../models/satellite_info.dart';

/// Polar sky plot of the GNSS constellation (azimuth around, elevation as
/// radius). Triangle = used in fix, square = visible only; shade encodes Cn0.
/// Port of the original `SatelliteRadialChart` (north-up; a heading needle
/// indicates device compass direction).
class RadialSkyPlot extends StatelessWidget {
  final List<SatelliteInfo> satellites;
  final double headingDegrees;
  final int? selectedSvid;
  final void Function(SatelliteInfo) onTap;

  const RadialSkyPlot({
    super.key,
    required this.satellites,
    required this.onTap,
    this.headingDegrees = 0,
    this.selectedSvid,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(side / 2, side / 2);
        final radius = side / 2 * 0.86;
        return GestureDetector(
          onTapUp: (d) {
            final hit = _hitTest(d.localPosition, center, radius);
            if (hit != null) onTap(hit);
          },
          child: CustomPaint(
            size: Size.square(side),
            painter: _SkyPainter(satellites, headingDegrees, selectedSvid),
          ),
        );
      },
    );
  }

  static Offset _project(SatelliteInfo s, Offset center, double radius) {
    final r = ((90.0 - s.elevationDegrees.clamp(0, 90)) / 90.0) * radius;
    final a = (s.azimuthDegrees - 90.0) * math.pi / 180.0;
    return center + Offset(r * math.cos(a), r * math.sin(a));
  }

  SatelliteInfo? _hitTest(Offset p, Offset center, double radius) {
    SatelliteInfo? best;
    double bestDist = 26;
    for (final s in satellites) {
      final d = (_project(s, center, radius) - p).distance;
      if (d < bestDist) {
        bestDist = d;
        best = s;
      }
    }
    return best;
  }
}

class _SkyPainter extends CustomPainter {
  final List<SatelliteInfo> sats;
  final double heading;
  final int? selectedSvid;
  _SkyPainter(this.sats, this.heading, this.selectedSvid);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.86;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.greyLight;

    // Elevation rings at 0, 30, 60 degrees.
    for (final el in [0.0, 30.0, 60.0]) {
      canvas.drawCircle(center, (90 - el) / 90 * radius, ring);
    }
    // Crosshair.
    canvas.drawLine(Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy), ring);
    canvas.drawLine(Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius), ring);

    _label(canvas, 'N', Offset(center.dx, center.dy - radius - 14));
    _label(canvas, 'S', Offset(center.dx, center.dy + radius + 4));
    _label(canvas, 'E', Offset(center.dx + radius + 8, center.dy - 8));
    _label(canvas, 'W', Offset(center.dx - radius - 14, center.dy - 8));

    // Device heading needle.
    final ha = (heading - 90) * math.pi / 180.0;
    final needle = Paint()
      ..color = AppColors.blue.withValues(alpha: 0.6)
      ..strokeWidth = 2;
    canvas.drawLine(
        center, center + Offset(radius * math.cos(ha), radius * math.sin(ha)), needle);

    // Satellites.
    for (final s in sats) {
      final pos = RadialSkyPlot._project(s, center, radius);
      final selected = s.svid == selectedSvid;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = selected ? AppColors.blue : GreyLevel.color(s.cn0DbHz);
      if (s.usedInFix) {
        _triangle(canvas, pos, 9, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: pos, width: 14, height: 14), paint);
      }
      _label(canvas, '${s.svid}', pos + const Offset(10, -16), size: 10, color: AppColors.greyDark);
    }
  }

  void _triangle(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx - r, c.dy + r)
      ..lineTo(c.dx + r, c.dy + r)
      ..close();
    canvas.drawPath(path, p);
  }

  void _label(Canvas canvas, String text, Offset at,
      {double size = 13, Color color = AppColors.greyDark}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.sats != sats || old.heading != heading || old.selectedSvid != selectedSvid;
}
