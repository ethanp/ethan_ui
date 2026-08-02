import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import 'e_surface.dart';

/// Frosted horizontal chrome strip for desktop toolbars.
class EToolbar extends StatelessWidget {
  const EToolbar({
    super.key,
    required this.child,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: ELayout.spaceLg),
  });

  final Widget child;

  /// Fixed height. Pass null to size the toolbar to [child].
  final double? height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final paddedChild = Padding(
      padding: padding,
      child: height == null
          ? child
          : Align(alignment: Alignment.centerLeft, child: child),
    );

    if (height == null) {
      return SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            const Positioned.fill(
              child: EFrostedFill(edge: EFrostEdge.top),
            ),
            paddedChild,
          ],
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const EFrostedFill(edge: EFrostEdge.top),
          paddedChild,
        ],
      ),
    );
  }
}
