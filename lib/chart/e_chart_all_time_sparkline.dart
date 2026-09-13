abstract final class EChartAllTimeSparkline() {
  static List<double> highestInEachColumn(
    List<double> values, {
    required int columnCount,
  }) {
    if (values.isEmpty || columnCount <= 0) return const [];
    if (values.length <= columnCount) return List<double>.of(values);

    final columnHighs = List<double>.filled(columnCount, 0);
    for (var index = 0; index < values.length; index++) {
      final column = (index / values.length * columnCount).floor().clamp(
        0,
        columnCount - 1,
      );
      if (values[index] > columnHighs[column]) {
        columnHighs[column] = values[index];
      }
    }
    return columnHighs;
  }
}
