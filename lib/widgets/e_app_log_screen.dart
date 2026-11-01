import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../chrome/e_app_header.dart';
import '../chrome/e_overlaid_tab_bar.dart';
import '../theme/e_colors.dart';
import 'e_app_log_viewer.dart';

/// Full-screen [EAppLogViewer] under an [EAppHeader]. Pushed inside a tab's
/// navigator, so the tab bar stays and the body pads for it.
class const EAppLogScreen({super.key, final String? eyebrow})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: EAppHeader(eyebrow: eyebrow, title: 'Logs'),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: ETabBarOverlay.paddingOf(context),
          child: const EAppLogViewer(),
        ),
      ),
    );
  }
}

/// Settings row that opens [EAppLogScreen]; sits in an `ESettingsRowGroup`.
class const EAppLogRow({
  super.key,
  final String? eyebrow,
  final Color accent = EColors.accent,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.terminal, color: accent),
      title: const Text('Logs'),
      subtitle: Text(
        'Last ${appLogBuffer.maxEntries} info, warning, and error lines',
        style: const TextStyle(color: EColors.textMuted),
      ),
      trailing: const Icon(Icons.chevron_right, color: EColors.textMuted),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EAppLogScreen(eyebrow: eyebrow),
        ),
      ),
    );
  }
}
