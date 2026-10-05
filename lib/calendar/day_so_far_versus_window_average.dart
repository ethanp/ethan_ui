import 'package:ethan_utils/ethan_utils.dart';

import '../chart/e_trailing_seven_day_smoothed_totals.dart';
import 'e_calendar_instant_quantity.dart';

/// Today's cumulative quantity against the mean day in a date window.
class const DaySoFarVersusWindowAverage({
  required final double todaySoFar,
  required final double windowAverageTotal,
  required final int averagedDayCount,
  required final List<EMinuteOfDayQuantity> todayCumulative,
  required final List<EMinuteOfDayQuantity> windowAverageCumulative,
  required final int nowMinuteOfDay,
}) {
  static const minutesInDay = 24 * 60;

  factory fromInstants({
    required List<ECalendarInstantQuantity> instants,
    required DateTime now,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    return DaySoFarVersusWindowCurves.fromInstants(
      instants: instants,
      now: now,
    ).inWindow(windowStart: windowStart, windowEnd: windowEnd);
  }

  bool get hasAnythingToCompare =>
      todaySoFar > 0 || windowAverageTotal > 0;

  double windowAverageAt(int minuteOfDay) =>
      _interpolated(windowAverageCumulative, minuteOfDay);

  double todayAt(int minuteOfDay) {
    final minute = minuteOfDay > nowMinuteOfDay ? nowMinuteOfDay : minuteOfDay;
    return _held(todayCumulative, minute);
  }

  double _held(List<EMinuteOfDayQuantity> points, int minuteOfDay) {
    var held = 0.0;
    for (final point in points) {
      if (point.minuteOfDay > minuteOfDay) break;
      held = point.quantity;
    }
    return held;
  }

  static List<EMinuteOfDayQuantity> _todayCurve(
    List<EMinuteOfDayQuantity> steps,
    int nowMinute,
  ) {
    final points = <EMinuteOfDayQuantity>[
      const EMinuteOfDayQuantity(minuteOfDay: 0, quantity: 0),
    ];
    for (final step in steps) {
      if (step.minuteOfDay > nowMinute) break;
      if (points.last.minuteOfDay < step.minuteOfDay) {
        points.add(
          EMinuteOfDayQuantity(
            minuteOfDay: step.minuteOfDay,
            quantity: points.last.quantity,
          ),
        );
      }
      _appendStep(points, step.minuteOfDay, step.quantity);
    }
    if (points.last.minuteOfDay < nowMinute) {
      points.add(
        EMinuteOfDayQuantity(
          minuteOfDay: nowMinute,
          quantity: points.last.quantity,
        ),
      );
    }
    return points;
  }

  static List<EMinuteOfDayQuantity> _smoothedAverageCurve(
    List<double> hourlyMeans,
  ) {
    final smoothed = ETrailingSevenDaySmoothedTotals.smooth(hourlyMeans);
    return [
      for (var hour = 0; hour <= 24; hour++)
        EMinuteOfDayQuantity(minuteOfDay: hour * 60, quantity: smoothed[hour]),
    ];
  }

  static double _interpolated(
    List<EMinuteOfDayQuantity> points,
    int minuteOfDay,
  ) {
    if (points.isEmpty) return 0;
    final minute = minuteOfDay.clamp(0, minutesInDay);
    var previous = points.first;
    for (final point in points) {
      if (point.minuteOfDay == minute) return point.quantity;
      if (point.minuteOfDay > minute) {
        final span = point.minuteOfDay - previous.minuteOfDay;
        if (span <= 0) return point.quantity;
        final fraction = (minute - previous.minuteOfDay) / span;
        return previous.quantity +
            (point.quantity - previous.quantity) * fraction;
      }
      previous = point;
    }
    return previous.quantity;
  }

  static void _appendStep(
    List<EMinuteOfDayQuantity> points,
    int minuteOfDay,
    double quantity,
  ) {
    if (points.isNotEmpty &&
        points.last.minuteOfDay == minuteOfDay &&
        points.last.quantity == quantity) {
      return;
    }
    points.add(
      EMinuteOfDayQuantity(minuteOfDay: minuteOfDay, quantity: quantity),
    );
  }

}

/// Per-day cumulative curves, built once so a scrub only sums the window.
class DaySoFarVersusWindowCurves._({
  required final Map<DateTime, List<double>> hourlyByDay,
  required final List<EMinuteOfDayQuantity> todaySteps,
  required final int nowMinute,
}) {
  final Map<DateTime, List<double>> _hourlyByDay = hourlyByDay;
  final List<EMinuteOfDayQuantity> _todaySteps = todaySteps;
  final int _nowMinute = nowMinute;

  factory fromInstants({
    required List<ECalendarInstantQuantity> instants,
    required DateTime now,
  }) {
    final today = now.startOfDay;
    final nowMinute = now.hour * 60 + now.minute;
    final dosesByDay = <DateTime, Map<int, double>>{};
    for (final instant in instants) {
      final day = instant.at.startOfDay;
      if (day == today && instant.at.isAfter(now)) continue;
      final minute = instant.at.hour * 60 + instant.at.minute;
      final doses = dosesByDay.putIfAbsent(day, () => <int, double>{});
      doses.update(
        minute,
        (quantity) => quantity + instant.quantity.toDouble(),
        ifAbsent: () => instant.quantity.toDouble(),
      );
    }
    return DaySoFarVersusWindowCurves._(
      hourlyByDay: {
        for (final entry in dosesByDay.entries)
          entry.key: _hourlyCumulative(entry.value),
      },
      todaySteps: _cumulativeSteps(dosesByDay[today]),
      nowMinute: nowMinute,
    );
  }

  DaySoFarVersusWindowAverage inWindow({
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    final first = windowStart.startOfDay;
    final last = windowEnd.startOfDay;
    final hourSums = List<double>.filled(25, 0);
    var dayCount = 0;
    if (!first.isAfter(last)) {
      for (var day = first; !day.isAfter(last); day = day.shiftedByDays(1)) {
        dayCount++;
        final hourly = _hourlyByDay[day];
        if (hourly == null) continue;
        for (var hour = 0; hour < hourly.length; hour++) {
          hourSums[hour] += hourly[hour];
        }
      }
    }
    final hourlyMeans = [
      for (var hour = 0; hour < hourSums.length; hour++)
        dayCount == 0 ? 0.0 : hourSums[hour] / dayCount,
    ];
    final averageCurve = DaySoFarVersusWindowAverage._smoothedAverageCurve(
      hourlyMeans,
    );
    var todaySoFar = 0.0;
    for (final step in _todaySteps) {
      if (step.minuteOfDay > _nowMinute) break;
      todaySoFar = step.quantity;
    }
    return DaySoFarVersusWindowAverage(
      todaySoFar: todaySoFar,
      windowAverageTotal: averageCurve.last.quantity,
      averagedDayCount: dayCount,
      todayCumulative: DaySoFarVersusWindowAverage._todayCurve(
        _todaySteps,
        _nowMinute,
      ),
      windowAverageCumulative: averageCurve,
      nowMinuteOfDay: _nowMinute,
    );
  }

  static List<double> _hourlyCumulative(Map<int, double> doses) {
    final minutes = doses.keys.toList()..sort();
    final hourly = List<double>.filled(25, 0);
    var running = 0.0;
    var stepIndex = 0;
    for (var hour = 0; hour <= 24; hour++) {
      final minute = hour * 60;
      while (stepIndex < minutes.length && minutes[stepIndex] <= minute) {
        running += doses[minutes[stepIndex]]!;
        stepIndex++;
      }
      hourly[hour] = running;
    }
    return hourly;
  }

  static List<EMinuteOfDayQuantity> _cumulativeSteps(Map<int, double>? doses) {
    if (doses == null || doses.isEmpty) return const [];
    final minutes = doses.keys.toList()..sort();
    var running = 0.0;
    return [
      for (final minute in minutes)
        EMinuteOfDayQuantity(
          minuteOfDay: minute,
          quantity: running += doses[minute]!,
        ),
    ];
  }
}
