import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import 'app_log_viewer.dart';

const _eAppLogViewerStyle = AppLogViewerStyle(
  surface: EColors.backgroundLift,
  surfaceElevated: EColors.surface,
  border: EColors.border,
  accent: EColors.accent,
  textPrimary: EColors.textPrimary,
  textSecondary: EColors.textSecondary,
  textTertiary: EColors.textTertiary,
  warning: EColors.warning,
  error: EColors.danger,
  radius: ELayout.radiusMd,
  spacingXs: ELayout.spaceXs,
  spacingSm: ELayout.spaceSm,
  spacingMd: ELayout.spaceMd,
  spacingXl: ELayout.spaceXl,
);

/// [AppLogViewer] painted with [EColors] / [ELayout]. Hosts pass no style.
class const EAppLogViewer({
  final String emptyMessage = 'No logs yet',
  final bool showClearButton = true,
  final double logFontSize = 12,
  final double? maxBodyHeight,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppLogViewer(
      style: _eAppLogViewerStyle,
      emptyMessage: emptyMessage,
      showClearButton: showClearButton,
      logFontSize: logFontSize,
      maxBodyHeight: maxBodyHeight,
    );
  }
}
