/// The series and point chosen on a chart, identified by host-stamped ids.
class const EChartSelectedPoint<T extends Object>({
  required final String seriesId,
  required final T pointId,
  required final DateTime date,
  required final double value,
}) {
  @override
  bool operator ==(Object other) =>
      other is EChartSelectedPoint<T> &&
      other.seriesId == seriesId &&
      other.pointId == pointId &&
      other.date == date &&
      other.value == value;

  @override
  int get hashCode => Object.hash(seriesId, pointId, date, value);
}
