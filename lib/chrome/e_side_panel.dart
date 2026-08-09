import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_surface.dart';

/// Metal side rail with a titled header and scrollable body.
class ESidePanel extends StatelessWidget {
  const ESidePanel({
    super.key,
    required this.title,
    required this.child,
    this.onDismiss,
    this.width,
  });

  final String title;
  final Widget child;
  final VoidCallback? onDismiss;

  /// When null, the panel sizes to its child's intrinsic width.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final panel = ESurface(
      kind: ESurfaceKind.panel,
      borderRadius: BorderRadius.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          Expanded(child: child),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: panel);
    }

    return IntrinsicWidth(child: panel);
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ELayout.spaceMd,
        ELayout.spaceMd,
        ELayout.spaceXs,
        ELayout.spaceSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title.toUpperCase(), style: EText.label),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 18),
              color: EColors.textMuted,
              visualDensity: VisualDensity.compact,
              tooltip: 'Hide $title',
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
