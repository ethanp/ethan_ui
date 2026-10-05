import 'package:ethan_ui/calendar/day_so_far_versus_window_average.dart';
import 'package:ethan_ui/calendar/e_calendar_instant_quantity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 4, 15, 30);
  final windowStart = DateTime(2026, 9, 27);
  final windowEnd = DateTime(2026, 10, 3);

  DaySoFarVersusWindowAverage paceFor(
    List<ECalendarInstantQuantity> instants, {
    DateTime? start,
    DateTime? end,
  }) {
    return DaySoFarVersusWindowAverage.fromInstants(
      instants: instants,
      now: now,
      windowStart: start ?? windowStart,
      windowEnd: end ?? windowEnd,
    );
  }

  test('average uses the window and ignores doses outside it', () {
    final instants = [
      ECalendarInstantQuantity(
        at: DateTime(2026, 9, 26, 12),
        quantity: 100,
      ),
      ECalendarInstantQuantity(
        at: DateTime(2026, 10, 3, 12),
        quantity: 14,
      ),
      ECalendarInstantQuantity(
        at: DateTime(2026, 10, 4, 10),
        quantity: 4,
      ),
    ];
    final pace = paceFor(instants);
    final wider = paceFor(
      instants,
      end: DateTime(2026, 10, 10),
    );

    expect(pace.averagedDayCount, 7);
    expect(pace.windowAverageTotal, closeTo(2, 0.05));
    expect(pace.windowAverageAt(12 * 60), greaterThan(0));
    expect(pace.windowAverageAt(12 * 60), lessThan(2));
    expect(wider.windowAverageTotal, lessThan(pace.windowAverageTotal));
    expect(pace.todaySoFar, 4);
    expect(
      pace.windowAverageCumulative.last.minuteOfDay,
      DaySoFarVersusWindowAverage.minutesInDay,
    );
  });

  test('a dose later today is not part of today so far', () {
    final pace = paceFor([
      ECalendarInstantQuantity(
        at: DateTime(2026, 10, 4, 18),
        quantity: 9,
      ),
    ]);

    expect(pace.todaySoFar, 0);
    expect(pace.hasAnythingToCompare, isFalse);
  });
}
