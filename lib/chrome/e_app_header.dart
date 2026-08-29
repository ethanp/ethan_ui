import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// Frost-ready screen header: accent mark, title stack, trailing actions.
///
/// Pair with [EScaffoldShell] for frost, or use standalone on [Scaffold.appBar].
/// [Scaffold] allocates status-bar height above [preferredSize]; this header
/// pads its content down by that inset so titles do not crowd the safe area.
/// Height grows with eyebrow / subtitle so macOS type scale does not overflow.
class EAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const EAppHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.accent,
    this.leading,
    this.actions = const [],
    this.height,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;

  /// Glow for the accent rail and eyebrow. Defaults to [EColors.accentGlow].
  final Color? accent;

  /// When set, replaces the auto-generated back button.
  final Widget? leading;

  final List<Widget> actions;

  /// When null, height is derived from the title stack and action plate.
  final double? height;
  final bool automaticallyImplyLeading;

  Color get _accent => accent ?? EColors.accentGlow;

  @override
  Size get preferredSize => Size.fromHeight(height ?? _contentHeight);

  double get _contentHeight {
    const verticalPadding = ELayout.spaceSm * 2 + 1; // + hairline
    var stackHeight = ELayout.typeSize(25) * 1.05;
    if (eyebrow != null) {
      stackHeight += ELayout.typeSize(11) * 1.2 + 3;
    }
    if (subtitle != null) {
      stackHeight += ELayout.typeSize(12) * 1.15 + 4;
    }
    // Compact tinted actions are 44px tall — keep the bar at least that.
    // Ceil + slack: glyph metrics often exceed style.height * fontSize by a
    // fraction of a pixel (macOS type scale), which still trips RenderFlex.
    return (verticalPadding + math.max(stackHeight, 44)).ceilToDouble() + 4;
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final showBack = leading == null &&
        automaticallyImplyLeading &&
        (route?.impliesAppBarDismissal ?? false);

    final topInset = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.only(top: topInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: EColors.border.withValues(alpha: 0.55),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ELayout.spaceLg,
            ELayout.spaceSm,
            ELayout.spaceMd,
            ELayout.spaceSm,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: ELayout.spaceSm),
              ] else if (showBack) ...[
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: ELayout.spaceXs),
              ],
              _HeaderAccentMark(accent: _accent),
              const SizedBox(width: ELayout.spaceMd),
              Expanded(child: _titleStack()),
              for (final action in actions) ...[
                const SizedBox(width: ELayout.spaceSm),
                action,
              ],
            ],
          ),
        ),
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
            style: EText.label.small.copyWith(
              color: _accent,
              letterSpacing: 1.4,
              fontSize: ELayout.typeSize(11),
            ),
          ),
        if (eyebrow != null) const SizedBox(height: 3),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: EText.section.copyWith(
            fontSize: ELayout.typeSize(25),
            letterSpacing: -0.6,
            height: 1.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: EText.caption.copyWith(
              color: EColors.textMuted,
              fontSize: ELayout.typeSize(12),
              height: 1.15,
            ),
          ),
        ],
      ],
    );
  }
}

class _HeaderAccentMark extends StatelessWidget {
  const _HeaderAccentMark({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 3,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accent,
              Color.lerp(accent, EColors.surface, 0.55)!
                  .withValues(alpha: 0.35),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.28),
              blurRadius: 7,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}
