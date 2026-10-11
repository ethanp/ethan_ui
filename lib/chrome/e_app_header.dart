import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_tinted_action.dart';

/// Frost-ready screen header: accent mark, title stack, trailing actions.
///
/// Pair with [EScaffoldShell] for frost, or use standalone on [Scaffold.appBar].
/// [Scaffold] allocates status-bar height above [preferredSize]; this header
/// pads its content down by that inset so titles do not crowd the safe area.
/// Height follows the measured title stack, including system text scale.
/// Long titles shrink, then wrap to two lines, then ellipsize at the minimum size.
class const EAppHeader({
  super.key,
  required final String title,
  final String? eyebrow,
  final String? subtitle,

  /// Glow for the accent rail and eyebrow. Defaults to [EColors.accentGlow].
  final Color? accent,

  /// When set, replaces the auto-generated back button.
  final Widget? leading,
  final List<Widget> actions = const [],

  /// When null, height is derived from the title stack and action plate.
  final double? height,
  final bool automaticallyImplyLeading = true,
}) extends StatelessWidget implements PreferredSizeWidget {
  Color get _accent => accent ?? EColors.accentGlow;

  @override
  Size get preferredSize => Size.fromHeight(height ?? _contentHeight);

  double get _contentHeight {
    final TextScaler textScaler = _viewTextScaler;
    var stackHeight = _titleBlockHeight(textScaler);
    if (eyebrow != null) {
      stackHeight += _lineHeight(_eyebrowStyle, textScaler) + 3;
    }
    if (subtitle != null) {
      stackHeight += _lineHeight(_subtitleStyle, textScaler) + 4;
    }
    const verticalPadding = ELayout.spaceSm * 2;
    final double actionPlate = ETintedAction.compactPlateHeight(textScaler);
    // One extra pixel: device-pixel rounding can still exceed the measured
    // line box by a fraction and trip RenderFlex.
    return (verticalPadding + math.max(stackHeight, actionPlate))
            .ceilToDouble() +
        1;
  }

  TextScaler get _viewTextScaler {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return TextScaler.noScaling;
    return MediaQueryData.fromView(views.first).textScaler;
  }

  double _lineHeight(TextStyle style, TextScaler textScaler) {
    final painter = TextPainter(
      text: TextSpan(text: 'Ag', style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    return painter.height.ceilToDouble();
  }

  TextStyle get _eyebrowStyle => EText.label.small.copyWith(
    color: _accent,
    letterSpacing: 1.4,
    fontSize: ELayout.typeSize(11),
  );

  TextStyle _titleStyleFor(double fontSize) => EText.section.copyWith(
    fontSize: fontSize,
    letterSpacing: -0.6,
    height: 1.05,
    fontWeight: FontWeight.w600,
  );

  double _titleBlockHeight(TextScaler textScaler) {
    final _FittedTitle fit = _FittedTitle.forWidth(
      text: title,
      maxWidth: _reservedTitleWidth,
      textScaler: textScaler,
      styleFor: _titleStyleFor,
    );
    if (fit.maxLines == 1) {
      return _lineHeight(_titleStyleFor(_FittedTitle.largest), textScaler);
    }
    return _lineHeight(
          _titleStyleFor(_FittedTitle.smallestSingleLine),
          textScaler,
        ) *
        2;
  }

  double get _reservedTitleWidth {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return 240;
    final view = views.first;
    final double screenWidth = view.physicalSize.width / view.devicePixelRatio;
    final double horizontalInset =
        (view.padding.left + view.padding.right) / view.devicePixelRatio;
    return math.max(48, screenWidth - horizontalInset - _titleChromeWidth);
  }

  double get _titleChromeWidth {
    var chrome = ELayout.spaceLg + ELayout.spaceMd;
    chrome += _HeaderChrome.accentMark + ELayout.spaceMd;
    if (leading != null) {
      chrome += _HeaderChrome.leadingSlot + ELayout.spaceSm;
    } else if (automaticallyImplyLeading) {
      chrome += _HeaderChrome.leadingSlot + ELayout.spaceXs;
    }
    chrome += actions.length * (ELayout.spaceSm + _HeaderChrome.actionSlot);
    return chrome;
  }

  TextStyle get _subtitleStyle => EText.caption.copyWith(
    color: EColors.textMuted,
    fontSize: ELayout.typeSize(12),
    height: 1.15,
  );

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final showBack =
        leading == null &&
        automaticallyImplyLeading &&
        (route?.impliesAppBarDismissal ?? false);

    final topInset = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.only(top: topInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: EColors.border.withValues(alpha: 0.55)),
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
            style: _eyebrowStyle,
          ),
        if (eyebrow != null) const SizedBox(height: 3),
        _titleText(),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _subtitleStyle,
          ),
        ],
      ],
    );
  }

  Widget _titleText() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final _FittedTitle fit = _FittedTitle.forWidth(
          text: title,
          maxWidth: constraints.maxWidth,
          textScaler: MediaQuery.textScalerOf(context),
          styleFor: _titleStyleFor,
        );
        return Text(
          title,
          maxLines: fit.maxLines,
          overflow: TextOverflow.ellipsis,
          style: _titleStyleFor(fit.fontSize),
        );
      },
    );
  }
}

class const _HeaderAccentMark({required final Color accent})
    extends StatelessWidget {
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
              Color.lerp(
                accent,
                EColors.surface,
                0.55,
              )!.withValues(alpha: 0.35),
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

abstract final class _HeaderChrome() {
  static const accentMark = 3.0;
  static const leadingSlot = 48.0;

  /// Conservative trailing-action width so the reserved title column
  /// stays inside the laid-out one.
  static const actionSlot = 96.0;
}

class const _FittedTitle({
  required final double fontSize,
  required final int maxLines,
}) {
  static const largestPhone = 25.0;
  static const smallestSingleLinePhone = 18.0;
  static const smallestPhone = 16.0;

  static double get largest => ELayout.typeSize(largestPhone);

  static double get smallestSingleLine =>
      ELayout.typeSize(smallestSingleLinePhone);

  static double get smallest => ELayout.typeSize(smallestPhone);

  static _FittedTitle forWidth({
    required String text,
    required double maxWidth,
    required TextScaler textScaler,
    required TextStyle Function(double fontSize) styleFor,
  }) {
    if (!maxWidth.isFinite || maxWidth <= 0) {
      return _FittedTitle(fontSize: largest, maxLines: 1);
    }
    final double? singleLine = _largestFont(
      text: text,
      maxWidth: maxWidth,
      textScaler: textScaler,
      styleFor: styleFor,
      minFont: smallestSingleLine,
      maxFont: largest,
      maxLines: 1,
    );
    if (singleLine != null) {
      return _FittedTitle(fontSize: singleLine, maxLines: 1);
    }
    final double? twoLines = _largestFont(
      text: text,
      maxWidth: maxWidth,
      textScaler: textScaler,
      styleFor: styleFor,
      minFont: smallest,
      maxFont: smallestSingleLine,
      maxLines: 2,
    );
    return _FittedTitle(fontSize: twoLines ?? smallest, maxLines: 2);
  }

  static double? _largestFont({
    required String text,
    required double maxWidth,
    required TextScaler textScaler,
    required TextStyle Function(double fontSize) styleFor,
    required double minFont,
    required double maxFont,
    required int maxLines,
  }) {
    if (_fits(text, styleFor(maxFont), maxWidth, maxLines, textScaler)) {
      return maxFont;
    }
    var fontSize = maxFont;
    while (fontSize - 0.5 > minFont) {
      fontSize -= 0.5;
      if (_fits(text, styleFor(fontSize), maxWidth, maxLines, textScaler)) {
        return fontSize;
      }
    }
    if (_fits(text, styleFor(minFont), maxWidth, maxLines, textScaler)) {
      return minFont;
    }
    return null;
  }

  static bool _fits(
    String text,
    TextStyle style,
    double maxWidth,
    int maxLines,
    TextScaler textScaler,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    return !painter.didExceedMaxLines;
  }
}
