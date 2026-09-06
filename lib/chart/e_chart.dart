import 'package:flutter/material.dart';

import 'e_chart_annotation.dart';
import 'e_chart_chrome.dart';
import 'e_chart_hit_test.dart';
import 'e_chart_line.dart';
import 'e_chart_lines_paint.dart';
import 'e_chart_plot.dart';
import 'e_chart_selected_point.dart';
import 'e_chart_value_scale.dart';

/// A dated value chart: lines, optional annotations, tap and hover.
class const EChart({
  required final List<EChartLine> lines,
  required final EChartValueScale valueScale,
  required final DateTime start,
  required final DateTime end,
  final List<EChartAnnotation> annotations = const [],
  final EChartSelectedPoint? selectedPoint,
  final void Function(EChartSelectedPoint? point)? onPointSelected,
  final void Function(EChartSelectedPoint? point)? onHoveredPoint,
  final double leftPadding = 36,
  final double rightPadding = 8,
  final double topPadding = 8,
  final double bottomPadding = 22,
}) extends StatefulWidget {
  @override
  State<EChart> createState() => _EChartState();
}

class _EChartState() extends State<EChart> {
  EChartSelectedPoint? _hoveredPoint;

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
              painter: _EChartPainter(
                plot: plot,
                lines: widget.lines,
                annotations: widget.annotations,
                selectedPoint: widget.selectedPoint,
                hoveredPoint: _hoveredPoint,
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
      lines: widget.lines,
    ).nearestPoint(local);
    if (hovered == _hoveredPoint) return;
    setState(() => _hoveredPoint = hovered);
    widget.onHoveredPoint?.call(hovered);
  }

  void _select(Offset local, EChartPlot plot) {
    final selected = EChartHitTest(
      plot: plot,
      lines: widget.lines,
    ).nearestPoint(local);
    widget.onPointSelected?.call(selected);
  }
}

class _EChartPainter({
  required final EChartPlot plot,
  required final List<EChartLine> lines,
  required final List<EChartAnnotation> annotations,
  required final EChartSelectedPoint? selectedPoint,
  required final EChartSelectedPoint? hoveredPoint,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    EChartChrome(plot).paint(canvas);
    EChartLinesPaint(
      plot: plot,
      lines: lines,
      selectedPoint: selectedPoint ?? hoveredPoint,
    ).paint(canvas);
    for (final annotation in annotations) {
      annotation.paint(canvas, plot);
    }
  }

  @override
  bool shouldRepaint(covariant _EChartPainter oldDelegate) {
    return plot.start != oldDelegate.plot.start ||
        plot.end != oldDelegate.plot.end ||
        plot.valueScale != oldDelegate.plot.valueScale ||
        plot.width != oldDelegate.plot.width ||
        plot.height != oldDelegate.plot.height ||
        !identical(lines, oldDelegate.lines) ||
        !identical(annotations, oldDelegate.annotations) ||
        selectedPoint != oldDelegate.selectedPoint ||
        hoveredPoint != oldDelegate.hoveredPoint;
  }
}
