import 'package:flutter/material.dart';

import 'e_chart_annotation.dart';
import 'e_chart_chrome.dart';
import 'e_chart_hit_test.dart';
import 'e_chart_lines_paint.dart';
import 'e_chart_plot.dart';
import 'e_chart_selected_point.dart';
import 'e_chart_series.dart';
import 'e_chart_value_scale.dart';

/// A dated value chart: series, optional annotations, tap and hover.
class const EChart<T extends Object>({
  required final List<EChartSeries<T>> series,
  required final EChartValueScale valueScale,
  required final DateTime start,
  required final DateTime end,
  final List<EChartAnnotation> annotations = const [],
  final EChartSelectedPoint<T>? selectedPoint,
  final void Function(EChartSelectedPoint<T>? point)? onPointSelected,
  final void Function(EChartSelectedPoint<T>? point)? onHoveredPoint,
  final double leftPadding = 36,
  final double rightPadding = 8,
  final double topPadding = 8,
  final double bottomPadding = 22,
  final bool paintsValueTicks = true,
}) extends StatefulWidget {
  @override
  State<EChart<T>> createState() => _EChartState<T>();
}

class _EChartState<T extends Object>() extends State<EChart<T>> {
  EChartSelectedPoint<T>? _hoveredPoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final plot = EChartPlot(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          start: widget.start,
          end: widget.end,
          valueScale: widget.valueScale,
          leftPadding: widget.leftPadding,
          rightPadding: widget.rightPadding,
          topPadding: widget.topPadding,
          bottomPadding: widget.bottomPadding,
        );
        return MouseRegion(
          onHover: (event) => _hover(event.localPosition, plot),
          onExit: (_) {
            if (_hoveredPoint == null) return;
            setState(() => _hoveredPoint = null);
            widget.onHoveredPoint?.call(null);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _select(details.localPosition, plot),
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _EChartPainter<T>(
                plot: plot,
                series: widget.series,
                annotations: widget.annotations,
                selectedPoint: widget.selectedPoint,
                hoveredPoint: _hoveredPoint,
                paintsValueTicks: widget.paintsValueTicks,
              ),
            ),
          ),
        );
      },
    );
  }

  void _hover(Offset local, EChartPlot plot) {
    final hovered = EChartHitTest(
      plot: plot,
      series: widget.series,
    ).nearestPoint(local);
    if (hovered == _hoveredPoint) return;
    setState(() => _hoveredPoint = hovered);
    widget.onHoveredPoint?.call(hovered);
  }

  void _select(Offset local, EChartPlot plot) {
    final selected = EChartHitTest(
      plot: plot,
      series: widget.series,
    ).nearestPoint(local);
    widget.onPointSelected?.call(selected);
  }
}

class _EChartPainter<T extends Object>({
  required final EChartPlot plot,
  required final List<EChartSeries<T>> series,
  required final List<EChartAnnotation> annotations,
  required final EChartSelectedPoint<T>? selectedPoint,
  required final EChartSelectedPoint<T>? hoveredPoint,
  required final bool paintsValueTicks,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    EChartChrome(plot, paintsValueTicks: paintsValueTicks).paint(canvas);
    EChartLinesPaint(
      plot: plot,
      series: series,
      selectedPoint: selectedPoint ?? hoveredPoint,
    ).paint(canvas);
    for (final annotation in annotations) {
      annotation.paint(canvas, plot);
    }
  }

  @override
  bool shouldRepaint(covariant _EChartPainter<T> oldDelegate) {
    return plot.start != oldDelegate.plot.start ||
        plot.end != oldDelegate.plot.end ||
        plot.valueScale != oldDelegate.plot.valueScale ||
        plot.width != oldDelegate.plot.width ||
        plot.height != oldDelegate.plot.height ||
        !identical(series, oldDelegate.series) ||
        !identical(annotations, oldDelegate.annotations) ||
        selectedPoint != oldDelegate.selectedPoint ||
        hoveredPoint != oldDelegate.hoveredPoint ||
        paintsValueTicks != oldDelegate.paintsValueTicks;
  }
}
