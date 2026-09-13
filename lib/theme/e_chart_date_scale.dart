import 'dart:math' as math;

import 'package:ethan_utils/ethan_utils.dart';

import 'e_chart_axis.dart';

enum _DateTickCadence() {
  hour,
  day,
  week,
  month,
  quarter,
  year,
}

/// Date ticks spaced by the finest cadence that still stays ~70px apart.
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
  late final _DateTickCadence _cadence = _cadenceForRange();
  late final List<DateTime> tickDays = _computeTickDays();
  late final Set<DateTime> tickDaySet = tickDays.toSet();

  bool containsDay(DateTime date) => tickDaySet.contains(date.startOfDay);

  String caption(DateTime date) {
    return switch (_cadence) {
      _DateTickCadence.hour => _hourCaption(date),
      _DateTickCadence.year => '${date.year}',
      _DateTickCadence.month || _DateTickCadence.quarter => _monthCaption(date),
      _DateTickCadence.day || _DateTickCadence.week => _dayCaption(date),
    };
  }

  int get _tickCount =>
      math.max(3, (plotWidth / EChartAxis.minPxPerLabel).round());

  _DateTickCadence _cadenceForRange() {
    if (end.difference(start) < const Duration(days: 1)) {
      return _DateTickCadence.hour;
    }
    final spanDays = _rangeEnd.difference(_rangeStart).inDays;
    if (spanDays <= 0) return _DateTickCadence.day;
    if (spanDays + 1 <= _tickCount) return _DateTickCadence.day;
    if (_weekStartTicks().length <= _tickCount) return _DateTickCadence.week;
    if (_monthStartTicks().length <= _tickCount) return _DateTickCadence.month;
    if (_quarterMonthTicks().length <= _tickCount) {
      return _DateTickCadence.quarter;
    }
    return _DateTickCadence.year;
  }

  List<DateTime> _computeTickDays() {
    return switch (_cadence) {
      _DateTickCadence.hour => [_rangeStart],
      _DateTickCadence.day => _stepDayTicks(),
      _DateTickCadence.week => _weekStartTicks(),
      _DateTickCadence.month => _monthStartTicks(),
      _DateTickCadence.quarter => _subsample(_quarterMonthTicks()),
      _DateTickCadence.year => _subsample(_januaryYearTicks()),
    };
  }

  List<DateTime> _stepDayTicks() {
    final spanDays = _rangeEnd.difference(_rangeStart).inDays;
    final stepDays = math.max(1, (spanDays / _tickCount).round());
    final ticks = <DateTime>[_rangeStart];
    var cursor = _rangeStart.shiftedByDays(stepDays);
    final minGap = stepDays ~/ 2;
    while (cursor.isBefore(_rangeEnd.shiftedByDays(-minGap))) {
      ticks.add(cursor);
      cursor = cursor.shiftedByDays(stepDays);
    }
    ticks.add(_rangeEnd);
    return ticks;
  }

  List<DateTime> _weekStartTicks() {
    var cursor = _rangeStart.shiftedByDays(-(_rangeStart.weekday - 1));
    if (cursor.isBefore(_rangeStart)) cursor = cursor.shiftedByDays(7);
    final ticks = <DateTime>[];
    while (!cursor.isAfter(_rangeEnd)) {
      ticks.add(cursor);
      cursor = cursor.shiftedByDays(7);
    }
    return ticks;
  }

  List<DateTime> _monthStartTicks() {
    var cursor = DateTime(_rangeStart.year, _rangeStart.month);
    if (cursor.isBefore(_rangeStart)) {
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    final ticks = <DateTime>[];
    while (!cursor.isAfter(_rangeEnd)) {
      ticks.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return ticks;
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

  String _hourCaption(DateTime date) {
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final meridiem = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute$meridiem';
  }

  String _monthCaption(DateTime date) {
    final month = _monthNames[date.month];
    if (_rangeStart.year == _rangeEnd.year) return month;
    return '$month ${date.year % 100}';
  }

  String _dayCaption(DateTime date) {
    final monthDay = '${date.month}/${date.day}';
    if (_rangeStart.year == _rangeEnd.year) return monthDay;
    return '$monthDay/${date.year % 100}';
  }
}
