import 'package:flutter/painting.dart';

import 'e_chart_line.dart';
import 'e_chart_plot.dart';
import 'e_chart_selected_point.dart';

/// Nearest chart point by pixel distance.
class const EChartHitTest({
  required final EChartPlot plot,
  required final List<EChartLine> lines,
}) {
  static const defaultMaxDistance = 28.0;

  EChartSelectedPoint? nearestPoint(
    Offset local, {
    double maxDistance = defaultMaxDistance,
  }) {
    EChartSelectedPoint? closest;
    var closestDistance = maxDistance;
    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      for (var pointIndex = 0; pointIndex < line.points.length; pointIndex++) {
        final point = line.points[pointIndex];
        final distance = (Offset(plot.xForDate(point.date), plot.yForValue(point.value)) -
                local)
            .distance;
        if (distance <= closestDistance) {
          closestDistance = distance;
          closest = EChartSelectedPoint(
            line: line,
            point: point,
            lineIndex: lineIndex,
            pointIndex: pointIndex,
          );
        }
      }
    }
    return closest;
  }
}
