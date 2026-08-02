import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'e_colors.dart';
import 'e_layout.dart';
import 'e_text.dart';

abstract final class ETheme {
  static ThemeData build() {
    final colorScheme = ColorScheme.dark(
      surface: EColors.surface,
      primary: EColors.accent,
      onPrimary: EColors.textPrimary,
      secondary: EColors.accentGlow,
      onSecondary: EColors.background,
      error: EColors.danger,
      onError: EColors.textPrimary,
      onSurface: EColors.textPrimary,
      outline: EColors.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: EColors.background,
      canvasColor: EColors.background,
      dividerColor: EColors.border,
      splashFactory: InkSparkle.splashFactory,
      textTheme: EText.textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: EColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: EText.title,
        iconTheme: const IconThemeData(color: EColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: EColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: ELayout.borderRadius(ELayout.radiusMd),
          side: const BorderSide(color: EColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: EColors.accent,
          foregroundColor: EColors.textPrimary,
          disabledBackgroundColor: EColors.surfaceRaised,
          disabledForegroundColor: EColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: ELayout.borderRadius(ELayout.radiusSm),
          ),
          textStyle: EText.section,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EColors.textSecondary,
          disabledForegroundColor: EColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          side: const BorderSide(color: EColors.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: ELayout.borderRadius(ELayout.radiusSm),
          ),
          textStyle: EText.section,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: EColors.accentGlow,
          textStyle: EText.section,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EColors.textPrimary;
          }
          return EColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return EColors.accent;
          return EColors.surfaceRaised;
        }),
        trackOutlineColor: WidgetStateProperty.all(EColors.border),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: EColors.accentGlow,
        textColor: EColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: EColors.surfaceRaised,
        contentTextStyle: EText.body.copyWith(color: EColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ELayout.borderRadius(ELayout.radiusSm),
          side: const BorderSide(color: EColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: EColors.surface,
        titleTextStyle: EText.section,
        contentTextStyle: EText.body,
        shape: RoundedRectangleBorder(
          borderRadius: ELayout.borderRadius(ELayout.radiusLg),
          side: const BorderSide(color: EColors.border),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: EColors.accentGlow,
        circularTrackColor: EColors.accentSoft,
      ),
      dividerTheme: const DividerThemeData(
        color: EColors.border,
        thickness: 1,
        space: 1,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.ibmPlexSansTextTheme(base.textTheme).apply(
        bodyColor: EColors.textSecondary,
        displayColor: EColors.textPrimary,
      ),
    );
  }
}
