import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/e_chart_axis.dart';
import '../theme/e_chart_date_scale.dart';
import '../theme/e_colors.dart';
import 'e_chart_visible_range.dart';

enum _RangeScrubberGrab() {
  startHandle,
  endHandle,
  visiblePane,
}

/// All-time plot with a draggable visible window. [plot] paints the miniature
/// across [fullStart]–[fullEnd]; the window is the shared selected range.
class const EChartVisibleRangeScrubber({
  required final DateTime fullStart,
  required final DateTime fullEnd,
  required final EChartVisibleRange visible,
  required final ValueChanged<EChartVisibleRange> onVisibleRangeChanged,
  required final CustomPainter plot,
  final Color windowColor = const Color(0xFFD4B84C),
  final double height = 56,
  final String? semanticLabel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final axisStart = fullStart.startOfDay;
    final axisEnd = fullEnd.startOfDay;
    return Semantics(
      label:
          semanticLabel ??
          'Available ${EChartDateScale.daySpan(start: axisStart, end: axisEnd, rangeStart: axisStart, rangeEnd: axisEnd)}. '
          'Current ${EChartDateScale.daySpan(start: visible.start, end: visible.end, rangeStart: axisStart, rangeEnd: axisEnd)}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            key: const ValueKey('range-scrubber-track'),
            height: height,
            width: double.infinity,
            child: _RangeScrubberSurface(
              fullStart: axisStart,
              fullEnd: axisEnd,
              visible: visible,
              onVisibleRangeChanged: onVisibleRangeChanged,
              plot: plot,
              windowColor: windowColor,
            ),
          ),
          SizedBox(
            height: _FullRangeEndCaptions.bandHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _FullRangeEndCaptions(
                fullStart: axisStart,
                fullEnd: axisEnd,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class const _RangeScrubberSurface({
  required final DateTime fullStart,
  required final DateTime fullEnd,
  required final EChartVisibleRange visible,
  required final ValueChanged<EChartVisibleRange> onVisibleRangeChanged,
  required final CustomPainter plot,
  required final Color windowColor,
}) extends StatefulWidget {
  @override
  State<_RangeScrubberSurface> createState() => _RangeScrubberSurfaceState();
}

class _RangeScrubberSurfaceState() extends State<_RangeScrubberSurface> {
  static const _handleHitPx = 20.0;

  _RangeScrubberGrab? _grab;
  EChartVisibleRange? _rangeAtGrab;
  double _xAtGrab = 0;

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
        painter: _ScrubberTrackBackdrop(plot: widget.plot),
        foregroundPainter: _VisibleRangeWindowPainter(
          fullStart: widget.fullStart,
          fullEnd: widget.fullEnd,
          visible: widget.visible,
          windowColor: widget.windowColor,
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
            earliest: widget.fullStart,
            latest: widget.fullEnd,
          ),
        );
      case _RangeScrubberGrab.endHandle:
        widget.onVisibleRangeChanged(
          origin.withEnd(
            _dateAtX(x, width),
            earliest: widget.fullStart,
            latest: widget.fullEnd,
          ),
        );
      case _RangeScrubberGrab.visiblePane:
        widget.onVisibleRangeChanged(
          origin.shiftedByDays(
            _daysFromDeltaX(x - _xAtGrab, width),
            earliest: widget.fullStart,
            latest: widget.fullEnd,
          ),
        );
    }
  }

  _RangeScrubberGrab _grabAt(double x, double width) {
    final left = _xForDate(widget.visible.start, width);
    final right = _xForDate(widget.visible.end, width);
    final mid = (left + right) / 2;
    if (x <= mid) {
      if ((x - left).abs() <= _handleHitPx) {
        return _RangeScrubberGrab.startHandle;
      }
      if (x >= left && x <= right) return _RangeScrubberGrab.visiblePane;
      return _RangeScrubberGrab.startHandle;
    }
    if ((x - right).abs() <= _handleHitPx) return _RangeScrubberGrab.endHandle;
    if (x >= left && x <= right) return _RangeScrubberGrab.visiblePane;
    return _RangeScrubberGrab.endHandle;
  }

  double _xForDate(DateTime date, double width) {
    final spanDays = widget.fullEnd.difference(widget.fullStart).inDays;
    if (spanDays <= 0 || width <= 0) return 0;
    return date.startOfDay.difference(widget.fullStart).inDays / spanDays * width;
  }

  DateTime _dateAtX(double x, double width) {
    final spanDays = widget.fullEnd.difference(widget.fullStart).inDays;
    if (spanDays <= 0 || width <= 0) return widget.fullStart;
    final t = (x / width).clamp(0.0, 1.0);
    return widget.fullStart.shiftedByDays((spanDays * t).round());
  }

  int _daysFromDeltaX(double dx, double width) {
    final spanDays = widget.fullEnd.difference(widget.fullStart).inDays;
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

class _ScrubberTrackBackdrop({
  required final CustomPainter plot,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final plotRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas.save();
    canvas.clipRRect(plotRect);
    canvas.drawRRect(plotRect, Paint()..color = EColors.surfaceInset);
    plot.paint(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScrubberTrackBackdrop oldDelegate) {
    if (plot.runtimeType != oldDelegate.plot.runtimeType) return true;
    return plot.shouldRepaint(oldDelegate.plot);
  }
}

class _VisibleRangeWindowPainter({
  required final DateTime fullStart,
  required final DateTime fullEnd,
  required final EChartVisibleRange visible,
  required final Color windowColor,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final plotRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas.save();
    canvas.clipRRect(plotRect);
    _paintVisibleWindow(canvas, size);
    canvas.restore();
  }

  void _paintVisibleWindow(Canvas canvas, Size size) {
    final left = _xForDate(visible.start, size.width);
    final right = _xForDate(visible.end, size.width).clamp(left, size.width);
    final outside = Paint()..color = const Color(0x99000000);
    if (left > 0) {
      canvas.drawRect(Rect.fromLTRB(0, 0, left, size.height), outside);
    }
    if (right < size.width) {
      canvas.drawRect(
        Rect.fromLTRB(right, 0, size.width, size.height),
        outside,
      );
    }

    canvas.drawRect(
      Rect.fromLTRB(left, 0, right, size.height),
      Paint()
        ..color = windowColor.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromLTRB(left, 0, right, size.height),
      Paint()
        ..color = windowColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final handle = Paint()..color = EColors.textPrimary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(left, size.height / 2),
          width: 4,
          height: size.height - 8,
        ),
        const Radius.circular(2),
      ),
      handle,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(right, size.height / 2),
          width: 4,
          height: size.height - 8,
        ),
        const Radius.circular(2),
      ),
      handle,
    );
    _paintCurrentRange(canvas, size, left, right);
  }

  void _paintCurrentRange(Canvas canvas, Size size, double left, double right) {
    final caption = EChartDateScale.daySpan(
      start: visible.start,
      end: visible.end,
      rangeStart: fullStart,
      rangeEnd: fullEnd,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: caption, style: EChartAxis.tickLabel),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final innerLeft = left + 8;
    final innerRight = right - 8;
    if (innerRight - innerLeft < textPainter.width) return;
    textPainter.paint(
      canvas,
      Offset(
        innerLeft + (innerRight - innerLeft - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  double _xForDate(DateTime date, double width) {
    final spanDays = fullEnd.difference(fullStart).inDays;
    if (spanDays <= 0 || width <= 0) return 0;
    return date.startOfDay.difference(fullStart).inDays / spanDays * width;
  }

  @override
  bool shouldRepaint(covariant _VisibleRangeWindowPainter oldDelegate) {
    return oldDelegate.visible != visible ||
        oldDelegate.windowColor != windowColor ||
        oldDelegate.fullStart != fullStart ||
        oldDelegate.fullEnd != fullEnd;
  }
}

class _FullRangeEndCaptions({
  required final DateTime fullStart,
  required final DateTime fullEnd,
}) extends CustomPainter {
  static const bandHeight = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    _paintEnd(canvas, size, fullStart, alignToEnd: false);
    _paintEnd(canvas, size, fullEnd, alignToEnd: true);
  }

  void _paintEnd(
    Canvas canvas,
    Size size,
    DateTime date, {
    required bool alignToEnd,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: EChartDateScale.dayCaption(
          date,
          rangeStart: fullStart,
          rangeEnd: fullEnd,
        ),
        style: EChartAxis.tickLabel,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final x = alignToEnd ? size.width - textPainter.width : 0.0;
    textPainter.paint(
      canvas,
      Offset(x, (size.height - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _FullRangeEndCaptions oldDelegate) {
    return oldDelegate.fullStart != fullStart || oldDelegate.fullEnd != fullEnd;
  }
}
