import 'package:flutter/material.dart';

class const EOverlaidTabBar({
  required final double height,
  required super.child,
}) extends InheritedWidget {
  static EOverlaidTabBar? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EOverlaidTabBar>();
  }

  @override
  bool updateShouldNotify(EOverlaidTabBar oldWidget) => height != oldWidget.height;
}

extension EOverlaidTabBarContext on BuildContext {
  double get overlaidTabBarInset => EOverlaidTabBar.maybeOf(this)?.height ?? 0;
}

extension EOverlaidTabBarPadding on EdgeInsets {
  EdgeInsets withOverlaidTabBar(BuildContext context) =>
      copyWith(bottom: bottom + context.overlaidTabBarInset);
}
