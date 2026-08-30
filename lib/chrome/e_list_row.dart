import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import 'e_surface.dart';

/// Default list-row shell: leading identity | trailing actions.
///
/// Prefer this over hand-rolling [ESurfaceKind.row] + flex splits so identity
/// and action clusters stay evenly centered and spaced.
///
/// When [leadingWidth] is set, leading is fixed and [trailing] expands (dense
/// identity + action cluster). Otherwise leading expands and trailing sizes
/// intrinsically (e.g. label name + count).
class const EListRow({
  super.key,
  required final Widget leading,
  required final Widget trailing,
  final bool attention = false,
  final VoidCallback? onActivated,
  final EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(14, 12, 14, 12),

  /// When set, pins [leading] to a fixed width (e.g. [ELayout.listRowLeadingWidth]).
  final double? leadingWidth,
  final double gap = ELayout.spaceLg,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ESurface(
      kind: ESurfaceKind.row,
      attention: attention,
      onActivated: onActivated,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingWidth != null) ...[
            SizedBox(width: leadingWidth, child: leading),
            SizedBox(width: gap),
            Expanded(child: trailing),
          ] else ...[
            Expanded(child: leading),
            SizedBox(width: gap),
            trailing,
          ],
        ],
      ),
    );
  }
}
