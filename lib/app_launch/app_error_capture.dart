import 'dart:async';

import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import '../theme/e_theme.dart';
import '../widgets/error_snack_bar.dart';
import 'error_bus.dart';

const _logger = ELogger('AppErrorCapture');

/// Launches an app so no error goes unseen.
///
/// Uncaught zone, platform, and Flutter framework errors are logged to
/// [appLogBuffer] and pushed to [errorBus]. `print` and `debugPrint` output
/// lands in [appLogBuffer]. A bootstrap that throws before `runApp` shows a
/// startup failure screen instead of a blank window.
class const AppErrorCapture({
  required final String appName,

  /// Errors answering false are logged but kept off [errorBus], e.g. an
  /// unreachable sync backend that retries on its own.
  final bool Function(Object error)? shouldShowError,

  /// Flutter framework errors answering false skip capture and reach only
  /// the default handler.
  final bool Function(FlutterErrorDetails details)? shouldCaptureFlutterError,
}) {
  /// Runs [bootstrap], which calls `runApp`, inside the capturing zone after
  /// the widgets binding is initialized in that same zone.
  void launch(Future<void> Function() bootstrap) {
    runZonedGuarded(
      () => _bootstrapOrShowStartupFailure(bootstrap),
      (error, stackTrace) =>
          _reportUncaught('Uncaught zone error', error, stackTrace),
      zoneSpecification: ZoneSpecification(
        print: (zoneSelf, zoneDelegate, zone, line) {
          appLogBuffer.capturePrintLine(line);
          zoneDelegate.print(zone, line);
        },
      ),
    );
  }

  Future<void> _bootstrapOrShowStartupFailure(
    Future<void> Function() bootstrap,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    _captureFlutterErrors();
    _capturePlatformErrors();
    _captureDebugPrint();
    try {
      await bootstrap();
    } catch (error, stackTrace) {
      final bool appStarted = WidgetsBinding.instance.rootElement != null;
      _reportUncaught(
        appStarted ? 'Bootstrap error' : '$appName failed to start',
        error,
        stackTrace,
      );
      if (appStarted) return;
      runApp(
        _StartupFailureApp(
          appName: appName,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// The default handler already prints to the console, so these go straight
  /// to [appLogBuffer] rather than through [ELogger].
  void _captureFlutterErrors() {
    final FlutterExceptionHandler? defaultFlutterErrorHandler =
        FlutterError.onError;
    FlutterError.onError = (details) {
      if (shouldCaptureFlutterError?.call(details) ?? true) {
        appLogBuffer.record(
          component: 'FlutterError',
          level: AppLogLevel.error,
          message: details.exceptionAsString(),
          error: details.exception,
          stackTrace: details.stack,
        );
        _showUnlessQuiet(
          'Flutter framework error',
          details.exception,
          details.exceptionAsString(),
        );
      }
      defaultFlutterErrorHandler?.call(details);
    };
  }

  void _capturePlatformErrors() {
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      _reportUncaught('Uncaught platform error', error, stackTrace);
      return true;
    };
  }

  void _captureDebugPrint() {
    final DebugPrintCallback consoleDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null && message.isNotEmpty) {
        appLogBuffer.captureDebugPrintLine(message);
      }
      consoleDebugPrint(message, wrapWidth: wrapWidth);
    };
  }

  void _reportUncaught(String label, Object error, StackTrace stackTrace) {
    _logger.error(label, error, stackTrace);
    _showUnlessQuiet(label, error, error.toString());
  }

  void _showUnlessQuiet(String label, Object error, String message) {
    if (shouldShowError?.call(error) == false) return;
    errorBus.add('$label: $message');
  }
}

class const _StartupFailureApp({
  required final String appName,
  required final Object error,
  required final StackTrace stackTrace,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ETheme.material3Dark,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: EColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ELayout.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ErrorSnackBar(
                  message: '$appName failed to start: $error',
                  emailSubject: '$appName startup failure',
                ),
                const SizedBox(height: ELayout.spaceMd),
                SelectableText('$stackTrace', style: EText.mono),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
