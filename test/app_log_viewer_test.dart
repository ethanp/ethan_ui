import 'package:ethan_ui/ethan_ui.dart';
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _style = AppLogViewerStyle(
  surface: Color(0xFF1C1F23),
  surfaceElevated: Color(0xFF262A30),
  border: Color(0xFF3A404A),
  accent: Color(0xFF2F8F86),
  textPrimary: Color(0xFFF2F4F6),
  textSecondary: Color(0xFFC5CBD3),
  textTertiary: Color(0xFF8B939E),
  warning: Color(0xFFD4A05A),
  error: Color(0xFFD46A6A),
);

void main() {
  tearDown(appLogBuffer.clear);

  testWidgets('AppLogViewer builds selectable logs under MaterialApp', (
    tester,
  ) async {
    _seedLogs();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(height: 400, child: AppLogViewer(style: _style)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('INFO|Test'), findsOneWidget);
    expect(find.textContaining('ERROR|Test'), findsOneWidget);
    expect(find.byType(SelectableRegion), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.clear_all), findsOneWidget);
  });

  testWidgets('recording a log during build does not assert', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: AppLogViewer(style: _style)),
              Expanded(
                child: Builder(
                  builder: (context) {
                    appLogBuffer.record(
                      component: 'DuringBuild',
                      level: AppLogLevel.info,
                      message: 'logged while Expanded is building',
                    );
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('logged while Expanded is building'),
      findsOneWidget,
    );
  });

  testWidgets('AppLogViewer injects MaterialLocalizations under CupertinoApp', (
    tester,
  ) async {
    _seedLogs();

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: SizedBox(height: 400, child: AppLogViewer(style: _style)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('INFO|Test'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.clear_all), findsOneWidget);
  });
}

void _seedLogs() {
  appLogBuffer.record(
    component: 'Test',
    level: AppLogLevel.info,
    message: 'hello selectable',
  );
  appLogBuffer.record(
    component: 'Test',
    level: AppLogLevel.error,
    message: 'boom',
  );
}
