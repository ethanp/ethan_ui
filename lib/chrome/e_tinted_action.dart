import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_status_chip.dart';
import 'e_surface.dart';

/// Accent-tinted action plate: icon + title + optional subtitle / chip.
class ETintedAction extends StatelessWidget {
  const ETintedAction({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    this.onActivated,
    this.subtitle,
    this.chipLabel,
    this.chipTone,
    this.trailing,
    this.live = false,
  })  : compact = false,
        iconOnly = false;

  /// Dense list-row plate (title + subtitle, no status chip hang).
  const ETintedAction.compact({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    this.onActivated,
    this.subtitle,
    this.trailing,
    this.live = false,
  })  : compact = true,
        iconOnly = false,
        chipLabel = null,
        chipTone = null;

  /// Slimmest plate for tight rows: just the icon; [title] (and [subtitle])
  /// surface as a tooltip.
  const ETintedAction.iconOnly({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    this.onActivated,
    this.subtitle,
    this.live = false,
  })  : compact = true,
        iconOnly = true,
        trailing = null,
        chipLabel = null,
        chipTone = null;

  final Color accent;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onActivated;
  final String? chipLabel;
  final EStatusTone? chipTone;
  final Widget? trailing;
  final bool live;
  final bool compact;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final plate = ESurface(
      kind: ESurfaceKind.tinted,
      accent: accent,
      attention: live,
      onActivated: onActivated,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 6 : 12,
      ),
      child: iconOnly
          ? _iconOnlyBody()
          : compact
              ? _compactBody()
              : _comfortableBody(),
    );
    if (!iconOnly) return plate;
    return Tooltip(
      message: subtitle == null || subtitle!.isEmpty
          ? title
          : '$title · $subtitle',
      child: plate,
    );
  }

  Widget _iconOnlyBody() {
    return SizedBox(
      height: 44,
      child: Center(child: Icon(icon, size: 16, color: accent)),
    );
  }

  Widget _comfortableBody() {
    final showChip = chipLabel != null && chipTone != null;
    final showSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: ELayout.spaceSm),
            Expanded(
              child: Text(
                title,
                style: EText.section.copyWith(color: accent),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: ELayout.spaceSm),
              trailing!,
            ],
          ],
        ),
        if (showSubtitle || showChip) ...[
          const SizedBox(height: ELayout.spaceSm),
          Row(
            children: [
              if (showSubtitle)
                Expanded(
                  child: Text(
                    subtitle!,
                    style: EText.caption.copyWith(
                      color: accent.withValues(alpha: 0.62),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
              else
                const Spacer(),
              if (showChip) ...[
                if (showSubtitle) const SizedBox(width: ELayout.spaceSm),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: EStatusChip(
                      label: chipLabel!,
                      tone: chipTone!,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _compactBody() {
    final showSubtitle = subtitle != null && subtitle!.isNotEmpty;
    final labelColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: EText.label.copyWith(
            color: accent,
            letterSpacing: 0.2,
            height: 1.15,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (showSubtitle)
          Text(
            subtitle!,
            style: EText.caption.copyWith(
              color: accent.withValues(alpha: 0.62),
              fontSize: ELayout.typeSize(12),
              height: 1.15,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );

    return SizedBox(
      height: 44,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Expanded requires a bounded max width; callers sometimes pass
          // unbounded (e.g. Wrap / loose parents).
          final label = constraints.maxWidth.isFinite
              ? Expanded(child: labelColumn)
              : labelColumn;
          return Row(
            mainAxisSize: constraints.maxWidth.isFinite
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: ELayout.spaceSm),
              label,
              if (trailing != null) ...[
                const SizedBox(width: ELayout.spaceXs),
                trailing!,
              ],
            ],
          );
        },
      ),
    );
  }
}
