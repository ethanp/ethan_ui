import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a lone day is a trailing-7 total that tapers after the window exits', () {
    final trend = ETrailingSevenDaySmoothedTotals.of([
      EDailyQuantity(date: DateTime(2026, 1, 5), quantity: 60),
    ], through: DateTime(2026, 1, 16));

    final byDate = {
      for (final day in trend)
        DateTime(day.date.year, day.date.month, day.date.day): day,
    };

    expect(byDate[DateTime(2026, 1, 5)]!.trailingTotal, 60);
    expect(byDate[DateTime(2026, 1, 11)]!.trailingTotal, 60);
    expect(byDate[DateTime(2026, 1, 12)]!.trailingTotal, 0);
    expect(byDate[DateTime(2026, 1, 13)]!.smoothedTotal, greaterThan(0));
    expect(byDate[DateTime(2026, 1, 13)]!.smoothedTotal, lessThan(60));
    expect(byDate[DateTime(2026, 1, 16)]!.trailingTotal, 0);
  });

  test('two equal days a week apart do not stack into a double total', () {
    final trend = ETrailingSevenDaySmoothedTotals.of([
      EDailyQuantity(date: DateTime(2026, 1, 1), quantity: 70),
      EDailyQuantity(date: DateTime(2026, 1, 8), quantity: 70),
    ], through: DateTime(2026, 1, 20));

    final peakTrailing = trend.fold<double>(
      0,
      (highest, day) =>
          day.trailingTotal > highest ? day.trailingTotal : highest,
    );
    expect(peakTrailing, 70);
    expect(
      trend
          .firstWhere((day) => day.date == DateTime(2026, 1, 11))
          .trailingTotal,
      70,
    );
  });
}
