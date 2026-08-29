import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/e_colors.dart';

class ETab {
  const ETab({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class ETabBar extends StatelessWidget {
  const ETabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const height = 56.0;
  static const bottomPadding = 10.0;
  static const occupiedHeight = height + bottomPadding;
  static const iconSize = 30.0;

  final List<ETab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: EColors.frostFill,
              border: Border(
                top: BorderSide(
                  color: EColors.border.withValues(alpha: 0.45),
                  width: 0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: bottomPadding),
              child: SizedBox(
                height: height,
                child: Row(
                children: [
                  for (var tabIndex = 0; tabIndex < tabs.length; tabIndex++)
                    Expanded(
                      child: _ETabButton(
                        tab: tabs[tabIndex],
                        selected: tabIndex == selectedIndex,
                        onSelected: () => onSelected(tabIndex),
                      ),
                    ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ETabButton extends StatelessWidget {
  const _ETabButton({
    required this.tab,
    required this.selected,
    required this.onSelected,
  });

  final ETab tab;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? EColors.accent : EColors.textMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelected,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Center(
              child: Icon(tab.icon, size: ETabBar.iconSize, color: color),
            ),
          ),
          Text(
            tab.label,
            style: TextStyle(
              inherit: false,
              fontFamily: 'CupertinoSystemText',
              fontFamilyFallback: const ['.AppleSystemUIFont', '.SF Pro Text'],
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.24,
              height: 1,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
