import 'package:flutter/material.dart';

import '../chrome/e_pin_lock_and_switcher_shield.dart';
import '../theme/e_colors.dart';
import '../theme/e_theme.dart';
import '../widgets/e_error_banner.dart';

/// The [MaterialApp] every app launches: [displayName] as the window title,
/// the graphite dark theme, no debug banner, and [EErrorBanner] mounted above
/// every route. An [unlockPin] adds [EPinLockAndSwitcherShield] outside that
/// banner, so the PIN pad also covers an error.
class const EApp({
  required final String displayName,
  required final Widget home,
  final String? unlockPin,
  final ThemeData? theme,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: displayName,
      theme: theme ?? ETheme.material3Dark,
      color: EColors.background,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => _shieldedWhenPinned(
        EErrorBanner(emailSubject: '$displayName error', child: child!),
      ),
      home: home,
    );
  }

  Widget _shieldedWhenPinned(Widget routes) {
    final String? pin = unlockPin;
    if (pin == null) return routes;
    return EPinLockAndSwitcherShield(pin: pin, child: routes);
  }
}
