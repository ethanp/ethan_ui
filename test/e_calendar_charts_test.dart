import 'package:ethan_ui/ethan_ui.dart';
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

EChart<DateTime> _chartUnder(WidgetTester tester, Key key) {
  return tester.widget<EChart<DateTime>>(
    find.descendant(
      of: find.byKey(key),
      matching: find.byType(EChart<DateTime>),
    ),
  );
}

void main() {
  final measures = [
    for (var day = 1; day <= 20; day++)
      ECalendarDailyMeasure(
        date: DateTime(2026, 9, day),
        quantity: day.isEven ? 10 : 0,
        isActive: day.isEven,
      ),
  ];

  testWidgets('Week and Month change how many active-day bars are drawn', (
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
    expect(find.text('cardio Z2–5 minutes per week'), findsNothing);
    expect(find.text('Cardio Z2–5 minutes rolling load'), findsOneWidget);
    expect(find.byType(EChart<DateTime>), findsNWidgets(2));
    expect(find.byType(EChartYLabels), findsNWidgets(2));

    final weekActiveDayBars = _chartUnder(
      tester,
      const ValueKey('active-days-ECalendarChartBarPeriod.week'),
    ).series.single.points.length;

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();

    expect(find.text('Active days per month'), findsOneWidget);
    expect(find.text('cardio Z2–5 minutes per month'), findsNothing);
    final monthActiveDayBars = _chartUnder(
      tester,
      const ValueKey('active-days-ECalendarChartBarPeriod.month'),
    ).series.single.points.length;
    expect(monthActiveDayBars, 1);
    expect(weekActiveDayBars, greaterThan(monthActiveDayBars));
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

    final chart = tester.widget<EChart<DateTime>>(
      find.byKey(const ValueKey('rolling-load')),
    );
    final pointIds = chart.series.single.points
        .map((point) => point.id)
        .toList();
    final today = DateTime.now().startOfDay;
    final lastObserved = DateTime(2026, 9, 20);
    expect(pointIds.take(20).toList(), [
      for (var day = 1; day <= 20; day++) DateTime(2026, 9, day),
    ]);
    expect(
      pointIds.last,
      lastObserved.isAfter(today) ? lastObserved : today,
    );
  });

  testWidgets(
    'rolling load plots the double-smoothed window, not the raw 7-day total',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ETheme.material3Dark,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ECalendarCharts(
                dailyMeasures: [
                  ECalendarDailyMeasure(
                    date: DateTime(2026, 1, 1),
                    quantity: 0,
                    isActive: false,
                  ),
                  ECalendarDailyMeasure(
                    date: DateTime(2026, 1, 10),
                    quantity: 70,
                    isActive: true,
                  ),
                  ECalendarDailyMeasure(
                    date: DateTime(2026, 1, 31),
                    quantity: 0,
                    isActive: false,
                  ),
                ],
                measureTitle: 'dosage',
                formatMeasure: (quantity) => '$quantity',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Dosage rolling load'), findsOneWidget);
      final chart = tester.widget<EChart<DateTime>>(
        find.byKey(const ValueKey('rolling-load')),
      );
      final peak = chart.series.single.points.fold<double>(
        0,
        (highest, point) => point.value > highest ? point.value : highest,
      );
      expect(peak, greaterThan(0));
      expect(peak, lessThan(70));
    },
  );

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
    final today = DateTime.now().startOfDay;
    final through = last.isAfter(today) ? last : today;
    final defaultVisible = EChartVisibleRange.lastYearThrough(
      earliest: first,
      latest: through,
    );
    final chart = tester.widget<EChart<DateTime>>(
      find.byKey(const ValueKey('rolling-load')),
    );
    expect(chart.start, defaultVisible.start);
    expect(chart.end, defaultVisible.end);

    final horizontalScrolls = tester
        .widgetList<Scrollable>(find.byType(Scrollable))
        .where((scrollable) => scrollable.axis == Axis.horizontal);
    expect(horizontalScrolls, isEmpty);

    final weekPointsBefore = _chartUnder(
      tester,
      const ValueKey('active-days-ECalendarChartBarPeriod.week'),
    ).series.single.points.map((point) => point.date).toList();

    await tester.ensureVisible(find.byType(EChartAllTimeRangeScrubber));
    await tester.pumpAndSettle();
    final scrubberBox = tester.getRect(find.byType(EChartAllTimeRangeScrubber));
    await tester.dragFrom(
      Offset(scrubberBox.right - 48, scrubberBox.center.dy),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();

    final afterScrub = tester.widget<EChart<DateTime>>(
      find.byKey(const ValueKey('rolling-load')),
    );
    expect(afterScrub.start.isBefore(defaultVisible.start), isTrue);
    expect(afterScrub.end.isBefore(through), isTrue);

    final weekPointsAfter = _chartUnder(
      tester,
      const ValueKey('active-days-ECalendarChartBarPeriod.week'),
    ).series.single.points.map((point) => point.date).toList();
    expect(weekPointsAfter, weekPointsBefore);
  });
}
