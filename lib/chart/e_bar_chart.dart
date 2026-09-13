import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_chart_value_scale.dart';
import 'e_chart_y_labels.dart';

class const EBarChartBar({
  required final String id,
  required final double value,
  required final String caption,
  required final String axisLabel,
});

class const EBarChart({
  super.key,
  required final String title,
  required final List<EBarChartBar> bars,
  final Color barColor = EColors.accent,
  final double plotHeight = 140,
  final String Function(double value)? formatY,
  final bool sharesPlotWidthEvenly = false,
}) extends StatefulWidget {
  @override
  State<EBarChart> createState() => _EBarChartState();
}

class _EBarChartState() extends State<EBarChart> {
  final _latestInView = ScrollController();
  String? _inspectedId;

  @override
  void initState() {
    super.initState();
    _jumpToLatest();
  }

  @override
  void didUpdateWidget(EBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bars.length != widget.bars.length) _jumpToLatest();
  }

  @override
  void dispose() {
    _latestInView.dispose();
    super.dispose();
  }

  void _jumpToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_latestInView.hasClients) return;
      _latestInView.jumpTo(_latestInView.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: EText.section),
        if (_inspectedCaption != null) ...[
          const SizedBox(height: ELayout.spaceXs),
          Text(_inspectedCaption!, style: EText.caption),
        ],
        const SizedBox(height: ELayout.spaceSm),
        if (widget.bars.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: ELayout.spaceLg),
            child: Text('No data yet', style: EText.caption),
          )
        else
          _plot(),
      ],
    );
  }

  String? get _inspectedCaption {
    if (_inspectedId == null) return null;
    for (final bar in widget.bars) {
      if (bar.id == _inspectedId) return '${bar.axisLabel} · ${bar.caption}';
    }
    return null;
  }

  Widget _plot() {
    final maxValue = widget.bars.fold<double>(
      0.0,
      (highest, bar) => math.max(highest, bar.value),
    );
    final valueScale = EChartValueScale.nice(maxValue);
    final chartMax = valueScale.max;
    const minBarWidth = 16.0;
    final minPlotWidth = widget.bars.length * minBarWidth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EChartYLabels(
          scale: valueScale,
          height: widget.plotHeight,
          formatTick: widget.formatY,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final plotWidth = widget.sharesPlotWidthEvenly
                  ? constraints.maxWidth
                  : math.max(constraints.maxWidth, minPlotWidth);
              final plot = SizedBox(
                width: plotWidth,
                child: Column(
                    children: [
                      SizedBox(
                        height: widget.plotHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final bar in widget.bars)
                              Expanded(
                                child: _bar(bar, chartMax),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ELayout.spaceXs),
                      Row(
                        children: [
                          for (final bar in widget.bars)
                            Expanded(
                              child: Text(
                                bar.axisLabel,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: EText.caption.copyWith(fontSize: 8),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
              );
              if (widget.sharesPlotWidthEvenly ||
                  plotWidth <= constraints.maxWidth) {
                return plot;
              }
              return SingleChildScrollView(
                controller: _latestInView,
                scrollDirection: Axis.horizontal,
                child: plot,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _bar(EBarChartBar bar, double chartMax) {
    final isInspected = bar.id == _inspectedId;
    final heightFraction = (bar.value / chartMax).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: () {
        setState(() {
          _inspectedId = isInspected ? null : bar.id;
        });
      },
      child: Semantics(
        button: true,
        label: '${bar.axisLabel} ${bar.caption}',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: math.max(2, widget.plotHeight * heightFraction),
              decoration: BoxDecoration(
                color: widget.barColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
                border: isInspected
                    ? Border.all(color: EColors.textPrimary, width: 1.5)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
