import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../chrome/e_surface.dart';
import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// Line-level color for matching [LogConsole] log lines.
class const LogConsoleHighlight({
  required final Pattern pattern,
  required final Color color,
  final FontWeight fontWeight = FontWeight.w600,
}) {
  LogLineHighlight toLogLineHighlight() =>
      LogLineHighlight(pattern: pattern, color: color, fontWeight: fontWeight);
}

class const LogConsole({
  super.key,
  required final String log,
  final ScrollController? controller,
  final double? maxHeight,
  final String emptyMessage = '(no log yet)',
  final List<LogConsoleHighlight> highlights = const [],

  /// See [LogTextView.trimBeforeLastHighlight].
  final bool trimBeforeLastHighlight = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final console = ESurface(
      kind: ESurfaceKind.inset,
      borderRadius: ELayout.borderRadiusSm,
      child: LogTextView(
        log: log,
        controller: controller,
        emptyMessage: emptyMessage,
        highlights: [
          for (final highlight in highlights) highlight.toLogLineHighlight(),
        ],
        trimBeforeLastHighlight: trimBeforeLastHighlight,
        padding: const EdgeInsets.all(ELayout.spaceMd),
        textStyle: EText.mono,
        controlColor: EColors.textMuted,
        controlActiveColor: EColors.accentGlow,
      ),
    );

    if (maxHeight == null) return console;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight!),
      child: console,
    );
  }
}
