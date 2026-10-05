import 'package:ethan_ui/calendar/e_calendar_instant_quantity.dart';
import 'package:ethan_ui/calendar/e_day_so_far_versus_window_chart.dart';
import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class const _Dose({
  required final int hour,
  required final int minute,
  required final num quantity,
});

void main() {
  final today = DateTime(2026, 10, 4);

  testWidgets('scrubbing reads the window average at that hour', (tester) async {
    final now = DateTime(2026, 10, 4, 20);
    await _pump(
      tester,
      now: now,
      instants: [
        for (var daysAgo = 1; daysAgo <= 7; daysAgo++)
          ECalendarInstantQuantity(
            at: DateTime(2026, 10, 4 - daysAgo, 18),
            quantity: 9,
          ),
      ],
    );

    final atNow = _averageAmount(tester);
    expect(atNow, greaterThan(1));
    expect(find.byKey(const ValueKey('clear-as-of-now')), findsNothing);

    final plot = tester.getRect(find.byKey(const ValueKey('today-versus-window')));
    await tester.dragFrom(plot.center, Offset(-plot.width * 0.35, 0));
    await tester.pumpAndSettle();

    expect(_averageAmount(tester), lessThan(atNow));
    expect(find.byKey(const ValueKey('clear-as-of-now')), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('clear-as-of-now')));
    await tester.pumpAndSettle();

    expect(_averageAmount(tester), atNow);
    expect(find.byKey(const ValueKey('clear-as-of-now')), findsNothing);
  });

  testWidgets('behind the past week at 7:41 PM', (tester) async {
    await _pump(
      tester,
      now: DateTime(2026, 10, 4, 19, 41),
      instants: _instants(
        today: today,
        pastWeek: const [
          _Dose(hour: 8, minute: 0, quantity: 2),
          _Dose(hour: 12, minute: 0, quantity: 2),
          _Dose(hour: 16, minute: 0, quantity: 2),
          _Dose(hour: 21, minute: 0, quantity: 3),
        ],
        todayDoses: const [
          _Dose(hour: 9, minute: 0, quantity: 2),
          _Dose(hour: 15, minute: 0, quantity: 2),
        ],
        lighterDayOffset: 3,
      ),
    );
    await _expectPreview(tester, 'day_pace_behind_the_week.png');
  });

  testWidgets('ahead of the past week at 3 PM', (tester) async {
    await _pump(
      tester,
      now: DateTime(2026, 10, 4, 15),
      instants: _instants(
        today: today,
        pastWeek: const [_Dose(hour: 18, minute: 0, quantity: 2)],
        todayDoses: const [
          _Dose(hour: 8, minute: 0, quantity: 4),
          _Dose(hour: 11, minute: 0, quantity: 4),
          _Dose(hour: 14, minute: 0, quantity: 4),
        ],
      ),
    );
    await _expectPreview(tester, 'day_pace_ahead_of_the_week.png');
  });

  testWidgets('morning before today has a dose', (tester) async {
    await _pump(
      tester,
      now: DateTime(2026, 10, 4, 8, 5),
      instants: _instants(
        today: today,
        pastWeek: const [
          _Dose(hour: 11, minute: 0, quantity: 4),
          _Dose(hour: 19, minute: 0, quantity: 6),
        ],
      ),
    );
    await _expectPreview(tester, 'day_pace_morning_before_today.png');
  });

  testWidgets('near midnight with today close to the week', (tester) async {
    await _pump(
      tester,
      now: DateTime(2026, 10, 4, 23, 40),
      instants: _instants(
        today: today,
        pastWeek: const [
          _Dose(hour: 12, minute: 0, quantity: 4),
          _Dose(hour: 20, minute: 0, quantity: 4),
        ],
        todayDoses: const [
          _Dose(hour: 10, minute: 0, quantity: 3),
          _Dose(hour: 18, minute: 0, quantity: 3),
          _Dose(hour: 22, minute: 0, quantity: 2),
        ],
      ),
    );
    await _expectPreview(tester, 'day_pace_near_midnight.png');
  });
}

List<ECalendarInstantQuantity> _instants({
  required DateTime today,
  required List<_Dose> pastWeek,
  List<_Dose> todayDoses = const [],
  int? lighterDayOffset,
}) {
  final instants = <ECalendarInstantQuantity>[];
  for (var daysAgo = 1; daysAgo <= 7; daysAgo++) {
    final day = today.subtract(Duration(days: daysAgo));
    final doses = daysAgo == lighterDayOffset
        ? pastWeek.take(pastWeek.length - 1)
        : pastWeek;
    for (final dose in doses) {
      instants.add(
        ECalendarInstantQuantity(
          at: DateTime(day.year, day.month, day.day, dose.hour, dose.minute),
          quantity: dose.quantity,
        ),
      );
    }
  }
  for (final dose in todayDoses) {
    instants.add(
      ECalendarInstantQuantity(
        at: DateTime(today.year, today.month, today.day, dose.hour, dose.minute),
        quantity: dose.quantity,
      ),
    );
  }
  return instants;
}

Future<void> _pump(
  WidgetTester tester, {
  required DateTime now,
  required List<ECalendarInstantQuantity> instants,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 360));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: EColors.surface,
      ),
      home: Scaffold(
        backgroundColor: EColors.surface,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: RepaintBoundary(
            key: const ValueKey('day-pace-preview'),
            child: EDaySoFarVersusWindowChart(
              instants: instants,
              now: now,
              windowStart: DateTime(2026, 9, 27),
              windowEnd: DateTime(2026, 10, 3),
              formatMeasure: (quantity) => '${quantity}mg',
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(
    tester.getSize(find.byKey(const ValueKey('today-versus-window'))).height,
    EDaySoFarVersusWindowChart.plotHeight,
  );
  expect(tester.takeException(), isNull);
}

double _averageAmount(WidgetTester tester) {
  final caption = tester
      .widget<Text>(find.byKey(const ValueKey('window-average-as-of')))
      .data!;
  return double.parse(caption.replaceAll('mg', ''));
}

Future<void> _expectPreview(WidgetTester tester, String filename) {
  return expectLater(
    find.byKey(const ValueKey('day-pace-preview')),
    matchesGoldenFile('goldens/$filename'),
  );
}
