import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weeks are owned by Monday and ignore inactive zeros', () {
    final buckets = ECalendarPeriodBuckets.weeks([
      ECalendarDailyMeasure(
        date: DateTime(2026, 9, 6),
        quantity: 0,
        isActive: false,
      ),
      ECalendarDailyMeasure(
        date: DateTime(2026, 9, 8),
        quantity: 20,
        isActive: true,
      ),
      ECalendarDailyMeasure(
        date: DateTime(2026, 9, 9),
        quantity: 10,
        isActive: true,
      ),
    ]);

    expect(buckets, hasLength(2));
    expect(buckets.first.periodStart, DateTime(2026, 8, 31));
    expect(buckets.first.activeDays, 0);
    expect(buckets.first.measureSum, 0);
    expect(buckets.last.periodStart, DateTime(2026, 9, 7));
    expect(buckets.last.activeDays, 2);
    expect(buckets.last.measureSum, 30);
  });

  test('months use the calendar month and do not count zero days as active', () {
    final buckets = ECalendarPeriodBuckets.months([
      ECalendarDailyMeasure(
        date: DateTime(2026, 8, 31),
        quantity: 5,
        isActive: true,
      ),
      ECalendarDailyMeasure(
        date: DateTime(2026, 9, 2),
        quantity: 0,
        isActive: false,
      ),
      ECalendarDailyMeasure(
        date: DateTime(2026, 9, 8),
        quantity: 12,
        isActive: true,
      ),
    ]);

    expect(buckets, hasLength(2));
    expect(buckets.first.periodStart, DateTime(2026, 8, 1));
    expect(buckets.first.activeDays, 1);
    expect(buckets.last.periodStart, DateTime(2026, 9, 1));
    expect(buckets.last.activeDays, 1);
    expect(buckets.last.measureSum, 12);
  });
}
