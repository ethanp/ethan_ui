import 'e_chart_line.dart';

/// The line and point chosen on a chart.
class const EChartSelectedPoint({
  required final EChartLine line,
  required final EChartPoint point,
  required final int lineIndex,
  required final int pointIndex,
}) {
  @override
  bool operator ==(Object other) =>
      other is EChartSelectedPoint &&
      other.lineIndex == lineIndex &&
      other.pointIndex == pointIndex &&
      identical(other.line, line) &&
      identical(other.point, point);

  @override
  int get hashCode => Object.hash(lineIndex, pointIndex, line, point);
}
