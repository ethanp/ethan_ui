import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// A settings screen section: uppercase caption header over its children,
/// spaced by [ELayout.spaceMd]. Children are cards: an [ESettingsRowGroup]
/// of list rows, an [ESettingsCard], or a tile that draws its own card.
class const ESettingsSection({
  super.key,
  required final String title,
  required final List<Widget> children,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: ELayout.spaceMd,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: ELayout.spaceSm),
          child: Text(
            title.toUpperCase(),
            style: EText.caption.copyWith(
              color: EColors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// The card a settings section child sits on.
class const ESettingsCard({
  super.key,
  required final Widget child,
  final EdgeInsetsGeometry padding = const EdgeInsets.all(ELayout.spaceMd),
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: EColors.backgroundLift,
      shape: const RoundedRectangleBorder(
        borderRadius: ELayout.borderRadiusMd,
        side: BorderSide(color: EColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

/// List rows (ListTile-shaped) on one [ESettingsCard], separated by hairlines
/// inset to the text column so each row reads as its own control.
class const ESettingsRowGroup({super.key, required final List<Widget> children})
    extends StatelessWidget {
  /// Where a ListTile's title starts: content padding + leading icon + gap.
  static const _textColumnInset = 56.0;

  @override
  Widget build(BuildContext context) {
    return ESettingsCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (int index, Widget row) in children.indexed) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 0.5,
                indent: _textColumnInset,
                color: EColors.border,
              ),
            row,
          ],
        ],
      ),
    );
  }
}
