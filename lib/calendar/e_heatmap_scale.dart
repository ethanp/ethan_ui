import '../theme/e_heatmap_intensity.dart';

abstract interface class EHeatmapScale() {
  EHeatmapIntensity levelFor(num quantity);

  /// 0..1 along the brass stops, lerping inside the named band.
  double intensityFor(num quantity);

  String captionFor(EHeatmapIntensity level);

  String get legendTitle;
}

class const EHeatmapBand({
  required final num upperBound,
  required final String caption,
});

class EFixedThresholdHeatmapScale({
  @override required final String legendTitle,
  required final List<EHeatmapBand> bands,
}) implements EHeatmapScale {
  @override
  EHeatmapIntensity levelFor(num quantity) {
    if (bands.length != EHeatmapIntensity.values.length) {
      throw StateError(
        'EFixedThresholdHeatmapScale needs exactly '
        '${EHeatmapIntensity.values.length} bands',
      );
    }
    final clamped = quantity < 0 ? 0 : quantity;
    for (var bandIndex = 0; bandIndex < bands.length; bandIndex++) {
      if (clamped <= bands[bandIndex].upperBound) {
        return EHeatmapIntensity.values[bandIndex];
      }
    }
    return EHeatmapIntensity.values.last;
  }

  @override
  double intensityFor(num quantity) {
    if (bands.length != EHeatmapIntensity.values.length) {
      throw StateError(
        'EFixedThresholdHeatmapScale needs exactly '
        '${EHeatmapIntensity.values.length} bands',
      );
    }
    if (quantity <= 0) return 0;
    var fromBound = 0.0;
    var fromIntensity = 0.0;
    for (var bandIndex = 1; bandIndex < bands.length; bandIndex++) {
      final toBound = bands[bandIndex].upperBound;
      final toIntensity = EHeatmapIntensity.values[bandIndex].percentOfMax / 100;
      if (!toBound.isFinite) return toIntensity;
      if (quantity <= toBound) {
        return EHeatmapIntensity.intensityBetweenBounds(
          quantity: quantity,
          fromBound: fromBound,
          toBound: toBound,
          fromIntensity: fromIntensity,
          toIntensity: toIntensity,
        );
      }
      fromBound = toBound.toDouble();
      fromIntensity = toIntensity;
    }
    return 1;
  }

  @override
  String captionFor(EHeatmapIntensity level) => bands[level.index].caption;
}

class EPeriodQuartileHeatmapScale({
  required final Iterable<num> observedQuantities,
  @override required final String legendTitle,
  required final String Function(num quantity) captionForQuantity,
}) implements EHeatmapScale {
  final List<num> _positiveSorted = [
    for (final quantity in observedQuantities)
      if (quantity > 0) quantity,
  ]..sort();

  @override
  EHeatmapIntensity levelFor(num quantity) {
    if (quantity <= 0 || _positiveSorted.isEmpty) return EHeatmapIntensity.none;
    if (quantity >= _quartileUpperBound(100)) return EHeatmapIntensity.peak;
    if (quantity <= _quartileUpperBound(25)) return EHeatmapIntensity.low;
    if (quantity <= _quartileUpperBound(50)) return EHeatmapIntensity.mid;
    if (quantity <= _quartileUpperBound(75)) return EHeatmapIntensity.high;
    return EHeatmapIntensity.peak;
  }

  @override
  double intensityFor(num quantity) {
    if (quantity <= 0 || _positiveSorted.isEmpty) return 0;
    if (quantity >= _quartileUpperBound(100)) return 1;
    final bounds = <double>[];
    final intensities = <double>[];
    _addUniqueStop(bounds, intensities, 0, 0);
    _addUniqueStop(bounds, intensities, _quartileUpperBound(25).toDouble(), 0.25);
    _addUniqueStop(bounds, intensities, _quartileUpperBound(50).toDouble(), 0.50);
    _addUniqueStop(bounds, intensities, _quartileUpperBound(75).toDouble(), 0.75);
    _addUniqueStop(bounds, intensities, _quartileUpperBound(100).toDouble(), 1);
    var fromBound = bounds.first;
    var fromIntensity = intensities.first;
    for (var stopIndex = 1; stopIndex < bounds.length; stopIndex++) {
      if (quantity <= bounds[stopIndex]) {
        return EHeatmapIntensity.intensityBetweenBounds(
          quantity: quantity,
          fromBound: fromBound,
          toBound: bounds[stopIndex],
          fromIntensity: fromIntensity,
          toIntensity: intensities[stopIndex],
        );
      }
      fromBound = bounds[stopIndex];
      fromIntensity = intensities[stopIndex];
    }
    return 1;
  }

  static void _addUniqueStop(
    List<double> bounds,
    List<double> intensities,
    double bound,
    double intensity,
  ) {
    if (bounds.isEmpty || bound > bounds.last) {
      bounds.add(bound);
      intensities.add(intensity);
      return;
    }
    if (intensity > intensities.last) intensities.last = intensity;
  }

  @override
  String captionFor(EHeatmapIntensity level) =>
      captionForQuantity(_boundFor(level));

  num _boundFor(EHeatmapIntensity level) => switch (level) {
    EHeatmapIntensity.none => 0,
    EHeatmapIntensity.low => _quartileUpperBound(25),
    EHeatmapIntensity.mid => _quartileUpperBound(50),
    EHeatmapIntensity.high => _quartileUpperBound(75),
    EHeatmapIntensity.peak => _quartileUpperBound(100),
  };

  num _quartileUpperBound(int percentile) {
    final sorted = _positiveSorted;
    if (sorted.isEmpty) return 0;
    final rank = (percentile / 100 * sorted.length).ceil().clamp(
      1,
      sorted.length,
    );
    return sorted[rank - 1];
  }
}
