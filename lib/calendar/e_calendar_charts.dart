import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../chart/e_chart.dart';
import '../chart/e_chart_all_time_range_scrubber.dart';
import '../chart/e_chart_interpolation.dart';
import '../chart/e_chart_series.dart';
import '../chart/e_chart_value_scale.dart';
import '../chart/e_chart_visible_range.dart';
import '../chart/e_chart_y_labels.dart';
import '../chart/e_trailing_seven_day_smoothed_totals.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_calendar_instant_quantity.dart';
import 'e_calendar_period_buckets.dart';
import 'e_day_so_far_versus_window_chart.dart';

class const ECalendarCharts({
  required final List<ECalendarDailyMeasure> dailyMeasures,
  required final String measureTitle,
  required final String Function(num quantity) formatMeasure,
  final List<ECalendarInstantQuantity> instantQuantities = const [],
  final DateTime? now,
}) extends StatefulWidget {
  static const measureBarColor = Color(0xFFD4B84C);

  @override
  State<ECalendarCharts> createState() => _ECalendarChartsState();
}

class _ECalendarChartsState() extends State<ECalendarCharts> {
  late final ValueNotifier<EChartVisibleRange> _visibleRange;
  List<ECalendarDailyMeasure> _filledDays = const [];
  List<ETrailingSevenDaySmoothedPoint> _smoothed = const [];
  List<EChartAllTimeRangeSample> _minimapSamples = const [];

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
    _minimapSamples = [
      for (final day in _smoothed)
        EChartAllTimeRangeSample(date: day.date, value: day.smoothedTotal),
    ];
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EChartVisibleRange>(
      valueListenable: _visibleRange,
      builder: (context, visible, _) => _charts(visible),
    );
  }

  Widget _charts(EChartVisibleRange visible) {
    final trendPoints = _trendPointsIn(visible);
    final trendScale = EChartValueScale.nice(
      _trendVisibleMax(trendPoints, visible),
    );
    final yGutterWidth = EChartYLabels.gutterWidthFor(
      scale: trendScale,
      formatTick: (value) => widget.formatMeasure(value),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_rollingLoadTitle, style: EText.section),
        const SizedBox(height: ELayout.spaceSm),
        _rollingLoadChart(visible, trendScale, trendPoints, yGutterWidth),
        const SizedBox(height: ELayout.spaceLg),
        _rangeScrubber(visible),
        EDaySoFarVersusWindowChart(
          instants: widget.instantQuantities,
          formatMeasure: widget.formatMeasure,
          now: widget.now,
          windowStart: visible.start,
          windowEnd: visible.end,
        ),
      ],
    );
  }

  Widget _rangeScrubber(EChartVisibleRange visible) {
    return EChartAllTimeRangeScrubber(
      samples: _minimapSamples,
      visible: visible,
      lineColor: ECalendarCharts.measureBarColor,
      onVisibleRangeChanged: (range) {
        _visibleRange.value = range;
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

}

class const _DatedPlotRow({
  final Key? chartKey,
  required final EChartVisibleRange visible,
  required final EChartValueScale valueScale,
  required final double yGutterWidth,
  required final String Function(double value) formatY,
  required final List<EChartSeries<DateTime>> series,
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
            series: series,
          ),
        ),
      ],
    );
  }
}
