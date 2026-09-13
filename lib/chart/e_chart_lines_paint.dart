import 'package:flutter/painting.dart';

import '../theme/e_colors.dart';
import 'e_chart_plot.dart';
import 'e_chart_selected_point.dart';
import 'e_chart_series.dart';

/// Strokes, optional fills, and dots in plot space.
class const EChartLinesPaint<T extends Object>({
  required final EChartPlot plot,
  required final List<EChartSeries<T>> series,
  final EChartSelectedPoint<T>? selectedPoint,
}) {
  void paint(Canvas canvas) {
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(plot.left, plot.top, plot.right, plot.bottom),
    );
    final selectedSeriesId = selectedPoint?.seriesId;
    for (final seriesItem in series) {
      if (seriesItem.id == selectedSeriesId) continue;
      _paintSeries(canvas, seriesItem);
    }
    final selectedSeries = series
        .where((seriesItem) => seriesItem.id == selectedSeriesId)
        .firstOrNull;
    if (selectedSeries != null) {
      _paintSeries(canvas, selectedSeries);
    }
    canvas.restore();
  }

  void _paintSeries(Canvas canvas, EChartSeries<T> seriesItem) {
    if (seriesItem.points.isEmpty) return;
    final offsets = [
      for (final point in seriesItem.points)
        Offset(plot.xForDate(point.date), plot.yForValue(point.value)),
    ];
    if (offsets.length >= 2 &&
        (seriesItem.paintsStroke || seriesItem.fillColor != null)) {
      final path = seriesItem.interpolation.pathThrough(offsets);
      final fillColor = seriesItem.fillColor;
      if (fillColor != null) {
        final fill = Path.from(path)
          ..lineTo(offsets.last.dx, plot.bottom)
          ..lineTo(offsets.first.dx, plot.bottom)
          ..close();
        canvas.drawPath(
          fill,
          Paint()
            ..color = fillColor
            ..style = PaintingStyle.fill,
        );
      }
      if (seriesItem.paintsStroke) {
        switch (seriesItem.dash) {
          case EChartStrokeDash.solid:
            canvas.drawPath(
              path,
              Paint()
                ..color = seriesItem.color
                ..strokeWidth = seriesItem.strokeWidth
                ..style = PaintingStyle.stroke
                ..strokeJoin = StrokeJoin.round
                ..strokeCap = StrokeCap.round,
            );
          case EChartStrokeDash.dotted:
            _paintDottedPath(canvas, path, seriesItem);
        }
      }
    }
    if (!seriesItem.paintsDots) return;
    for (
      var pointIndex = 0;
      pointIndex < seriesItem.points.length;
      pointIndex++
    ) {
      final point = seriesItem.points[pointIndex];
      _paintDot(
        canvas,
        point,
        offsets[pointIndex],
        isSelected:
            selectedPoint != null &&
            selectedPoint!.seriesId == seriesItem.id &&
            selectedPoint!.pointId == point.id,
      );
    }
  }

  void _paintDottedPath(Canvas canvas, Path path, EChartSeries<T> seriesItem) {
    final dotPaint = Paint()
      ..color = seriesItem.color
      ..style = PaintingStyle.fill;
    final gap = seriesItem.strokeWidth * 3;
    for (final pathMetric in path.computeMetrics()) {
      for (var distance = 0.0; distance <= pathMetric.length; distance += gap) {
        final tangent = pathMetric.getTangentForOffset(distance);
        if (tangent == null) continue;
        canvas.drawCircle(
          tangent.position,
          seriesItem.strokeWidth / 2,
          dotPaint,
        );
      }
    }
  }

  void _paintDot(
    Canvas canvas,
    EChartPoint<T> point,
    Offset offset, {
    required bool isSelected,
  }) {
    final radius = (point.dotRadius ?? 3) + (isSelected ? 3 : 0);
    canvas.drawCircle(
      offset,
      radius,
      Paint()..color = point.color ?? EColors.border,
    );
    if (isSelected) {
      canvas.drawCircle(
        offset,
        radius,
        Paint()
          ..color = EColors.textPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }
}
