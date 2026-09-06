import 'package:ethan_ui/ethan_ui.dart';
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forDigits width fits measured figures plus chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ETheme.material3Dark,
        home: const Scaffold(
          body: Center(child: ETextField.forDigits(count: 2)),
        ),
      ),
    );

    final Size fieldSize = tester.getSize(find.byType(ETextField));
    final double figuresWidth = '88'.laidOutWidth(EText.body.medium);
    expect(
      fieldSize.width,
      greaterThanOrEqualTo(figuresWidth + ELayout.spaceMd * 2),
    );
    expect(fieldSize.width, ETextField.widthForDigitCount(2));
    expect(
      ETextField.widthForDigitCount(2),
      ETextField.widthForText('88') +
          ELayout.spaceMd * 2 +
          EInput.outlineSm.borderSide.width * 2,
    );
  });
}
