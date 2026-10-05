import 'package:ethan_ui/calendar/e_day_so_far_versus_window_chart.dart';
import 'package:ethan_ui/ethan_ui.dart';
import 'package:ethan_utils/ethan_utils.dart';
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

  testWidgets('rolling load sits above the range scrubber', (tester) async {
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

    expect(find.byType(EChart<DateTime>), findsOneWidget);
    expect(find.byType(EChartYLabels), findsOneWidget);

    final rollingLoadTop = tester.getTopLeft(find.byType(EChart<DateTime>)).dy;
    final scrubberTop = tester
        .getTopLeft(find.byType(EChartAllTimeRangeScrubber))
        .dy;
    expect(rollingLoadTop, lessThan(scrubberTop));
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
    _expectScrubberSpans(
      tester,
      fullStart: first,
      fullEnd: through,
      visible: defaultVisible,
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

    final track = find.byKey(const ValueKey('range-scrubber-track'));
    await tester.ensureVisible(track);
    await tester.pumpAndSettle();
    final trackBox = tester.getRect(track);
    await tester.dragFrom(
      Offset(trackBox.right - 48, trackBox.center.dy),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();

    final afterScrub = tester.widget<EChart<DateTime>>(
      find.byKey(const ValueKey('rolling-load')),
    );
    expect(afterScrub.start.isBefore(defaultVisible.start), isTrue);
    expect(afterScrub.end.isBefore(through), isTrue);
    _expectScrubberSpans(
      tester,
      fullStart: first,
      fullEnd: through,
      visible: EChartVisibleRange(
        start: afterScrub.start,
        end: afterScrub.end,
      ),
    );
  });

  testWidgets('today sits under the scrubber against the past week', (
    tester,
  ) async {
    final today = DateTime.now().startOfDay;
    final now = DateTime(today.year, today.month, today.day, 15);
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ECalendarCharts(
              dailyMeasures: [
                ECalendarDailyMeasure(
                  date: today.shiftedByDays(-1),
                  quantity: 14,
                  isActive: true,
                ),
                ECalendarDailyMeasure(
                  date: today,
                  quantity: 4,
                  isActive: true,
                ),
              ],
              instantQuantities: [
                ECalendarInstantQuantity(
                  at: today.shiftedByDays(-8).add(const Duration(hours: 12)),
                  quantity: 100,
                ),
                ECalendarInstantQuantity(
                  at: today.shiftedByDays(-1).add(const Duration(hours: 12)),
                  quantity: 10,
                ),
                ECalendarInstantQuantity(at: today, quantity: 4),
              ],
              measureTitle: 'dosage',
              formatMeasure: (quantity) => '${quantity}mg',
              now: now,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EDaySoFarVersusWindowChart), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('today-versus-window'))).height,
      EDaySoFarVersusWindowChart.plotHeight,
    );
    final scrubberTop = tester
        .getTopLeft(find.byType(EChartAllTimeRangeScrubber))
        .dy;
    final todayTop = tester
        .getTopLeft(find.byKey(const ValueKey('today-versus-window')))
        .dy;
    expect(scrubberTop, lessThan(todayTop));
  });
}

void _expectScrubberSpans(
  WidgetTester tester, {
  required DateTime fullStart,
  required DateTime fullEnd,
  required EChartVisibleRange visible,
}) {
  final label = tester
      .getSemantics(find.byType(EChartVisibleRangeScrubber))
      .label;
  expect(
    label,
    contains(
      EChartDateScale.daySpan(
        start: fullStart,
        end: fullEnd,
        rangeStart: fullStart,
        rangeEnd: fullEnd,
      ),
    ),
  );
  expect(
    label,
    contains(
      EChartDateScale.daySpan(
        start: visible.start,
        end: visible.end,
        rangeStart: fullStart,
        rangeEnd: fullEnd,
      ),
    ),
  );
}
