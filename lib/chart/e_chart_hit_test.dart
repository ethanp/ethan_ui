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
    final barHit = _barColumnContaining(local);
    if (barHit != null) return barHit;
    EChartSelectedPoint<T>? closest;
    var closestDistance = maxDistance;
    for (final seriesItem in series) {
      if (seriesItem.hits == EChartPointHits.ignore) continue;
      if (seriesItem.paintsBars) continue;
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

  EChartSelectedPoint<T>? _barColumnContaining(Offset local) {
    if (!plot.contains(local)) return null;
    EChartSelectedPoint<T>? closest;
    var closestDistance = double.infinity;
    for (final seriesItem in series) {
      if (seriesItem.hits == EChartPointHits.ignore) continue;
      if (!seriesItem.paintsBars) continue;
      for (final point in seriesItem.points) {
        final until = point.until;
        if (until == null || !until.isAfter(point.date)) continue;
        final bar = plot.barSpan(
          start: point.date,
          until: until,
          value: point.value,
        );
        if (local.dx < bar.left || local.dx > bar.right) continue;
        final distance = (bar.center - local).distance;
        if (distance >= closestDistance) continue;
        closestDistance = distance;
        closest = EChartSelectedPoint(
          seriesId: seriesItem.id,
          pointId: point.id,
          date: point.date,
          value: point.value,
        );
      }
    }
    return closest;
  }
}
