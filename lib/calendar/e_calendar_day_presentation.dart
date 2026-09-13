import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_heatmap_intensity.dart';

sealed class ECalendarDayVisual() {
  Color get fill;

  Color get ink;

  bool get showsMeasuredGlow;
}

class const ECalendarDayEmpty() implements ECalendarDayVisual {
  @override
  Color get fill => EHeatmapIntensity.none.color;

  @override
  Color get ink => EColors.textMuted.withValues(alpha: 0.6);

  @override
  bool get showsMeasuredGlow => false;
}

class const ECalendarDayRecordedWithoutMeasure() implements ECalendarDayVisual {
  @override
  Color get fill => EColors.surface;

  @override
  Color get ink => EColors.textSecondary;

  @override
  bool get showsMeasuredGlow => false;
}

class const ECalendarDayMeasuredHeat({required final double intensity})
    implements ECalendarDayVisual {
  @override
  Color get fill => EHeatmapIntensity.colorAt(intensity);

  @override
  Color get ink => EHeatmapIntensity.inkAt(intensity);

  @override
  bool get showsMeasuredGlow => true;
}

class const ECalendarDaySeverity({
  required final Color background,
  @override required final Color ink,
}) implements ECalendarDayVisual {
  @override
  Color get fill => background;

  @override
  bool get showsMeasuredGlow => true;
}

class const ECalendarDayMarker({
  required final String label,
  final IconData? icon,
});

class const ECalendarDayPresentation<TId>({
  required final DateTime date,
  required final TId id,
  required final String semanticsLabel,
  required final ECalendarDayVisual visual,
  final String? primaryLabel,
  final String? secondaryLabel,
  final List<ECalendarDayMarker> markers = const [],
}) {
  String get dayNumberLabel => primaryLabel ?? '${date.day}';
}

class const ECalendarPeriodPresentation({
  required final int activeDays,
  final String? measureCaption,
}) {
  bool get isEmpty => activeDays <= 0;
}
