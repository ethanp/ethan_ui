import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('compact action with a subtitle fits in the header', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await _HeaderHarness.pumpCompactAction(tester);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('compact action with a subtitle fits in the macOS header', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await _HeaderHarness.pumpCompactAction(tester);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('title and subtitle fit on a pushed page', (tester) async {
    await _HeaderHarness.open(
      tester,
      const EAppHeader(title: 'Book title', subtitle: 'reading'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('title and subtitle fit at a larger text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _HeaderHarness.open(
      tester,
      const EAppHeader(
        title: 'The Long Way to a Small, Angry Planet',
        subtitle: 'reading',
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('eyebrow and subtitle fit at the macOS type scale', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await _HeaderHarness.open(
        tester,
        const EAppHeader(
          eyebrow: 'Library',
          title: 'Book title',
          subtitle: 'reading',
        ),
      );
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('short title stays one line at full size on a phone', (
    tester,
  ) async {
    await _HeaderHarness.openOnPhone(
      tester,
      const EAppHeader(title: 'Dune', subtitle: 'reading'),
      actionsWidth: 80,
    );
    _HeaderHarness.expectTitle(tester, 'Dune', fontSize: 25, maxLines: 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('medium title shrinks and stays on one line', (tester) async {
    const title = 'Handbooks';
    await _HeaderHarness.openOnPhone(
      tester,
      const EAppHeader(title: title, subtitle: 'reading'),
      actionsWidth: 80,
    );
    final Text titleText = _HeaderHarness.titleTextOf(tester, title);
    expect(titleText.maxLines, 1);
    expect(titleText.style!.fontSize!, lessThan(25));
    expect(titleText.style!.fontSize!, greaterThanOrEqualTo(18));
    expect(_HeaderHarness.paragraph(tester, title).didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('longer title wraps to two lines instead of shrinking further', (
    tester,
  ) async {
    const title = 'Newborn Handbook';
    await _HeaderHarness.openOnPhone(
      tester,
      const EAppHeader(title: title, subtitle: 'reading'),
      actionsWidth: 80,
    );
    final Text titleText = _HeaderHarness.titleTextOf(tester, title);
    expect(titleText.maxLines, 2);
    expect(titleText.style!.fontSize!, greaterThanOrEqualTo(16));
    expect(titleText.style!.fontSize!, lessThanOrEqualTo(18));
    expect(_HeaderHarness.paragraph(tester, title).didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'title ellipsizes at the minimum size when two lines still overflow',
    (tester) async {
      final String title = List.filled(30, 'Handbook').join(' ');
      await _HeaderHarness.openOnPhone(
        tester,
        EAppHeader(title: title, subtitle: 'reading'),
        actionsWidth: 80,
      );
      final Text titleText = _HeaderHarness.titleTextOf(tester, title);
      expect(titleText.maxLines, 2);
      expect(titleText.overflow, TextOverflow.ellipsis);
      expect(titleText.style!.fontSize, 16);
      expect(_HeaderHarness.paragraph(tester, title).didExceedMaxLines, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}

class _HeaderHarness() {
  static Future<void> pumpCompactAction(WidgetTester tester) {
    return open(
      tester,
      EAppHeader(
        eyebrow: 'Library',
        title: 'Book title',
        subtitle: 'reading',
        actions: [
          ETintedAction.compact(
            accent: EColors.accent,
            icon: Icons.bolt_rounded,
            title: 'Refresh',
            subtitle: 'Just now',
            onActivated: () {},
          ),
        ],
      ),
    );
  }

  static Future<void> open(
    WidgetTester tester,
    EAppHeader header, {
    double? actionsWidth,
  }) async {
    final EAppHeader headerWithAction = actionsWidth == null
        ? header
        : EAppHeader(
            title: header.title,
            eyebrow: header.eyebrow,
            subtitle: header.subtitle,
            actions: [SizedBox(width: actionsWidth, height: 36)],
          );
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        appBar: headerWithAction,
                        body: const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  static Future<void> openOnPhone(
    WidgetTester tester,
    EAppHeader header, {
    required double actionsWidth,
  }) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    try {
      await open(tester, header, actionsWidth: actionsWidth);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  }

  static void expectTitle(
    WidgetTester tester,
    String title, {
    required double fontSize,
    required int maxLines,
  }) {
    final Text titleText = titleTextOf(tester, title);
    expect(titleText.maxLines, maxLines);
    expect(titleText.style!.fontSize, fontSize);
  }

  static Text titleTextOf(WidgetTester tester, String title) {
    return tester.widget<Text>(find.text(title));
  }

  static RenderParagraph paragraph(WidgetTester tester, String title) {
    return tester.renderObject<RenderParagraph>(find.text(title));
  }
}
