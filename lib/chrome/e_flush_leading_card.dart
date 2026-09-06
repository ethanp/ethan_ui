import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import 'e_surface.dart';

/// List card whose leading child is flush to the left, top, and bottom edges.
///
/// Content starts after [leadingWidth] plus [leadingGap]. Use this for artwork
/// (covers, album art, thumbnails) instead of a padded [EListRow].
class const EFlushLeadingCard({
  super.key,
  required final Widget leading,
  required final Widget child,
  required final double leadingWidth,
  final double leadingGap = 6,
  final VoidCallback? onActivated,
  final ESurfaceKind kind = ESurfaceKind.row,
  final BorderRadius borderRadius = ELayout.borderRadiusSm,
}) extends StatelessWidget {
  static const maxLeadingWidth = 80.0;
  static const leadingWidthFraction = 0.30;

  static double cappedLeadingWidth(double cardWidth) =>
      min(maxLeadingWidth, cardWidth * leadingWidthFraction);

  @override
  Widget build(BuildContext context) {
    return ESurface(
      kind: kind,
      onActivated: onActivated,
      borderRadius: borderRadius,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: _flushBody(),
      ),
    );
  }

  Widget _flushBody() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(left: leadingWidth + leadingGap),
          child: child,
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: leadingWidth,
          child: leading,
        ),
      ],
    );
  }
}
