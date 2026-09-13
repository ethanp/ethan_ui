import 'package:flutter/painting.dart';

import '../theme/e_colors.dart';
import 'e_chart_interpolation.dart';

enum EChartStrokeDash() {
  solid,
  dotted,
}

/// Whether hit-testing considers this series' points.
enum EChartPointHits() {
  include,
  ignore,
}

/// One dated value on a series, stamped with host identity [id].
class const EChartPoint<T extends Object>({
  required final DateTime date,
  required final double value,
  required final T id,
  final Color? color,
  final double? dotRadius,
});

/// How a series is drawn. Construct via [EChartSeries] factories, not by
/// combining independent booleans.
sealed class const EChartSeriesMark();

class const EChartStrokeMark({
  final EChartInterpolation interpolation = EChartInterpolation.polyline,
  final EChartStrokeDash dash = EChartStrokeDash.solid,
  final double width = 1.2,
  final Color? fillColor,
}) extends EChartSeriesMark;

class const EChartDotsMark() extends EChartSeriesMark;

class const EChartStrokeAndDotsMark({
  final EChartInterpolation interpolation = EChartInterpolation.polyline,
  final EChartStrokeDash dash = EChartStrokeDash.solid,
  final double width = 1.2,
  final Color? fillColor,
}) extends EChartSeriesMark;

/// A dated series: data, a visual kind, and a hit policy.
class const EChartSeries<T extends Object>._({
  required final String id,
  required final List<EChartPoint<T>> points,
  required final Color color,
  required final EChartSeriesMark mark,
  final EChartPointHits hits = EChartPointHits.include,
  final String? label,
}) {

  factory line({
    required String id,
    required List<EChartPoint<T>> points,
    Color color = EColors.border,
    double strokeWidth = 1.2,
    EChartInterpolation interpolation = EChartInterpolation.polyline,
    EChartStrokeDash dash = EChartStrokeDash.solid,
    Color? fillColor,
    EChartPointHits hits = EChartPointHits.include,
    String? label,
  }) {
    return EChartSeries._(
      id: id,
      points: points,
      color: color,
      mark: EChartStrokeMark(
        interpolation: interpolation,
        dash: dash,
        width: strokeWidth,
        fillColor: fillColor,
      ),
      hits: hits,
      label: label,
    );
  }

  factory dots({
    required String id,
    required List<EChartPoint<T>> points,
    Color color = EColors.border,
    EChartPointHits hits = EChartPointHits.include,
    String? label,
  }) {
    return EChartSeries._(
      id: id,
      points: points,
      color: color,
      mark: const EChartDotsMark(),
      hits: hits,
      label: label,
    );
  }

  factory lineAndDots({
    required String id,
    required List<EChartPoint<T>> points,
    Color color = EColors.border,
    double strokeWidth = 1.2,
    EChartInterpolation interpolation = EChartInterpolation.polyline,
    EChartStrokeDash dash = EChartStrokeDash.solid,
    Color? fillColor,
    EChartPointHits hits = EChartPointHits.include,
    String? label,
  }) {
    return EChartSeries._(
      id: id,
      points: points,
      color: color,
      mark: EChartStrokeAndDotsMark(
        interpolation: interpolation,
        dash: dash,
        width: strokeWidth,
        fillColor: fillColor,
      ),
      hits: hits,
      label: label,
    );
  }

  EChartInterpolation get interpolation => switch (mark) {
    EChartStrokeMark(:final interpolation) => interpolation,
    EChartStrokeAndDotsMark(:final interpolation) => interpolation,
    EChartDotsMark() => EChartInterpolation.polyline,
  };

  EChartStrokeDash get dash => switch (mark) {
    EChartStrokeMark(:final dash) => dash,
    EChartStrokeAndDotsMark(:final dash) => dash,
    EChartDotsMark() => EChartStrokeDash.solid,
  };

  double get strokeWidth => switch (mark) {
    EChartStrokeMark(:final width) => width,
    EChartStrokeAndDotsMark(:final width) => width,
    EChartDotsMark() => 1.2,
  };

  Color? get fillColor => switch (mark) {
    EChartStrokeMark(:final fillColor) => fillColor,
    EChartStrokeAndDotsMark(:final fillColor) => fillColor,
    EChartDotsMark() => null,
  };

  bool get paintsStroke =>
      mark is EChartStrokeMark || mark is EChartStrokeAndDotsMark;

  bool get paintsDots =>
      mark is EChartDotsMark || mark is EChartStrokeAndDotsMark;
}
