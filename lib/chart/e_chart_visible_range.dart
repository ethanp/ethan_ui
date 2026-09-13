import 'package:ethan_utils/ethan_utils.dart';

class const EChartVisibleRange({
  required final DateTime start,
  required final DateTime end,
}) {
  static const defaultVisibleDayCount = 365;
  static const minVisibleDayCount = 14;

  factory lastYearThrough({
    required DateTime earliest,
    required DateTime latest,
  }) {
    final fullStart = earliest.startOfDay;
    final fullEnd = latest.startOfDay;
    if (!fullStart.isBefore(fullEnd)) {
      return EChartVisibleRange(start: fullEnd, end: fullEnd);
    }
    final yearStart = fullEnd.shiftedByDays(-(defaultVisibleDayCount - 1));
    return EChartVisibleRange(
      start: yearStart.isBefore(fullStart) ? fullStart : yearStart,
      end: fullEnd,
    );
  }

  int get inclusiveDayCount =>
      end.startOfDay.difference(start.startOfDay).inDays + 1;

  EChartVisibleRange clampedTo({
    required DateTime earliest,
    required DateTime latest,
  }) {
    final fullStart = earliest.startOfDay;
    final fullEnd = latest.startOfDay;
    var nextStart = start.startOfDay;
    var nextEnd = end.startOfDay;
    if (nextStart.isBefore(fullStart)) nextStart = fullStart;
    if (nextEnd.isAfter(fullEnd)) nextEnd = fullEnd;
    if (nextStart.isAfter(nextEnd)) {
      return EChartVisibleRange(start: fullStart, end: fullEnd);
    }
    return EChartVisibleRange(start: nextStart, end: nextEnd);
  }

  EChartVisibleRange withStart(
    DateTime newStart, {
    required DateTime earliest,
    required DateTime latest,
  }) {
    final fullStart = earliest.startOfDay;
    final fullEnd = latest.startOfDay;
    final keptEnd = end.startOfDay.isAfter(fullEnd) ? fullEnd : end.startOfDay;
    var nextStart = newStart.startOfDay;
    if (nextStart.isBefore(fullStart)) nextStart = fullStart;
    final latestStart = keptEnd.shiftedByDays(-(minVisibleDayCount - 1));
    if (nextStart.isAfter(latestStart)) {
      nextStart = latestStart.isBefore(fullStart) ? fullStart : latestStart;
    }
    if (nextStart.isAfter(keptEnd)) nextStart = keptEnd;
    return EChartVisibleRange(start: nextStart, end: keptEnd);
  }

  EChartVisibleRange withEnd(
    DateTime newEnd, {
    required DateTime earliest,
    required DateTime latest,
  }) {
    final fullStart = earliest.startOfDay;
    final fullEnd = latest.startOfDay;
    final keptStart = start.startOfDay.isBefore(fullStart)
        ? fullStart
        : start.startOfDay;
    var nextEnd = newEnd.startOfDay;
    if (nextEnd.isAfter(fullEnd)) nextEnd = fullEnd;
    final earliestEnd = keptStart.shiftedByDays(minVisibleDayCount - 1);
    if (nextEnd.isBefore(earliestEnd)) {
      nextEnd = earliestEnd.isAfter(fullEnd) ? fullEnd : earliestEnd;
    }
    if (nextEnd.isBefore(keptStart)) nextEnd = keptStart;
    return EChartVisibleRange(start: keptStart, end: nextEnd);
  }

  EChartVisibleRange shiftedByDays(
    int days, {
    required DateTime earliest,
    required DateTime latest,
  }) {
    if (days == 0) return this;
    final fullStart = earliest.startOfDay;
    final fullEnd = latest.startOfDay;
    final durationDays = end.startOfDay.difference(start.startOfDay).inDays;
    var nextStart = start.startOfDay.shiftedByDays(days);
    var nextEnd = nextStart.shiftedByDays(durationDays);
    if (nextStart.isBefore(fullStart)) {
      nextStart = fullStart;
      nextEnd = nextStart.shiftedByDays(durationDays);
    }
    if (nextEnd.isAfter(fullEnd)) {
      nextEnd = fullEnd;
      nextStart = nextEnd.shiftedByDays(-durationDays);
      if (nextStart.isBefore(fullStart)) nextStart = fullStart;
    }
    return EChartVisibleRange(start: nextStart, end: nextEnd);
  }

  @override
  bool operator ==(Object other) =>
      other is EChartVisibleRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}
