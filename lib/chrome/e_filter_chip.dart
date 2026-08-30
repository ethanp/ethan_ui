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
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onActivated,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ELayout.spaceMd,
          vertical: ELayout.spaceSm,
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
              Icon(icon, size: 14, color: color),
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
