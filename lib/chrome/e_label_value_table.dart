import 'package:flutter/material.dart';

import '../theme/e_layout.dart';

/// Rows of label → value (or a small control), held to a width where each
/// value stays next to its label. On a wide window the table sits at the
/// left instead of stretching labels and values to opposite edges.
class const ELabelValueTable({
  super.key,
  required final List<Widget> rows,
  final double maxWidth = ELayout.feedContentMaxWidth,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: rows,
        ),
      ),
    );
  }
}
