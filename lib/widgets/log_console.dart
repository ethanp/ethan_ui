import 'package:flutter/material.dart';

import '../chrome/e_surface.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

class LogConsole extends StatelessWidget {
  const LogConsole({
    super.key,
    required this.log,
    this.controller,
    this.maxHeight,
    this.emptyMessage = '(no log yet)',
  });

  final String log;
  final ScrollController? controller;
  final double? maxHeight;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final console = ESurface(
      kind: ESurfaceKind.inset,
      borderRadius: ELayout.borderRadius(ELayout.radiusSm),
      child: Scrollbar(
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          reverse: controller == null,
          padding: const EdgeInsets.all(ELayout.spaceMd),
          child: SelectableText(
            log.isEmpty ? emptyMessage : log,
            style: EText.mono,
          ),
        ),
      ),
    );

    if (maxHeight == null) return console;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight!),
      child: console,
    );
  }
}
