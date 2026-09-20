import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('widens past the default gutter so captions like 8000mg stay one line', (
    tester,
  ) async {
    final scale = EChartValueScale.nice(8000);
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: EChartYLabels(
            scale: scale,
            height: 180,
            formatTick: (value) => '${value.round()}mg',
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(EChartYLabels));
    expect(size.width, greaterThan(36));
    expect(
      EChartYLabels.gutterWidthFor(
        scale: scale,
        formatTick: (value) => '${value.round()}mg',
      ),
      size.width,
    );
  });
}
