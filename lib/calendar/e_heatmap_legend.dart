import 'package:flutter/material.dart';

import '../theme/e_heatmap_intensity.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_heatmap_scale.dart';

class const EHeatmapLegend({required final EHeatmapScale scale})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(scale.legendTitle, style: EText.caption),
        const SizedBox(height: ELayout.spaceSm),
        Row(
          children: [
            for (final level in EHeatmapIntensity.values)
              EHeatmapLegendSwatch(
                level: level,
                caption: scale.captionFor(level),
              ),
          ],
        ),
      ],
    );
  }
}
