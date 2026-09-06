import 'package:flutter/painting.dart';

import '../theme/e_chart_date_scale.dart';
import 'e_chart_value_scale.dart';

/// The rectangle where dates run left-to-right and values run up.
class EChartPlot({
  required Size size,
  required final DateTime start,
  required final DateTime end,
  required final EChartValueScale valueScale,
  final double leftPadding = 36,
  final double rightPadding = 8,
  final double topPadding = 8,
  final double bottomPadding = 22,
}) {
  this {
    left = leftPadding;
    right = size.width - rightPadding;
    top = topPadding;
    bottom = size.height - bottomPadding;
    width = right - left;
    height = bottom - top;
    _dateRangeSeconds = end.difference(start).inSeconds.toDouble();
    dateScale = EChartDateScale(start: start, end: end, plotWidth: width);
  }

  late final double left;
  late final double right;
  late final double top;
  late final double bottom;
  late final double width;
  late final double height;
  late final double _dateRangeSeconds;
  late final EChartDateScale dateScale;

  double xForDate(DateTime date) {
    if (_dateRangeSeconds == 0) return left + width / 2;
    return left +
        (date.difference(start).inSeconds / _dateRangeSeconds) * width;
  }

  DateTime dateForX(double x) {
    if (width == 0) return start;
    final fraction = ((x - left) / width).clamp(0.0, 1.0);
    final seconds = (fraction * _dateRangeSeconds).round();
    return start.add(Duration(seconds: seconds));
  }

  double yForValue(double value) {
    return bottom - valueScale.fractionFromBottom(value) * height;
  }

  double valueForY(double y) {
    if (height == 0) return valueScale.min;
    final fraction = ((bottom - y) / height).clamp(0.0, 1.0);
    return valueScale.min + fraction * (valueScale.max - valueScale.min);
  }

  bool contains(Offset local) {
    return local.dx >= left &&
        local.dx <= right &&
        local.dy >= top &&
        local.dy <= bottom;
  }

  List<double> yearBoundaryXs() {
    if (start.year == end.year) return const [];
    return [
      for (var year = start.year + 1; year <= end.year; year++)
        xForDate(DateTime(year)),
    ];
  }
}
