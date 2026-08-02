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
class ESegmentedControl extends StatelessWidget {
  const ESegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ESegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ESurface(
      kind: ESurfaceKind.inset,
      padding: const EdgeInsets.all(ELayout.spaceXs),
      borderRadius: ELayout.borderRadiusLg,
      child: Row(
        children: [
          for (var index = 0; index < segments.length; index++)
            Expanded(
              child: _SegmentButton(
                segment: segments[index],
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
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
    required this.onTap,
  });

  final ESegment segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: ELayout.borderRadiusMd,
        child: AnimatedContainer(
          duration: EMotion.standard,
          curve: EMotion.curve,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? EColors.accent.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: ELayout.borderRadiusMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                segment.icon,
                size: 18,
                color: selected ? EColors.accentGlow : EColors.textMuted,
              ),
              const SizedBox(width: ELayout.spaceSm),
              Flexible(
                child: Text(
                  segment.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EText.section.copyWith(
                    color: selected ? EColors.textPrimary : EColors.textMuted,
                  ),
                ),
              ),
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
