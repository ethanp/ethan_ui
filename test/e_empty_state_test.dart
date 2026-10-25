import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty state fits a short macOS slot', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 180,
              child: EEmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'Working tree is clean',
                message: 'No local uncommitted changes.',
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Working tree is clean'), findsOneWidget);
      expect(find.text('No local uncommitted changes.'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
