import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../chrome/e_surface.dart';
import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// Line-level color for matching [LogConsole] log lines.
class LogConsoleHighlight {
  const LogConsoleHighlight({
    required this.pattern,
    required this.color,
    this.fontWeight = FontWeight.w600,
  });

  final Pattern pattern;
  final Color color;
  final FontWeight fontWeight;

  LogLineHighlight toLogLineHighlight() => LogLineHighlight(
        pattern: pattern,
        color: color,
        fontWeight: fontWeight,
      );
}

class LogConsole extends StatelessWidget {
  const LogConsole({
    super.key,
    required this.log,
    this.controller,
    this.maxHeight,
    this.emptyMessage = '(no log yet)',
    this.highlights = const [],
  });

  final String log;
  final ScrollController? controller;
  final double? maxHeight;
  final String emptyMessage;
  final List<LogConsoleHighlight> highlights;

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
