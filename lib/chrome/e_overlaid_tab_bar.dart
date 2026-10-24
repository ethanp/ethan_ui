import 'package:flutter/material.dart';

import '../theme/e_layout.dart';

class const EOverlaidTabBar({
  required final double height,
  required super.child,
}) extends InheritedWidget {
  static EOverlaidTabBar? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EOverlaidTabBar>();
  }

  @override
  bool updateShouldNotify(EOverlaidTabBar oldWidget) =>
      height != oldWidget.height;
}

extension EOverlaidTabBarContext on BuildContext {
  double get overlaidTabBarInset => EOverlaidTabBar.maybeOf(this)?.height ?? 0;
}

/// Standard page padding, lifted clear of an [EOverlaidTabBar] ancestor.
///
/// Scroll views use [paddingOf]. Other bodies wrap themselves in this widget.
class const ETabBarOverlay({required final Widget child})
    extends StatelessWidget {
  static const pagePadding = EdgeInsets.all(ELayout.spaceLg);

  static EdgeInsets paddingOf(
    BuildContext context, {
    EdgeInsets contentPadding = pagePadding,
  }) {
    return contentPadding.copyWith(
      bottom: contentPadding.bottom + context.overlaidTabBarInset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: paddingOf(context), child: child);
  }
}
