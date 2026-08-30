import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import 'e_surface.dart';

class const ECard({
  super.key,
  required final Widget child,
  final EdgeInsetsGeometry? padding = const EdgeInsets.all(ELayout.spaceLg),
  final EdgeInsetsGeometry? margin,
  final VoidCallback? onActivated,
}) extends StatelessWidget {
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
