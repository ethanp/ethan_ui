import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_text.dart';
import 'e_calendar_day_presentation.dart';

class const EMonthStackPeriodSummary({
  required final ECalendarPeriodPresentation presentation,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${presentation.activeDays}',
                textAlign: TextAlign.center,
                style: EText.caption.copyWith(
                  color: EColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              Text(
                presentation.activeDays == 1 ? 'day' : 'days',
                textAlign: TextAlign.center,
                style: EText.caption.copyWith(
                  color: EColors.textMuted,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        if (presentation.measureCaption != null) ...[
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              presentation.measureCaption!,
              style: EText.caption.copyWith(fontSize: 10),
            ),
          ),
        ],
      ],
    );
  }
}
