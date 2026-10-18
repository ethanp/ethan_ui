import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('clearing a scrolled log does not leave a scrollbar behind', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    final log = [for (var index = 0; index < 80; index++) 'line $index']
        .join('\n');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: LogTextView(
              log: log,
              controller: scrollController,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pump();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: LogTextView(
              log: '',
              controller: scrollController,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('(no log yet)'), findsOneWidget);
    expect(find.byType(Scrollbar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
