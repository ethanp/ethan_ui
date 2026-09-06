import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EChartDateScale', () {
    test('multi-year charts tick each January and skip mid-year months', () {
      final scale = EChartDateScale(
        start: DateTime(2021, 3, 1),
        end: DateTime(2026, 9, 1),
        plotWidth: 660,
      );

      expect(scale.tickDays, [
        DateTime(2022),
        DateTime(2023),
        DateTime(2024),
        DateTime(2025),
        DateTime(2026),
      ]);
      expect(scale.caption(DateTime(2025)), '2025');
    });

    test('same-year multi-month charts keep quarter-month ticks', () {
      final scale = EChartDateScale(
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 11, 1),
        plotWidth: 660,
      );

      expect(scale.tickDays, [
        DateTime(2026, 4, 1),
        DateTime(2026, 7, 1),
        DateTime(2026, 10, 1),
      ]);
      expect(scale.caption(DateTime(2026, 7, 1)), 'Jul');
    });
  });
}
