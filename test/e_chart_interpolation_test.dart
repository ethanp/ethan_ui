import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MonotoneCubic', () {
    test('fewer than 3 points falls back to the polyline', () {
      final two = [const Offset(0, 0), const Offset(10, 8)];
      expect(MonotoneCubic.tryFit(two), isNull);
      expect(MonotoneCubic.yAtX(two, 5), 4);
      expect(MonotoneCubic.yAtX([const Offset(3, 9)], 100), 9);
    });

    test('output passes through every supplied point', () {
      final offsets = [
        const Offset(0, 0),
        const Offset(4, 3),
        const Offset(10, 1),
        const Offset(16, 8),
      ];
      final fit = MonotoneCubic.tryFit(offsets);
      expect(fit, isNotNull);
      for (final offset in offsets) {
        expect(fit!.yAtX(offset.dx), closeTo(offset.dy, 1e-9));
      }
    });

    test('monotone increasing input does not overshoot local extrema', () {
      final offsets = [
        const Offset(0, 0),
        const Offset(2, 1),
        const Offset(5, 4),
        const Offset(9, 4.5),
        const Offset(14, 10),
      ];
      _expectNoLocalOvershoot(offsets);
    });

    test('monotone decreasing input does not overshoot local extrema', () {
      final offsets = [
        const Offset(0, 20),
        const Offset(3, 14),
        const Offset(7, 9),
        const Offset(12, 8),
        const Offset(18, 1),
      ];
      _expectNoLocalOvershoot(offsets);
    });

    test('flat sections remain flat', () {
      final offsets = [
        const Offset(0, 5),
        const Offset(4, 5),
        const Offset(8, 5),
        const Offset(12, 5),
      ];
      final fit = MonotoneCubic.tryFit(offsets);
      expect(fit, isNotNull);
      for (var sampleX = 0.0; sampleX <= 12; sampleX += 0.25) {
        expect(fit!.yAtX(sampleX), closeTo(5, 1e-9));
      }
    });

    test('duplicate or non-increasing X falls back to the polyline', () {
      final duplicateX = [
        const Offset(0, 0),
        const Offset(4, 2),
        const Offset(4, 9),
        const Offset(8, 3),
      ];
      expect(MonotoneCubic.tryFit(duplicateX), isNull);
      expect(MonotoneCubic.yAtX(duplicateX, 4), 2);

      final decreasingX = [
        const Offset(0, 0),
        const Offset(6, 4),
        const Offset(3, 8),
        const Offset(10, 1),
      ];
      expect(MonotoneCubic.tryFit(decreasingX), isNull);
      expect(
        MonotoneCubic.yAtX(decreasingX, 3),
        EChartInterpolation.polylineYAtX(decreasingX, 3),
      );
    });

    test('extreme slope ratios stay finite', () {
      final offsets = [
        const Offset(0, 0),
        const Offset(1e-9, 1e9),
        const Offset(1, 1e9 + 1e-9),
        const Offset(2, 0),
      ];
      final y = MonotoneCubic.yAtX(offsets, 0.5);
      expect(y.isFinite, isTrue);
      expect(y.isNaN, isFalse);
    });

    test('generated monotone sequences never overshoot or produce NaN', () {
      for (var length = 3; length <= 12; length++) {
        for (final decreasing in [false, true]) {
          final offsets = [
            for (var index = 0; index < length; index++)
              Offset(
                index * 3.0 + (index.isOdd ? 0.5 : 0),
                decreasing ? (length - 1 - index) * 2.0 : index * (index + 2.0),
              ),
          ];
          _expectNoLocalOvershoot(offsets);
          final midX = (offsets.first.dx + offsets.last.dx) / 2;
          final midY = MonotoneCubic.yAtX(offsets, midX);
          expect(midY.isFinite, isTrue);
          expect(midY.isNaN, isFalse);
        }
      }
    });
  });
}

void _expectNoLocalOvershoot(List<Offset> offsets) {
  final fit = MonotoneCubic.tryFit(offsets);
  expect(fit, isNotNull);
  for (var index = 0; index < offsets.length - 1; index++) {
    final left = offsets[index];
    final right = offsets[index + 1];
    final lo = left.dy < right.dy ? left.dy : right.dy;
    final hi = left.dy > right.dy ? left.dy : right.dy;
    for (var step = 0; step <= 20; step++) {
      final t = step / 20;
      final x = left.dx + (right.dx - left.dx) * t;
      final y = fit!.yAtX(x);
      expect(y.isFinite, isTrue);
      expect(y, greaterThanOrEqualTo(lo - 1e-9));
      expect(y, lessThanOrEqualTo(hi + 1e-9));
    }
  }
}
