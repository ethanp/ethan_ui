import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';

/// Semantic surface roles for the machined-console look.
enum ESurfaceKind {
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
class ESurface extends StatelessWidget {
  const ESurface({
    super.key,
    required this.kind,
    required this.child,
    this.padding,
    this.accent,
    this.attention = false,
    this.onTap,
    this.borderRadius,
  });

  final ESurfaceKind kind;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? accent;
  final bool attention;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

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

    if (onTap == null) {
      return DecoratedBox(decoration: decoration, child: content);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
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
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: kind == ESurfaceKind.inset ? 0 : 18,
          offset: Offset(0, kind == ESurfaceKind.inset ? 0 : 8),
        ),
        if (attention)
          BoxShadow(
            color: attentionColor.withValues(alpha: 0.08),
            blurRadius: 18,
          ),
        if (kind == ESurfaceKind.tinted)
          BoxShadow(
            color: (accent ?? EColors.accentGlow).withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }
}

enum EFrostEdge { top, bottom, none }

/// Frosted translucent fill for chrome (app bar, bottom strip).
class EFrostedFill extends StatelessWidget {
  const EFrostedFill({super.key, this.child, this.edge = EFrostEdge.top});

  final Widget? child;
  final EFrostEdge edge;

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

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(color: EColors.frostFill, border: border),
          child: child ?? const SizedBox.expand(),
        ),
      ),
    );
  }
}
