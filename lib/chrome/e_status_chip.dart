import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_motion.dart';
import '../theme/e_text.dart';

/// Status accent for chips and hanging edges — colors live on each constant
/// (Bloch-style), not in parallel switch maps at call sites.
enum EStatusTone({
  required final Color foreground,
  required final Color background,
  final double fillAlpha = 0.85,
}) {
  accent(foreground: EColors.accentGlow, background: EColors.accentSoft),
  pending(foreground: EColors.pending, background: EColors.pendingSoft),
  success(foreground: EColors.success, background: EColors.successSoft),
  warning(foreground: EColors.warning, background: EColors.warningSoft),
  danger(foreground: EColors.danger, background: EColors.dangerSoft),
  muted(
    foreground: EColors.textMuted,
    background: EColors.surfaceRaised,
    fillAlpha: 1,
  ),
}

/// Compact status chip used by deploy targets, agent pills, etc.
class const EStatusChip({
  super.key,
  required final String label,
  required final EStatusTone tone,
  final bool uppercase = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: EMotion.fast,
      curve: EMotion.curve,
      decoration: BoxDecoration(
        color: tone.background.withValues(alpha: tone.fillAlpha),
        borderRadius: ELayout.borderRadiusPill,
        border: Border.all(color: tone.foreground.withValues(alpha: 0.38)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        uppercase ? label.toUpperCase() : label,
        style: EText.label.small.copyWith(
          color: tone.foreground,
          letterSpacing: uppercase ? 0.8 : 0.4,
        ),
      ),
    );
  }
}
