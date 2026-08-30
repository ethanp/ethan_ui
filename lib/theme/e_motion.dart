import 'package:flutter/material.dart';

/// Shared motion tokens — keep domain UI free of magic durations.
abstract final class EMotion() {
  static const fast = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 200);
  static const emphasized = Duration(milliseconds: 280);

  static const curve = Curves.easeOutCubic;
  static const curveEmphasized = Curves.easeOutBack;
}
