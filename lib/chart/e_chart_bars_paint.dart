import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../theme/e_colors.dart';
import 'e_chart_plot.dart';
import 'e_chart_selected_point.dart';
import 'e_chart_series.dart';

/// Date-axis bars in plot space. Clipped so a pan slides them instead of
/// remapping slot values.
class const EChartBarsPaint<T extends Object>({
  required final EChartPlot plot,
  required final List<EChartSeries<T>> series,
  final EChartSelectedPoint<T>? selectedPoint,
}) {
  void paint(Canvas canvas) {
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(plot.left, plot.top, plot.right, plot.bottom),
    );
    for (final seriesItem in series) {
      if (!seriesItem.paintsBars) continue;
      _paintSeries(canvas, seriesItem);
    }
    canvas.restore();
  }

  void _paintSeries(Canvas canvas, EChartSeries<T> seriesItem) {
    for (final point in seriesItem.points) {
      final until = point.until;
      if (until == null || !until.isAfter(point.date)) continue;
      final bar = plot.barSpan(
        start: point.date,
        until: until,
        value: point.value,
      );
      final radius = Radius.circular(math.min(3, bar.height));
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          bar,
          topLeft: radius,
          topRight: radius,
        ),
        Paint()..color = point.color ?? seriesItem.color,
      );
      final isSelected =
          selectedPoint != null &&
          selectedPoint!.seriesId == seriesItem.id &&
          selectedPoint!.pointId == point.id;
      if (!isSelected) continue;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          bar,
          topLeft: radius,
          topRight: radius,
        ),
        Paint()
          ..color = EColors.textPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }
}
