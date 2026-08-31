import 'package:flutter/material.dart';

import 'e_privacy_lock_look.dart';

/// Full-screen fill that hides app content from the iOS app switcher.
class const EPrivacyScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: EPrivacyLockLook.shield,
      child: SizedBox.expand(),
    );
  }
}
