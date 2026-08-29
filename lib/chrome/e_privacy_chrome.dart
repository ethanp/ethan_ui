import 'package:flutter/material.dart';

/// PIN pad and app-switcher shield — same tokens as viant_ios.
abstract final class EPrivacyChrome {
  static const shield = Color(0xFF0A1628);
  static const lockBackground = Color(0xFF000000);
  static const keyFill = Color(0xFF1C1C1E);
  static const filledDot = Color(0xFFBF5AF2);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFAEAEB3);
  static const danger = Color(0xFFFF453A);

  static const title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const error = TextStyle(color: danger, fontSize: 15);

  static const digit = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    color: textPrimary,
  );
}
