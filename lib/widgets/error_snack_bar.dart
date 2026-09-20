import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'error_report_mail.dart';

const _log = ELogger('ErrorSnackBar');

class const ErrorSnackBar({
  required final String message,
  final String emailSubject = 'App error',
  final String emailAddress = ErrorReportMail.address,
  final VoidCallback? onDismiss,
}) extends StatelessWidget {
  static const _untilDismissed = Duration(days: 365);

  static void show(
    BuildContext context, {
    required String message,
    String emailSubject = 'App error',
    String emailAddress = ErrorReportMail.address,
  }) {
    _log.error(message);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: _untilDismissed,
          dismissDirection: DismissDirection.none,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          content: ErrorSnackBar(
            message: message,
            emailSubject: emailSubject,
            emailAddress: emailAddress,
            onDismiss: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.all(ELayout.spaceMd),
        padding: const EdgeInsets.all(ELayout.spaceMd),
        decoration: _toastDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: ELayout.spaceSm),
            _messageBody(),
            const SizedBox(height: ELayout.spaceMd),
            _actions(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _toastDecoration() {
    return BoxDecoration(
      color: EColors.dangerSoft,
      borderRadius: ELayout.borderRadiusMd,
      border: Border.all(color: EColors.danger.withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Icon(Icons.warning, color: EColors.danger, size: 18),
        const SizedBox(width: ELayout.spaceSm),
        Text('Error', style: EText.section.danger),
        const Spacer(),
        if (onDismiss != null)
          IconButton(
            tooltip: 'Dismiss',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: onDismiss,
            icon: const Icon(Icons.close, color: EColors.textTertiary, size: 16),
          ),
      ],
    );
  }

  Widget _messageBody() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: SingleChildScrollView(
        child: SelectableText(message, style: EText.caption.secondary),
      ),
    );
  }

  Widget _actions() {
    final buttonStyle = FilledButton.styleFrom(
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: ELayout.spaceMd,
        vertical: ELayout.spaceSm,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: ELayout.borderRadiusSm,
      ),
    );

    return Wrap(
      spacing: ELayout.spaceSm,
      runSpacing: ELayout.spaceSm,
      children: [
        FilledButton(
          style: buttonStyle.copyWith(
            backgroundColor: const WidgetStatePropertyAll(EColors.danger),
          ),
          onPressed: () => ErrorReportMail.openCompose(
            subject: emailSubject,
            body: ErrorReportMail.bodyWithRecentLogs(message),
            emailAddress: emailAddress,
          ),
          child: const Text('Email to me'),
        ),
        FilledButton(
          style: buttonStyle.copyWith(
            backgroundColor: const WidgetStatePropertyAll(EColors.surface),
          ),
          onPressed: () => Clipboard.setData(ClipboardData(text: message)),
          child: const Text('Copy'),
        ),
        if (onDismiss != null)
          FilledButton(
            style: buttonStyle.copyWith(
              backgroundColor: const WidgetStatePropertyAll(EColors.surface),
            ),
            onPressed: onDismiss,
            child: const Text('Dismiss'),
          ),
      ],
    );
  }
}
