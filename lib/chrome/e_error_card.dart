import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_surface.dart';

/// Compact danger notice: a title, an explanation, and optional actions.
class const EErrorCard({
  super.key,
  required final String title,
  required final Widget body,
  final List<Widget> actions = const [],
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ESurface(
      kind: ESurfaceKind.tinted,
      accent: EColors.danger,
      padding: const EdgeInsets.all(ELayout.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: EText.section.copyWith(color: EColors.danger)),
          const SizedBox(height: ELayout.spaceSm),
          body,
          if (actions.isNotEmpty) ...[
            const SizedBox(height: ELayout.spaceSm),
            _actions(),
          ],
        ],
      ),
    );
  }

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          if (index > 0) const SizedBox(width: ELayout.spaceXs),
          actions[index],
        ],
      ],
    );
  }
}
