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
    required this.onTap,
    this.subtitle,
    this.chipLabel,
    this.chipTone,
    this.trailing,
    this.live = false,
  }) : compact = false;

  /// Dense list-row plate (title + subtitle, no status chip hang).
  const ETintedAction.compact({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.live = false,
  })  : compact = true,
        chipLabel = null,
        chipTone = null;

  final Color accent;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final String? chipLabel;
  final EStatusTone? chipTone;
  final Widget? trailing;
  final bool live;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ESurface(
      kind: ESurfaceKind.tinted,
      accent: accent,
      attention: live,
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 6 : 12,
      ),
      child: compact ? _compactBody() : _comfortableBody(),
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
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: ELayout.spaceSm),
          Expanded(
            child: Column(
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
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: ELayout.spaceXs),
            trailing!,
          ],
        ],
      ),
    );
  }
}
