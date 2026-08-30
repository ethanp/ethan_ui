import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

class const EEmptyState({
  super.key,
  required final String title,
  required final String message,
  final IconData? icon,
  final Widget? action,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ELayout.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(ELayout.spaceXl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EColors.accent.withValues(alpha: 0.1),
                      EColors.accent.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: ELayout.borderRadiusXl,
                ),
                child: Icon(icon, size: 48, color: EColors.accent),
              ),
              const SizedBox(height: ELayout.spaceXl),
            ],
            Text(
              title,
              style: EText.headline.medium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ELayout.spaceLg),
            Text(
              message,
              style: EText.body.medium,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: ELayout.spaceXl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class const ELoadingState({super.key, final String? message})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ELayout.spaceXl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EColors.accent.withValues(alpha: 0.1),
                  EColors.accent.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: ELayout.borderRadiusXl,
            ),
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: ELayout.spaceLg),
            Text(
              message!,
              style: EText.body.medium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
