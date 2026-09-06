import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// Colored selectable chip for filter / pick lists.
class const EFilterChip({
  super.key,
  required final String label,
  required final Color color,
  required final bool selected,
  required final VoidCallback onActivated,
  final IconData? icon,
  final bool compact = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onActivated,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? ELayout.spaceSm : ELayout.spaceMd,
          vertical: compact ? ELayout.spaceXs : ELayout.spaceSm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.28 : 0.14),
          borderRadius: ELayout.borderRadiusSm,
          border: Border.all(
            color: color.withValues(alpha: selected ? 0.85 : 0.35),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 12 : 14, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: EText.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
