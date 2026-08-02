import 'package:flutter/material.dart';

/// Palette keyed to the skeuomorphic app icon: graphite metal, signal blue.
///
/// Visual treatments (bevels, frost, shadows) live in chrome widgets — colors
/// here are tokens only.
abstract final class EColors {
  static const background = Color(0xFF0B0D10);
  static const backgroundLift = Color(0xFF141820);
  static const surface = Color(0xFF1A1F27);
  static const surfaceRaised = Color(0xFF242B35);
  static const surfaceInset = Color(0xFF0C0F14);

  static const border = Color(0xFF2C3440);
  static const borderStrong = Color(0xFF3E4856);
  static const bevelHighlight = Color(0x33FFFFFF);
  static const bevelShadow = Color(0x66000000);

  static const frostFill = Color(0xCC12161D);
  static const frostBorder = Color(0x33FFFFFF);

  static const textPrimary = Color(0xFFF3F5F8);
  static const textSecondary = Color(0xFFB6BFCC);
  static const textMuted = Color(0xFF7A8494);

  static const accent = Color(0xFF3B82F6);
  static const accentSoft = Color(0xFF1A2F4D);
  static const accentGlow = Color(0xFF60A5FA);

  static const platformIos = accentGlow;
  static const platformIosSoft = accentSoft;
  static const platformMacos = Color(0xFFD5DEE9);
  static const platformMacosSoft = Color(0xFF2A323E);

  static const success = Color(0xFF34D399);
  static const successSoft = Color(0xFF163528);
  static const warning = Color(0xFFFBBF24);
  static const warningSoft = Color(0xFF3A2E12);
  static const danger = Color(0xFFF87171);
  static const dangerSoft = Color(0xFF3A1A1A);

  static const mono = Color(0xFFD1D9E6);

  static const scaffoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF151A22),
      background,
      Color(0xFF080A0D),
    ],
    stops: [0.0, 0.42, 1.0],
  );

  static const ambientGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x402563EB),
      Color(0x000B0D10),
    ],
  );

  static const metalPanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF262D38),
      Color(0xFF171C24),
    ],
  );

  static const metalRowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF222833),
      Color(0xFF151A21),
    ],
  );

  static LinearGradient tintedMetalGradient(Color accent) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(accent, const Color(0xFF2A323E), 0.55)!,
        Color.lerp(accent, const Color(0xFF151A21), 0.78)!,
      ],
    );
  }
}
