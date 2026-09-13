import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixed = EFixedThresholdHeatmapScale(
    legendTitle: 'Aerobic load · cardio Z2–5 minutes',
    bands: const [
      EHeatmapBand(upperBound: 0, caption: '0'),
      EHeatmapBand(upperBound: 15, caption: '1–15m'),
      EHeatmapBand(upperBound: 30, caption: '16–30m'),
      EHeatmapBand(upperBound: 45, caption: '31–45m'),
      EHeatmapBand(upperBound: double.infinity, caption: '46m+'),
    ],
  );

  group('EFixedThresholdHeatmapScale', () {
    test('maps every inclusive boundary onto the named band', () {
      expect(fixed.levelFor(0), EHeatmapIntensity.none);
      expect(fixed.levelFor(1), EHeatmapIntensity.low);
      expect(fixed.levelFor(15), EHeatmapIntensity.low);
      expect(fixed.levelFor(16), EHeatmapIntensity.mid);
      expect(fixed.levelFor(30), EHeatmapIntensity.mid);
      expect(fixed.levelFor(31), EHeatmapIntensity.high);
      expect(fixed.levelFor(45), EHeatmapIntensity.high);
      expect(fixed.levelFor(46), EHeatmapIntensity.peak);
    });

    test('clamps negatives to the zero band and overflow to the last band', () {
      expect(fixed.levelFor(-12), EHeatmapIntensity.none);
      expect(fixed.levelFor(400), EHeatmapIntensity.peak);
      expect(fixed.intensityFor(46), 1);
      expect(fixed.intensityFor(400), 1);
    });

    test('uses the exact band captions', () {
      expect(fixed.captionFor(EHeatmapIntensity.none), '0');
      expect(fixed.captionFor(EHeatmapIntensity.low), '1–15m');
      expect(fixed.captionFor(EHeatmapIntensity.mid), '16–30m');
      expect(fixed.captionFor(EHeatmapIntensity.high), '31–45m');
      expect(fixed.captionFor(EHeatmapIntensity.peak), '46m+');
    });
  });

  group('EPeriodQuartileHeatmapScale', () {
    test('empty observations are none for any quantity', () {
      final scale = EPeriodQuartileHeatmapScale(
        observedQuantities: const [0, 0],
        legendTitle: 'uses/day · period quartiles',
        captionForQuantity: (quantity) => '≤${quantity.round()}',
      );
      expect(scale.levelFor(0), EHeatmapIntensity.none);
      expect(scale.levelFor(9), EHeatmapIntensity.none);
      expect(scale.captionFor(EHeatmapIntensity.none), '≤0');
      expect(scale.captionFor(EHeatmapIntensity.peak), '≤0');
    });

    test('splits observed days into equal-count bands with cell-unit captions', () {
      final scale = EPeriodQuartileHeatmapScale(
        observedQuantities: const [1, 2, 3, 4, 5, 6, 7, 8],
        legendTitle: 'uses/day · period quartiles',
        captionForQuantity: (quantity) => '≤${quantity.round()}',
      );
      expect(scale.levelFor(0), EHeatmapIntensity.none);
      expect(scale.levelFor(1), EHeatmapIntensity.low);
      expect(scale.levelFor(2), EHeatmapIntensity.low);
      expect(scale.levelFor(3), EHeatmapIntensity.mid);
      expect(scale.levelFor(4), EHeatmapIntensity.mid);
      expect(scale.levelFor(5), EHeatmapIntensity.high);
      expect(scale.levelFor(6), EHeatmapIntensity.high);
      expect(scale.levelFor(7), EHeatmapIntensity.peak);
      expect(scale.levelFor(8), EHeatmapIntensity.peak);
      expect(scale.captionFor(EHeatmapIntensity.none), '≤0');
      expect(scale.captionFor(EHeatmapIntensity.low), '≤2');
      expect(scale.captionFor(EHeatmapIntensity.mid), '≤4');
      expect(scale.captionFor(EHeatmapIntensity.high), '≤6');
      expect(scale.captionFor(EHeatmapIntensity.peak), '≤8');
    });

    test('shades lerp toward either side of their quartile', () {
      final scale = EPeriodQuartileHeatmapScale(
        observedQuantities: const [400, 500, 600, 700, 800, 900],
        legendTitle: 'dosage · period quartiles',
        captionForQuantity: (quantity) => '${quantity.round()}',
      );
      expect(scale.intensityFor(400), lessThan(scale.intensityFor(500)));
      expect(scale.intensityFor(500), lessThan(scale.intensityFor(600)));
      expect(scale.intensityFor(700), lessThan(scale.intensityFor(800)));
      expect(scale.intensityFor(800), lessThan(scale.intensityFor(900)));
      expect(
        scale.intensityFor(500) - scale.intensityFor(400),
        lessThan(scale.intensityFor(900) - scale.intensityFor(400)),
      );
    });

    test('period max is always peak even when it equals the 75th percentile', () {
      final scale = EPeriodQuartileHeatmapScale(
        observedQuantities: const [10, 20, 20, 30, 30, 40, 40, 40],
        legendTitle: 'dosage · period quartiles',
        captionForQuantity: (quantity) => '${quantity.round()}mg',
      );
      expect(scale.captionFor(EHeatmapIntensity.high), '40mg');
      expect(scale.captionFor(EHeatmapIntensity.peak), '40mg');
      expect(scale.levelFor(40), EHeatmapIntensity.peak);
      expect(scale.intensityFor(40), 1);
      expect(scale.intensityFor(30), lessThan(1));
      expect(scale.intensityFor(10), greaterThan(0));
    });

    test('does not use fraction of the period max', () {
      final scale = EPeriodQuartileHeatmapScale(
        observedQuantities: const [10, 11, 12, 13, 14, 15, 16, 40],
        legendTitle: 'Daily library-progress change · period quartiles',
        captionForQuantity: (quantity) => '≤${quantity.round()}pp',
      );
      expect(scale.levelFor(10), EHeatmapIntensity.low);
      expect(scale.levelFor(16), EHeatmapIntensity.peak);
      expect(scale.levelFor(40), EHeatmapIntensity.peak);
      expect(scale.captionFor(EHeatmapIntensity.low), '≤11pp');
      expect(scale.captionFor(EHeatmapIntensity.mid), '≤13pp');
      expect(scale.captionFor(EHeatmapIntensity.high), '≤15pp');
      expect(scale.captionFor(EHeatmapIntensity.peak), '≤40pp');
    });
  });
}
