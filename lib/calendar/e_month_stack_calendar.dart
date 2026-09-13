import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_calendar_day_presentation.dart';
import 'e_month_stack_day_chrome.dart';
import 'e_month_stack_metrics.dart';
import 'e_month_stack_multi_select.dart';
import 'e_month_stack_period_summary.dart';

class const EMonthStackCalendar<TId>({
  required final DateTime firstVisibleMonth,
  required final DateTime lastVisibleMonth,
  required final ECalendarDayPresentation<TId> Function(DateTime date)
  presentationFor,
  required final void Function(ECalendarDayPresentation<TId> day) onDaySelected,
  final ECalendarPeriodPresentation Function(DateTime weekMonday)?
  weekPresentation,
  final ECalendarPeriodPresentation Function(DateTime monthStart)?
  monthPresentation,
  final DateTime? today,
  final double? maxHeight,
  final bool scrollToEnd = false,
  final bool omitEmptyMonths = true,
  final bool keepLastMonthIfAnyVisible = false,
  final bool persistSelection = false,
  final void Function(List<ECalendarDayPresentation<TId>> days)?
  onMultiSelectConfirmed,
  final String? multiSelectActionLabel,
  final Widget? empty,
}) extends StatefulWidget {
  @override
  State<EMonthStackCalendar<TId>> createState() =>
      _EMonthStackCalendarState<TId>();
}

class _EMonthStackCalendarState<TId>() extends State<EMonthStackCalendar<TId>> {
  ScrollController? _verticalScroll;
  DateTime? _selectedDate;
  final EMonthStackMultiSelect _multiSelect = EMonthStackMultiSelect();

  @override
  void initState() {
    super.initState();
    if (widget.maxHeight != null) {
      _verticalScroll = ScrollController();
      if (widget.scrollToEnd) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_verticalScroll!.hasClients) {
            _verticalScroll!.jumpTo(_verticalScroll!.position.maxScrollExtent);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _verticalScroll?.dispose();
    super.dispose();
  }

  DateTime get _today => (widget.today ?? DateTime.now()).startOfDay;

  @override
  Widget build(BuildContext context) {
    final months = _visibleMonths();
    if (months.isEmpty) {
      return widget.empty ??
          Padding(
            padding: const EdgeInsets.all(ELayout.spaceXl),
            child: Center(child: Text('No activity yet', style: EText.caption)),
          );
    }

    final grid = LayoutBuilder(
      builder: (context, constraints) {
        final metrics = EMonthStackMetrics.fit(
          availableWidth: constraints.maxWidth,
          showsPeriodSummaries: _showsPeriodSummaries,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final month in months) _month(month, metrics),
          ],
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.maxHeight != null)
          SizedBox(
            height: widget.maxHeight,
            child: SingleChildScrollView(
              controller: _verticalScroll,
              child: grid,
            ),
          )
        else
          grid,
        if (_multiSelect.isSelecting) ...[
          const SizedBox(height: ELayout.spaceMd),
          _multiSelectActionBar(),
        ],
      ],
    );
  }

  List<DateTime> _visibleMonths() {
    final months = <DateTime>[];
    var cursor = DateTime(
      widget.firstVisibleMonth.year,
      widget.firstVisibleMonth.month,
      1,
    );
    final last = DateTime(
      widget.lastVisibleMonth.year,
      widget.lastVisibleMonth.month,
      1,
    );
    while (!cursor.isAfter(last)) {
      final isLast = cursor.year == last.year && cursor.month == last.month;
      if (!widget.omitEmptyMonths ||
          _monthHasNonEmptyDay(cursor) ||
          (widget.keepLastMonthIfAnyVisible && isLast && months.isNotEmpty)) {
        months.add(cursor);
      }
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    return months;
  }

  bool _monthHasNonEmptyDay(DateTime monthStart) {
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    for (var day = 1; day <= daysInMonth; day++) {
      final presentation = widget.presentationFor(
        DateTime(monthStart.year, monthStart.month, day),
      );
      if (presentation.visual is! ECalendarDayEmpty) return true;
    }
    return false;
  }

  Widget _month(DateTime monthStart, EMonthStackMetrics metrics) {
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    return Padding(
      padding: const EdgeInsets.only(bottom: ELayout.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _monthHeader(monthStart, metrics),
          _weekdayHeaders(metrics),
          ..._weekRows(monthStart, daysInMonth, metrics),
        ],
      ),
    );
  }

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String _monthCaption(DateTime monthStart) =>
      '${_monthNames[monthStart.month - 1]} ${monthStart.year}';

  bool get _showsPeriodSummaries =>
      widget.weekPresentation != null || widget.monthPresentation != null;

  Widget _monthHeader(DateTime monthStart, EMonthStackMetrics metrics) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: metrics.cellExtent * DateTime.daysPerWeek - 4,
            child: Text(
              _monthCaption(monthStart),
              style: EText.caption.copyWith(
                color: EColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (metrics.showsPeriodSummaries) _monthSummary(monthStart, metrics),
        ],
      ),
    );
  }

  Widget _monthSummary(DateTime monthStart, EMonthStackMetrics metrics) {
    final presentation = widget.monthPresentation?.call(monthStart);
    return Padding(
      padding: const EdgeInsets.only(left: EMonthStackMetrics.summaryGap),
      child: SizedBox(
        key: ValueKey(
          'e-cal-month-${monthStart.year}-${monthStart.month}',
        ),
        width: metrics.summaryWidth,
        child: presentation != null && !presentation.isEmpty
            ? EMonthStackPeriodSummary(presentation: presentation)
            : null,
      ),
    );
  }

  Widget _weekdayHeaders(EMonthStackMetrics metrics) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final label in _weekdayLabels)
          SizedBox(
            width: metrics.cellExtent,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: EText.caption.copyWith(
                color: EColors.textMuted,
                fontSize: 9,
              ),
            ),
          ),
        if (metrics.showsPeriodSummaries)
          SizedBox(
            width: metrics.summaryWidth + EMonthStackMetrics.summaryGap,
          ),
      ],
    );
  }

  List<Widget> _weekRows(
    DateTime monthStart,
    int daysInMonth,
    EMonthStackMetrics metrics,
  ) {
    final firstWeekday = DateTime(monthStart.year, monthStart.month, 1).weekday;
    final totalSlots = firstWeekday - 1 + daysInMonth;
    final weekCount = (totalSlots / DateTime.daysPerWeek).ceil();
    return [
      for (var week = 0; week < weekCount; week++)
        _weekRow(monthStart, daysInMonth, week, firstWeekday, metrics),
    ];
  }

  Widget _weekRow(
    DateTime monthStart,
    int daysInMonth,
    int week,
    int firstWeekday,
    EMonthStackMetrics metrics,
  ) {
    final cells = <Widget>[];
    var sundayIsInMonth = false;
    for (var weekdayIndex = 0; weekdayIndex < DateTime.daysPerWeek; weekdayIndex++) {
      final dayOffset =
          week * DateTime.daysPerWeek + weekdayIndex - (firstWeekday - 1);
      final isInMonth = dayOffset >= 0 && dayOffset < daysInMonth;
      if (!isInMonth) {
        cells.add(SizedBox(
          width: metrics.cellExtent,
          height: metrics.cellExtent,
        ));
        continue;
      }
      if (weekdayIndex == 6) sundayIsInMonth = true;
      final date = DateTime(monthStart.year, monthStart.month, dayOffset + 1);
      cells.add(_dayTile(widget.presentationFor(date), metrics));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...cells,
          if (metrics.showsPeriodSummaries)
            _weekSummary(
              monthStart,
              week,
              firstWeekday,
              sundayIsInMonth,
              metrics,
            ),
        ],
      ),
    );
  }

  Widget _weekSummary(
    DateTime monthStart,
    int week,
    int firstWeekday,
    bool sundayIsInMonth,
    EMonthStackMetrics metrics,
  ) {
    ECalendarPeriodPresentation? presentation;
    if (sundayIsInMonth) {
      final sundayOffset = week * DateTime.daysPerWeek + 6 - (firstWeekday - 1);
      final sunday = DateTime(
        monthStart.year,
        monthStart.month,
        sundayOffset + 1,
      );
      presentation = widget.weekPresentation!(sunday.shiftedByDays(-6));
    }
    return Padding(
      padding: const EdgeInsets.only(left: EMonthStackMetrics.summaryGap),
      child: SizedBox(
        width: metrics.summaryWidth,
        child: presentation != null && !presentation.isEmpty
            ? EMonthStackPeriodSummary(presentation: presentation)
            : null,
      ),
    );
  }

  Widget _dayTile(
    ECalendarDayPresentation<TId> presentation,
    EMonthStackMetrics metrics,
  ) {
    final date = presentation.date.startOfDay;
    final isToday = date.sameDayAs(_today);
    final isPersistSelected =
        widget.persistSelection && _selectedDate?.sameDayAs(date) == true;
    final isMultiSelected = _multiSelect.contains(date);

    return GestureDetector(
      onTap: () => _activateDay(presentation),
      onLongPress: widget.onMultiSelectConfirmed != null &&
              !_multiSelect.isSelecting
          ? () => setState(() => _multiSelect.enter(date))
          : null,
      child: Semantics(
        button: true,
        label: presentation.semanticsLabel,
        child: EMonthStackDayChrome(
          key: ValueKey('e-cal-day-${date.year}-${date.month}-${date.day}'),
          presentation: presentation,
          cellSize: metrics.cellSize,
          isToday: isToday,
          isSelected: isPersistSelected || isMultiSelected,
          showsMultiSelectCheck: isMultiSelected,
        ),
      ),
    );
  }

  void _activateDay(ECalendarDayPresentation<TId> presentation) {
    final date = presentation.date.startOfDay;
    if (_multiSelect.isSelecting) {
      setState(() => _multiSelect.toggle(date));
      return;
    }
    if (widget.persistSelection) {
      setState(() {
        _selectedDate = _selectedDate?.sameDayAs(date) == true ? null : date;
      });
    }
    widget.onDaySelected(presentation);
  }

  Widget _multiSelectActionBar() {
    final selectedCount = _multiSelect.selectedDates.length;
    return EMonthStackMultiSelectBar(
      selectedCount: selectedCount,
      actionLabel: widget.multiSelectActionLabel ?? 'Confirm',
      onCancel: () => setState(_multiSelect.exit),
      onConfirm: selectedCount > 0
          ? () {
              widget.onMultiSelectConfirmed!(
                _multiSelect.confirmedDays(widget.presentationFor),
              );
              setState(_multiSelect.exit);
            }
          : null,
    );
  }
}
