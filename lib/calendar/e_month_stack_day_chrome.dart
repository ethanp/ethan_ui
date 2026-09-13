import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_heatmap_intensity.dart';
import 'e_calendar_day_presentation.dart';
import 'e_month_stack_metrics.dart';

class const EMonthStackDayChrome({
  super.key,
  required final ECalendarDayPresentation<dynamic> presentation,
  required final double cellSize,
  required final bool isToday,
  required final bool isSelected,
  required final bool showsMultiSelectCheck,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final visual = presentation.visual;
    return Container(
      width: cellSize,
      height: cellSize,
      margin: const EdgeInsets.all(EMonthStackMetrics.cellMargin),
      decoration: BoxDecoration(
        color: isSelected
            ? EColors.accent.withValues(alpha: 0.25)
            : visual.fill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? EColors.accent
              : isToday
              ? EHeatmapIntensity.todayRing
              : visual is ECalendarDayEmpty
              ? EHeatmapIntensity.cellHairline.color
              : visual.fill.withValues(alpha: 0.6),
          width: isSelected
              ? 2
              : isToday
              ? 1.5
              : EHeatmapIntensity.cellHairline.width,
        ),
        boxShadow: visual.showsMeasuredGlow && !isSelected
            ? [
                BoxShadow(
                  color: visual.fill.withValues(alpha: 0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: showsMultiSelectCheck
          ? const Center(
              child: Icon(Icons.check, size: 16, color: EColors.accent),
            )
          : _labels(visual),
    );
  }

  Widget _labels(ECalendarDayVisual visual) {
    return Stack(
      children: [
        Positioned(
          left: 3,
          top: 2,
          child: Text(
            presentation.dayNumberLabel,
            style: TextStyle(
              fontSize: visual is ECalendarDayEmpty ? 11 : 8,
              fontWeight: FontWeight.w500,
              color: visual.ink.withValues(
                alpha: visual is ECalendarDayEmpty ? 1 : 0.7,
              ),
            ),
          ),
        ),
        if (presentation.secondaryLabel != null)
          Positioned(
            right: 2,
            top: 12,
            child: Text(
              presentation.secondaryLabel!,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: visual.ink,
              ),
            ),
          ),
        if (presentation.markers.isNotEmpty)
          Positioned(
            left: 2,
            bottom: 2,
            child: Row(
              children: [
                for (final marker in presentation.markers)
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Text(
                      marker.label[0],
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: visual.ink.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
