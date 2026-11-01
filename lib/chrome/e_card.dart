import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import 'e_surface.dart';

/// A padded [ESurface]. Raised ([ESurfaceKind.panel]) by default; pass
/// [ESurfaceKind.row] for a flat card inside a dense list.
class const ECard({
  super.key,
  required final Widget child,
  final ESurfaceKind kind = ESurfaceKind.panel,
  final EdgeInsetsGeometry? padding = const EdgeInsets.all(ELayout.spaceLg),
  final EdgeInsetsGeometry? margin,
  final VoidCallback? onActivated,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ESurface(
      kind: kind,
      padding: padding,
      margin: margin,
      onActivated: onActivated,
      child: child,
    );
  }
}
