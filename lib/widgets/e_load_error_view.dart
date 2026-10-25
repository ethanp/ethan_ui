import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// Centered, selectable failure for a screen whose data did not load.
///
/// Logs [error] with [stackTrace] once per distinct error, under
/// [screenName], so it reaches the app log and `flutter run` output.
class const ELoadErrorView({
  required final String screenName,
  required final Object error,
  final StackTrace? stackTrace,
  super.key,
}) extends StatefulWidget {
  @override
  State<ELoadErrorView> createState() => _ELoadErrorViewState();
}

class _ELoadErrorViewState() extends State<ELoadErrorView> {
  @override
  void initState() {
    super.initState();
    _logLoadFailure();
  }

  @override
  void didUpdateWidget(ELoadErrorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != widget.error) _logLoadFailure();
  }

  void _logLoadFailure() {
    ELogger(widget.screenName).error(
      '${widget.screenName} failed to load',
      widget.error,
      widget.stackTrace,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ELayout.spaceLg),
        child: SelectableText(
          '${widget.screenName} failed to load\n${widget.error}',
          textAlign: TextAlign.center,
          style: EText.body.medium.copyWith(color: EColors.danger),
        ),
      ),
    );
  }
}
