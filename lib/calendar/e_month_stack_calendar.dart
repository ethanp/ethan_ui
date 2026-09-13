import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_heatmap_intensity.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_calendar_day_presentation.dart';

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
  bool _isSelectingDays = false;
  final Set<DateTime> _multiSelectedDates = {};

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
        final metrics = _MonthStackMetrics.fit(
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
        if (_isSelectingDays) ...[
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

  Widget _month(DateTime monthStart, _MonthStackMetrics metrics) {
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

  Widget _monthHeader(DateTime monthStart, _MonthStackMetrics metrics) {
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

  Widget _monthSummary(DateTime monthStart, _MonthStackMetrics metrics) {
    final presentation = widget.monthPresentation?.call(monthStart);
    return Padding(
      padding: const EdgeInsets.only(left: _MonthStackMetrics.summaryGap),
      child: SizedBox(
        key: ValueKey(
          'e-cal-month-${monthStart.year}-${monthStart.month}',
        ),
        width: metrics.summaryWidth,
        child: presentation != null && !presentation.isEmpty
            ? _PeriodSummaryChrome(presentation: presentation)
            : null,
      ),
    );
  }

  Widget _weekdayHeaders(_MonthStackMetrics metrics) {
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
            width: metrics.summaryWidth + _MonthStackMetrics.summaryGap,
          ),
      ],
    );
  }

  List<Widget> _weekRows(
    DateTime monthStart,
    int daysInMonth,
    _MonthStackMetrics metrics,
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
    _MonthStackMetrics metrics,
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
    _MonthStackMetrics metrics,
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
      padding: const EdgeInsets.only(left: _MonthStackMetrics.summaryGap),
      child: SizedBox(
        width: metrics.summaryWidth,
        child: presentation != null && !presentation.isEmpty
            ? _PeriodSummaryChrome(presentation: presentation)
            : null,
      ),
    );
  }

  Widget _dayTile(
    ECalendarDayPresentation<TId> presentation,
    _MonthStackMetrics metrics,
  ) {
    final date = presentation.date.startOfDay;
    final isToday = date.sameDayAs(_today);
    final isPersistSelected =
        widget.persistSelection && _selectedDate?.sameDayAs(date) == true;
    final isMultiSelected = _multiSelectedDates.any(date.sameDayAs);

    return GestureDetector(
      onTap: () => _activateDay(presentation),
      onLongPress: widget.onMultiSelectConfirmed != null && !_isSelectingDays
          ? () => _enterMultiSelect(date)
          : null,
      child: Semantics(
        button: true,
        label: presentation.semanticsLabel,
        child: _MonthStackDayChrome(
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
    if (_isSelectingDays) {
      setState(() {
        if (_multiSelectedDates.any(date.sameDayAs)) {
          _multiSelectedDates.removeWhere(date.sameDayAs);
        } else {
          _multiSelectedDates.add(date);
        }
      });
      return;
    }
    if (widget.persistSelection) {
      setState(() {
        _selectedDate = _selectedDate?.sameDayAs(date) == true ? null : date;
      });
    }
    widget.onDaySelected(presentation);
  }

  void _enterMultiSelect(DateTime date) {
    setState(() {
      _isSelectingDays = true;
      _multiSelectedDates
        ..clear()
        ..add(date.startOfDay);
    });
  }

  void _exitMultiSelect() {
    setState(() {
      _isSelectingDays = false;
      _multiSelectedDates.clear();
    });
  }

  Widget _multiSelectActionBar() {
    final selectedCount = _multiSelectedDates.length;
    final actionLabel = widget.multiSelectActionLabel ?? 'Confirm';
    final dayWord = selectedCount == 1 ? 'day' : 'days';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _exitMultiSelect,
          child: Text('Cancel', style: EText.body.medium.copyWith(color: EColors.textMuted)),
        ),
        TextButton(
          onPressed: selectedCount > 0
              ? () {
                  final days = _multiSelectedDates.toList()
                    ..sort((a, b) => a.compareTo(b));
                  widget.onMultiSelectConfirmed!(
                    days.map(widget.presentationFor).toList(),
                  );
                  _exitMultiSelect();
                }
              : null,
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

class const _MonthStackMetrics({
  required final double cellSize,
  required final double cellExtent,
  required final double summaryWidth,
  required final bool showsPeriodSummaries,
}) {
  static const preferredCellSize = 39.0;
  static const cellMargin = 2.0;
  static const preferredCellExtent = preferredCellSize + cellMargin * 2;
  static const preferredSummaryWidth = 80.0;
  static const summaryGap = 8.0;
  static const minCellSize = 24.0;

  static _MonthStackMetrics fit({
    required double availableWidth,
    required bool showsPeriodSummaries,
  }) {
    final summaryGutter = showsPeriodSummaries
        ? summaryGap + preferredSummaryWidth
        : 0.0;
    final widthForCells = availableWidth.isFinite
        ? availableWidth - summaryGutter
        : preferredCellExtent * DateTime.daysPerWeek;
    final minExtent = minCellSize + cellMargin * 2;
    final cellExtent = (widthForCells / DateTime.daysPerWeek).clamp(
      minExtent,
      preferredCellExtent,
    );
    return _MonthStackMetrics(
      cellSize: cellExtent - cellMargin * 2,
      cellExtent: cellExtent,
      summaryWidth: preferredSummaryWidth,
      showsPeriodSummaries: showsPeriodSummaries,
    );
  }
}

class const _MonthStackDayChrome({
  super.key,
  required final ECalendarDayPresentation<dynamic> presentation,
  required final double cellSize,
  required final bool isToday,
  required final bool isSelected,
  required final bool showsMultiSelectCheck,
}) extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final visual = presentation.visual;
    return Container(
      width: cellSize,
      height: cellSize,
      margin: const EdgeInsets.all(_MonthStackMetrics.cellMargin),
      decoration: BoxDecoration(
        color: isSelected
            ? EColors.accent.withValues(alpha: 0.25)
            : visual.fill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? EColors.accent
              : isToday
              ? EHeatmapIntensity.todayRing
              : visual is ECalendarDayEmpty
              ? EHeatmapIntensity.cellHairline.color
              : visual.fill.withValues(alpha: 0.6),
          width: isSelected
              ? 2
              : isToday
              ? 1.5
              : EHeatmapIntensity.cellHairline.width,
        ),
        boxShadow: visual.showsMeasuredGlow && !isSelected
            ? [
                BoxShadow(
                  color: visual.fill.withValues(alpha: 0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: showsMultiSelectCheck
          ? const Center(child: Icon(Icons.check, size: 16, color: EColors.accent))
          : _labels(visual),
    );
  }

  Widget _labels(ECalendarDayVisual visual) {
    return Stack(
      children: [
        Positioned(
          left: 3,
          top: 2,
          child: Text(
            presentation.dayNumberLabel,
            style: TextStyle(
              fontSize: visual is ECalendarDayEmpty ? 11 : 8,
              fontWeight: FontWeight.w500,
              color: visual.ink.withValues(
                alpha: visual is ECalendarDayEmpty ? 1 : 0.7,
              ),
            ),
          ),
        ),
        if (presentation.secondaryLabel != null)
          Positioned(
            right: 2,
            top: 12,
            child: Text(
              presentation.secondaryLabel!,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: visual.ink,
              ),
            ),
          ),
        if (presentation.markers.isNotEmpty)
          Positioned(
            left: 2,
            bottom: 2,
            child: Row(
              children: [
                for (final marker in presentation.markers)
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Text(
                      marker.label[0],
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: visual.ink.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class const _PeriodSummaryChrome({
  required final ECalendarPeriodPresentation presentation,
}) extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${presentation.activeDays}',
                textAlign: TextAlign.center,
                style: EText.caption.copyWith(
                  color: EColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              Text(
                presentation.activeDays == 1 ? 'day' : 'days',
                textAlign: TextAlign.center,
                style: EText.caption.copyWith(
                  color: EColors.textMuted,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        if (presentation.measureCaption != null) ...[
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              presentation.measureCaption!,
              style: EText.caption.copyWith(fontSize: 10),
            ),
          ),
        ],
      ],
    );
  }
}
