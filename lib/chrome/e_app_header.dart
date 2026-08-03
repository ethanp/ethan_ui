import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// Frost-ready screen header: accent mark, title stack, trailing actions.
///
/// Pair with [EScaffoldShell] (frost already applied) or use standalone.
/// Height grows with eyebrow / subtitle so macOS type scale does not overflow.
class EAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const EAppHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actions = const [],
    this.height,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final List<Widget> actions;

  /// When null, height is derived from the title stack and action plate.
  final double? height;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => Size.fromHeight(height ?? _contentHeight);

  double get _contentHeight {
    const verticalPadding = ELayout.spaceSm * 2;
    var stackHeight = ELayout.typeSize(22) * 1.1;
    if (eyebrow != null) {
      stackHeight += ELayout.typeSize(11) * 1.2 + 2;
    }
    if (subtitle != null) {
      stackHeight += ELayout.typeSize(12) * 1.1 + 2;
    }
    // Compact tinted actions are 44px tall — keep the bar at least that.
    // Ceil + slack: glyph metrics often exceed style.height * fontSize by a
    // fraction of a pixel (macOS type scale), which still trips RenderFlex.
    return (verticalPadding + math.max(stackHeight, 44)).ceilToDouble() + 4;
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final showBack =
        automaticallyImplyLeading && (route?.impliesAppBarDismissal ?? false);

    // Scaffold already applies the top MediaQuery inset for primary app bars.
    // Do not wrap in SafeArea — that shrinks the fixed preferred height and
    // overflows the title stack (especially with eyebrow + subtitle on macOS).
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ELayout.spaceLg,
        ELayout.spaceSm,
        ELayout.spaceMd,
        ELayout.spaceSm,
      ),
      child: Row(
        children: [
          if (showBack) ...[
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: ELayout.spaceXs),
          ],
          const _HeaderAccentMark(),
          const SizedBox(width: ELayout.spaceMd),
          Expanded(child: _titleStack()),
          for (final action in actions) ...[
            const SizedBox(width: ELayout.spaceSm),
            action,
          ],
        ],
      ),
    );
  }

  Widget _titleStack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null)
          Text(
            eyebrow!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: EText.label.copyWith(
              color: EColors.accentGlow,
              letterSpacing: 1.1,
              fontSize: ELayout.typeSize(11),
            ),
          ),
        if (eyebrow != null) const SizedBox(height: 2),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: EText.section.copyWith(
            fontSize: ELayout.typeSize(22),
            letterSpacing: -0.45,
            height: 1.1,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: EText.caption.copyWith(
              fontSize: ELayout.typeSize(12),
              height: 1.1,
            ),
          ),
        ],
      ],
    );
  }
}

class _HeaderAccentMark extends StatelessWidget {
  const _HeaderAccentMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 3,
      height: 30,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              EColors.accentGlow,
              EColors.accent.withValues(alpha: 0.4),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: EColors.accentGlow.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}
