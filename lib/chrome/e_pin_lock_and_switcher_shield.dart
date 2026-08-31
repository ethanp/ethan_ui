import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'e_pin_lock_screen.dart';
import 'e_privacy_screen.dart';

/// PIN lock on launch and resume, plus an app-switcher cover when backgrounded.
///
/// Locked on first frame. Leaving the foreground covers immediately.
/// Resume re-locks, then drops the shield after the next frame so content
/// does not flash under the PIN pad.
class const EPinLockAndSwitcherShield({
  super.key,
  required final Widget child,
  required final String pin,
}) extends StatefulWidget {
  @override
  State<EPinLockAndSwitcherShield> createState() =>
      _EPinLockAndSwitcherShieldState();
}

class _EPinLockAndSwitcherShieldState()
    extends State<EPinLockAndSwitcherShield>
    with WidgetsBindingObserver {
  bool _locked = true;
  bool _showPrivacy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        setState(() => _showPrivacy = true);
        SchedulerBinding.instance.scheduleForcedFrame();
      case AppLifecycleState.resumed:
        setState(() => _locked = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _showPrivacy = false);
        });
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_locked)
          Positioned.fill(
            child: EPinLockScreen(
              pin: widget.pin,
              onUnlocked: () => setState(() => _locked = false),
            ),
          ),
        if (_showPrivacy) const Positioned.fill(child: EPrivacyScreen()),
      ],
    );
  }
}
