import 'package:flutter/material.dart';

import '../chrome/e_surface.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// Titled metal panel used by agent / settings sections.
class const EPanel({
  super.key,
  required final String title,
  required final Widget child,
  final Widget? trailing,
  final String? subtitle,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ESurface(
      kind: ESurfaceKind.panel,
      padding: const EdgeInsets.all(ELayout.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title.toUpperCase(), style: EText.label.small),
                    if (subtitle != null) ...[
                      const SizedBox(height: ELayout.spaceXs),
                      Text(subtitle!, style: EText.section),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
