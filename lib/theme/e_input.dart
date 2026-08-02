import 'package:flutter/material.dart';

import 'e_colors.dart';
import 'e_layout.dart';

/// Text-field outline borders and filled decorations for the machined-console
/// theme.
abstract final class EInput {
  static const outlineSm = OutlineInputBorder(
    borderRadius: ELayout.borderRadiusSm,
    borderSide: BorderSide(color: EColors.border),
  );

  static const outlineSmFocused = OutlineInputBorder(
    borderRadius: ELayout.borderRadiusSm,
    borderSide: BorderSide(color: EColors.accentGlow),
  );

  static const outlineMd = OutlineInputBorder(
    borderRadius: ELayout.borderRadiusMd,
    borderSide: BorderSide(color: EColors.border),
  );

  static const outlineMdFocused = OutlineInputBorder(
    borderRadius: ELayout.borderRadiusMd,
    borderSide: BorderSide(color: EColors.accentGlow),
  );

  /// Filled field with [outlineSm] / [outlineSmFocused].
  static InputDecoration filled({
    String? hintText,
    TextStyle? hintStyle,
    bool isDense = false,
    Color fillColor = EColors.surface,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(ELayout.spaceMd),
    OutlineInputBorder? focusedBorder,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      isDense: isDense,
      filled: true,
      fillColor: fillColor,
      contentPadding: contentPadding,
      prefixIcon: prefixIcon,
      border: outlineSm,
      enabledBorder: outlineSm,
      focusedBorder: focusedBorder ?? outlineSmFocused,
    );
  }

  /// Filled field with [outlineMd] / [outlineMdFocused].
  static InputDecoration filledMd({
    String? hintText,
    TextStyle? hintStyle,
    bool isDense = false,
    Color fillColor = EColors.surface,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(ELayout.spaceMd),
    OutlineInputBorder? focusedBorder,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      isDense: isDense,
      filled: true,
      fillColor: fillColor,
      contentPadding: contentPadding,
      prefixIcon: prefixIcon,
      border: outlineMd,
      enabledBorder: outlineMd,
      focusedBorder: focusedBorder ?? outlineMdFocused,
    );
  }
}
