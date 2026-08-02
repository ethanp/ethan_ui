import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_motion.dart';
import '../theme/e_text.dart';

enum EStatusTone { accent, success, warning, danger, muted }

/// Compact status chip used by deploy targets, agent pills, etc.
class EStatusChip extends StatelessWidget {
  const EStatusChip({
    super.key,
    required this.label,
    required this.tone,
    this.uppercase = false,
  });

  final String label;
  final EStatusTone tone;
  final bool uppercase;

  Color get _foreground => switch (tone) {
    EStatusTone.accent => EColors.accentGlow,
    EStatusTone.success => EColors.success,
    EStatusTone.warning => EColors.warning,
    EStatusTone.danger => EColors.danger,
    EStatusTone.muted => EColors.textMuted,
  };

  Color get _background => switch (tone) {
    EStatusTone.accent => EColors.accentSoft,
    EStatusTone.success => EColors.successSoft,
    EStatusTone.warning => EColors.warningSoft,
    EStatusTone.danger => EColors.dangerSoft,
    EStatusTone.muted => EColors.surfaceRaised,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: EMotion.fast,
      curve: EMotion.curve,
      decoration: BoxDecoration(
        color: _background.withValues(
          alpha: tone == EStatusTone.muted ? 1 : 0.85,
        ),
        borderRadius: ELayout.borderRadiusPill,
        border: Border.all(color: _foreground.withValues(alpha: 0.38)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        uppercase ? label.toUpperCase() : label,
        style: EText.label.copyWith(
          color: _foreground,
          letterSpacing: uppercase ? 0.8 : 0.4,
        ),
      ),
    );
  }
}
