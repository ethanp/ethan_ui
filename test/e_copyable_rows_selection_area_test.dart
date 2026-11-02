import 'package:ethan_ui/ethan_ui.dart';
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String? clipboardText;

  setUp(() {
    clipboardText = null;
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            clipboardText =
                (methodCall.arguments as Map<Object?, Object?>)['text']
                    as String?;
          }
          if (methodCall.method == 'Clipboard.hasStrings') {
            return <String, bool>{'value': clipboardText != null};
          }
          return null;
        });
  });

  testWidgets(
    'copy selected rows copies every row the selection touches, in full',
    (tester) async {
      await tester.pumpWidget(_spendRowsInBottomSheet());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await _dragSelectWithMouse(
        tester,
        from: tester.getCenter(find.text('Coffee')),
        to: tester.getCenter(find.text('Rent')),
      );
      await tester.tapAt(
        tester.getCenter(find.text('Rent')),
        buttons: kSecondaryMouseButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy selected rows'));
      await tester.pumpAndSettle();

      expect(
        clipboardText,
        'Merchant\tAmount\n'
        'Coffee\t\$4.50\n'
        'Rent\t\$2,100.00',
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets('plain copy still copies only the selected text', (tester) async {
    await tester.pumpWidget(_spendRowsInBottomSheet());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await _dragSelectWithMouse(
      tester,
      from: tester.getCenter(find.text('Coffee')),
      to: tester.getCenter(find.text('Rent')),
    );
    await tester.tapAt(
      tester.getCenter(find.text('Coffee')),
      buttons: kSecondaryMouseButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();

    expect(clipboardText, 'ee\$4.50Rent');
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}

Future<void> _dragSelectWithMouse(
  WidgetTester tester, {
  required Offset from,
  required Offset to,
}) async {
  final TestGesture mouseDrag = await tester.startGesture(
    from,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pump();
  await mouseDrag.moveTo(to);
  await tester.pump();
  await mouseDrag.up();
  await tester.pumpAndSettle();
}

Widget _spendRowsInBottomSheet() {
  const List<List<String>> spendRows = [
    ['Coffee', r'$4.50'],
    ['Rent', r'$2,100.00'],
    ['Books', r'$31.00'],
  ];
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (_) => ECopyableRowsSelectionArea(
              headerCells: const ['Merchant', 'Amount'],
              child: ListView(
                children: spendRows.mapL(
                  (cells) => ECopyableRow(
                    cells: cells,
                    child: Row(
                      children: [
                        SizedBox(width: 120, child: Text(cells[0])),
                        Text(cells[1]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}
