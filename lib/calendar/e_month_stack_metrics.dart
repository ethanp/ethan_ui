class const EMonthStackMetrics({
  required final double cellSize,
  required final double cellExtent,
  required final double summaryWidth,
  required final bool showsPeriodSummaries,
}) {
  static const preferredCellSize = 39.0;
  static const cellMargin = 2.0;
  static const preferredCellExtent = preferredCellSize + cellMargin * 2;
  static const preferredSummaryWidth = 80.0;
  static const summaryGap = 8.0;
  static const minCellSize = 24.0;

  static EMonthStackMetrics fit({
    required double availableWidth,
    required bool showsPeriodSummaries,
  }) {
    final summaryGutter = showsPeriodSummaries
        ? summaryGap + preferredSummaryWidth
        : 0.0;
    final widthForCells = availableWidth.isFinite
        ? availableWidth - summaryGutter
        : preferredCellExtent * DateTime.daysPerWeek;
    final minExtent = minCellSize + cellMargin * 2;
    final cellExtent = (widthForCells / DateTime.daysPerWeek).clamp(
      minExtent,
      preferredCellExtent,
    );
    return EMonthStackMetrics(
      cellSize: cellExtent - cellMargin * 2,
      cellExtent: cellExtent,
      summaryWidth: preferredSummaryWidth,
      showsPeriodSummaries: showsPeriodSummaries,
    );
  }
}
