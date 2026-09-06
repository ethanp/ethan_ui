import 'dart:math' as math;

import 'package:ethan_utils/ethan_utils.dart';

import 'e_chart_axis.dart';

/// Sparse date ticks that stay ~70px apart: years, quarter months, or M/D.
class EChartDateScale({
  required final DateTime start,
  required final DateTime end,
  required final double plotWidth,
}) {
  static const _monthNames = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late final DateTime _rangeStart = start.startOfDay;
  late final DateTime _rangeEnd = end.startOfDay;
  late final List<DateTime> tickDays = _computeTickDays();
  late final Set<DateTime> tickDaySet = tickDays.toSet();

  bool containsDay(DateTime date) => tickDaySet.contains(date.startOfDay);

  String caption(DateTime date) {
    if (end.difference(start) < const Duration(days: 1)) {
      final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final meridiem = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour12:$minute$meridiem';
    }
    if (_rangeStart.year != _rangeEnd.year) return '${date.year}';
    if (end.difference(start) > const Duration(days: 60)) {
      return _monthNames[date.month];
    }
    return '${date.month}/${date.day}';
  }

  int get _tickCount =>
      math.max(3, (plotWidth / EChartAxis.minPxPerLabel).round());

  List<DateTime> _computeTickDays() {
    final spanDays = _rangeEnd.difference(_rangeStart).inDays;
    if (spanDays <= 0) return [_rangeStart];

    if (_rangeStart.year != _rangeEnd.year) {
      return _subsample(_januaryYearTicks());
    }
    if (spanDays > 90) return _subsample(_quarterMonthTicks());

    final stepDays = math.max(1, (spanDays / _tickCount).round());
    final ticks = <DateTime>[_rangeStart];
    var cursor = _rangeStart.shiftedByDays(stepDays);
    final minGap = stepDays ~/ 2;
    while (cursor.isBefore(_rangeEnd.shiftedByDays(-minGap))) {
      ticks.add(cursor);
      cursor = cursor.shiftedByDays(stepDays);
    }
    ticks.add(_rangeEnd);
    return _subsample(ticks);
  }

  List<DateTime> _januaryYearTicks() {
    var cursor = DateTime(_rangeStart.year);
    if (cursor.isBefore(_rangeStart)) cursor = DateTime(cursor.year + 1);
    final ticks = <DateTime>[];
    while (!cursor.isAfter(_rangeEnd)) {
      ticks.add(cursor);
      cursor = DateTime(cursor.year + 1);
    }
    return ticks;
  }

  List<DateTime> _quarterMonthTicks() {
    final quarterStartMonth = ((_rangeStart.month - 1) ~/ 3) * 3 + 1;
    var cursor = DateTime(_rangeStart.year, quarterStartMonth);
    if (cursor.isBefore(_rangeStart)) {
      cursor = DateTime(cursor.year, cursor.month + 3);
    }
    final ticks = <DateTime>[];
    while (!cursor.isAfter(_rangeEnd)) {
      ticks.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 3);
    }
    return ticks;
  }

  List<DateTime> _subsample(List<DateTime> candidates) {
    if (candidates.length <= 1) return candidates;
    if (candidates.length <= _tickCount) return candidates;

    final picked = <DateTime>[];
    final indexStep = (candidates.length - 1) / (_tickCount - 1);
    for (var pickIndex = 0; pickIndex < _tickCount; pickIndex++) {
      final candidateIndex = (pickIndex * indexStep).round().clamp(
        0,
        candidates.length - 1,
      );
      final tick = candidates[candidateIndex];
      if (picked.isEmpty || picked.last != tick) picked.add(tick);
    }
    return picked;
  }
}
