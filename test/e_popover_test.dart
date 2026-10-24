import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('trigger uses the active fill while the panel is open', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Scaffold(
          body: EPopover(
            width: 180,
            trigger: (_, toggle) =>
                IconButton(onPressed: toggle, icon: const Icon(Icons.sort)),
            panel: const Text('Sort by'),
          ),
        ),
      ),
    );

    expect(find.text('Sort by'), findsNothing);
    expect(_plateColor(tester), Colors.transparent);

    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    expect(find.text('Sort by'), findsOneWidget);
    expect(_plateColor(tester), EColors.accent.withValues(alpha: 0.35));

    await tester.tapAt(const Offset(400, 400));
    await tester.pumpAndSettle();

    expect(find.text('Sort by'), findsNothing);
    expect(_plateColor(tester), Colors.transparent);
  });

  testWidgets('wide panel shifts onto the screen', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final EPopoverController controller = EPopoverController();
    await tester.pumpWidget(
      _host(
        controller: controller,
        alignment: Alignment.topCenter,
        panel: const SizedBox(key: Key('panel'), height: 36),
      ),
    );
    controller.show();
    await tester.pump();

    final Rect panel = tester.getRect(find.byKey(const Key('panel')));
    expect(panel.left, greaterThanOrEqualTo(8));
    expect(panel.right, lessThanOrEqualTo(392));
    expect(panel.width, 340);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tall panel stops at the space under the anchor', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final EPopoverController controller = EPopoverController();
    await tester.pumpWidget(
      _host(
        controller: controller,
        alignment: Alignment.topRight,
        panel: ListView(
          shrinkWrap: true,
          children: const [SizedBox(key: Key('tags'), height: 2000)],
        ),
      ),
    );
    controller.show();
    await tester.pump();

    final Rect panel = tester.getRect(find.byType(ListView));
    expect(panel.bottom, lessThanOrEqualTo(792));
    expect(panel.right, lessThanOrEqualTo(392));
    expect(panel.height, lessThan(760));
    expect(tester.takeException(), isNull);
  });

  testWidgets('short panel stays content sized', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final EPopoverController controller = EPopoverController();
    await tester.pumpWidget(
      _host(
        controller: controller,
        alignment: Alignment.topRight,
        panel: const SizedBox(key: Key('panel'), height: 36),
      ),
    );
    controller.show();
    await tester.pump();

    expect(tester.getSize(find.byKey(const Key('panel'))).height, 36);
    expect(tester.takeException(), isNull);
  });
}

Color? _plateColor(WidgetTester tester) {
  final AnimatedContainer plate = tester.widget<AnimatedContainer>(
    find.byType(AnimatedContainer),
  );
  return (plate.decoration! as BoxDecoration).color;
}

Widget _host({
  required EPopoverController controller,
  required Alignment alignment,
  required Widget panel,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: alignment,
        child: EPopover(
          controller: controller,
          width: 340,
          trigger: (_, _) => const SizedBox(width: 40, height: 40),
          panel: panel,
        ),
      ),
    ),
  );
}
