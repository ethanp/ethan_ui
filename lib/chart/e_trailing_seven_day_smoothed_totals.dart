import 'dart:math' as math;

import 'package:ethan_utils/ethan_utils.dart';

class const EDailyQuantity({
  required final DateTime date,
  required final num quantity,
});

class const ETrailingSevenDaySmoothedPoint({
  required final DateTime date,
  required final double trailingTotal,
  required final double smoothedTotal,
});

/// Trailing 7-day totals, then two centered 7-day moving-average passes.
abstract final class ETrailingSevenDaySmoothedTotals() {
  static const windowDays = 7;
  static const smoothingHalfWindow = 3;
  static const smoothingPasses = 2;

  static List<ETrailingSevenDaySmoothedPoint> of(
    Iterable<EDailyQuantity> observed, {
    DateTime? through,
  }) {
    final quantityOn = <DateTime, double>{
      for (final day in observed) day.date.startOfDay: day.quantity.toDouble(),
    };
    if (quantityOn.isEmpty) return const [];

    final dates = quantityOn.keys.toList()..sort();
    var last = dates.last;
    if (through != null && through.startOfDay.isAfter(last)) {
      last = through.startOfDay;
    }

    final filledDates = <DateTime>[];
    for (var day = dates.first; !day.isAfter(last); day = day.shiftedByDays(1)) {
      filledDates.add(day);
    }

    final trailingTotals = [
      for (var index = 0; index < filledDates.length; index++)
        _trailingTotalEndingAt(filledDates, quantityOn, index),
    ];
    var smoothedTotals = trailingTotals;
    for (var pass = 0; pass < smoothingPasses; pass++) {
      smoothedTotals = _centeredMovingAverage(smoothedTotals);
    }

    return [
      for (var index = 0; index < filledDates.length; index++)
        ETrailingSevenDaySmoothedPoint(
          date: filledDates[index],
          trailingTotal: trailingTotals[index],
          smoothedTotal: smoothedTotals[index],
        ),
    ];
  }

  static double _trailingTotalEndingAt(
    List<DateTime> dates,
    Map<DateTime, double> quantityOn,
    int endIndex,
  ) {
    var total = 0.0;
    for (var dayOffset = 0; dayOffset < windowDays; dayOffset++) {
      final index = endIndex - dayOffset;
      if (index < 0) continue;
      total += quantityOn[dates[index]] ?? 0;
    }
    return total;
  }

  static List<double> _centeredMovingAverage(List<double> values) => [
    for (var index = 0; index < values.length; index++)
      _windowAverage(values, index),
  ];

  static double _windowAverage(List<double> values, int index) {
    final firstIndex = math.max(0, index - smoothingHalfWindow);
    final lastIndex = math.min(values.length - 1, index + smoothingHalfWindow);
    var total = 0.0;
    for (
      var neighborIndex = firstIndex;
      neighborIndex <= lastIndex;
      neighborIndex++
    ) {
      total += values[neighborIndex];
    }
    return total / (lastIndex - firstIndex + 1);
  }
}
