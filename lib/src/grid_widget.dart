import 'dart:ui';
import 'package:material_ui/material_ui.dart';

/// A [StatelessWidget] that renders a grid background using a [CustomPaint].
class GridWidget extends StatelessWidget {
  final double gridSpacing;
  final double overflowSpacing;
  final Color lineColor;
  final double lineWidth;

  /// The background color of the grid. If null, it remains transparent.
  final Color? backgroundColor;

  const GridWidget({
    super.key,
    this.gridSpacing = 10,
    this.overflowSpacing = 10000,
    this.lineColor = Colors.black,
    this.lineWidth = 1,
    this.backgroundColor,
  })  : assert(gridSpacing > 0, 'gridSpacing must be greater than zero');

  @override
  Widget build(BuildContext context) {
    // You can wrap in a ColoredBox, but painting the background directly
    // inside the CustomPainter is slightly more performant.
    return CustomPaint(
      painter: GridPainter(
        gridSize: gridSpacing,
        gridColor: lineColor,
        strokeWidth: lineWidth,
        overflow: overflowSpacing,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

/// A [CustomPainter] that draws an extended grid.
class GridPainter extends CustomPainter {
  final double gridSize;
  final Color gridColor;
  final double strokeWidth;
  final double overflow;
  final Color? backgroundColor;

  GridPainter({
    this.gridSize = 10,
    this.gridColor = Colors.black,
    this.strokeWidth = 1,
    this.overflow = 10000,
    this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paint the background first (if provided)
    if (backgroundColor != null) {
      canvas.drawColor(backgroundColor!, BlendMode.src);
    }

    // 2. Configure the paint brush once
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double startX = -overflow;
    final double endX = size.width + overflow;
    final double startY = -overflow;
    final double endY = size.height + overflow;

    // 3. Batch the points instead of calling drawLine in a loop
    final List<Offset> points = [];

    // Vertical lines
    for (double x = startX; x <= endX; x += gridSize) {
      points.add(Offset(x, startY));
      points.add(Offset(x, endY));
    }

    // Horizontal lines
    for (double y = startY; y <= endY; y += gridSize) {
      points.add(Offset(startX, y));
      points.add(Offset(endX, y));
    }

    // 4. Send all points to the GPU in a single engine call
    canvas.drawPoints(PointMode.lines, points, paint);
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return gridSize != oldDelegate.gridSize ||
        gridColor != oldDelegate.gridColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        overflow != oldDelegate.overflow ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}