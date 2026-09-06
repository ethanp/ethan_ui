import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_text.dart';
import 'e_status_chip.dart';

/// How far through a thing: optional labels plus a hairline track.
///
/// Not a nested card — sit this on the parent surface with type and spacing.
class const EProgressMeter({
  required final double value,
  final String? leadingLabel,
  final String? trailingLabel,
  final EStatusTone tone = EStatusTone.success,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leadingLabel != null || trailingLabel != null) ...[
          _labels(),
          const SizedBox(height: 4),
        ],
        _track(),
      ],
    );
  }

  Widget _labels() {
    return Row(
      children: [
        if (leadingLabel != null)
          Text(
            leadingLabel!,
            style: EText.caption.copyWith(
              color: tone.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        const Spacer(),
        if (trailingLabel != null)
          Flexible(
            child: Text(
              trailingLabel!,
              style: EText.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }

  Widget _track() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 5,
        backgroundColor: EColors.surfaceRaised,
        valueColor: AlwaysStoppedAnimation<Color>(tone.foreground),
      ),
    );
  }
}
