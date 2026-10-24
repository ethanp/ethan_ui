import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/e_motion.dart';

abstract final class _PopoverChrome() {
  static const gap = 4.0;
  static const margin = 8.0;
  static const activeRadius = 8.0;
  static const activeFillAlpha = 0.35;
}

/// Opens [panel] from [trigger] and keeps the panel on screen.
///
/// [trigger] receives whether the panel is open, and a toggle. While the
/// panel is open, the trigger is wrapped in the active fill. Set
/// [triggerPaintsActive] when the trigger paints that state itself.
class const EPopover({
  super.key,
  final EPopoverController? controller,
  required final Widget Function(bool open, VoidCallback toggle) trigger,
  required final double width,
  required final Widget panel,
  final bool triggerPaintsActive = false,
}) extends StatefulWidget {
  @override
  State<EPopover> createState() => _EPopoverState();
}

/// Show and hide an [EPopover] from outside its trigger.
class EPopoverController() {
  _EPopoverState? _state;

  bool get isShowing => _state?._open ?? false;

  void show() => _state?._show();

  void hide() => _state?._hide();

  void _attach(_EPopoverState state) => _state = state;

  void _detach(_EPopoverState state) {
    if (_state == state) _state = null;
  }
}

class _EPopoverState() extends State<EPopover> {
  final OverlayPortalController _portal = OverlayPortalController();

  bool get _open => _portal.isShowing;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(EPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller?._detach(this);
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    super.dispose();
  }

  void _show() {
    if (_portal.isShowing) return;
    _portal.show();
    setState(() {});
  }

  void _hide() {
    if (!_portal.isShowing) return;
    _portal.hide();
    setState(() {});
  }

  void _toggle() {
    if (_portal.isShowing) {
      _hide();
      return;
    }
    _show();
  }

  @override
  Widget build(BuildContext context) {
    final bool open = _open;
    final Widget trigger = widget.trigger(open, _toggle);
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _portal,
      overlayChildBuilder: (context, info) => _EPopoverOverlay(
        info: info,
        width: widget.width,
        onDismiss: _hide,
        panel: widget.panel,
      ),
      child: widget.triggerPaintsActive
          ? trigger
          : _activeTriggerPlate(open: open, child: trigger),
    );
  }

  Widget _activeTriggerPlate({required bool open, required Widget child}) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: EMotion.fast,
      curve: EMotion.curve,
      decoration: BoxDecoration(
        color: open
            ? accent.withValues(alpha: _PopoverChrome.activeFillAlpha)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(_PopoverChrome.activeRadius),
      ),
      child: open
          ? IconTheme.merge(
              data: IconThemeData(color: accent),
              child: child,
            )
          : child,
    );
  }
}

class const _EPopoverOverlay({
  required final OverlayChildLayoutInfo info,
  required final double width,
  required final VoidCallback onDismiss,
  required final Widget panel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Rect anchor = MatrixUtils.transformRect(
      info.childPaintTransform,
      Offset.zero & info.childSize,
    );
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        CustomSingleChildLayout(
          delegate: _PlaceAnchoredPanel(
            anchor: anchor,
            overlaySize: info.overlaySize,
            width: width,
            padding: mediaQuery.padding,
            viewInsets: mediaQuery.viewInsets,
          ),
          child: panel,
        ),
      ],
    );
  }
}

class const _PlaceAnchoredPanel({
  required final Rect anchor,
  required final Size overlaySize,
  required final double width,
  required final EdgeInsets padding,
  required final EdgeInsets viewInsets,
}) extends SingleChildLayoutDelegate {
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final _AnchorSlot slot = _slot();
    return BoxConstraints(
      minWidth: slot.width,
      maxWidth: slot.width,
      minHeight: 0,
      maxHeight: slot.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final _AnchorSlot slot = _slot();
    final Rect allowed = slot.allowed;
    var x = anchor.right - childSize.width;
    if (x < allowed.left) x = allowed.left;
    if (x + childSize.width > allowed.right) {
      x = allowed.right - childSize.width;
    }
    final double y = slot.below
        ? anchor.bottom + _PopoverChrome.gap
        : anchor.top - _PopoverChrome.gap - childSize.height;
    final double maxY = math.max(
      allowed.top,
      allowed.bottom - childSize.height,
    );
    return Offset(x, y.clamp(allowed.top, maxY));
  }

  @override
  bool shouldRelayout(_PlaceAnchoredPanel oldDelegate) {
    return anchor != oldDelegate.anchor ||
        overlaySize != oldDelegate.overlaySize ||
        width != oldDelegate.width ||
        padding != oldDelegate.padding ||
        viewInsets != oldDelegate.viewInsets;
  }

  _AnchorSlot _slot() {
    final Rect allowed = Rect.fromLTRB(
      padding.left + _PopoverChrome.margin,
      padding.top + _PopoverChrome.margin,
      overlaySize.width - padding.right - _PopoverChrome.margin,
      overlaySize.height -
          padding.bottom -
          viewInsets.bottom -
          _PopoverChrome.margin,
    );
    final double spaceBelow =
        allowed.bottom - anchor.bottom - _PopoverChrome.gap;
    final double spaceAbove = anchor.top - allowed.top - _PopoverChrome.gap;
    final bool below = spaceBelow >= spaceAbove;
    final double room = below ? spaceBelow : spaceAbove;
    return _AnchorSlot(
      below: below,
      maxHeight: math.max(0, room),
      width: math.min(width, allowed.width),
      allowed: allowed,
    );
  }
}

class const _AnchorSlot({
  required final bool below,
  required final double maxHeight,
  required final double width,
  required final Rect allowed,
});
