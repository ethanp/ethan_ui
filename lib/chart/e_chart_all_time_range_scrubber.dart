import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../theme/e_chart_date_scale.dart';
import 'e_chart_visible_range.dart';
import 'e_chart_visible_range_scrubber.dart';

class const EChartAllTimeRangeSample({
  required final DateTime date,
  required final double value,
});

class const EChartAllTimeRangeLine({
  required final List<EChartAllTimeRangeSample> samples,
  required final Color color,
});

class const EChartAllTimeRangeBarSegment({
  required final double value,
  required final Color color,
});

class const EChartAllTimeRangeBar({
  required final DateTime start,
  required final DateTime end,
  required final List<EChartAllTimeRangeBarSegment> segments,
});

class const EChartAllTimeRangeScrubber({
  final List<EChartAllTimeRangeSample> samples = const [],
  final List<EChartAllTimeRangeLine> lines = const [],
  final List<EChartAllTimeRangeBar> bars = const [],
  final DateTime? rangeStart,
  final DateTime? rangeEnd,
  required final EChartVisibleRange visible,
  required final ValueChanged<EChartVisibleRange> onVisibleRangeChanged,
  final Color lineColor = const Color(0xFFD4B84C),
  final Color? windowColor,
  final double height = 56,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fullStart = (rangeStart ?? _earliestDate())?.startOfDay;
    final fullEnd = (rangeEnd ?? _latestDate())?.startOfDay;
    if (fullStart == null || fullEnd == null) return const SizedBox.shrink();
    final drawnLines = [
      if (samples.length >= 2)
        EChartAllTimeRangeLine(samples: samples, color: lineColor),
      ...lines,
    ];
    return EChartVisibleRangeScrubber(
      fullStart: fullStart,
      fullEnd: fullEnd,
      visible: visible,
      onVisibleRangeChanged: onVisibleRangeChanged,
      windowColor: windowColor ?? lineColor,
      height: height,
      semanticLabel:
          'Available ${EChartDateScale.daySpan(start: fullStart, end: fullEnd, rangeStart: fullStart, rangeEnd: fullEnd)}. '
          'Current ${EChartDateScale.daySpan(start: visible.start, end: visible.end, rangeStart: fullStart, rangeEnd: fullEnd)}.',
      plot: _AllTimeRangePlot(
        fullStart: fullStart,
        fullEnd: fullEnd,
        lines: drawnLines,
        bars: bars,
      ),
    );
  }

  /// Raw dates compare in the same order as their days, so only the winner
  /// pays for [DateTimeExtensions.startOfDay].
  DateTime? _earliestDate() {
    DateTime? earliest;
    void consider(DateTime date) {
      if (earliest == null || date.isBefore(earliest!)) earliest = date;
    }

    for (final sample in samples) {
      consider(sample.date);
    }
    for (final line in lines) {
      for (final sample in line.samples) {
        consider(sample.date);
      }
    }
    for (final bar in bars) {
      consider(bar.start);
    }
    return earliest;
  }

  DateTime? _latestDate() {
    DateTime? latest;
    void consider(DateTime date) {
      if (latest == null || date.isAfter(latest!)) latest = date;
    }

    for (final sample in samples) {
      consider(sample.date);
    }
    for (final line in lines) {
      for (final sample in line.samples) {
        consider(sample.date);
      }
    }
    for (final bar in bars) {
      consider(bar.end);
    }
    return latest;
  }
}

class _AllTimeRangePlot({
  required final DateTime fullStart,
  required final DateTime fullEnd,
  required final List<EChartAllTimeRangeLine> lines,
  required final List<EChartAllTimeRangeBar> bars,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final axis = _MinimapDateAxis(start: fullStart, end: fullEnd);
    for (final line in lines) {
      _paintLine(canvas, size, axis, line);
    }
    _paintBars(canvas, size, axis);
  }

  void _paintLine(
    Canvas canvas,
    Size size,
    _MinimapDateAxis axis,
    EChartAllTimeRangeLine line,
  ) {
    if (line.samples.length < 2) return;
    var peak = 0.0;
    for (final sample in line.samples) {
      if (sample.value > peak) peak = sample.value;
    }
    if (peak <= 0) return;

    final path = Path();
    for (var index = 0; index < line.samples.length; index++) {
      final sample = line.samples[index];
      final x = axis.xAt(sample.date, size.width);
      final y = _yForValue(sample.value, peak, size.height);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, _stroke(line.color));
  }

  void _paintBars(Canvas canvas, Size size, _MinimapDateAxis axis) {
    var peak = 0.0;
    for (final bar in bars) {
      final total = _barTotal(bar);
      if (total > peak) peak = total;
    }
    if (peak <= 0) return;

    for (final bar in bars) {
      final total = _barTotal(bar);
      if (total <= 0) continue;
      final barHeight = total / peak * (size.height - 6);
      final rect = axis.span(
        start: bar.start,
        end: bar.end,
        width: size.width,
        top: size.height - 3 - barHeight,
        bottom: size.height - 3,
      );
      var segmentTop = rect.bottom;
      for (final segment in bar.segments) {
        if (segment.value <= 0) continue;
        final segmentHeight = segment.value / total * rect.height;
        segmentTop -= segmentHeight;
        canvas.drawRect(
          Rect.fromLTRB(
            rect.left,
            segmentTop,
            rect.right,
            segmentTop + segmentHeight,
          ),
          Paint()..color = segment.color,
        );
      }
    }
  }

  double _barTotal(EChartAllTimeRangeBar bar) {
    var total = 0.0;
    for (final segment in bar.segments) {
      total += segment.value;
    }
    return total;
  }

  double _yForValue(double value, double peak, double height) {
    return height - 3 - (value / peak) * (height - 6);
  }

  Paint _stroke(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
  }

  @override
  bool shouldRepaint(covariant _AllTimeRangePlot oldDelegate) {
    if (oldDelegate.fullStart != fullStart ||
        oldDelegate.fullEnd != fullEnd ||
        oldDelegate.lines.length != lines.length ||
        oldDelegate.bars.length != bars.length) {
      return true;
    }
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final previous = oldDelegate.lines[index];
      if (!identical(line.samples, previous.samples) ||
          line.color != previous.color) {
        return true;
      }
    }
    for (var index = 0; index < bars.length; index++) {
      if (!identical(bars[index], oldDelegate.bars[index])) return true;
    }
    return false;
  }
}

/// Runs once per plotted point, so it counts calendar days through a UTC day
/// number instead of building a local `DateTime` (a time-zone lookup) per
/// point. UTC days also keep a DST day from rounding down to the day before.
class _MinimapDateAxis({required DateTime start, required DateTime end}) {
  final int _startDayNumber = _calendarDayNumber(start);
  final int _spanDays = _calendarDayNumber(end) - _calendarDayNumber(start);

  double xAt(DateTime date, double width) {
    if (_spanDays <= 0 || width <= 0) return 0;
    return (_calendarDayNumber(date) - _startDayNumber) / _spanDays * width;
  }

  static int _calendarDayNumber(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  Rect span({
    required DateTime start,
    required DateTime end,
    required double width,
    required double top,
    required double bottom,
  }) {
    final left = xAt(start, width);
    final right = xAt(end, width);
    final barRight = right - left > 1.5 ? right - 0.5 : left + 1;
    return Rect.fromLTRB(left, top, barRight, bottom);
  }
}
