import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import 'e_chart_all_time_sparkline.dart';
import 'e_chart_visible_range.dart';

class const EChartAllTimeRangeSample({
  required final DateTime date,
  required final double value,
});

enum _RangeScrubberGrab() {
  startHandle,
  endHandle,
  visiblePane,
}

class const EChartAllTimeRangeScrubber({
  required final List<EChartAllTimeRangeSample> samples,
  required final EChartVisibleRange visible,
  required final ValueChanged<EChartVisibleRange> onVisibleRangeChanged,
  final Color lineColor = const Color(0xFFD4B84C),
  final double height = 56,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) return const SizedBox.shrink();
    return Semantics(
      label:
          'All-time range. Visible ${_dateLabel(visible.start)} through ${_dateLabel(visible.end)}.',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: _RangeScrubberSurface(
          samples: samples,
          visible: visible,
          onVisibleRangeChanged: onVisibleRangeChanged,
          lineColor: lineColor,
        ),
      ),
    );
  }

  static String _dateLabel(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class const _RangeScrubberSurface({
  required final List<EChartAllTimeRangeSample> samples,
  required final EChartVisibleRange visible,
  required final ValueChanged<EChartVisibleRange> onVisibleRangeChanged,
  required final Color lineColor,
}) extends StatefulWidget {
  @override
  State<_RangeScrubberSurface> createState() => _RangeScrubberSurfaceState();
}

class _RangeScrubberSurfaceState() extends State<_RangeScrubberSurface> {
  static const _handleHitPx = 20.0;

  _RangeScrubberGrab? _grab;
  EChartVisibleRange? _rangeAtGrab;
  double _xAtGrab = 0;

  DateTime get _fullStart => widget.samples.first.date.startOfDay;
  DateTime get _fullEnd => widget.samples.last.date.startOfDay;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        _ScrubberHorizontalDragRecognizer:
            GestureRecognizerFactoryWithHandlers<
              _ScrubberHorizontalDragRecognizer
            >(
              _ScrubberHorizontalDragRecognizer.new,
              (recognizer) {
                recognizer
                  ..onStart = _beginDrag
                  ..onUpdate = _updateDrag
                  ..onEnd = (_) {
                    _grab = null;
                  }
                  ..onCancel = () {
                    _grab = null;
                  };
              },
            ),
      },
      child: CustomPaint(
        painter: _AllTimeRangePainter(
          values: [for (final sample in widget.samples) sample.value],
          fullStart: _fullStart,
          fullEnd: _fullEnd,
          visible: widget.visible,
          lineColor: widget.lineColor,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  void _beginDrag(DragStartDetails details) {
    final width = context.size?.width ?? 0;
    _grab = _grabAt(details.localPosition.dx, width);
    _rangeAtGrab = widget.visible;
    _xAtGrab = details.localPosition.dx;
  }

  void _updateDrag(DragUpdateDetails details) {
    final grab = _grab;
    final origin = _rangeAtGrab;
    final width = context.size?.width ?? 0;
    if (grab == null || origin == null || width <= 0) return;

    final x = details.localPosition.dx;
    switch (grab) {
      case _RangeScrubberGrab.startHandle:
        widget.onVisibleRangeChanged(
          origin.withStart(
            _dateAtX(x, width),
            earliest: _fullStart,
            latest: _fullEnd,
          ),
        );
      case _RangeScrubberGrab.endHandle:
        widget.onVisibleRangeChanged(
          origin.withEnd(
            _dateAtX(x, width),
            earliest: _fullStart,
            latest: _fullEnd,
          ),
        );
      case _RangeScrubberGrab.visiblePane:
        widget.onVisibleRangeChanged(
          origin.shiftedByDays(
            _daysFromDeltaX(x - _xAtGrab, width),
            earliest: _fullStart,
            latest: _fullEnd,
          ),
        );
    }
  }

  _RangeScrubberGrab _grabAt(double x, double width) {
    final left = _xForDate(widget.visible.start, width);
    final right = _xForDate(widget.visible.end, width);
    final mid = (left + right) / 2;
    if (x <= mid) {
      if ((x - left).abs() <= _handleHitPx) return _RangeScrubberGrab.startHandle;
      if (x >= left && x <= right) return _RangeScrubberGrab.visiblePane;
      return _RangeScrubberGrab.startHandle;
    }
    if ((x - right).abs() <= _handleHitPx) return _RangeScrubberGrab.endHandle;
    if (x >= left && x <= right) return _RangeScrubberGrab.visiblePane;
    return _RangeScrubberGrab.endHandle;
  }

  double _xForDate(DateTime date, double width) {
    final spanDays = _fullEnd.difference(_fullStart).inDays;
    if (spanDays <= 0 || width <= 0) return 0;
    return date.startOfDay.difference(_fullStart).inDays / spanDays * width;
  }

  DateTime _dateAtX(double x, double width) {
    final spanDays = _fullEnd.difference(_fullStart).inDays;
    if (spanDays <= 0 || width <= 0) return _fullStart;
    final t = (x / width).clamp(0.0, 1.0);
    return _fullStart.shiftedByDays((spanDays * t).round());
  }

  int _daysFromDeltaX(double dx, double width) {
    final spanDays = _fullEnd.difference(_fullStart).inDays;
    if (spanDays <= 0 || width <= 0) return 0;
    return (dx / width * spanDays).round();
  }
}

class _ScrubberHorizontalDragRecognizer() extends HorizontalDragGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class _AllTimeRangePainter({
  required final List<double> values,
  required final DateTime fullStart,
  required final DateTime fullEnd,
  required final EChartVisibleRange visible,
  required final Color lineColor,
}) extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    final plot = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas.clipRRect(plot);
    canvas.drawRRect(plot, Paint()..color = EColors.surfaceInset);

    _strokeSparkline(canvas, size);

    final left = _xForDate(visible.start, size.width);
    final right = _xForDate(visible.end, size.width).clamp(left, size.width);
    final outside = Paint()..color = const Color(0x99000000);
    if (left > 0) {
      canvas.drawRect(Rect.fromLTRB(0, 0, left, size.height), outside);
    }
    if (right < size.width) {
      canvas.drawRect(Rect.fromLTRB(right, 0, size.width, size.height), outside);
    }

    canvas.drawRect(
      Rect.fromLTRB(left, 0, right, size.height),
      Paint()
        ..color = lineColor.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromLTRB(left, 0, right, size.height),
      Paint()
        ..color = lineColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final handle = Paint()..color = EColors.textPrimary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(left, size.height / 2), width: 4, height: size.height - 8),
        const Radius.circular(2),
      ),
      handle,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(right, size.height / 2), width: 4, height: size.height - 8),
        const Radius.circular(2),
      ),
      handle,
    );
  }

  void _strokeSparkline(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;
    final columns = EChartAllTimeSparkline.highestInEachColumn(
      values,
      columnCount: size.width.floor().clamp(1, 2048),
    );
    final peak = columns.fold<double>(0, (highest, value) => value > highest ? value : highest);
    if (peak <= 0) return;

    final path = Path();
    for (var column = 0; column < columns.length; column++) {
      final x = columns.length == 1
          ? size.width / 2
          : column / (columns.length - 1) * size.width;
      final y = size.height - (columns[column] / peak) * (size.height - 6) - 3;
      if (column == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  double _xForDate(DateTime date, double width) {
    final spanDays = fullEnd.difference(fullStart).inDays;
    if (spanDays <= 0 || width <= 0) return 0;
    return date.startOfDay.difference(fullStart).inDays / spanDays * width;
  }

  @override
  bool shouldRepaint(covariant _AllTimeRangePainter oldDelegate) {
    return oldDelegate.visible != visible ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fullStart != fullStart ||
        oldDelegate.fullEnd != fullEnd ||
        oldDelegate.values.length != values.length;
  }
}
