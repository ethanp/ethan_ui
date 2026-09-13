import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_heatmap_intensity.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_calendar_day_presentation.dart';

class const EContributionCalendar<TId>({
  required final DateTime firstVisibleDate,
  required final DateTime lastVisibleDate,
  required final ECalendarDayPresentation<TId> Function(DateTime date)
  presentationFor,
  final Widget Function(
    BuildContext context,
    ECalendarDayPresentation<TId> day,
  )?
  selectedDayBuilder,
  final DateTime? today,
  final bool scrollToEnd = true,
}) extends StatefulWidget {
  @override
  State<EContributionCalendar<TId>> createState() =>
      _EContributionCalendarState<TId>();
}

class _EContributionCalendarState<TId>()
    extends State<EContributionCalendar<TId>> {
  final _horizontalScroll = ScrollController();
  DateTime? _selectedDate;
  bool _weeksFitViewport = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _alignLatestWeek());
  }

  void _alignLatestWeek() {
    if (!_horizontalScroll.hasClients) return;
    final fits = _horizontalScroll.position.maxScrollExtent <= 0;
    if (fits != _weeksFitViewport) {
      setState(() => _weeksFitViewport = fits);
    }
    if (!fits && widget.scrollToEnd) {
      _horizontalScroll.jumpTo(_horizontalScroll.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _horizontalScroll.dispose();
    super.dispose();
  }

  DateTime get _today => (widget.today ?? DateTime.now()).startOfDay;

  DateTime get _first => widget.firstVisibleDate.startOfDay;

  DateTime get _last => widget.lastVisibleDate.startOfDay;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDate == null
        ? null
        : widget.presentationFor(_selectedDate!);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          controller: _horizontalScroll,
          scrollDirection: Axis.horizontal,
          physics: _weeksFitViewport
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_weekdayLabels(), ..._months()],
          ),
        ),
        if (selected != null && widget.selectedDayBuilder != null) ...[
          const SizedBox(height: ELayout.spaceSm),
          widget.selectedDayBuilder!(context, selected),
        ],
      ],
    );
  }

  Widget _weekdayLabels() {
    const labels = ['', 'M', '', 'W', '', 'F', ''];
    return Column(
      children: [
        const SizedBox(height: 13),
        for (final label in labels)
          SizedBox(
            height: _ContributionChrome.cellExtent,
            width: 20,
            child: Text(
              label,
              style: EText.caption.copyWith(fontSize: 9),
            ),
          ),
      ],
    );
  }

  List<Widget> _months() {
    final months = <Widget>[];
    var cursor = DateTime(_first.year, _first.month, 1);
    final lastMonth = DateTime(_last.year, _last.month, 1);
    while (!cursor.isAfter(lastMonth)) {
      final month = _month(cursor);
      if (month != null) months.add(month);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    return months;
  }

  Widget? _month(DateTime monthStart) {
    final firstOfMonth = DateTime(monthStart.year, monthStart.month, 1);
    var weekStart = firstOfMonth.shiftedByDays(-(firstOfMonth.weekday % 7));
    final weekColumns = <Widget>[];
    while (weekStart.isBefore(DateTime(monthStart.year, monthStart.month + 1, 1))) {
      final column = _weekColumn(weekStart, monthStart);
      if (column != null) weekColumns.add(column);
      weekStart = weekStart.shiftedByDays(7);
      if (weekStart.isAfter(_last.shiftedByDays(6))) break;
    }
    if (weekColumns.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              for (var weekIndex = 0; weekIndex < weekColumns.length; weekIndex++)
                SizedBox(
                  width: _ContributionChrome.cellExtent,
                  child: weekIndex == 0
                      ? Text(
                          _monthCaption(monthStart),
                          style: EText.caption.copyWith(fontSize: 9),
                          overflow: TextOverflow.visible,
                          softWrap: false,
                        )
                      : null,
                ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: weekColumns,
        ),
      ],
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

  String _monthCaption(DateTime monthStart) {
    final year = monthStart.year % 100;
    final yearLabel = year.toString().padLeft(2, '0');
    return '${_monthNames[monthStart.month - 1]} $yearLabel';
  }

  Widget? _weekColumn(DateTime weekStart, DateTime monthStart) {
    final days = <Widget>[];
    var hasVisibleDay = false;
    for (var dayOffset = 0; dayOffset < DateTime.daysPerWeek; dayOffset++) {
      final date = weekStart.shiftedByDays(dayOffset).startOfDay;
      final isInMonth =
          date.year == monthStart.year && date.month == monthStart.month;
      if (!isInMonth || date.isBefore(_first) || date.isAfter(_last)) {
        days.add(const SizedBox(
          width: _ContributionChrome.cellExtent,
          height: _ContributionChrome.cellExtent,
        ));
        continue;
      }
      hasVisibleDay = true;
      days.add(_dayTile(widget.presentationFor(date)));
    }
    if (!hasVisibleDay) return null;
    return Column(children: days);
  }

  Widget _dayTile(ECalendarDayPresentation<TId> presentation) {
    final date = presentation.date.startOfDay;
    final isSelected = _selectedDate?.sameDayAs(date) == true;
    final isToday = date.sameDayAs(_today);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = isSelected ? null : date;
        });
      },
      child: Semantics(
        button: true,
        label: presentation.semanticsLabel,
        child: Container(
          key: ValueKey('e-contrib-day-${date.year}-${date.month}-${date.day}'),
          width: _ContributionChrome.cellSize,
          height: _ContributionChrome.cellSize,
          margin: const EdgeInsets.all(_ContributionChrome.cellMargin),
          decoration: BoxDecoration(
            color: presentation.visual.fill,
            borderRadius: BorderRadius.circular(2),
            border: isSelected
                ? Border.all(color: EColors.accent, width: 1.5)
                : isToday
                ? Border.all(color: EHeatmapIntensity.todayRing, width: 1.5)
                : Border.fromBorderSide(EHeatmapIntensity.cellHairline),
          ),
        ),
      ),
    );
  }
}

abstract final class _ContributionChrome() {
  static const cellSize = 10.0;
  static const cellMargin = 1.0;
  static const cellExtent = cellSize + cellMargin * 2;
}
