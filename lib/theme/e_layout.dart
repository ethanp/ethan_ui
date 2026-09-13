import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Layout tokens for the machined-console theme: radii, spacing, type scale.
abstract final class ELayout() {
  static const radiusSm = 10.0;
  static const radiusMd = 14.0;
  static const radiusLg = 18.0;
  static const radiusXl = 20.0;
  static const radiusPill = 999.0;

  static const borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const borderRadiusPill = BorderRadius.all(Radius.circular(radiusPill));

  static const spaceXs = 4.0;
  static const spaceSm = 8.0;
  static const spaceMd = 12.0;
  static const spaceLg = 16.0;
  static const spaceXl = 24.0;

  /// Default height for compact desktop toolbar controls.
  static const toolbarControlHeight = 36.0;

  static const contentMaxWidth = 920.0;

  /// Comfortable width for identity + status rows (history, settings lists).
  static const feedContentMaxWidth = 560.0;

  /// Modal bottom sheets on desktop. Material 3 caps these at 640, which
  /// starves categorize / rule sheets that have chip grids and long patterns.
  static const sheetMaxWidth = 1200.0;

  /// Desktop sits farther from the eye — scale type/icons up on the macOS
  /// Flutter target (not the host OS). Widget tests can override with
  /// [debugDefaultTargetPlatformOverride] so phone README screenshots use 1.0.
  static bool get _isMacosTarget =>
      defaultTargetPlatform == TargetPlatform.macOS;

  static double get typeScale => _isMacosTarget ? 1.25 : 1.0;

  /// Large hero / detail icon tile.
  static double get iconTile => _isMacosTarget ? 88.0 : 72.0;

  /// Dense list-row leading icon beside the title.
  static double get listRowIcon => _isMacosTarget ? 52.0 : 44.0;

  /// Preferred width for icon+title leading columns.
  static double get listRowLeadingWidth => _isMacosTarget ? 200.0 : 168.0;

  static double typeSize(double phoneSize) => phoneSize * typeScale;

  static BorderRadius borderRadius(double radius) =>
      BorderRadius.circular(radius);
}
