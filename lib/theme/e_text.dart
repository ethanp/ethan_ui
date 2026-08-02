import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'e_colors.dart';
import 'e_layout.dart';

/// Typographic scale — IBM Plex Sans for UI, Plex Mono for machine readout.
///
/// Sizes are phone-baseline values scaled by [ELayout.typeScale] (larger on
/// macOS). Prefer these styles over one-off `fontSize` overrides.
abstract final class EText {
  static String? get _sans => GoogleFonts.ibmPlexSans().fontFamily;
  static String? get _mono => GoogleFonts.ibmPlexMono().fontFamily;

  static double _size(double phoneSize) => ELayout.typeSize(phoneSize);

  static TextStyle get title => TextStyle(
    fontFamily: _sans,
    fontSize: _size(28),
    fontWeight: FontWeight.w600,
    letterSpacing: -0.55,
    color: EColors.textPrimary,
    height: 1.15,
  );

  static TextStyle get projectName => TextStyle(
    fontFamily: _sans,
    fontSize: _size(20),
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: EColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get section => TextStyle(
    fontFamily: _sans,
    fontSize: _size(17),
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    color: EColors.textPrimary,
    height: 1.25,
  );

  static TextStyle get body => TextStyle(
    fontFamily: _sans,
    fontSize: _size(16),
    fontWeight: FontWeight.w400,
    color: EColors.textSecondary,
    height: 1.45,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: _sans,
    fontSize: _size(14),
    fontWeight: FontWeight.w400,
    color: EColors.textMuted,
    height: 1.35,
  );

  static TextStyle get label => TextStyle(
    fontFamily: _sans,
    fontSize: _size(12),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.75,
    color: EColors.textMuted,
    height: 1.2,
  );

  static TextStyle get mono => TextStyle(
    fontFamily: _mono,
    fontSize: _size(13.5),
    fontWeight: FontWeight.w400,
    color: EColors.mono,
    height: 1.45,
  );

  static TextStyle get monoEmphasis => TextStyle(
    fontFamily: _mono,
    fontSize: _size(14.5),
    fontWeight: FontWeight.w500,
    color: EColors.accentGlow,
    height: 1.35,
  );

  static TextTheme get textTheme => TextTheme(
    titleLarge: title,
    titleMedium: section,
    bodyMedium: body,
    bodySmall: caption,
    labelSmall: label,
  );
}
