import 'package:flutter/painting.dart';

import '../theme/e_colors.dart';
import 'e_chart_line.dart';
import 'e_chart_plot.dart';
import 'e_chart_selected_point.dart';

/// Polylines, optional fills, and dots in plot space.
class const EChartLinesPaint({
  required final EChartPlot plot,
  required final List<EChartLine> lines,
  final EChartSelectedPoint? selectedPoint,
}) {
  void paint(Canvas canvas) {
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(plot.left, plot.top, plot.right, plot.bottom));
    final selectedLineIndex = selectedPoint?.lineIndex;
    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      if (lineIndex == selectedLineIndex) continue;
      _paintLine(canvas, lines[lineIndex], lineIndex);
    }
    if (selectedLineIndex != null &&
        selectedLineIndex >= 0 &&
        selectedLineIndex < lines.length) {
      _paintLine(canvas, lines[selectedLineIndex], selectedLineIndex);
    }
    canvas.restore();
  }

  void _paintLine(Canvas canvas, EChartLine line, int lineIndex) {
    if (line.points.isEmpty) return;
    final offsets = [
      for (final point in line.points)
        Offset(plot.xForDate(point.date), plot.yForValue(point.value)),
    ];
    if (offsets.length >= 2) {
      final path = line.stroke.pathThrough(offsets);
      if (line.fillColor != null) {
        final fill = Path.from(path)
          ..lineTo(offsets.last.dx, plot.bottom)
          ..lineTo(offsets.first.dx, plot.bottom)
          ..close();
        canvas.drawPath(
          fill,
          Paint()
            ..color = line.fillColor!
            ..style = PaintingStyle.fill,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = line.color
          ..strokeWidth = line.strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
    if (!line.showDots) return;
    for (var pointIndex = 0; pointIndex < line.points.length; pointIndex++) {
      _paintDot(
        canvas,
        line.points[pointIndex],
        offsets[pointIndex],
        isSelected:
            selectedPoint != null &&
            selectedPoint!.lineIndex == lineIndex &&
            selectedPoint!.pointIndex == pointIndex,
      );
    }
  }

  void _paintDot(
    Canvas canvas,
    EChartPoint point,
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
