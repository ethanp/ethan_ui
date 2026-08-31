import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import 'e_surface.dart';

/// Standard screen shell: ambient metal backdrop + centered content column.
///
/// Domain screens supply [appBar] / [body] / [bottomBar] without re-stating
/// gradients or max-width constraints.
class const EScaffoldShell({
  super.key,
  required final Widget body,
  final PreferredSizeWidget? appBar,
  final Widget? bottomBar,
  final double contentMaxWidth = ELayout.contentMaxWidth,
  final Widget? floatingActionButton,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EColors.background,
      extendBody: bottomBar != null,
      appBar: appBar == null ? null : _FrostBehindAppBar(child: appBar!),
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

class const _FrostBehindAppBar({required final PreferredSizeWidget child})
    extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [const EFrostedFill(), child]);
  }
}
