import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final earliest = DateTime(2018, 3, 1);
  final latest = DateTime(2026, 9, 12);

  test('last year through latest is 365 inclusive days', () {
    final visible = EChartVisibleRange.lastYearThrough(
      earliest: earliest,
      latest: latest,
    );
    expect(visible.end, DateTime(2026, 9, 12));
    expect(visible.start, DateTime(2025, 9, 13));
    expect(visible.inclusiveDayCount, 365);
  });

  test('history shorter than a year uses the full span', () {
    final visible = EChartVisibleRange.lastYearThrough(
      earliest: DateTime(2026, 8, 1),
      latest: DateTime(2026, 9, 12),
    );
    expect(visible.start, DateTime(2026, 8, 1));
    expect(visible.end, DateTime(2026, 9, 12));
  });

  test('start handle cannot collapse below 14 days', () {
    final visible = EChartVisibleRange(
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 1, 31),
    );
    final resized = visible.withStart(
      DateTime(2026, 1, 30),
      earliest: earliest,
      latest: latest,
    );
    expect(resized.end, DateTime(2026, 1, 31));
    expect(resized.start, DateTime(2026, 1, 18));
    expect(resized.inclusiveDayCount, 14);
  });

  test('end handle cannot collapse below 14 days', () {
    final visible = EChartVisibleRange(
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 1, 31),
    );
    final resized = visible.withEnd(
      DateTime(2026, 1, 2),
      earliest: earliest,
      latest: latest,
    );
    expect(resized.start, DateTime(2026, 1, 1));
    expect(resized.end, DateTime(2026, 1, 14));
  });

  test('pane scrub keeps duration and stays inside all-time', () {
    final visible = EChartVisibleRange(
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 3, 31),
    );
    final shifted = visible.shiftedByDays(
      400,
      earliest: earliest,
      latest: latest,
    );
    expect(shifted.end, latest);
    expect(
      shifted.inclusiveDayCount,
      visible.inclusiveDayCount,
    );
  });
}
