import 'package:flutter/material.dart';

import 'e_colors.dart';

/// Sequential activity heat on dark metal: graphite → bronze → brass → lamp gold.
///
/// One warm-metal family, even lightness and opacity steps. Peak fill is 0.7
/// opaque. Colors live on each constant (Bloch-style). [colorAt] lerps adjacent
/// stops; calendars pass [EHeatmapScale.intensityFor] so values move toward
/// either side of their band.
enum EHeatmapIntensity({
  required final Color color,
  required final Color ink,
  required final int percentOfMax,
}) {
  none(color: Color(0xFF252A3A), ink: EColors.textMuted, percentOfMax: 0),
  low(color: Color(0x40534A32), ink: EColors.textPrimary, percentOfMax: 25),
  mid(color: Color(0x669A8440), ink: EColors.textPrimary, percentOfMax: 50),
  high(color: Color(0x8CD4B84C), ink: EColors.surfaceInset, percentOfMax: 75),
  peak(color: Color(0xB3F3E07A), ink: EColors.surfaceInset, percentOfMax: 100);

  String get percentOfMaxLabel => upperBoundCaption(percentOfMax);

  int quantityAtMax(num max) => (percentOfMax / 100.0 * max).round();

  String upperBoundCaption(num quantity) {
    if (this == none) return '0%';
    return '≤${quantity.round()}%';
  }

  static BorderSide get cellHairline => BorderSide(
    color: EColors.borderStrong.withValues(alpha: 0.45),
    width: 1,
  );

  static const Color todayRing = Color(0xFF9E9464);

  static EHeatmapIntensity nearest(double intensity) {
    final index = (intensity.clamp(0.0, 1.0) * (values.length - 1)).round();
    return values[index];
  }

  static double intensityBetweenBounds({
    required num quantity,
    required num fromBound,
    required num toBound,
    required double fromIntensity,
    required double toIntensity,
  }) {
    if (toBound <= fromBound) return toIntensity;
    final t = ((quantity - fromBound) / (toBound - fromBound)).clamp(0.0, 1.0);
    return fromIntensity + (toIntensity - fromIntensity) * t;
  }

  static Color colorAt(double intensity) {
    final scaled = intensity.clamp(0.0, 1.0) * (values.length - 1);
    final lowerIndex = scaled.floor();
    final upperIndex = scaled.ceil();
    return Color.lerp(
      values[lowerIndex].color,
      values[upperIndex].color,
      scaled - lowerIndex,
    )!;
  }

  static Color inkAt(double intensity) => nearest(intensity).ink;
}

class const EHeatmapLegendSwatch({
  required final EHeatmapIntensity level,
  final String? caption,
}) extends StatelessWidget {
  static const _width = 32.0;
  static const _height = 18.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: level.color,
        borderRadius: BorderRadius.circular(2),
        border: Border.fromBorderSide(EHeatmapIntensity.cellHairline),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          caption ?? level.percentOfMaxLabel,
          style: TextStyle(
            fontSize: 8,
            height: 1,
            fontWeight: FontWeight.w600,
            color: level.ink,
          ),
        ),
      ),
    );
  }
}
