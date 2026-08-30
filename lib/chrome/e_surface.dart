import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';

/// Semantic surface roles for the machined-console look.
enum ESurfaceKind() {
  /// Raised metal panel (agent sections, dialogs).
  panel,

  /// List / project row.
  row,

  /// Recessed well (logs, PIN display).
  inset,

  /// Accent-tinted action plate (platform deploy targets).
  tinted,
}

/// Shared brushed-metal surface. Domain UI should use this instead of
/// hand-rolled gradients, borders, and shadows.
///
/// [ESurfaceKind.row] and [ESurfaceKind.tinted] stay flat (border + gradient
/// only) so dense interactive lists stay cheap to repaint. Soft shadows are
/// reserved for [ESurfaceKind.panel].
class const ESurface({
  super.key,
  required final ESurfaceKind kind,
  required final Widget child,
  final EdgeInsetsGeometry? padding,
  final Color? accent,
  final bool attention = false,
  final VoidCallback? onActivated,
  final BorderRadius? borderRadius,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ??
        ELayout.borderRadius(switch (kind) {
          ESurfaceKind.panel => ELayout.radiusLg,
          ESurfaceKind.row => ELayout.radiusXl,
          ESurfaceKind.inset => ELayout.radiusMd,
          ESurfaceKind.tinted => ELayout.radiusMd,
        });

    final content = padding == null
        ? child
        : Padding(padding: padding!, child: child);
    final decoration = _decoration(radius);

    if (onActivated == null) {
      return DecoratedBox(decoration: decoration, child: content);
    }

    final ShapeBorder roundedShape = RoundedRectangleBorder(
      borderRadius: radius,
    );
    return Material(
      color: Colors.transparent,
      shape: roundedShape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onActivated,
        customBorder: roundedShape,
        splashColor: (accent ?? EColors.accentGlow).withValues(alpha: 0.16),
        highlightColor: (accent ?? EColors.accentGlow).withValues(alpha: 0.07),
        child: Ink(decoration: decoration, child: content),
      ),
    );
  }

  BoxDecoration _decoration(BorderRadius radius) {
    final attentionColor = EColors.warning;
    final borderColor = attention
        ? attentionColor.withValues(alpha: 0.4)
        : switch (kind) {
            ESurfaceKind.tinted => (accent ?? EColors.accentGlow).withValues(
              alpha: 0.38,
            ),
            ESurfaceKind.inset => EColors.border,
            _ => EColors.border.withValues(alpha: 0.95),
          };

    return BoxDecoration(
      gradient: switch (kind) {
        ESurfaceKind.panel => EColors.metalPanelGradient,
        ESurfaceKind.row => EColors.metalRowGradient,
        ESurfaceKind.inset => null,
        ESurfaceKind.tinted => EColors.tintedMetalGradient(
          accent ?? EColors.accent,
        ),
      },
      color: kind == ESurfaceKind.inset ? EColors.surfaceInset : null,
      borderRadius: radius,
      border: Border.all(color: borderColor),
      // Soft shadows only on panels — row/tinted stay flat for list density.
      boxShadow: kind == ESurfaceKind.panel
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              if (attention)
                BoxShadow(
                  color: attentionColor.withValues(alpha: 0.08),
                  blurRadius: 18,
                ),
            ]
          : const [],
    );
  }
}

enum EFrostEdge() {
  top,
  bottom,
  none,
}

/// Frost chrome fill for app bars and bottom strips.
///
/// Uses an opaque frost color — not [BackdropFilter] — so scrolling lists
/// underneath stay cheap to composite.
class const EFrostedFill({
  super.key,
  final Widget? child,
  final EFrostEdge edge = EFrostEdge.top,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final border = switch (edge) {
      EFrostEdge.top => const Border(
        bottom: BorderSide(color: EColors.frostBorder),
      ),
      EFrostEdge.bottom => const Border(
        top: BorderSide(color: EColors.frostBorder),
      ),
      EFrostEdge.none => null,
    };

    return DecoratedBox(
      decoration: BoxDecoration(color: EColors.frostFill, border: border),
      child: child ?? const SizedBox.expand(),
    );
  }
}
