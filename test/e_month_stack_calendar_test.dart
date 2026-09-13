import 'package:ethan_ui/ethan_ui.dart';
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 9, 12);

  ECalendarDayPresentation<DateTime> presentationFor(DateTime date) {
    final day = date.startOfDay;
    if (day.sameDayAs(DateTime(2026, 9, 8))) {
      return ECalendarDayPresentation(
        date: day,
        id: day,
        semanticsLabel: 'measured 20m',
        visual: const ECalendarDayMeasuredHeat(intensity: 0.5),
        secondaryLabel: '20m',
      );
    }
    if (day.sameDayAs(DateTime(2026, 9, 9))) {
      return ECalendarDayPresentation(
        date: day,
        id: day,
        semanticsLabel: 'recorded without measure',
        visual: const ECalendarDayRecordedWithoutMeasure(),
      );
    }
    return ECalendarDayPresentation(
      date: day,
      id: day,
      semanticsLabel: 'empty ${day.day}',
      visual: const ECalendarDayEmpty(),
    );
  }

  ECalendarPeriodPresentation weekPresentation(DateTime weekMonday) {
    var activeDays = 0;
    for (var offset = 0; offset < 7; offset++) {
      final visual = presentationFor(weekMonday.shiftedByDays(offset)).visual;
      if (visual is! ECalendarDayEmpty) activeDays++;
    }
    return ECalendarPeriodPresentation(
      activeDays: activeDays,
      measureCaption: activeDays > 0 ? '20m' : null,
    );
  }

  ECalendarPeriodPresentation monthPresentation(DateTime monthStart) {
    return const ECalendarPeriodPresentation(
      activeDays: 2,
      measureCaption: '20m',
    );
  }

  Future<void> pumpCalendar(
    WidgetTester tester, {
    void Function(ECalendarDayPresentation<DateTime> day)? onDaySelected,
    void Function(List<ECalendarDayPresentation<DateTime>> days)?
    onMultiSelectConfirmed,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: EMonthStackCalendar<DateTime>(
            firstVisibleMonth: DateTime(2026, 9, 1),
            lastVisibleMonth: DateTime(2026, 9, 1),
            today: today,
            omitEmptyMonths: false,
            presentationFor: presentationFor,
            weekPresentation: weekPresentation,
            monthPresentation: monthPresentation,
            onDaySelected: onDaySelected ?? (_) {},
            onMultiSelectConfirmed: onMultiSelectConfirmed,
            multiSelectActionLabel: 'Add Dose',
          ),
        ),
      ),
    );
  }

  testWidgets('tap returns the stamped day identity', (tester) async {
    ECalendarDayPresentation<DateTime>? selected;
    await pumpCalendar(tester, onDaySelected: (day) => selected = day);
    await tester.tap(find.byKey(const ValueKey('e-cal-day-2026-9-8')));
    expect(selected?.id, DateTime(2026, 9, 8));
    expect(selected?.semanticsLabel, 'measured 20m');
  });

  testWidgets('today uses the gold outline', (tester) async {
    await pumpCalendar(tester);
    final chrome = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const ValueKey('e-cal-day-2026-9-12')),
        matching: find.byType(Container),
      ),
    );
    final decoration = chrome.decoration! as BoxDecoration;
    expect(decoration.border?.top.color, EHeatmapIntensity.todayRing);
  });

  testWidgets('measured heat and recorded-without-measure use different fills', (
    tester,
  ) async {
    await pumpCalendar(tester);
    final measured = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const ValueKey('e-cal-day-2026-9-8')),
        matching: find.byType(Container),
      ),
    );
    final recorded = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const ValueKey('e-cal-day-2026-9-9')),
        matching: find.byType(Container),
      ),
    );
    expect(
      (measured.decoration! as BoxDecoration).color,
      EHeatmapIntensity.colorAt(0.5),
    );
    expect(
      (recorded.decoration! as BoxDecoration).color,
      EColors.surface,
    );
  });

  testWidgets('week and month summaries name active days without heat color', (
    tester,
  ) async {
    await pumpCalendar(tester);
    expect(find.text('days'), findsNWidgets(2));
    expect(find.text('20m'), findsWidgets);
    expect(find.byKey(const ValueKey('e-cal-month-2026-9')), findsOneWidget);
  });

  testWidgets('multi-select confirms stamped identities', (tester) async {
    List<ECalendarDayPresentation<DateTime>>? confirmed;
    await pumpCalendar(tester, onMultiSelectConfirmed: (days) => confirmed = days);
    await tester.longPress(find.byKey(const ValueKey('e-cal-day-2026-9-8')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('e-cal-day-2026-9-9')));
    await tester.pump();
    await tester.tap(find.text('2 days · Add Dose'));
    expect(confirmed?.map((day) => day.id).toList(), [
      DateTime(2026, 9, 8),
      DateTime(2026, 9, 9),
    ]);
  });

  testWidgets('phone width does not open a blank horizontal scroll', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCalendar(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axis == Axis.horizontal,
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('e-cal-month-2026-9')), findsOneWidget);
  });
}
