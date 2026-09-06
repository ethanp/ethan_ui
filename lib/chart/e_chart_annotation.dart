import 'package:flutter/painting.dart';

import 'e_chart_plot.dart';

/// Extra marks that are not a line: bands, captions, product ink.
abstract class EChartAnnotation() {
  void paint(Canvas canvas, EChartPlot plot);
}
