import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('error bus message stays visible above pushed routes', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) =>
            EErrorBanner(emailSubject: 'Test error', child: child!),
        home: const Scaffold(body: Text('home')),
      ),
    );

    errorBus.add('Save goal: disk full');
    await tester.pump();
    expect(find.text('Save goal: disk full'), findsOneWidget);

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('detail')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);
    expect(find.text('Save goal: disk full'), findsOneWidget);
  });
}
