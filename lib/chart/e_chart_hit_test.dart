import 'package:flutter/painting.dart';

import 'e_chart_plot.dart';
import 'e_chart_selected_point.dart';
import 'e_chart_series.dart';

/// Nearest chart point by pixel distance.
class const EChartHitTest<T extends Object>({
  required final EChartPlot plot,
  required final List<EChartSeries<T>> series,
}) {
  static const defaultMaxDistance = 28.0;

  EChartSelectedPoint<T>? nearestPoint(
    Offset local, {
    double maxDistance = defaultMaxDistance,
  }) {
    EChartSelectedPoint<T>? closest;
    var closestDistance = maxDistance;
    for (final seriesItem in series) {
      if (seriesItem.hits == EChartPointHits.ignore) continue;
      for (final point in seriesItem.points) {
        final distance =
            (Offset(plot.xForDate(point.date), plot.yForValue(point.value)) -
                    local)
                .distance;
        if (distance <= closestDistance) {
          closestDistance = distance;
          closest = EChartSelectedPoint(
            seriesId: seriesItem.id,
            pointId: point.id,
            date: point.date,
            value: point.value,
          );
        }
      }
    }
    return closest;
  }
}
