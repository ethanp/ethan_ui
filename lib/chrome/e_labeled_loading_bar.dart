import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_text.dart';

/// Indeterminate progress with a caption naming what is loading.
class const ELabeledLoadingBar({
  required final String label,
  final Color? color,
  final Color? trackColor,
  final double minHeight = 2,
}) extends StatelessWidget {
  static const _labelBarGap = 2.0;

  static TextStyle get _labelStyle =>
      EText.caption.copyWith(color: EColors.textMuted);

  static double layoutHeight(TextScaler textScaler, {double minHeight = 2}) {
    final painter = TextPainter(
      text: TextSpan(text: 'Ag', style: _labelStyle),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    return painter.height.ceilToDouble() + _labelBarGap + minHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: _labelStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: _labelBarGap),
        LinearProgressIndicator(
          minHeight: minHeight,
          backgroundColor: trackColor ?? EColors.border.withValues(alpha: 0.35),
          color: color ?? EColors.accentGlow,
        ),
      ],
    );
  }
}
