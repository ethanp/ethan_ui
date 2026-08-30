import 'package:flutter/material.dart';

import 'e_privacy_chrome.dart';

/// Full-screen fill that hides app content from the iOS app switcher.
class const EPrivacyScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: EPrivacyChrome.shield,
      child: SizedBox.expand(),
    );
  }
}
