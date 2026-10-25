import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';

/// One row in an [EChartLegend]: swatch, name, optional value and caption.
class const EChartLegendEntry({
  required final Widget swatch,
  required final String label,
  final String? value,
  final String? caption,
  final TextStyle? labelStyle,
  final TextStyle? valueStyle,
  final bool dimmed = false,
  final VoidCallback? onActivated,
  final VoidCallback? onDoubleActivated,
  final ValueChanged<bool>? onHoverChanged,
});

/// Chart series key laid out as aligned columns of rows.
///
/// Wide space gets several columns so the block stays short. Each column is a
/// list: name on the left, value on the right, so amounts scan in a line.
class const EChartLegend({required final List<EChartLegendEntry> entries})
    extends StatelessWidget {
  static const _minColumnWidth = 240.0;

  /// Past this, a column's value drifts away from its name.
  static const _maxColumnWidth = 320.0;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) => _columns(constraints.maxWidth),
    );
  }

  Widget _columns(double maxWidth) {
    if (!maxWidth.isFinite) return _looseColumn();
    final fittedCount = (maxWidth / _minColumnWidth).floor();
    final columnCount = math.max(1, math.min(entries.length, fittedCount));
    final rowCount = (entries.length / columnCount).ceil();
    final columnWidth = math.min(maxWidth / columnCount, _maxColumnWidth);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var column = 0; column < columnCount; column++)
          SizedBox(
            width: columnWidth,
            child: _column(
              column,
              rowCount,
              showLeadingRule: column > 0,
              hasNextColumn: column < columnCount - 1,
            ),
          ),
      ],
    );
  }

  Widget _looseColumn() {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final entry in entries)
          TableRow(
            children: [
              _entry(entry, expandLabel: false, includeValue: false),
              _valueCell(entry),
            ],
          ),
      ],
    );
  }

  /// Values sit [ELayout.spaceMd] off the rule on both sides, so a
  /// right-aligned amount never touches the next column's rule.
  Widget _column(
    int column,
    int rowCount, {
    required bool showLeadingRule,
    required bool hasNextColumn,
  }) {
    final rows = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var row = 0; row < rowCount; row++)
          if (column * rowCount + row < entries.length)
            _entry(entries[column * rowCount + row], expandLabel: true),
      ],
    );
    final paddedRows = Padding(
      padding: EdgeInsets.only(
        left: showLeadingRule ? ELayout.spaceMd : 0,
        right: hasNextColumn ? ELayout.spaceMd : 0,
      ),
      child: rows,
    );
    if (!showLeadingRule) return paddedRows;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: EColors.borderStrong)),
      ),
      child: paddedRows,
    );
  }

  Widget _valueCell(EChartLegendEntry entry) {
    final value = entry.value;
    return _hitTarget(
      entry,
      Padding(
        padding: const EdgeInsets.only(
          left: ELayout.spaceSm,
          top: ELayout.spaceXs,
          bottom: ELayout.spaceXs,
        ),
        child: value == null
            ? const SizedBox.shrink()
            : Text(value, style: _valueStyle(entry)),
      ),
    );
  }

  Widget _entry(
    EChartLegendEntry entry, {
    required bool expandLabel,
    bool includeValue = true,
  }) {
    return _hitTarget(
      entry,
      Padding(
        padding: const EdgeInsets.symmetric(vertical: ELayout.spaceXs),
        child: _entryRow(
          entry,
          expandLabel: expandLabel,
          includeValue: includeValue,
        ),
      ),
    );
  }

  Widget _hitTarget(EChartLegendEntry entry, Widget child) {
    final hover = entry.onHoverChanged;
    if (hover != null) {
      child = MouseRegion(
        onEnter: (_) => hover(true),
        onExit: (_) => hover(false),
        child: child,
      );
    }
    if (entry.onActivated == null && entry.onDoubleActivated == null) {
      return child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: entry.onActivated,
      onDoubleTap: entry.onDoubleActivated,
      child: child,
    );
  }

  Widget _entryRow(
    EChartLegendEntry entry, {
    required bool expandLabel,
    required bool includeValue,
  }) {
    final name = Text(
      entry.label,
      style: _labelStyle(entry),
      maxLines: 1,
      softWrap: false,
      overflow: expandLabel ? TextOverflow.ellipsis : TextOverflow.visible,
    );
    final row = Row(
      mainAxisSize: expandLabel ? MainAxisSize.max : MainAxisSize.min,
      children: [
        entry.swatch,
        const SizedBox(width: ELayout.spaceXs),
        if (expandLabel) Expanded(child: name) else name,
        if (includeValue && entry.value != null) ...[
          const SizedBox(width: ELayout.spaceSm),
          Text(entry.value!, style: _valueStyle(entry)),
        ],
      ],
    );
    final caption = entry.caption;
    if (caption == null) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row,
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text(
            caption,
            style: EText.caption.copyWith(
              color: entry.dimmed ? EColors.textMuted : EColors.textTertiary,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: expandLabel ? TextOverflow.ellipsis : TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  TextStyle _labelStyle(EChartLegendEntry entry) {
    final style = entry.labelStyle ?? EText.caption;
    if (!entry.dimmed) return style;
    return style.copyWith(
      color: EColors.textMuted,
      decorationColor: EColors.textMuted,
    );
  }

  TextStyle _valueStyle(EChartLegendEntry entry) {
    final style =
        entry.valueStyle ?? EText.caption.copyWith(fontWeight: FontWeight.w600);
    final colored = entry.dimmed
        ? style.copyWith(
            color: EColors.textMuted,
            decorationColor: EColors.textMuted,
          )
        : style;
    return colored.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

