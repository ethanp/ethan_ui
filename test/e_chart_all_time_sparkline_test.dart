import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('highest in each column keeps peaks when downsampling', () {
    final values = [1.0, 8.0, 2.0, 3.0, 9.0, 1.0];
    expect(
      EChartAllTimeSparkline.highestInEachColumn(values, columnCount: 2),
      [8.0, 9.0],
    );
  });

  test('short series is left as-is', () {
    expect(
      EChartAllTimeSparkline.highestInEachColumn([2, 4, 3], columnCount: 10),
      [2, 4, 3],
    );
  });
}
