import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../chart/e_bar_chart.dart';
import '../chart/e_chart.dart';
import '../chart/e_chart_all_time_range_scrubber.dart';
import '../chart/e_chart_interpolation.dart';
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
    _smoothed = ETrailingSevenDaySmoothedTotals.of([
      for (final day in _filledDays)
        EDailyQuantity(date: day.date, quantity: day.quantity),
    ]);
    _weekBuckets = ECalendarPeriodBuckets.weeks(widget.dailyMeasures);
    _monthBuckets = ECalendarPeriodBuckets.months(widget.dailyMeasures);
    if (_filledDays.isEmpty) return;
    final next = resetWindow
        ? EChartVisibleRange.lastYearThrough(
            earliest: _filledDays.first.date,
            latest: _filledDays.last.date,
          )
        : _visibleRange.value.clampedTo(
            earliest: _filledDays.first.date,
            latest: _filledDays.last.date,
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
      latest: filled.last.date,
    );
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
          builder: (context, visible, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _barChart(
                  key: ValueKey('active-days-$_barPeriod'),
                  title: 'Active days per $_periodNoun',
                  barColor: EColors.accent,
                  formatY: (value) => value.round().toString(),
                  bars: [
                    for (final bucket in _bucketsIn(visible))
                      EBarChartBar(
                        id: 'days-${bucket.periodStart.millisecondsSinceEpoch}',
                        value: bucket.activeDays.toDouble(),
                        caption:
                            '${bucket.activeDays} '
                            '${bucket.activeDays == 1 ? 'day' : 'days'}',
                        axisLabel: _axisLabel(bucket.periodStart),
                      ),
                  ],
                ),
                const SizedBox(height: ELayout.spaceXl),
                _barChart(
                  key: ValueKey('measure-$_barPeriod'),
                  title: '${widget.measureTitle} per $_periodNoun',
                  barColor: ECalendarCharts.measureBarColor,
                  formatY: (value) => widget.formatMeasure(value),
                  bars: [
                    for (final bucket in _bucketsIn(visible))
                      EBarChartBar(
                        id: 'measure-${bucket.periodStart.millisecondsSinceEpoch}',
                        value: bucket.measureSum.toDouble(),
                        caption: widget.formatMeasure(bucket.measureSum),
                        axisLabel: _axisLabel(bucket.periodStart),
                      ),
                  ],
                ),
                const SizedBox(height: ELayout.spaceXl),
                Text(
                  'Trailing 7-day ${widget.measureTitle}',
                  style: EText.section,
                ),
                const SizedBox(height: ELayout.spaceSm),
                SizedBox(height: 180, child: _trend(visible)),
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
          },
        ),
      ],
    );
  }

  Widget _barChart({
    required Key key,
    required String title,
    required Color barColor,
    required String Function(double value) formatY,
    required List<EBarChartBar> bars,
  }) {
    return EBarChart(
      key: key,
      title: title,
      barColor: barColor,
      formatY: formatY,
      sharesPlotWidthEvenly: true,
      bars: bars,
    );
  }

  List<ECalendarPeriodBucket> _bucketsIn(EChartVisibleRange visible) {
    return [
      for (final bucket in _allBuckets)
        if (_bucketOverlaps(bucket, visible)) bucket,
    ];
  }

  bool _bucketOverlaps(
    ECalendarPeriodBucket bucket,
    EChartVisibleRange visible,
  ) {
    final lastDay = _barPeriod == ECalendarChartBarPeriod.week
        ? bucket.periodStart.shiftedByDays(6)
        : DateTime(bucket.periodStart.year, bucket.periodStart.month + 1, 0);
    return !lastDay.isBefore(visible.start) &&
        !bucket.periodStart.isAfter(visible.end);
  }

  Widget _trend(EChartVisibleRange visible) {
    if (_filledDays.isEmpty) {
      return Center(child: Text('No data yet', style: EText.caption));
    }
    final points = _trendPointsIn(visible);
    if (points.isEmpty) {
      return Center(child: Text('No data yet', style: EText.caption));
    }
    final visibleMax = points
        .where(
          (point) =>
              !point.date.isBefore(visible.start) &&
              !point.date.isAfter(visible.end),
        )
        .fold<double>(
          0,
          (highest, point) => point.value > highest ? point.value : highest,
        );
    final valueScale = EChartValueScale.nice(visibleMax);
    return Row(
      children: [
        EChartYLabels(
          scale: valueScale,
          height: 180,
          topPadding: 8,
          bottomPadding: 22,
          formatTick: (value) => widget.formatMeasure(value),
        ),
        Expanded(
          child: EChart<DateTime>(
            start: visible.start,
            end: visible.end,
            valueScale: valueScale,
            leftPadding: 8,
            paintsValueTicks: false,
            series: [
              EChartSeries.line(
                id: 'daily-measure',
                points: points,
                color: ECalendarCharts.measureBarColor,
                strokeWidth: 2.5,
                interpolation: EChartInterpolation.polyline,
              ),
            ],
          ),
        ),
      ],
    );
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

  String _axisLabel(DateTime periodStart) {
    if (_barPeriod == ECalendarChartBarPeriod.month) {
      return _monthNames[periodStart.month - 1];
    }
    return '${periodStart.month}/${periodStart.day}';
  }
}
