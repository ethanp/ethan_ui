import 'package:flutter/painting.dart';

/// How a series connects its points in plot space.
enum EChartInterpolation() {
  polyline,
  monotoneCubic,

  /// One sample per pixel of increasing X — same as spend_trends pace lines.
  alongIncreasingX;

  Path pathThrough(List<Offset> offsets) {
    return switch (this) {
      polyline => polylinePath(offsets),
      monotoneCubic => MonotoneCubic.pathThrough(offsets),
      alongIncreasingX => alongIncreasingXPath(offsets),
    };
  }

  /// Y on the same interpolant used for painting. Outside the X span, clamps
  /// to the nearest endpoint.
  double yAtX(List<Offset> offsets, double x) {
    return switch (this) {
      polyline || alongIncreasingX => polylineYAtX(offsets, x),
      monotoneCubic => MonotoneCubic.yAtX(offsets, x),
    };
  }

  static Path polylinePath(List<Offset> offsets) {
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var offsetIndex = 1; offsetIndex < offsets.length; offsetIndex++) {
      path.lineTo(offsets[offsetIndex].dx, offsets[offsetIndex].dy);
    }
    return path;
  }

  static double polylineYAtX(List<Offset> offsets, double x) {
    if (offsets.length == 1) return offsets.first.dy;
    if (x <= offsets.first.dx) return offsets.first.dy;
    if (x >= offsets.last.dx) return offsets.last.dy;
    for (var index = 0; index < offsets.length - 1; index++) {
      final left = offsets[index];
      final right = offsets[index + 1];
      if (x > right.dx) continue;
      final spanX = right.dx - left.dx;
      if (spanX <= 0) return right.dy;
      final alongSegment = ((x - left.dx) / spanX).clamp(0.0, 1.0);
      return left.dy + (right.dy - left.dy) * alongSegment;
    }
    return offsets.last.dy;
  }

  static Path alongIncreasingXPath(List<Offset> offsets) {
    if (offsets.length < 2) return polylinePath(offsets);
    final startX = offsets.first.dx;
    final endX = offsets.last.dx;
    if (endX <= startX) return polylinePath(offsets);
    final path = Path();
    var isFirstSample = true;
    for (var sampleX = startX; sampleX <= endX; sampleX += 1) {
      final sampleY = polylineYAtX(offsets, sampleX);
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

/// Fritsch–Carlson monotone cubic in plot space.
///
/// Falls back to a polyline when there are fewer than 3 points or any segment
/// has non-increasing X.
class MonotoneCubic() {
  static Path pathThrough(List<Offset> offsets) {
    final interpolant = tryFit(offsets);
    if (interpolant == null) {
      return EChartInterpolation.polylinePath(offsets);
    }
    return interpolant.path;
  }

  static double yAtX(List<Offset> offsets, double x) {
    final interpolant = tryFit(offsets);
    if (interpolant == null) {
      return EChartInterpolation.polylineYAtX(offsets, x);
    }
    return interpolant.yAtX(x);
  }

  static MonotoneCubicFit? tryFit(List<Offset> offsets) {
    if (offsets.length < 3) return null;
    final segmentSlopes = <double>[];
    for (var index = 0; index < offsets.length - 1; index++) {
      final width = offsets[index + 1].dx - offsets[index].dx;
      if (width <= 0) return null;
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
      final tangent =
          (leftWidth + rightWidth) /
          (leftWidth / leftSlope + rightWidth / rightSlope);
      tangents.add(tangent.isFinite ? tangent : 0);
    }
    tangents.add(segmentSlopes.last);
    if (tangents.any((tangent) => !tangent.isFinite)) return null;
    return MonotoneCubicFit(offsets: offsets, tangents: tangents);
  }
}

class const MonotoneCubicFit({
  required final List<Offset> offsets,
  required final List<double> tangents,
}) {
  Path get path {
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

  double yAtX(double x) {
    if (x <= offsets.first.dx) return offsets.first.dy;
    if (x >= offsets.last.dx) return offsets.last.dy;
    for (var index = 0; index < offsets.length - 1; index++) {
      final left = offsets[index];
      final right = offsets[index + 1];
      if (x > right.dx) continue;
      final width = right.dx - left.dx;
      final t = ((x - left.dx) / width).clamp(0.0, 1.0);
      return _cubicY(index, t);
    }
    return offsets.last.dy;
  }

  double _cubicY(int segmentIndex, double t) {
    final left = offsets[segmentIndex];
    final right = offsets[segmentIndex + 1];
    final thirdWidth = (right.dx - left.dx) / 3;
    final control1Y = left.dy + tangents[segmentIndex] * thirdWidth;
    final control2Y = right.dy - tangents[segmentIndex + 1] * thirdWidth;
    final oneMinusT = 1 - t;
    return oneMinusT * oneMinusT * oneMinusT * left.dy +
        3 * oneMinusT * oneMinusT * t * control1Y +
        3 * oneMinusT * t * t * control2Y +
        t * t * t * right.dy;
  }
}
