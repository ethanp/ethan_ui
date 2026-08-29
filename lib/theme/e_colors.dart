import 'package:flutter/material.dart';

abstract final class EColors {
  static const background = Color(0xFF1A1B2E);
  static const backgroundLift = Color(0xFF252A3A);
  static const surface = Color(0xFF2F3542);
  static const surfaceRaised = Color(0xFF3A4151);
  static const surfaceInset = Color(0xFF141628);

  static const border = Color(0xFF3A4151);
  static const borderStrong = Color(0xFF4A5568);
  static const bevelHighlight = Color(0x33FFFFFF);
  static const bevelShadow = Color(0x66000000);

  static const frostFill = Color(0xCC1A1B2E);
  static const frostBorder = Color(0x33FFFFFF);

  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFFE2E8F0);
  static const textTertiary = Color(0xFFCBD5E1);
  static const textMuted = Color(0xFF94A3B8);

  static const accent = Color(0xFF6B73FF);
  static const accentDeep = Color(0xFF4A52E0);
  static const accentSoft = Color(0xFF2A2F5C);
  static const accentGlow = Color(0xFF8B93FF);

  static const platformIos = accentGlow;
  static const platformIosSoft = accentSoft;
  static const platformMacos = Color(0xFFD5DEE9);
  static const platformMacosSoft = Color(0xFF2A323E);

  static const success = Color(0xFF81C784);
  static const successSoft = Color(0xFF1E3324);
  static const warning = Color(0xFFFFB74D);
  static const warningSoft = Color(0xFF3A2E12);
  static const danger = Color(0xFFE57373);
  static const dangerSoft = Color(0xFF3A2224);

  static const mono = Color(0xFFD1D9E6);

  static const scaffoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF252A3A), background, Color(0xFF141628)],
    stops: [0.0, 0.42, 1.0],
  );

  static const ambientGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x406B73FF), Color(0x001A1B2E)],
  );

  static const metalPanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A4151), Color(0xFF2F3542)],
  );

  static const metalRowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2F3542), Color(0xFF252A3A)],
  );

  static final Map<Color, LinearGradient> _tintedMetalGradients = {};

  static LinearGradient tintedMetalGradient(Color accent) {
    return _tintedMetalGradients.putIfAbsent(
      accent,
      () => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(accent, surfaceRaised, 0.55)!,
          Color.lerp(accent, backgroundLift, 0.78)!,
        ],
      ),
    );
  }
}
