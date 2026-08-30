import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'e_colors.dart';
import 'e_input.dart';
import 'e_layout.dart';
import 'e_text.dart';

abstract final class ETheme() {
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
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: EColors.surface,
        contentPadding: EdgeInsets.all(ELayout.spaceMd),
        border: EInput.outlineSm,
        enabledBorder: EInput.outlineSm,
        focusedBorder: EInput.outlineSmFocused,
      ),
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
        shape: const RoundedRectangleBorder(
          borderRadius: ELayout.borderRadiusMd,
          side: BorderSide(color: EColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: EColors.accent,
          foregroundColor: EColors.textPrimary,
          disabledBackgroundColor: EColors.surfaceRaised,
          disabledForegroundColor: EColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: ELayout.borderRadiusSm,
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
          shape: const RoundedRectangleBorder(
            borderRadius: ELayout.borderRadiusSm,
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
        contentTextStyle: EText.body.medium.primary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: ELayout.borderRadiusSm,
          side: BorderSide(color: EColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: EColors.surface,
        titleTextStyle: EText.section,
        contentTextStyle: EText.body.medium,
        shape: const RoundedRectangleBorder(
          borderRadius: ELayout.borderRadiusLg,
          side: BorderSide(color: EColors.border),
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
      navigationBarTheme: NavigationBarThemeData(
        height: 56,
        elevation: 0,
        backgroundColor: EColors.backgroundLift,
        indicatorColor: EColors.accent.withValues(alpha: 0.28),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return EText.label.small.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? EColors.accent : EColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? EColors.accent : EColors.textMuted,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: EColors.surfaceRaised,
        selectedColor: EColors.accentSoft,
        disabledColor: EColors.surface,
        deleteIconColor: EColors.textMuted,
        labelStyle: EText.caption.copyWith(color: EColors.textSecondary),
        secondaryLabelStyle: EText.caption.copyWith(color: EColors.accentGlow),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: ELayout.borderRadiusSm,
          side: BorderSide(color: EColors.border),
        ),
        side: const BorderSide(color: EColors.border),
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: EColors.textSecondary,
        displayColor: EColors.textPrimary,
      ),
    );
  }
}
