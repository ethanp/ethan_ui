import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('150m peak steps by the half hour', () {
    final scale = EChartValueScale.minuteTotals(150);
    expect(scale.ticks, [0, 30, 60, 90, 120, 150]);
    expect(scale.max, 150);
  });

  test('a peak past five half hours steps by 45 minutes', () {
    final scale = EChartValueScale.minuteTotals(170);
    expect(scale.ticks, [0, 45, 90, 135, 180]);
  });

  test('a peak past five 45-minute steps steps by the hour', () {
    final scale = EChartValueScale.minuteTotals(260);
    expect(scale.ticks, [0, 60, 120, 180, 240, 300]);
  });

  test('a peak past five hours steps by whole hours', () {
    final scale = EChartValueScale.minuteTotals(400);
    expect(scale.ticks, [0, 120, 240, 360, 480]);
  });

  test('never steps by 50 minutes', () {
    for (var peak = 1; peak <= 1200; peak++) {
      final scale = EChartValueScale.minuteTotals(peak.toDouble());
      final step = scale.ticks[1] - scale.ticks[0];
      expect(step == 30 || step == 45 || step % 60 == 0, isTrue);
      expect(scale.ticks.length - 1, lessThanOrEqualTo(5));
    }
  });
}
