import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('150m peak steps by the hour and still covers the peak', () {
    final scale = EChartValueScale.clockMinutes(150);
    expect(scale.ticks, [0, 60, 120, 180]);
    expect(scale.max, 180);
  });

  test('90m peak steps by the half hour', () {
    final scale = EChartValueScale.clockMinutes(90);
    expect(scale.ticks, [0, 30, 60, 90]);
  });

  test('a multi-hour peak steps by two hours', () {
    final scale = EChartValueScale.clockMinutes(400);
    expect(scale.ticks, [0, 120, 240, 360, 480]);
  });
}
