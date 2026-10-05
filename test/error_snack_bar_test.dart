import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows selectable error text and an email button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorSnackBar(message: 'PostgREST conflict: 409'),
        ),
      ),
    );

    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.text('PostgREST conflict: 409'), findsOneWidget);
  });

  testWidgets('ErrorSnackBar.show stays until dismissed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => ErrorSnackBar.show(
                  context,
                  message: 'Upload failed',
                ),
                child: const Text('Show'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Upload failed'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Upload failed'), findsNothing);
  });
}
