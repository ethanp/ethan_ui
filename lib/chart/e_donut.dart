import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One share of a whole.
class const EDonutSlice({
  required final double value,
  required final Color color,
});

/// Share-of-whole ring. Percents belong on the host legend.
class const EDonut({
  required final List<EDonutSlice> slices,
  final double thickness = 22,
  final double gapRadians = 0.04,
}) extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EDonutPainter(slices: slices, thickness: thickness, gapRadians: gapRadians),
      child: const SizedBox.expand(),
    );
  }
}

class _EDonutPainter({
  required final List<EDonutSlice> slices,
  required final double thickness,
  required final double gapRadians,
}) extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
    if (total <= 0) return;
    final side = math.min(size.width, size.height);
    final ringRect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: side / 2 - thickness / 2,
    );
    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2;
      final drawnSweep = math.max(0.0, sweep - gapRadians);
      canvas.drawArc(
        ringRect,
        startAngle + gapRadians / 2,
        drawnSweep,
        false,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _EDonutPainter oldDelegate) {
    return !identical(slices, oldDelegate.slices) ||
        thickness != oldDelegate.thickness ||
        gapRadians != oldDelegate.gapRadians;
  }
}
