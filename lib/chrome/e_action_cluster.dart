import 'package:flutter/material.dart';

import '../theme/e_colors.dart';
import '../theme/e_layout.dart';
import '../theme/e_text.dart';
import 'e_status_chip.dart';
import 'e_surface.dart';

/// Dense action-cluster metrics — only used by this file.
abstract final class _ClusterChrome {
  static const cellHeight = 44.0;
  static const cellPadH = 8.0;
  static const cellPadV = 6.0;
  static const statusEdgeHeight = 14.0;
  static const statusEdgeOverlap = 3.0;
  static const condensedMaxWidth = 92.0;
  static const railIconOnly = 28.0;
  static const railLabeled = 44.0;
  static const labeledRailMinClusterWidth = 168.0;
}

/// One tappable cell inside an [EActionCluster] well.
class EActionClusterCell {
  const EActionClusterCell({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.condensedLabel,
    this.statusLabel,
    this.statusTone,
    this.trailing,
    this.live = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;

  /// Icon + this label when the cell is too narrow for title + subtitle.
  final String? condensedLabel;

  /// Hanging top-edge ribbon (e.g. `changed`). Not an inline chip.
  final String? statusLabel;
  final EStatusTone? statusTone;
  final Widget? trailing;
  final bool live;
}

/// Fused platform well: accent rail + hairline-split Run|Deploy cells.
class EActionCluster extends StatelessWidget {
  const EActionCluster({
    super.key,
    required this.accent,
    required this.cells,
    this.icon,
    this.label,
  });

  final Color accent;
  final List<EActionClusterCell> cells;
  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) return const SizedBox.shrink();

    final height =
        _ClusterChrome.cellHeight + _ClusterChrome.cellPadV * 2;
    const radius = ELayout.borderRadiusMd;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showRail =
              icon != null || (label != null && label!.isNotEmpty);
          final showRailLabel =
              showRail &&
              label != null &&
              label!.isNotEmpty &&
              constraints.maxWidth >= _ClusterChrome.labeledRailMinClusterWidth;
          final railWidth = !showRail
              ? 0.0
              : showRailLabel
                  ? _ClusterChrome.railLabeled
                  : _ClusterChrome.railIconOnly;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              ESurface(
                kind: ESurfaceKind.inset,
                borderRadius: radius,
                child: ClipRRect(
                  borderRadius: radius,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showRail)
                        _AccentRail(
                          accent: accent,
                          icon: icon,
                          label: showRailLabel ? label : null,
                          width: railWidth,
                        ),
                      for (var index = 0; index < cells.length; index++) ...[
                        if (index > 0)
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: EColors.border.withValues(alpha: 0.85),
                          ),
                        Expanded(child: _Cell(accent: accent, cell: cells[index])),
                      ],
                    ],
                  ),
                ),
              ),
              ..._hangingEdges(
                clusterWidth: constraints.maxWidth,
                railWidth: railWidth,
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _hangingEdges({
    required double clusterWidth,
    required double railWidth,
  }) {
    final dividerTotal = cells.length > 1 ? (cells.length - 1).toDouble() : 0.0;
    final flexSpan = clusterWidth - railWidth - dividerTotal;
    if (flexSpan <= 0 || cells.isEmpty) return const [];

    final cellWidth = flexSpan / cells.length;
    var x = railWidth;
    final hangs = <Widget>[];
    for (var index = 0; index < cells.length; index++) {
      if (index > 0) x += 1;
      final cell = cells[index];
      final statusLabel = cell.statusLabel;
      final statusTone = cell.statusTone;
      if (statusLabel != null && statusTone != null) {
        hangs.add(
          Positioned(
            left: x,
            width: cellWidth,
            top: -_ClusterChrome.statusEdgeHeight +
                _ClusterChrome.statusEdgeOverlap,
            child: IgnorePointer(
              child: _StatusEdge(label: statusLabel, tone: statusTone),
            ),
          ),
        );
      }
      x += cellWidth;
    }
    return hangs;
  }
}

class _AccentRail extends StatelessWidget {
  const _AccentRail({
    required this.accent,
    required this.width,
    this.icon,
    this.label,
  });

  final Color accent;
  final double width;
  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: EColors.border.withValues(alpha: 0.85)),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accent.withValues(alpha: 0.18),
              accent.withValues(alpha: 0.06),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: label == null ? 4 : 6,
            vertical: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 14, color: accent),
              if (icon != null && label != null) const SizedBox(height: 4),
              if (label != null)
                Text(
                  label!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EText.caption.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: ELayout.typeSize(9),
                    height: 1.0,
                    letterSpacing: 0.1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.accent, required this.cell});

  final Color accent;
  final EActionClusterCell cell;

  @override
  Widget build(BuildContext context) {
    final cellAccent = cell.live ? accent : accent.withValues(alpha: 0.92);
    final tooltip = cell.subtitle == null || cell.subtitle!.isEmpty
        ? cell.title
        : '${cell.title} · ${cell.subtitle}';

    return Material(
      color: cell.live ? accent.withValues(alpha: 0.1) : Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: cell.onTap,
          splashColor: accent.withValues(alpha: 0.14),
          highlightColor: accent.withValues(alpha: 0.06),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final condensed =
                  constraints.maxWidth <= _ClusterChrome.condensedMaxWidth;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      condensed ? ELayout.spaceXs : _ClusterChrome.cellPadH,
                  vertical: _ClusterChrome.cellPadV,
                ),
                child: SizedBox(
                  height: _ClusterChrome.cellHeight,
                  child: condensed
                      ? _condensed(cellAccent)
                      : _full(cellAccent),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _full(Color cellAccent) {
    final showSubtitle = cell.subtitle != null && cell.subtitle!.isNotEmpty;
    return Row(
      children: [
        Icon(cell.icon, size: 15, color: cellAccent),
        const SizedBox(width: ELayout.spaceXs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cell.title,
                style: EText.label.copyWith(
                  color: cellAccent,
                  letterSpacing: 0.2,
                  height: 1.15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (showSubtitle)
                Text(
                  cell.subtitle!,
                  style: EText.caption.copyWith(
                    color: accent.withValues(alpha: 0.58),
                    fontSize: ELayout.typeSize(12),
                    height: 1.15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
        if (cell.trailing != null) ...[
          const SizedBox(width: ELayout.spaceXs),
          cell.trailing!,
        ],
      ],
    );
  }

  Widget _condensed(Color cellAccent) {
    final condensedLabel = cell.condensedLabel;
    return Row(
      children: [
        Icon(cell.icon, size: 14, color: cellAccent),
        if (condensedLabel != null && condensedLabel.isNotEmpty) ...[
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              condensedLabel,
              style: EText.label.copyWith(
                color: cellAccent,
                letterSpacing: 0.05,
                height: 1.1,
                fontSize: ELayout.typeSize(11),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        if (cell.trailing != null) ...[
          const SizedBox(width: 2),
          cell.trailing!,
        ],
      ],
    );
  }
}

class _StatusEdge extends StatelessWidget {
  const _StatusEdge({required this.label, required this.tone});

  final String label;
  final EStatusTone tone;

  Color get _foreground => switch (tone) {
        EStatusTone.accent => EColors.accentGlow,
        EStatusTone.success => EColors.success,
        EStatusTone.warning => EColors.warning,
        EStatusTone.danger => EColors.danger,
        EStatusTone.muted => EColors.textMuted,
      };

  Color get _background => switch (tone) {
        EStatusTone.accent => EColors.accentSoft,
        EStatusTone.success => EColors.successSoft,
        EStatusTone.warning => EColors.warningSoft,
        EStatusTone.danger => EColors.dangerSoft,
        EStatusTone.muted => EColors.surfaceRaised,
      };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _background.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        border: Border.all(color: _foreground.withValues(alpha: 0.4)),
      ),
      child: SizedBox(
        height: _ClusterChrome.statusEdgeHeight,
        child: Center(
          child: Text(
            label,
            style: EText.label.copyWith(
              color: _foreground,
              fontSize: ELayout.typeSize(9),
              letterSpacing: 0.6,
              height: 1.0,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
