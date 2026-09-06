import 'package:flutter/material.dart';

import 'e_colors.dart';
import 'e_text.dart';

/// Shared plot chrome tokens for time-series charts.
abstract final class EChartAxis() {
  static const minPxPerLabel = 70.0;
  static const tickReservedSize = 22.0;

  static TextStyle get tickLabel => EText.body.tiny.muted;

  static Color get gridLine => EColors.border.withValues(alpha: 0.55);

  static Color get plotEdge => EColors.border;
}
