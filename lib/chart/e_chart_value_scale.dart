import 'package:ethan_utils/ethan_utils.dart';

/// How tall a value is on a chart: nice ticks, clock-minute ticks, or a fixed range.
class const EChartValueScale({
  required final double min,
  required final double max,
  required final List<double> ticks,
  final String tickSuffix = '',
}) {
  factory nice(
    double dataMax, {
    int targetTickCount = 4,
    double fallbackMax = 1,
    String tickSuffix = '',
  }) {
    final scale = NiceValueScale.forMax(
      dataMax,
      targetTickCount: targetTickCount,
      fallbackMax: fallbackMax,
    );
    return EChartValueScale(
      min: 0,
      max: scale.max,
      ticks: scale.ticks,
      tickSuffix: tickSuffix,
    );
  }

  static const clockMinuteSteps = <int>[1, 2, 5, 10, 15, 20, 30, 60, 90, 120];

  factory clockMinutes(double peak, {int targetTickCount = 4}) {
    final positiveMax = peak > 0 ? peak : 1.0;
    final rawStep = positiveMax / targetTickCount;
    var step = clockMinuteSteps.last;
    for (final candidate in clockMinuteSteps) {
      if (candidate >= rawStep) {
        step = candidate;
        break;
      }
    }
    final niceMax = (positiveMax / step).ceil() * step;
    return EChartValueScale(
      min: 0,
      max: niceMax.toDouble(),
      ticks: [
        for (var minute = 0; minute <= niceMax; minute += step)
          minute.toDouble(),
      ],
    );
  }

  factory fixed({
    required double min,
    required double max,
    required List<double> ticks,
    String tickSuffix = '',
  }) {
    return EChartValueScale(
      min: min,
      max: max,
      ticks: ticks,
      tickSuffix: tickSuffix,
    );
  }

  double fractionFromBottom(double value) {
    final span = max - min;
    if (span == 0) return 0.5;
    return ((value - min) / span).clamp(0.0, 1.0);
  }

  String caption(double value) {
    final number = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$number$tickSuffix';
  }

  @override
  bool operator ==(Object other) =>
      other is EChartValueScale &&
      other.min == min &&
      other.max == max &&
      other.tickSuffix == tickSuffix &&
      _sameTicks(other.ticks, ticks);

  @override
  int get hashCode => Object.hash(min, max, tickSuffix, Object.hashAll(ticks));

  static bool _sameTicks(List<double> left, List<double> right) {
    if (identical(left, right)) return true;
    if (left.length != right.length) return false;
    for (var tickIndex = 0; tickIndex < left.length; tickIndex++) {
      if (left[tickIndex] != right[tickIndex]) return false;
    }
    return true;
  }
}
