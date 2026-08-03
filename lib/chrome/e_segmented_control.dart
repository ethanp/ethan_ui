import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_motion.dart';
import '../theme/e_text.dart';
import 'e_surface.dart';

class ESegment {
  const ESegment({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Compact frosted segmented control for companion chrome.
///
/// When [expand] is true (default), segments share the parent width equally —
/// use in bottom bars. When false, the control sizes to its labels.
class ESegmentedControl extends StatelessWidget {
  const ESegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
    this.expand = true,
  });

  final List<ESegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// If true, segments expand equally to fill the parent. If false, each
  /// segment sizes to its icon + label.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return ESurface(
      kind: ESurfaceKind.inset,
      padding: const EdgeInsets.all(ELayout.spaceXs),
      borderRadius: ELayout.borderRadiusLg,
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var index = 0; index < segments.length; index++)
            if (expand)
              Expanded(
                child: _SegmentButton(
                  segment: segments[index],
                  selected: selectedIndex == index,
                  expand: true,
                  onTap: () => onSelected(index),
                ),
              )
            else
              _SegmentButton(
                segment: segments[index],
                selected: selectedIndex == index,
                expand: false,
                onTap: () => onSelected(index),
              ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.segment,
    required this.selected,
    required this.expand,
    required this.onTap,
  });

  final ESegment segment;
  final bool selected;
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      segment.label,
      maxLines: 1,
      softWrap: false,
      overflow: expand ? TextOverflow.ellipsis : TextOverflow.visible,
      style: EText.section.copyWith(
        color: selected ? EColors.textPrimary : EColors.textMuted,
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: ELayout.borderRadiusMd,
        child: AnimatedContainer(
          duration: EMotion.standard,
          curve: EMotion.curve,
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? EColors.accent.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: ELayout.borderRadiusMd,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                segment.icon,
                size: 18,
                color: selected ? EColors.accentGlow : EColors.textMuted,
              ),
              const SizedBox(width: ELayout.spaceSm),
              if (expand) Flexible(child: label) else label,
            ],
          ),
        ),
      ),
    );
  }
}

/// Frosted bottom chrome wrapping a centered [ESegmentedControl].
class EFrostedBottomBar extends StatelessWidget {
  const EFrostedBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EFrostedFill(
      edge: EFrostEdge.bottom,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: child,
        ),
      ),
    );
  }
}
