import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import '../theme/e_input.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// Themed [TextField] using [EInput.filled].
///
/// Line fields expand with the parent. [ETextField.forDigits] sizes width from
/// expected figures so compact numeric entry is not clipped.
class const ETextField({
  super.key,
  final TextEditingController? controller,
  final FocusNode? focusNode,
  final String? hintText,
  final TextInputType? keyboardType,
  final TextAlign textAlign = TextAlign.start,
  final bool autofocus = false,
  final ValueChanged<String>? onChanged,
  final ValueChanged<String>? onSubmitted,
  final bool autocorrect = true,
  final bool enableSuggestions = true,
  final int? maxLines = 1,
  final bool enabled = true,
  final int? digitCount,
}) extends StatelessWidget {
  /// Compact numeric field sized for [count] figures.
  const new forDigits({
    Key? key,
    required int count,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
  }) : this(
         key: key,
         controller: controller,
         focusNode: focusNode,
         autofocus: autofocus,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         enabled: enabled,
         digitCount: count,
         textAlign: TextAlign.center,
         keyboardType: TextInputType.number,
         autocorrect: false,
         enableSuggestions: false,
         maxLines: 1,
       );

  static const _caretSlack = 8.0;

  static TextStyle get _fieldStyle => EText.body.medium;

  /// Width that fits [count] wide digits plus field chrome.
  static double widthForDigitCount(int count) {
    final double figuresWidth = ('8' * count).laidOutWidth(_fieldStyle);
    return figuresWidth +
        ELayout.spaceMd * 2 +
        EInput.outlineSm.borderSide.width * 2 +
        _caretSlack;
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      style: _fieldStyle,
      textAlign: textAlign,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: EInput.filled(hintText: hintText),
    );
    if (digitCount == null) return field;
    return SizedBox(width: widthForDigitCount(digitCount!), child: field);
  }
}
