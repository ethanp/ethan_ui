import 'package:flutter/material.dart';

import '../theme/e_layout.dart';
import 'e_surface.dart';

/// Default list-row shell: leading identity | trailing actions.
///
/// Prefer this over hand-rolling [ESurfaceKind.row] + flex splits so identity
/// and action clusters stay evenly centered and spaced.
class EListRow extends StatelessWidget {
  const EListRow({
    super.key,
    required this.leading,
    required this.trailing,
    this.attention = false,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 12),
    this.leadingWidth,
    this.gap = ELayout.spaceLg,
  });

  final Widget leading;
  final Widget trailing;
  final bool attention;
  final EdgeInsetsGeometry padding;

  /// When set, pins [leading] to a fixed width (e.g. [ELayout.listRowLeadingWidth]).
  final double? leadingWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return ESurface(
      kind: ESurfaceKind.row,
      attention: attention,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingWidth != null)
            SizedBox(width: leadingWidth, child: leading)
          else
            leading,
          SizedBox(width: gap),
          Expanded(child: trailing),
        ],
      ),
    );
  }
}
