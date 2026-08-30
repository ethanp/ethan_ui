import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/e_colors.dart';

class const ETab({required final IconData icon, required final String label});

class const ETabBar({
  super.key,
  required final List<ETab> tabs,
  required final int selectedIndex,
  required final ValueChanged<int> onSelected,
}) extends StatelessWidget {
  static const height = 56.0;
  static const bottomPadding = 10.0;
  static const occupiedHeight = height + bottomPadding;
  static const iconSize = 30.0;

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

class const _ETabButton({
  required final ETab tab,
  required final bool selected,
  required final VoidCallback onSelected,
}) extends StatelessWidget {
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
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
