import 'package:flutter/painting.dart';

import '../theme/e_colors.dart';

/// How a line connects its points.
enum EChartLineStroke() {
  polyline,
  monotoneCubic,

  /// One sample per pixel of increasing X — same as spend_trends pace lines.
  alongIncreasingX;

  Path pathThrough(List<Offset> offsets) {
    return switch (this) {
      polyline => _polyline(offsets),
      monotoneCubic => _monotoneCubic(offsets),
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

  Path _monotoneCubic(List<Offset> offsets) {
    if (offsets.length < 3) return _polyline(offsets);
    final segmentSlopes = <double>[];
    for (var index = 0; index < offsets.length - 1; index++) {
      final width = offsets[index + 1].dx - offsets[index].dx;
      if (width <= 0) return _polyline(offsets);
      segmentSlopes.add((offsets[index + 1].dy - offsets[index].dy) / width);
    }
    final tangents = <double>[segmentSlopes.first];
    for (var index = 1; index < offsets.length - 1; index++) {
      final leftSlope = segmentSlopes[index - 1];
      final rightSlope = segmentSlopes[index];
      if (leftSlope == 0 ||
          rightSlope == 0 ||
          leftSlope.sign != rightSlope.sign) {
        tangents.add(0);
        continue;
      }
      final leftWidth = offsets[index].dx - offsets[index - 1].dx;
      final rightWidth = offsets[index + 1].dx - offsets[index].dx;
      tangents.add(
        (leftWidth + rightWidth) /
            (leftWidth / leftSlope + rightWidth / rightSlope),
      );
    }
    tangents.add(segmentSlopes.last);

    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var index = 0; index < offsets.length - 1; index++) {
      final left = offsets[index];
      final right = offsets[index + 1];
      final thirdWidth = (right.dx - left.dx) / 3;
      path.cubicTo(
        left.dx + thirdWidth,
        left.dy + tangents[index] * thirdWidth,
        right.dx - thirdWidth,
        right.dy - tangents[index + 1] * thirdWidth,
        right.dx,
        right.dy,
      );
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

enum EChartLinePattern() {
  solid,
  dotted,
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
  final bool showStroke = true,
  final EChartLineStroke stroke = EChartLineStroke.polyline,
  final EChartLinePattern pattern = EChartLinePattern.solid,
  final bool isInteractive = true,
  final Color? fillColor,
  final String? label,
});
