import 'dart:io';

import 'package:flutter/material.dart';

/// Layout tokens for the machined-console theme: radii, spacing, type scale.
abstract final class ELayout {
  static const radiusSm = 10.0;
  static const radiusMd = 14.0;
  static const radiusLg = 18.0;
  static const radiusXl = 20.0;
  static const radiusPill = 999.0;

  static const spaceXs = 4.0;
  static const spaceSm = 8.0;
  static const spaceMd = 12.0;
  static const spaceLg = 16.0;
  static const spaceXl = 24.0;

  static const contentMaxWidth = 920.0;

  /// Desktop sits farther from the eye — scale type/icons up on macOS.
  static double get typeScale => Platform.isMacOS ? 1.25 : 1.0;

  static double get iconTile => Platform.isMacOS ? 88.0 : 72.0;

  static double typeSize(double phoneSize) => phoneSize * typeScale;

  static BorderRadius borderRadius(double radius) =>
      BorderRadius.circular(radius);
}
