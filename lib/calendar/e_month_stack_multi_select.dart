import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_text.dart';
import 'e_calendar_day_presentation.dart';

class EMonthStackMultiSelect() {
  bool isSelecting = false;
  final Set<DateTime> selectedDates = {};

  bool contains(DateTime date) => selectedDates.any(date.sameDayAs);

  void enter(DateTime date) {
    isSelecting = true;
    selectedDates
      ..clear()
      ..add(date.startOfDay);
  }

  void exit() {
    isSelecting = false;
    selectedDates.clear();
  }

  void toggle(DateTime date) {
    if (contains(date)) {
      selectedDates.removeWhere(date.sameDayAs);
    } else {
      selectedDates.add(date.startOfDay);
    }
  }

  List<DateTime> get sortedDates {
    final days = selectedDates.toList()..sort((a, b) => a.compareTo(b));
    return days;
  }

  List<ECalendarDayPresentation<TId>> confirmedDays<TId>(
    ECalendarDayPresentation<TId> Function(DateTime date) presentationFor,
  ) {
    return sortedDates.map(presentationFor).toList();
  }
}

class const EMonthStackMultiSelectBar({
  required final int selectedCount,
  required final String actionLabel,
  required final VoidCallback onCancel,
  required final VoidCallback? onConfirm,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dayWord = selectedCount == 1 ? 'day' : 'days';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: EText.body.medium.copyWith(color: EColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            '$selectedCount $dayWord · $actionLabel',
            style: EText.body.medium.copyWith(
              color: selectedCount > 0 ? EColors.accent : EColors.textMuted,
              fontWeight: selectedCount > 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
