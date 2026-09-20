import 'package:ethan_utils/ethan_utils.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class ErrorReportMail() {
  static const address = 'etahnp@gmail.com';
  static const _recentLogLineCount = 75;

  static Future<void> openCompose({
    required String subject,
    required String body,
    String emailAddress = address,
  }) async {
    final encodedSubject = Uri.encodeComponent(subject);
    final encodedBody = Uri.encodeComponent(body);
    final gmailUri = Uri.parse(
      'googlegmail:///co?to=$emailAddress&subject=$encodedSubject&body=$encodedBody',
    );
    if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      return;
    }

    final webUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm'
      '&to=$emailAddress&su=$encodedSubject&body=$encodedBody',
    );
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  static String bodyWithRecentLogs(String errorMessage) {
    final logLines = appLogBuffer.entries;
    final skipped = (logLines.length - _recentLogLineCount).clamp(
      0,
      logLines.length,
    );
    final included = logLines.length < _recentLogLineCount
        ? logLines.length
        : _recentLogLineCount;
    final logTail = logLines
        .skip(skipped)
        .map((entry) => entry.formattedText)
        .join('\n');
    return 'Error at ${DateTime.now().toIso8601String()}:\n\n'
        '$errorMessage\n\n'
        '--- Recent log ($included lines) ---\n'
        '$logTail';
  }
}
