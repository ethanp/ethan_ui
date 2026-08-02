import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import 'e_surface.dart';

/// Standard screen shell: ambient metal backdrop + centered content column.
///
/// Domain screens supply [appBar] / [body] / [bottomBar] without re-stating
/// gradients or max-width constraints.
class EScaffoldShell extends StatelessWidget {
  const EScaffoldShell({
    super.key,
    required this.body,
    this.appBar,
    this.bottomBar,
    this.contentMaxWidth = ELayout.contentMaxWidth,
    this.floatingActionButton,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomBar;
  final double contentMaxWidth;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EColors.background,
      appBar: appBar == null ? null : _FrostedPreferredSize(child: appBar!),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: EColors.scaffoldGradient),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 240,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: EColors.ambientGlowGradient,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentMaxWidth,
                      minHeight: constraints.maxHeight,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: body,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrostedPreferredSize extends StatelessWidget
    implements PreferredSizeWidget {
  const _FrostedPreferredSize({required this.child});

  final PreferredSizeWidget child;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Stack(
        fit: StackFit.expand,
        children: [const EFrostedFill(), child],
      ),
    );
  }
}
