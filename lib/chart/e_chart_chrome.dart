import 'package:flutter/painting.dart';

import '../theme/e_chart_axis.dart';
import 'e_chart_plot.dart';

/// Edges, date ticks, value ticks, and year guides around a plot.
class const EChartChrome(
  final EChartPlot plot, {
  final bool paintsValueTicks = true,
}) {
  void paint(Canvas canvas) {
    paintValueGrid(canvas);
    strokePlotEdges(canvas);
    paintYearBoundaryGuides(canvas);
    paintDateTicks(canvas);
    if (paintsValueTicks) paintValueTicks(canvas);
  }

  void paintValueGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = EChartAxis.gridLine
      ..strokeWidth = 1;
    for (final tick in plot.valueScale.ticks) {
      if (tick == plot.valueScale.min) continue;
      final tickY = plot.yForValue(tick);
      canvas.drawLine(
        Offset(plot.left, tickY),
        Offset(plot.right, tickY),
        gridPaint,
      );
    }
  }

  void strokePlotEdges(Canvas canvas) {
    final axisPaint = Paint()
      ..color = EChartAxis.plotEdge
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axisPaint,
    );
  }

  void paintYearBoundaryGuides(Canvas canvas) {
    final boundaryXs = plot.yearBoundaryXs();
    if (boundaryXs.isEmpty) return;
    final linePaint = Paint()
      ..color = EChartAxis.gridLine
      ..strokeWidth = 1;
    for (final boundaryX in boundaryXs) {
      canvas.drawLine(
        Offset(boundaryX, plot.top),
        Offset(boundaryX, plot.bottom),
        linePaint,
      );
    }
  }

  void paintDateTicks(Canvas canvas) {
    final tickPaint = Paint()
      ..color = EChartAxis.plotEdge
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    const tickLength = 5.0;

    for (final date in plot.dateScale.tickDays) {
      final tickX = plot.xForDate(date);
      canvas.drawLine(
        Offset(tickX, plot.bottom),
        Offset(tickX, plot.bottom + tickLength),
        tickPaint,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: plot.dateScale.caption(date),
          style: EChartAxis.tickLabel,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelX = (tickX - textPainter.width / 2).clamp(
        plot.left - 4,
        plot.right - textPainter.width + 4,
      );
      textPainter.paint(canvas, Offset(labelX, plot.bottom + tickLength + 3));
    }
  }

  void paintValueTicks(Canvas canvas) {
    for (final tick in plot.valueScale.ticks) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: plot.valueScale.caption(tick),
          style: EChartAxis.tickLabel,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          plot.left - textPainter.width - 4,
          plot.yForValue(tick) - textPainter.height / 2,
        ),
      );
    }
  }
}
