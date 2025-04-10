import 'package:flutter/material.dart';
import 'dart:ui';

/// A [StatelessWidget] that renders a grid background using a [CustomPaint].
///
/// The grid is drawn using a [GridPainter] that renders vertical and horizontal lines
/// spaced by [gridSpacing]. The grid extends beyond the widget bounds by [overflowSpacing]
/// pixels, ensuring that the grid covers larger movable or zoomable areas.
///
/// Example usage:
/// ```dart
/// GridWidget(
///   gridSpacing: 20,
///   overflowSpacing: 500,
///   lineColor: Colors.grey,
///   lineWidth: 0.5,
/// )
/// ```
///
class GridWidget extends StatelessWidget {
  /// The spacing in pixels between grid lines.
  final double gridSpacing;

  /// The extra pixel padding beyond the widget's bounds where grid lines are drawn.
  final double overflowSpacing;

  /// The color of the grid lines.
  final Color lineColor;

  /// The thickness (stroke width) of the grid lines.
  final double lineWidth;

  /// Creates a [GridWidget] with the specified grid configuration.
  ///
  /// [gridSpacing] must be greater than zero.
  /// [overflowSpacing] defines how far beyond the widget's bounds the grid is extended.
  const GridWidget({
    super.key,
    this.gridSpacing = 10,
    this.overflowSpacing = 10000,
    this.lineColor = Colors.black,
    this.lineWidth = 1,
  })  : assert(gridSpacing > 0, 'gridSpacing must be greater than zero');

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // The [GridPainter] is responsible for drawing the grid lines.
      painter: GridPainter(
        gridSize: gridSpacing,
        gridColor: lineColor,
        strokeWidth: lineWidth,
        overflow: overflowSpacing,
      ),
    );
  }
}

/// A [CustomPainter] that draws an extended grid, consisting of evenly spaced vertical and horizontal lines.
///
/// The grid lines are drawn beyond the bounds of the widget by [overflow] pixels, ensuring
/// coverage even when the widget is part of larger, panning, or zooming canvases.
class GridPainter extends CustomPainter {
  /// The spacing between consecutive grid lines.
  final double gridSize;

  /// The color used to draw the grid lines.
  final Color gridColor;

  /// The thickness (stroke width) of the grid lines.
  final double strokeWidth;

  /// The additional area (in pixels) outside the widget bounds where grid lines are rendered.
  final double overflow;

  /// Creates a [GridPainter] with the provided grid configuration.
  ///
  /// All parameters have default values and can be overridden.
  GridPainter({
    this.gridSize = 10,
    this.gridColor = Colors.black,
    this.strokeWidth = 1,
    this.overflow = 10000,
  });

  /// Paints the grid onto the provided [canvas] over the specified [size].
  ///
  /// The grid extends from `-overflow` to `(size.width or size.height) + overflow`
  /// along both the x-axis and y-axis. Each grid line is drawn with the configured
  /// [gridColor] and [strokeWidth].
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = strokeWidth;

    // Define the extended boundaries for the grid.
    final double startX = -overflow;
    final double endX = size.width + overflow;
    final double startY = -overflow;
    final double endY = size.height + overflow;

    // Draw vertical grid lines from startX to endX.
    for (double x = startX; x <= endX; x += gridSize) {
      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }

    // Draw horizontal grid lines from startY to endY.
    for (double y = startY; y <= endY; y += gridSize) {
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  /// Determines whether the grid needs to be repainted.
  ///
  /// Returns true if any of the grid's configuration parameters have changed.
  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return gridSize != oldDelegate.gridSize ||
        gridColor != oldDelegate.gridColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        overflow != oldDelegate.overflow;
  }
}
