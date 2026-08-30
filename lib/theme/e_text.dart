import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'e_colors.dart';
import 'e_layout.dart';

abstract final class EText() {
  static String? get _sans {
    if (kIsWeb) return null;
    if (Platform.isIOS || Platform.isMacOS) return 'CupertinoSystemText';
    return null;
  }

  static const _sansFallback = ['.AppleSystemUIFont', '.SF Pro Text'];

  static String? get _mono => GoogleFonts.ibmPlexMono().fontFamily;

  static double _size(double phoneSize) => ELayout.typeSize(phoneSize);

  static const headline = _EHeadlineScale();
  static const body = _EBodyScale();
  static const label = _ELabelScale();

  static TextStyle get title => headline.large;

  static TextStyle get projectName => headline.small;

  static TextStyle get section => label.large;

  static TextStyle get caption => body.small.tertiary;

  static TextStyle get error => body.small.copyWith(color: EColors.danger);

  static TextStyle get mono => TextStyle(
    inherit: false,
    decoration: TextDecoration.none,
    fontFamily: _mono,
    fontSize: _size(13.5),
    fontWeight: FontWeight.w400,
    color: EColors.mono,
    height: 1.45,
    textBaseline: TextBaseline.alphabetic,
  );

  static TextStyle get monoEmphasis => TextStyle(
    inherit: false,
    decoration: TextDecoration.none,
    fontFamily: _mono,
    fontSize: _size(14.5),
    fontWeight: FontWeight.w500,
    color: EColors.accentGlow,
    height: 1.35,
    textBaseline: TextBaseline.alphabetic,
  );

  static TextStyle _sansStyle({
    required FontWeight fontWeight,
    required Color color,
    required double height,
    required double letterSpacing,
  }) => TextStyle(
    inherit: false,
    decoration: TextDecoration.none,
    fontFamily: _sans,
    fontFamilyFallback: _sans == null ? null : _sansFallback,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    textBaseline: TextBaseline.alphabetic,
  );

  static TextTheme get textTheme => TextTheme(
    titleLarge: title,
    titleMedium: section,
    bodyMedium: body.medium,
    bodySmall: caption,
    labelSmall: label.small,
  );
}

class const _EHeadlineScale() {
  TextStyle get _base => EText._sansStyle(
    fontWeight: FontWeight.w600,
    color: EColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  TextStyle get large => _base.copyWith(
    fontSize: EText._size(32),
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.55,
  );

  TextStyle get medium => _base.copyWith(fontSize: EText._size(24));

  TextStyle get small => _base.copyWith(
    fontSize: EText._size(20),
    height: 1.4,
    letterSpacing: -0.2,
  );
}

class const _EBodyScale() {
  TextStyle get _base => EText._sansStyle(
    fontWeight: FontWeight.w400,
    color: EColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  TextStyle get large => _base.copyWith(fontSize: EText._size(18));

  TextStyle get medium => _base.copyWith(fontSize: EText._size(16));

  TextStyle get small =>
      _base.copyWith(fontSize: EText._size(14), color: EColors.textSecondary);

  TextStyle get tiny => _base.copyWith(fontSize: EText._size(10));
}

class const _ELabelScale() {
  TextStyle get _base => EText._sansStyle(
    fontWeight: FontWeight.w500,
    color: EColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.1,
  );

  TextStyle get large =>
      _base.copyWith(fontSize: EText._size(16), fontWeight: FontWeight.w600);

  TextStyle get medium => _base.copyWith(fontSize: EText._size(14));

  TextStyle get small =>
      _base.copyWith(fontSize: EText._size(12), color: EColors.textSecondary);
}

extension ETextStyleModifiers on TextStyle {
  TextStyle withColor(Color textColor) => copyWith(color: textColor);
  TextStyle size(double fontSize) => copyWith(fontSize: fontSize);
  TextStyle weight(FontWeight fontWeight) => copyWith(fontWeight: fontWeight);

  TextStyle get primary => withColor(EColors.textPrimary);
  TextStyle get secondary => withColor(EColors.textSecondary);
  TextStyle get tertiary => withColor(EColors.textTertiary);
  TextStyle get quaternary => withColor(EColors.textMuted);
  TextStyle get muted => withColor(EColors.textMuted);
  TextStyle get accent => withColor(EColors.accent);
  TextStyle get danger => withColor(EColors.danger);
  TextStyle get white => withColor(Colors.white);

  TextStyle get semibold => weight(FontWeight.w600);
  TextStyle get bold => weight(FontWeight.bold);
}
