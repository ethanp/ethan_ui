import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final measures = [
    for (var day = 1; day <= 20; day++)
      ECalendarDailyMeasure(
        date: DateTime(2026, 9, day),
        quantity: day.isEven ? 10 : 0,
        isActive: day.isEven,
      ),
  ];

  testWidgets('Week and Month change how many measure bars are drawn', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ECalendarCharts(
              dailyMeasures: measures,
              measureTitle: 'cardio Z2–5 minutes',
              formatMeasure: (quantity) => '${quantity.round()}m',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Active days per week'), findsOneWidget);
    expect(find.text('cardio Z2–5 minutes per week'), findsOneWidget);
    expect(find.text('Trailing 7-day cardio Z2–5 minutes'), findsOneWidget);
    expect(find.byType(EBarChart), findsNWidgets(2));
    expect(find.byType(EChartYLabels), findsNWidgets(3));

    final weekMeasureBars = tester
        .widget<EBarChart>(find.byKey(const ValueKey('measure-ECalendarChartBarPeriod.week')))
        .bars
        .length;

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();

    expect(find.text('Active days per month'), findsOneWidget);
    expect(find.text('cardio Z2–5 minutes per month'), findsOneWidget);
    final monthMeasureBars = tester
        .widget<EBarChart>(
          find.byKey(const ValueKey('measure-ECalendarChartBarPeriod.month')),
        )
        .bars
        .length;
    expect(monthMeasureBars, 1);
    expect(weekMeasureBars, greaterThan(monthMeasureBars));
  });

  testWidgets('trend line stamps each day as the point id', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ECalendarCharts(
              dailyMeasures: measures,
              measureTitle: 'notes',
              formatMeasure: (quantity) => '$quantity',
            ),
          ),
        ),
      ),
    );

    final chart = tester.widget<EChart<DateTime>>(find.byType(EChart<DateTime>));
    expect(chart.series.single.points.map((point) => point.id).toList(), [
      for (var day = 1; day <= 20; day++) DateTime(2026, 9, day),
    ]);
  });

  testWidgets('defaults to the last 365 days and an all-time range scrubber', (
    tester,
  ) async {
    final last = DateTime(2026, 9, 12);
    final first = DateTime(2025, 7, 1);
    final allTime = [
      for (
        var day = first;
        !day.isAfter(last);
        day = DateTime(day.year, day.month, day.day + 1)
      )
        ECalendarDailyMeasure(
          date: day,
          quantity: day.day % 3 == 0 ? 8 : 0,
          isActive: day.day % 3 == 0,
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ECalendarCharts(
              dailyMeasures: allTime,
              measureTitle: 'notes',
              formatMeasure: (quantity) => '$quantity',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EChartAllTimeRangeScrubber), findsOneWidget);
    final chart = tester.widget<EChart<DateTime>>(find.byType(EChart<DateTime>));
    expect(chart.start, DateTime(2025, 9, 13));
    expect(chart.end, last);

    final horizontalScrolls = tester
        .widgetList<Scrollable>(find.byType(Scrollable))
        .where((scrollable) => scrollable.axis == Axis.horizontal);
    expect(horizontalScrolls, isEmpty);

    await tester.ensureVisible(find.byType(EChartAllTimeRangeScrubber));
    await tester.pumpAndSettle();
    final scrubberBox = tester.getRect(find.byType(EChartAllTimeRangeScrubber));
    await tester.dragFrom(
      Offset(scrubberBox.right - 48, scrubberBox.center.dy),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();

    final afterScrub = tester.widget<EChart<DateTime>>(
      find.byType(EChart<DateTime>),
    );
    expect(afterScrub.start.isBefore(DateTime(2025, 9, 13)), isTrue);
    expect(afterScrub.end.isBefore(last), isTrue);
  });
}
