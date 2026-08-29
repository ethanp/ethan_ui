import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import 'e_surface.dart';

class ECard extends StatelessWidget {
  const ECard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ELayout.spaceLg),
    this.margin,
    this.onActivated,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onActivated;

  @override
  Widget build(BuildContext context) {
    final card = ESurface(
      kind: ESurfaceKind.panel,
      padding: padding,
      onActivated: onActivated,
      child: child,
    );
    if (margin == null) return card;
    return Padding(padding: margin!, child: card);
  }
}
