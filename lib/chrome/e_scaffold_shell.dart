import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import 'e_overlaid_tab_bar.dart';
import 'e_surface.dart';
import 'e_tab_bar.dart';

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
                    child: _bodyWithOverlaidTabBar(context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyWithOverlaidTabBar(BuildContext context) {
    if (bottomBar == null) return body;
    final MediaQueryData media = MediaQuery.of(context);
    final double bottomInset = media.padding.bottom > ETabBar.occupiedHeight
        ? media.padding.bottom
        : ETabBar.occupiedHeight;
    return EOverlaidTabBar(
      height: ETabBar.occupiedHeight,
      child: MediaQuery(
        data: media.copyWith(
          padding: media.padding.copyWith(bottom: bottomInset),
        ),
        child: body,
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
