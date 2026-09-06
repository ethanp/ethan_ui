import 'package:flutter/painting.dart';

import '../theme/e_colors.dart';

/// How a line connects its points.
enum EChartLineStroke() {
  polyline,
  /// One sample per pixel of increasing X — same as spend_trends pace lines.
  alongIncreasingX;

  Path pathThrough(List<Offset> offsets) {
    return switch (this) {
      polyline => _polyline(offsets),
      alongIncreasingX => _alongIncreasingX(offsets),
    };
  }

  Path _polyline(List<Offset> offsets) {
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var offsetIndex = 1; offsetIndex < offsets.length; offsetIndex++) {
      path.lineTo(offsets[offsetIndex].dx, offsets[offsetIndex].dy);
    }
    return path;
  }

  Path _alongIncreasingX(List<Offset> offsets) {
    if (offsets.length < 2) return _polyline(offsets);
    final startX = offsets.first.dx;
    final endX = offsets.last.dx;
    if (endX <= startX) return _polyline(offsets);
    final path = Path();
    var leftIndex = 0;
    var isFirstSample = true;
    for (var sampleX = startX; sampleX <= endX; sampleX += 1) {
      while (leftIndex < offsets.length - 2 &&
          offsets[leftIndex + 1].dx < sampleX) {
        leftIndex++;
      }
      final left = offsets[leftIndex];
      final right = offsets[leftIndex + 1];
      final spanX = right.dx - left.dx;
      final alongSegment = spanX <= 0
          ? 1.0
          : ((sampleX - left.dx) / spanX).clamp(0.0, 1.0);
      final sampleY = left.dy + (right.dy - left.dy) * alongSegment;
      if (isFirstSample) {
        path.moveTo(sampleX, sampleY);
        isFirstSample = false;
      } else {
        path.lineTo(sampleX, sampleY);
      }
    }
    return path;
  }
}

/// One dated value on a line.
class const EChartPoint({
  required final DateTime date,
  required final double value,
  final Color? color,
  final double? dotRadius,
});

/// A series through time.
class const EChartLine({
  required final List<EChartPoint> points,
  final Color color = EColors.border,
  final double strokeWidth = 1.2,
  final bool showDots = true,
  final EChartLineStroke stroke = EChartLineStroke.polyline,
  final Color? fillColor,
  final String? label,
});
