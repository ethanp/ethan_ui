import 'dart:math' as math;

import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../chart/e_chart.dart';
import '../chart/e_chart_all_time_range_scrubber.dart';
import '../chart/e_chart_interpolation.dart';
import '../chart/e_chart_selected_point.dart';
import '../chart/e_chart_series.dart';
import '../chart/e_chart_value_scale.dart';
import '../chart/e_chart_visible_range.dart';
import '../chart/e_chart_y_labels.dart';
import '../chart/e_trailing_seven_day_smoothed_totals.dart';
import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_calendar_period_buckets.dart';

enum ECalendarChartBarPeriod() {
  week,
  month,
}

class const ECalendarCharts({
  required final List<ECalendarDailyMeasure> dailyMeasures,
  required final String measureTitle,
  required final String Function(num quantity) formatMeasure,
}) extends StatefulWidget {
  static const measureBarColor = Color(0xFFD4B84C);

  @override
  State<ECalendarCharts> createState() => _ECalendarChartsState();
}

class _ECalendarChartsState() extends State<ECalendarCharts> {
  ECalendarChartBarPeriod _barPeriod = ECalendarChartBarPeriod.week;
  late final ValueNotifier<EChartVisibleRange> _visibleRange;
  List<ECalendarDailyMeasure> _filledDays = const [];
  List<ETrailingSevenDaySmoothedPoint> _smoothed = const [];
  List<ECalendarPeriodBucket> _weekBuckets = const [];
  List<ECalendarPeriodBucket> _monthBuckets = const [];

  @override
  void initState() {
    super.initState();
    _visibleRange = ValueNotifier(_rangeFor(widget.dailyMeasures));
    _refreshCaches(resetWindow: true);
  }

  @override
  void didUpdateWidget(ECalendarCharts oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshCaches(resetWindow: _spanChanged(oldWidget.dailyMeasures));
  }

  @override
  void dispose() {
    _visibleRange.dispose();
    super.dispose();
  }

  void _refreshCaches({required bool resetWindow}) {
    _filledDays = ECalendarPeriodBuckets.filledDailyRange(widget.dailyMeasures);
    final through = _throughDay(_filledDays);
    _smoothed = ETrailingSevenDaySmoothedTotals.of([
      for (final day in _filledDays)
        EDailyQuantity(date: day.date, quantity: day.quantity),
    ], through: through);
    _weekBuckets = ECalendarPeriodBuckets.weeks(widget.dailyMeasures);
    _monthBuckets = ECalendarPeriodBuckets.months(widget.dailyMeasures);
    if (_filledDays.isEmpty) return;
    final next = resetWindow
        ? EChartVisibleRange.lastYearThrough(
            earliest: _filledDays.first.date,
            latest: through,
          )
        : _visibleRange.value.clampedTo(
            earliest: _filledDays.first.date,
            latest: through,
          );
    if (_visibleRange.value != next) _visibleRange.value = next;
  }

  bool _spanChanged(List<ECalendarDailyMeasure> previous) {
    if (previous.length != widget.dailyMeasures.length) return true;
    if (previous.isEmpty) return widget.dailyMeasures.isNotEmpty;
    return previous.first.date != widget.dailyMeasures.first.date ||
        previous.last.date != widget.dailyMeasures.last.date;
  }

  EChartVisibleRange _rangeFor(List<ECalendarDailyMeasure> measures) {
    final filled = ECalendarPeriodBuckets.filledDailyRange(measures);
    if (filled.isEmpty) {
      final today = DateTime.now().startOfDay;
      return EChartVisibleRange(start: today, end: today);
    }
    return EChartVisibleRange.lastYearThrough(
      earliest: filled.first.date,
      latest: _throughDay(filled),
    );
  }

  DateTime _throughDay(List<ECalendarDailyMeasure> filled) {
    final today = DateTime.now().startOfDay;
    if (filled.isEmpty) return today;
    final last = filled.last.date.startOfDay;
    return last.isAfter(today) ? last : today;
  }

  String get _rollingLoadTitle {
    final measure = widget.measureTitle;
    if (measure.isEmpty) return 'Rolling load';
    return '${measure[0].toUpperCase()}${measure.substring(1)} rolling load';
  }

  List<ECalendarPeriodBucket> get _allBuckets =>
      _barPeriod == ECalendarChartBarPeriod.week ? _weekBuckets : _monthBuckets;

  String get _periodNoun =>
      _barPeriod == ECalendarChartBarPeriod.week ? 'week' : 'month';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ECalendarChartBarPeriod>(
          segments: const [
            ButtonSegment(
              value: ECalendarChartBarPeriod.week,
              label: Text('Week'),
            ),
            ButtonSegment(
              value: ECalendarChartBarPeriod.month,
              label: Text('Month'),
            ),
          ],
          selected: {_barPeriod},
          onSelectionChanged: (selected) {
            setState(() => _barPeriod = selected.single);
          },
        ),
        const SizedBox(height: ELayout.spaceLg),
        ValueListenableBuilder<EChartVisibleRange>(
          valueListenable: _visibleRange,
          builder: (context, visible, _) => _charts(visible),
        ),
      ],
    );
  }

  Widget _charts(EChartVisibleRange visible) {
    final daysScale = EChartValueScale.nice(_visibleActiveDaysMax(visible));
    final trendPoints = _trendPointsIn(visible);
    final trendScale = EChartValueScale.nice(
      _trendVisibleMax(trendPoints, visible),
    );
    final yGutterWidth = _sharedYGutterWidth(
      daysScale: daysScale,
      trendScale: trendScale,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _activeDaysChart(visible, daysScale, yGutterWidth),
        const SizedBox(height: ELayout.spaceXl),
        Text(_rollingLoadTitle, style: EText.section),
        const SizedBox(height: ELayout.spaceSm),
        _rollingLoadChart(visible, trendScale, trendPoints, yGutterWidth),
        const SizedBox(height: ELayout.spaceLg),
        EChartAllTimeRangeScrubber(
          samples: [
            for (final day in _smoothed)
              EChartAllTimeRangeSample(
                date: day.date,
                value: day.smoothedTotal,
              ),
          ],
          visible: visible,
          lineColor: ECalendarCharts.measureBarColor,
          onVisibleRangeChanged: (range) {
            _visibleRange.value = range;
          },
        ),
      ],
    );
  }

  Widget _activeDaysChart(
    EChartVisibleRange visible,
    EChartValueScale valueScale,
    double yGutterWidth,
  ) {
    return _InspectableBarChart(
      key: ValueKey('active-days-$_barPeriod'),
      title: 'Active days per $_periodNoun',
      barColor: EColors.accent,
      visible: visible,
      valueScale: valueScale,
      yGutterWidth: yGutterWidth,
      formatY: (value) => value.round().toString(),
      points: [
        for (final bucket in _allBuckets)
          EChartPoint<DateTime>(
            date: bucket.periodStart,
            until: bucket.periodEnd,
            value: bucket.activeDays.toDouble(),
            id: bucket.periodStart,
          ),
      ],
      inspectCaption: (selected) {
        final days = selected.value.round();
        return '${_periodCaption(selected.date)} · $days '
            '${days == 1 ? 'day' : 'days'}';
      },
    );
  }

  Widget _rollingLoadChart(
    EChartVisibleRange visible,
    EChartValueScale valueScale,
    List<EChartPoint<DateTime>> trendPoints,
    double yGutterWidth,
  ) {
    if (_filledDays.isEmpty || trendPoints.isEmpty) {
      return SizedBox(
        height: _DatedPlotRow.height,
        child: Center(child: Text('No data yet', style: EText.caption)),
      );
    }
    return SizedBox(
      height: _DatedPlotRow.height,
      child: _DatedPlotRow(
        chartKey: const ValueKey('rolling-load'),
        visible: visible,
        valueScale: valueScale,
        yGutterWidth: yGutterWidth,
        formatY: (value) => widget.formatMeasure(value),
        series: [
          EChartSeries.line(
            id: 'daily-measure',
            points: trendPoints,
            color: ECalendarCharts.measureBarColor,
            strokeWidth: 2.5,
            interpolation: EChartInterpolation.polyline,
          ),
        ],
      ),
    );
  }

  double _sharedYGutterWidth({
    required EChartValueScale daysScale,
    required EChartValueScale trendScale,
  }) {
    return math.max(
      EChartYLabels.gutterWidthFor(
        scale: daysScale,
        formatTick: (value) => value.round().toString(),
      ),
      EChartYLabels.gutterWidthFor(
        scale: trendScale,
        formatTick: (value) => widget.formatMeasure(value),
      ),
    );
  }

  double _visibleActiveDaysMax(EChartVisibleRange visible) {
    var highest = 0.0;
    for (final bucket in _allBuckets) {
      if (!bucket.overlaps(rangeStart: visible.start, rangeEnd: visible.end)) {
        continue;
      }
      if (bucket.activeDays > highest) highest = bucket.activeDays.toDouble();
    }
    return highest;
  }

  double _trendVisibleMax(
    List<EChartPoint<DateTime>> points,
    EChartVisibleRange visible,
  ) {
    var highest = 0.0;
    for (final point in points) {
      if (point.date.isBefore(visible.start) || point.date.isAfter(visible.end)) {
        continue;
      }
      if (point.value > highest) highest = point.value;
    }
    return highest;
  }

  List<EChartPoint<DateTime>> _trendPointsIn(EChartVisibleRange visible) {
    if (_smoothed.isEmpty) return const [];
    var first = 0;
    while (first < _smoothed.length &&
        _smoothed[first].date.isBefore(visible.start)) {
      first++;
    }
    var last = _smoothed.length - 1;
    while (last >= 0 && _smoothed[last].date.isAfter(visible.end)) {
      last--;
    }
    if (first > last) return const [];
    if (first > 0) first--;
    if (last + 1 < _smoothed.length) last++;
    return [
      for (var index = first; index <= last; index++)
        EChartPoint<DateTime>(
          date: _smoothed[index].date,
          value: _smoothed[index].smoothedTotal,
          id: _smoothed[index].date,
        ),
    ];
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

  String _periodCaption(DateTime periodStart) {
    if (_barPeriod == ECalendarChartBarPeriod.month) {
      return _monthNames[periodStart.month - 1];
    }
    return '${periodStart.month}/${periodStart.day}';
  }
}

class const _InspectableBarChart({
  super.key,
  required final String title,
  required final Color barColor,
  required final EChartVisibleRange visible,
  required final EChartValueScale valueScale,
  required final double yGutterWidth,
  required final String Function(double value) formatY,
  required final List<EChartPoint<DateTime>> points,
  required final String Function(EChartSelectedPoint<DateTime> selected)
  inspectCaption,
}) extends StatefulWidget {
  @override
  State<_InspectableBarChart> createState() => _InspectableBarChartState();
}

class _InspectableBarChartState() extends State<_InspectableBarChart> {
  EChartSelectedPoint<DateTime>? _inspected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: EText.section),
        if (_inspected != null) ...[
          const SizedBox(height: ELayout.spaceXs),
          Text(widget.inspectCaption(_inspected!), style: EText.caption),
        ],
        const SizedBox(height: ELayout.spaceSm),
        SizedBox(height: _DatedPlotRow.height, child: _plot()),
      ],
    );
  }

  Widget _plot() {
    if (widget.points.isEmpty) {
      return Center(child: Text('No data yet', style: EText.caption));
    }
    return _DatedPlotRow(
      visible: widget.visible,
      valueScale: widget.valueScale,
      yGutterWidth: widget.yGutterWidth,
      formatY: widget.formatY,
      selectedPoint: _inspected,
      onPointSelected: (selected) {
        setState(() {
          _inspected = selected?.pointId == _inspected?.pointId
              ? null
              : selected;
        });
      },
      series: [
        EChartSeries.bars(
          id: 'bars',
          color: widget.barColor,
          points: widget.points,
        ),
      ],
    );
  }
}

class const _DatedPlotRow({
  final Key? chartKey,
  required final EChartVisibleRange visible,
  required final EChartValueScale valueScale,
  required final double yGutterWidth,
  required final String Function(double value) formatY,
  required final List<EChartSeries<DateTime>> series,
  final EChartSelectedPoint<DateTime>? selectedPoint,
  final void Function(EChartSelectedPoint<DateTime>? selected)? onPointSelected,
}) extends StatelessWidget {
  static const height = 180.0;
  static const topPadding = 8.0;
  static const bottomPadding = 22.0;
  static const leftPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EChartYLabels(
          scale: valueScale,
          height: height,
          width: yGutterWidth,
          topPadding: topPadding,
          bottomPadding: bottomPadding,
          formatTick: formatY,
        ),
        Expanded(
          child: EChart<DateTime>(
            key: chartKey,
            start: visible.start,
            end: visible.end,
            valueScale: valueScale,
            leftPadding: leftPadding,
            topPadding: topPadding,
            bottomPadding: bottomPadding,
            paintsValueTicks: false,
            selectedPoint: selectedPoint,
            onPointSelected: onPointSelected,
            series: series,
          ),
        ),
      ],
    );
  }
}
