import 'dart:async';

import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../app_launch/error_bus.dart';
import 'error_snack_bar.dart';

const _logger = ELogger('EErrorBanner');

/// Shows the latest [errorBus] message as a copyable, emailable toast along
/// the bottom of [child] until dismissed. Mount it in `MaterialApp.builder`
/// so it stays above every route.
class const EErrorBanner({
  required final String emailSubject,
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<EErrorBanner> createState() => _EErrorBannerState();
}

class _EErrorBannerState() extends State<EErrorBanner> {
  StreamSubscription<String>? _errorBusSubscription;
  String? _currentError;

  /// `MaterialApp.builder` sits above the navigator's overlay, and the
  /// toast's selectable text needs one.
  late final OverlayEntry _toastEntry = OverlayEntry(
    builder: (_) => _bottomToast(),
  );

  @override
  void initState() {
    super.initState();
    _errorBusSubscription = errorBus.stream.listen(_showError);
  }

  @override
  void dispose() {
    _errorBusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Overlay(initialEntries: [_toastEntry]),
      ],
    );
  }

  Widget _bottomToast() {
    final String? currentError = _currentError;
    if (currentError == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: ErrorSnackBar(
          message: currentError,
          emailSubject: widget.emailSubject,
          onDismiss: () => _replaceToast(null),
        ),
      ),
    );
  }

  void _showError(String error) {
    _logger.error(error);
    _replaceToast(error);
  }

  void _replaceToast(String? error) {
    _currentError = error;
    _toastEntry.markNeedsBuild();
  }
}
