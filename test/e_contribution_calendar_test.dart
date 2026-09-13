import 'package:ethan_ui/ethan_ui.dart';
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toggles selection and builds selected-day content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: EContributionCalendar<DateTime>(
            firstVisibleDate: DateTime(2026, 9, 1),
            lastVisibleDate: DateTime(2026, 9, 12),
            today: DateTime(2026, 9, 12),
            scrollToEnd: false,
            presentationFor: (date) {
              final day = date.startOfDay;
              return ECalendarDayPresentation(
                date: day,
                id: day,
                semanticsLabel: 'library progress ${day.day}',
                visual: day.sameDayAs(DateTime(2026, 9, 8))
                    ? const ECalendarDayMeasuredHeat(intensity: 1)
                    : const ECalendarDayEmpty(),
              );
            },
            selectedDayBuilder: (context, day) =>
                Text('selected ${day.id.month}/${day.id.day}'),
          ),
        ),
      ),
    );

    expect(find.text('selected 9/8'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('e-contrib-day-2026-9-8')));
    await tester.pump();
    expect(find.text('selected 9/8'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('e-contrib-day-2026-9-8')));
    await tester.pump();
    expect(find.text('selected 9/8'), findsNothing);
  });
}
