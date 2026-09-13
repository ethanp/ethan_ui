import 'package:ethan_utils/ethan_utils.dart';

class const ECalendarDailyMeasure({
  required final DateTime date,
  required final num quantity,
  required final bool isActive,
});

class const ECalendarPeriodBucket({
  required final DateTime periodStart,
  required final int activeDays,
  required final num measureSum,
});

abstract final class ECalendarPeriodBuckets() {
  static List<ECalendarDailyMeasure> filledDailyRange(
    Iterable<ECalendarDailyMeasure> observed,
  ) {
    final byDay = <DateTime, ECalendarDailyMeasure>{
      for (final day in observed) day.date.startOfDay: day,
    };
    if (byDay.isEmpty) return const [];

    final dates = byDay.keys.toList()..sort();
    final filled = <ECalendarDailyMeasure>[];
    for (
      var cursor = dates.first;
      !cursor.isAfter(dates.last);
      cursor = cursor.shiftedByDays(1)
    ) {
      filled.add(
        byDay[cursor] ??
            ECalendarDailyMeasure(
              date: cursor,
              quantity: 0,
              isActive: false,
            ),
      );
    }
    return filled;
  }

  static List<ECalendarPeriodBucket> weeks(
    Iterable<ECalendarDailyMeasure> observed,
  ) {
    return _buckets(
      filledDailyRange(observed),
      periodStartOf: _mondayOf,
    );
  }

  static List<ECalendarPeriodBucket> months(
    Iterable<ECalendarDailyMeasure> observed,
  ) {
    return _buckets(
      filledDailyRange(observed),
      periodStartOf: (date) => DateTime(date.year, date.month, 1),
    );
  }

  static DateTime _mondayOf(DateTime date) =>
      date.startOfDay.shiftedByDays(-(date.weekday - 1));

  static List<ECalendarPeriodBucket> _buckets(
    List<ECalendarDailyMeasure> days, {
    required DateTime Function(DateTime date) periodStartOf,
  }) {
    if (days.isEmpty) return const [];

    final buckets = <DateTime, ECalendarPeriodBucket>{};
    for (final day in days) {
      final periodStart = periodStartOf(day.date);
      final existing =
          buckets[periodStart] ??
          ECalendarPeriodBucket(
            periodStart: periodStart,
            activeDays: 0,
            measureSum: 0,
          );
      buckets[periodStart] = ECalendarPeriodBucket(
        periodStart: periodStart,
        activeDays: existing.activeDays + (day.isActive ? 1 : 0),
        measureSum: existing.measureSum + day.quantity,
      );
    }

    final ordered = buckets.keys.toList()..sort();
    return [for (final start in ordered) buckets[start]!];
  }
}
