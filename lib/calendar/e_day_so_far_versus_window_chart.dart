import 'package:flutter/material.dart';

import '../chart/e_chart_value_scale.dart';
import '../chart/e_chart_y_labels.dart';
import '../chrome/e_filter_chip.dart';
import '../theme/e_chart_axis.dart';
import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'day_so_far_versus_window_average.dart';
import 'e_calendar_instant_quantity.dart';

enum _DayPace({required final Color color, required final String label}) {
  today(color: Color(0xFFFF6B2C), label: 'Today'),
  windowAverage(color: Color(0xFFA3A8B0), label: 'Average');
}

class const EDaySoFarVersusWindowChart({
  required final List<ECalendarInstantQuantity> instants,
  required final String Function(num quantity) formatMeasure,
  required final DateTime windowStart,
  required final DateTime windowEnd,
  final DateTime? now,
}) extends StatefulWidget {
  static const plotHeight = 180.0;
  static const plotTopPadding = 8.0;
  static const plotBottomPadding = 28.0;

  @override
  State<EDaySoFarVersusWindowChart> createState() =>
      _EDaySoFarVersusWindowChartState();
}

class _EDaySoFarVersusWindowChartState()
    extends State<EDaySoFarVersusWindowChart> {
  int? _asOfMinute;
  DaySoFarVersusWindowCurves? _curves;
  List<ECalendarInstantQuantity>? _curvesInstants;
  DateTime? _curvesClock;

  DateTime get _clock => widget.now ?? DateTime.now();

  int get _nowMinute => _clock.hour * 60 + _clock.minute;

  int get _selectedMinute => _asOfMinute ?? _nowMinute;

  bool get _isAtNow => _selectedMinute == _nowMinute;

  DaySoFarVersusWindowAverage _pace() {
    final clock = _clock;
    if (_curves == null ||
        !identical(_curvesInstants, widget.instants) ||
        !_sameClockMinute(_curvesClock, clock)) {
      _curves = DaySoFarVersusWindowCurves.fromInstants(
        instants: widget.instants,
        now: clock,
      );
      _curvesInstants = widget.instants;
      _curvesClock = clock;
    }
    return _curves!.inWindow(
      windowStart: widget.windowStart,
      windowEnd: widget.windowEnd,
    );
  }

  bool _sameClockMinute(DateTime? cached, DateTime clock) {
    if (cached == null) return false;
    return cached.year == clock.year &&
        cached.month == clock.month &&
        cached.day == clock.day &&
        cached.hour == clock.hour &&
        cached.minute == clock.minute;
  }

  @override
  Widget build(BuildContext context) {
    final pace = _pace();
    if (!pace.hasAnythingToCompare) return const SizedBox.shrink();
    return _separatedFromRollingLoad(_paceColumn(pace));
  }

  Widget _separatedFromRollingLoad(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: ELayout.spaceXl),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: EColors.borderStrong)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: ELayout.spaceLg),
          child: child,
        ),
      ),
    );
  }

  Widget _paceColumn(DaySoFarVersusWindowAverage pace) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headlines(pace),
        const SizedBox(height: ELayout.spaceMd),
        _plot(pace),
      ],
    );
  }

  Widget _headlines(DaySoFarVersusWindowAverage pace) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headline(
          _DayPace.today,
          _oneDecimal(pace.todayAt(_selectedMinute)),
          boundLabel: false,
          label: _DayPace.today.label,
        ),
        const SizedBox(width: ELayout.spaceXl),
        Expanded(
          child: _headline(
            _DayPace.windowAverage,
            _oneDecimal(pace.windowAverageAt(_selectedMinute)),
            boundLabel: true,
            label: '${pace.averagedDayCount}-day average',
            amountKey: const ValueKey('window-average-as-of'),
          ),
        ),
        if (!_isAtNow) ...[
          const SizedBox(width: ELayout.spaceSm),
          _clearToNow(),
        ],
      ],
    );
  }

  Widget _clearToNow() {
    return EFilterChip(
      key: const ValueKey('clear-as-of-now'),
      label: 'clear',
      icon: Icons.close,
      color: EColors.textMuted,
      selected: false,
      compact: true,
      onActivated: () => setState(() => _asOfMinute = null),
    );
  }

  Widget _headline(
    _DayPace pace,
    num amount, {
    required bool boundLabel,
    required String label,
    Key? amountKey,
  }) {
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: EText.label.medium.copyWith(color: pace.color),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: boundLabel ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: pace.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            if (boundLabel) Flexible(child: labelText) else labelText,
          ],
        ),
        Text(
          key: amountKey,
          widget.formatMeasure(amount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: EText.headline.medium.copyWith(
            color: pace.color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _plot(DaySoFarVersusWindowAverage pace) {
    final scale = EChartValueScale.nice(_dataMax(pace));
    return SizedBox(
      height: EDaySoFarVersusWindowChart.plotHeight,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EChartYLabels(
            scale: scale,
            height: EDaySoFarVersusWindowChart.plotHeight,
            topPadding: EDaySoFarVersusWindowChart.plotTopPadding,
            bottomPadding: EDaySoFarVersusWindowChart.plotBottomPadding,
            formatTick: (value) => widget.formatMeasure(_oneDecimal(value)),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) =>
                      _scrub(details.localPosition.dx, constraints.maxWidth),
                  onHorizontalDragStart: (details) =>
                      _scrub(details.localPosition.dx, constraints.maxWidth),
                  onHorizontalDragUpdate: (details) =>
                      _scrub(details.localPosition.dx, constraints.maxWidth),
                  child: CustomPaint(
                    key: const ValueKey('today-versus-window'),
                    painter: _DaySoFarVersusWindowPainter(
                      pace: pace,
                      selectedMinute: _selectedMinute,
                      scale: scale,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrub(double x, double width) {
    final minute = _minuteForX(x, width);
    setState(() => _asOfMinute = minute == _nowMinute ? null : minute);
  }

  int _minuteForX(double x, double width) {
    const left = 1.0;
    final right = width - 10;
    final span = right - left;
    if (span <= 0) return 0;
    final fraction = ((x - left) / span).clamp(0.0, 1.0);
    return (fraction * DaySoFarVersusWindowAverage.minutesInDay)
        .round()
        .clamp(0, DaySoFarVersusWindowAverage.minutesInDay);
  }

  static num _oneDecimal(double quantity) {
    final tenths = (quantity * 10).round();
    if (tenths % 10 == 0) return tenths ~/ 10;
    return tenths / 10;
  }

  static double _dataMax(DaySoFarVersusWindowAverage pace) {
    var highest = pace.todaySoFar;
    for (final point in pace.windowAverageCumulative) {
      if (point.quantity > highest) highest = point.quantity;
    }
    for (final point in pace.todayCumulative) {
      if (point.quantity > highest) highest = point.quantity;
    }
    return highest;
  }
}

class _ClockCaption({required final int minuteOfDay, required final String text});

class _DaySoFarVersusWindowPainter({
  required final DaySoFarVersusWindowAverage pace,
  required final int selectedMinute,
  required final EChartValueScale scale,
}) extends CustomPainter {
  static const _hourStep = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _PlotFrame(size: size, scale: scale);
    _paintValueGrid(canvas, plot);
    _paintDottedBaseline(canvas, plot);
    _paintCumulative(
      canvas,
      plot,
      pace.windowAverageCumulative,
      _DayPace.windowAverage.color,
    );
    _paintCumulative(
      canvas,
      plot,
      pace.todayCumulative,
      _DayPace.today.color,
    );
    _paintAsOfMarker(canvas, plot);
    _paintClockCaptions(canvas, plot);
  }

  @override
  bool shouldRepaint(covariant _DaySoFarVersusWindowPainter oldDelegate) {
    return selectedMinute != oldDelegate.selectedMinute ||
        pace.nowMinuteOfDay != oldDelegate.pace.nowMinuteOfDay ||
        pace.todaySoFar != oldDelegate.pace.todaySoFar ||
        pace.windowAverageTotal != oldDelegate.pace.windowAverageTotal ||
        scale != oldDelegate.scale ||
        pace.todayCumulative.length != oldDelegate.pace.todayCumulative.length ||
        pace.windowAverageCumulative.length !=
            oldDelegate.pace.windowAverageCumulative.length;
  }

  void _paintValueGrid(Canvas canvas, _PlotFrame plot) {
    final gridPaint = Paint()
      ..color = EChartAxis.gridLine
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = EChartAxis.plotEdge
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axisPaint,
    );
    for (final tick in scale.ticks) {
      if (tick == scale.min) continue;
      final tickY = plot.yForQuantity(tick);
      canvas.drawLine(
        Offset(plot.left, tickY),
        Offset(plot.right, tickY),
        gridPaint,
      );
    }
  }

  void _paintDottedBaseline(Canvas canvas, _PlotFrame plot) {
    final dotPaint = Paint()..color = EChartAxis.plotEdge;
    for (var x = plot.left; x <= plot.right; x += 6) {
      canvas.drawCircle(Offset(x, plot.bottom), 1.15, dotPaint);
    }
  }

  void _paintCumulative(
    Canvas canvas,
    _PlotFrame plot,
    List<EMinuteOfDayQuantity> points,
    Color color,
  ) {
    if (points.length < 2) return;
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final offset = plot.offsetFor(points[index]);
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintAsOfMarker(Canvas canvas, _PlotFrame plot) {
    final asOfX = plot.xForMinute(selectedMinute);
    canvas.drawLine(
      Offset(asOfX, plot.top),
      Offset(asOfX, plot.bottom),
      Paint()
        ..color = _DayPace.windowAverage.color.withValues(alpha: 0.85)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      Offset(asOfX, plot.yForQuantity(pace.windowAverageAt(selectedMinute))),
      5,
      Paint()..color = _DayPace.windowAverage.color,
    );
    final todayMinute = selectedMinute > pace.nowMinuteOfDay
        ? pace.nowMinuteOfDay
        : selectedMinute;
    canvas.drawCircle(
      Offset(plot.xForMinute(todayMinute), plot.yForQuantity(pace.todayAt(todayMinute))),
      6,
      Paint()..color = _DayPace.today.color,
    );
  }

  void _paintClockCaptions(Canvas canvas, _PlotFrame plot) {
    final hours = [
      for (var hour = 0; hour <= 24; hour += _hourStep)
        _ClockCaption(minuteOfDay: hour * 60, text: _hourCaption(hour)),
    ];
    final laidOut = [for (final hour in hours) _laidOut(hour.text)];
    final painted = <Rect>[];
    for (var index = 0; index < hours.length; index++) {
      painted.add(_paintHourCaption(canvas, plot, hours[index], laidOut[index], index, hours.length));
    }
    _paintAsOfCaption(canvas, plot, painted);
  }

  Rect _paintHourCaption(
    Canvas canvas,
    _PlotFrame plot,
    _ClockCaption caption,
    TextPainter laidOut,
    int index,
    int count,
  ) {
    final tickX = plot.xForMinute(caption.minuteOfDay);
    canvas.drawLine(
      Offset(tickX, plot.bottom),
      Offset(tickX, plot.bottom + 4),
      Paint()
        ..color = EChartAxis.plotEdge
        ..strokeWidth = 1,
    );
    final captionY = plot.bottom + 6;
    final left = index == 0
        ? plot.left
        : index == count - 1
        ? plot.right - laidOut.width
        : (tickX - laidOut.width / 2).clamp(
            plot.left,
            plot.right - laidOut.width,
          );
    laidOut.paint(canvas, Offset(left, captionY));
    return Rect.fromLTWH(left, captionY, laidOut.width, laidOut.height);
  }

  void _paintAsOfCaption(Canvas canvas, _PlotFrame plot, List<Rect> hours) {
    final laidOut = _laidOut(_minuteCaption(selectedMinute));
    final nowX = plot.xForMinute(selectedMinute);
    final captionY = plot.bottom + 6;
    final left = (nowX - laidOut.width / 2).clamp(
      plot.left,
      plot.right - laidOut.width,
    );
    final bounds = Rect.fromLTWH(left, captionY, laidOut.width, laidOut.height);
    for (final hour in hours) {
      if (bounds.inflate(6).overlaps(hour)) return;
    }
    laidOut.paint(canvas, Offset(left, captionY));
  }

  String _hourCaption(int hour) {
    final onClock = hour % 24;
    final suffix = onClock < 12 ? 'AM' : 'PM';
    final twelve = onClock % 12 == 0 ? 12 : onClock % 12;
    return '$twelve $suffix';
  }

  String _minuteCaption(int minuteOfDay) {
    if (minuteOfDay >= DaySoFarVersusWindowAverage.minutesInDay) {
      return '12 AM';
    }
    final hour24 = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    final suffix = hour24 < 12 ? 'AM' : 'PM';
    final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
    if (minute == 0) return '$hour $suffix';
    return '$hour:${minute.toString().padLeft(2, '0')} $suffix';
  }

  TextPainter _laidOut(String text) {
    return TextPainter(
      text: TextSpan(text: text, style: EChartAxis.tickLabel),
      textDirection: TextDirection.ltr,
    )..layout();
  }
}

class _PlotFrame({
  required final Size size,
  required final EChartValueScale scale,
}) {
  late final double left = 1;
  late final double right = size.width - 10;
  late final double top = EDaySoFarVersusWindowChart.plotTopPadding;
  late final double bottom =
      size.height - EDaySoFarVersusWindowChart.plotBottomPadding;
  late final double _width = right - left;
  late final double _height = bottom - top;

  double yForQuantity(double quantity) =>
      top + (1 - scale.fractionFromBottom(quantity)) * _height;

  double xForMinute(int minuteOfDay) =>
      left +
      (minuteOfDay / DaySoFarVersusWindowAverage.minutesInDay) * _width;

  Offset offsetFor(EMinuteOfDayQuantity point) =>
      Offset(xForMinute(point.minuteOfDay), yForQuantity(point.quantity));
}
