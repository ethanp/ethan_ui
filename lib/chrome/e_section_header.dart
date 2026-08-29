import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import '../theme/e_text.dart';

class ESectionHeader extends StatelessWidget {
  const ESectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ELayout.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: EText.headline.small),
                if (subtitle != null) ...[
                  const SizedBox(height: ELayout.spaceXs),
                  Text(subtitle!, style: EText.body.small),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
