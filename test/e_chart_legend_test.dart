import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('narrow legend stacks rows; wide legend puts them in columns', (
    tester,
  ) async {
    await _pump(tester, width: 200);
    final narrowIncome = tester.getTopLeft(find.text('Income'));
    final narrowSpending = tester.getTopLeft(find.text('Spending'));
    expect(narrowSpending.dy, greaterThan(narrowIncome.dy));

    await _pump(tester, width: 600);
    final wideIncome = tester.getTopLeft(find.text('Income'));
    final wideSpending = tester.getTopLeft(find.text('Spending'));
    expect(wideSpending.dy, closeTo(wideIncome.dy, 1));
    expect(wideSpending.dx, greaterThan(wideIncome.dx));
  });

  testWidgets('legend lays out inside a scrolling list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: ListView(
            children: [
              EChartLegend(entries: _entries),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Income'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legend in a row still lays out', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: Row(
            children: [
              EChartLegend(entries: _entries),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Income'), findsOneWidget);
    expect(find.text(r'$80k / yr'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, {required double width}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ETheme.material3Dark,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: EChartLegend(entries: _entries),
          ),
        ),
      ),
    ),
  );
}

final _entries = [
  EChartLegendEntry(
    swatch: const SizedBox(width: 10, height: 10),
    label: 'Income',
    value: r'$80k / yr',
  ),
  EChartLegendEntry(
    swatch: const SizedBox(width: 10, height: 10),
    label: 'Spending',
    value: r'$40k / yr',
    caption: '50–60%',
  ),
];
