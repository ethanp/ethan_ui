import 'package:flutter/material.dart';

import '../theme/e_chart_axis.dart';
import 'e_chart_value_scale.dart';

/// Left-side value ticks that stay put while the plot scrolls.
class const EChartYLabels({
  required final EChartValueScale scale,
  required final double height,
  final double topPadding = 0,
  final double bottomPadding = 0,
  final double width = 36,
  final String Function(double value)? formatTick,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EChartYLabelsPainter(
          scale: scale,
          topPadding: topPadding,
          bottomPadding: bottomPadding,
          formatTick: formatTick,
        ),
      ),
    );
  }
}

class const _EChartYLabelsPainter({
  required final EChartValueScale scale,
  required final double topPadding,
  required final double bottomPadding,
  required final String Function(double value)? formatTick,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final plotHeight = size.height - topPadding - bottomPadding;
    if (plotHeight <= 0) return;
    for (final tick in scale.ticks) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: formatTick?.call(tick) ?? scale.caption(tick),
          style: EChartAxis.tickLabel,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      final tickY =
          topPadding +
          (1 - scale.fractionFromBottom(tick)) * plotHeight -
          textPainter.height / 2;
      textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width - 4, tickY),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EChartYLabelsPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.topPadding != topPadding ||
        oldDelegate.bottomPadding != bottomPadding ||
        oldDelegate.formatTick != formatTick;
  }
}
