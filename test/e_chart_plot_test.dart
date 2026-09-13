import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EChartPlot', () {
    final plot = EChartPlot(
      size: const Size(400, 200),
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 1, 11),
      valueScale: EChartValueScale.fixed(
        min: 0,
        max: 100,
        ticks: const [0, 50, 100],
      ),
      leftPadding: 40,
      rightPadding: 10,
      topPadding: 10,
      bottomPadding: 20,
    );

    test('maps dates to x and back', () {
      expect(plot.left, 40);
      expect(plot.right, 390);
      expect(plot.xForDate(DateTime(2026, 1, 1)), plot.left);
      expect(plot.xForDate(DateTime(2026, 1, 11)), plot.right);
      expect(plot.dateForX(plot.left), DateTime(2026, 1, 1));
      expect(plot.dateForX(plot.right), DateTime(2026, 1, 11));
    });

    test('maps values to y', () {
      expect(plot.yForValue(0), plot.bottom);
      expect(plot.yForValue(100), plot.top);
      expect(plot.yForValue(50), closeTo((plot.top + plot.bottom) / 2, 0.001));
      expect(plot.valueForY(plot.bottom), 0);
      expect(plot.valueForY(plot.top), 100);
    });

    test('contains is the plot rectangle', () {
      expect(plot.contains(Offset(plot.left, plot.top)), isTrue);
      expect(plot.contains(Offset(plot.left - 1, plot.top)), isFalse);
    });
  });

  group('EChartValueScale', () {
    test('nice value scale covers data max', () {
      final scale = EChartValueScale.nice(80);
      expect(scale.max >= 80, isTrue);
      expect(scale.ticks.first, 0);
      expect(scale.ticks.last, scale.max);
      expect(scale.caption(25), '25');
    });

    test('fixed ticks keep a suffix', () {
      final scale = EChartValueScale.fixed(
        min: 0,
        max: 100,
        ticks: const [0, 25, 50, 75, 100],
        tickSuffix: '%',
      );
      expect(scale.caption(25), '25%');
    });
  });

  group('EChartHitTest', () {
    test('nearest point wins by pixel distance and returns stamped ids', () {
      final plot = EChartPlot(
        size: const Size(400, 220),
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 3),
        valueScale: EChartValueScale.fixed(
          min: 0,
          max: 100,
          ticks: const [0, 100],
        ),
      );
      final low = EChartPoint(date: DateTime(2026, 1, 2), value: 10, id: 'low');
      final high = EChartPoint(
        date: DateTime(2026, 1, 2),
        value: 90,
        id: 'high',
      );
      final hit = EChartHitTest(
        plot: plot,
        series: [
          EChartSeries.dots(id: 'lows', points: [low]),
          EChartSeries.dots(id: 'highs', points: [high]),
        ],
      );
      final nearHigh = hit.nearestPoint(
        Offset(plot.xForDate(high.date), plot.yForValue(high.value) + 4),
      );
      expect(nearHigh?.pointId, 'high');
      expect(nearHigh?.seriesId, 'highs');
      expect(nearHigh?.value, 90);
    });

    test('non-interactive projection series are ignored', () {
      final plot = EChartPlot(
        size: const Size(400, 220),
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 3),
        valueScale: EChartValueScale.fixed(
          min: 0,
          max: 100,
          ticks: const [0, 100],
        ),
      );
      final loggedPoint = EChartPoint(
        date: DateTime(2026, 1, 2),
        value: 40,
        id: 'logged',
      );
      final projectedPoint = EChartPoint(
        date: DateTime(2026, 1, 2),
        value: 42,
        id: 'projected',
      );
      final hit =
          EChartHitTest(
            plot: plot,
            series: [
              EChartSeries.dots(id: 'logged', points: [loggedPoint]),
              EChartSeries.line(
                id: 'projected',
                points: [projectedPoint],
                hits: EChartPointHits.ignore,
              ),
            ],
          ).nearestPoint(
            Offset(
              plot.xForDate(projectedPoint.date),
              plot.yForValue(projectedPoint.value),
            ),
          );

      expect(hit?.pointId, 'logged');
      expect(hit?.seriesId, 'logged');
    });

    test(
      'selection equality is by series and point id, not object identity',
      () {
        final first = EChartSelectedPoint(
          seriesId: 'events',
          pointId: 7,
          date: DateTime(2026, 1, 2),
          value: 40,
        );
        final rebuilt = EChartSelectedPoint(
          seriesId: 'events',
          pointId: 7,
          date: DateTime(2026, 1, 2),
          value: 40,
        );
        expect(first, rebuilt);
        expect(
          first,
          isNot(
            EChartSelectedPoint(
              seriesId: 'events',
              pointId: 8,
              date: DateTime(2026, 1, 2),
              value: 40,
            ),
          ),
        );
      },
    );
  });
}
