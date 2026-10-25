import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Selectable text over a table-like list of [ECopyableRow]s.
///
/// When a selection touches one or more rows, the selection toolbar gains
/// "Copy selected rows": every touched row is copied in full, one row per
/// line with tab-separated cells, so it pastes into a spreadsheet. The normal
/// Copy action still copies only the selected text.
class const ECopyableRowsSelectionArea({
  super.key,

  /// Column titles copied as the first line; no header line when null.
  final List<String>? headerCells,

  /// Subtree holding the [ECopyableRow]s (a list, column, or table).
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<ECopyableRowsSelectionArea> createState() =>
      _ECopyableRowsSelectionAreaState();
}

class _ECopyableRowsSelectionAreaState()
    extends State<ECopyableRowsSelectionArea> {
  final Set<_ECopyableRowState> _mountedRows = {};

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      contextMenuBuilder: _selectionToolbar,
      child: widget.child,
    );
  }

  Widget _selectionToolbar(
    BuildContext context,
    SelectableRegionState selectableRegionState,
  ) {
    final rowsTouchedBySelection = _rowsTouchedBySelectionInReadingOrder();
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: selectableRegionState.contextMenuAnchors,
      buttonItems: [
        ...selectableRegionState.contextMenuButtonItems,
        if (rowsTouchedBySelection.isNotEmpty)
          ContextMenuButtonItem(
            label: 'Copy selected rows',
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: _rowsAsTabSeparatedLines(rowsTouchedBySelection),
                ),
              );
              selectableRegionState.hideToolbar();
            },
          ),
      ],
    );
  }

  List<_ECopyableRowState> _rowsTouchedBySelectionInReadingOrder() {
    final touchedRows = _mountedRows
        .where((row) => row.isTouchedBySelection)
        .toList();
    touchedRows.sort((first, second) {
      final firstTopLeft = first.topLeftOnScreen;
      final secondTopLeft = second.topLeftOnScreen;
      final byTop = firstTopLeft.dy.compareTo(secondTopLeft.dy);
      if (byTop != 0) return byTop;
      return firstTopLeft.dx.compareTo(secondTopLeft.dx);
    });
    return touchedRows;
  }

  String _rowsAsTabSeparatedLines(List<_ECopyableRowState> rows) {
    final List<List<String>> copiedRowCells = [
      ?widget.headerCells,
      for (final row in rows) row.widget.cells,
    ];
    return copiedRowCells
        .map(
          (cells) => cells
              .map((cell) => cell.replaceAll(RegExp(r'[\t\r\n]+'), ' '))
              .join('\t'),
        )
        .join('\n');
  }
}

/// One row under an [ECopyableRowsSelectionArea]. [cells] is the text each
/// column contributes when the row is copied; [child] is what is shown.
class const ECopyableRow({
  super.key,

  /// Cell text in column order, copied tab-separated.
  required final List<String> cells,
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<ECopyableRow> createState() => _ECopyableRowState();
}

class _ECopyableRowState() extends State<ECopyableRow> {
  final SelectionListenerNotifier _rowSelection = SelectionListenerNotifier();
  _ECopyableRowsSelectionAreaState? _selectionArea;

  bool get isTouchedBySelection =>
      _rowSelection.registered &&
      _rowSelection.selection.status == SelectionStatus.uncollapsed;

  Offset get topLeftOnScreen =>
      (context.findRenderObject()! as RenderBox).localToGlobal(Offset.zero);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectionArea = context
        .findAncestorStateOfType<_ECopyableRowsSelectionAreaState>();
    if (selectionArea == _selectionArea) return;
    _selectionArea?._mountedRows.remove(this);
    _selectionArea = selectionArea?.._mountedRows.add(this);
  }

  @override
  void dispose() {
    _selectionArea?._mountedRows.remove(this);
    _rowSelection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionListener(
      selectionNotifier: _rowSelection,
      child: widget.child,
    );
  }
}
