import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'error_report_mail.dart';

class const ErrorReportDialog({
  required final String title,
  required final String userMessage,
  required final String emailSubject,
  required final String reportBody,
  final String emailAddress = ErrorReportMail.address,
}) extends StatelessWidget {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String userMessage,
    required String emailSubject,
    required String reportBody,
    String emailAddress = ErrorReportMail.address,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorReportDialog(
        title: title,
        userMessage: userMessage,
        emailSubject: emailSubject,
        reportBody: reportBody,
        emailAddress: emailAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: _userMessageAndReportBody(),
      actions: [
        TextButton(
          onPressed: () => ErrorReportMail.openCompose(
            subject: emailSubject,
            body: reportBody,
            emailAddress: emailAddress,
          ),
          child: const Text('Email to me'),
        ),
        TextButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: reportBody)),
          child: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }

  Widget _userMessageAndReportBody() {
    return SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(userMessage),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              child: SelectableText(
                reportBody,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
