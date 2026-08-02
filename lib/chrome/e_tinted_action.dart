import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_status_chip.dart';
import 'e_surface.dart';

/// Accent-tinted action plate: icon + title + subtitle, optional status chip.
///
/// Same chrome as platform deploy targets — gradient outline via [ESurface]
/// tinted kind.
class ETintedAction extends StatelessWidget {
  const ETintedAction({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.chipLabel,
    this.chipTone,
    this.trailing,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? chipLabel;
  final EStatusTone? chipTone;

  /// Secondary control on the title row (e.g. stop) — receives its own gestures.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final showChip = chipLabel != null && chipTone != null;
    return ESurface(
      kind: ESurfaceKind.tinted,
      accent: accent,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
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
          const SizedBox(height: ELayout.spaceSm),
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: EText.caption.copyWith(
                    color: accent.withValues(alpha: 0.62),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (showChip) ...[
                const SizedBox(width: ELayout.spaceSm),
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
      ),
    );
  }
}
