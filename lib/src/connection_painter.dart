import 'package:flutter/material.dart';
import 'manager.dart';

/// Enum representing the various types of connection drawing paths.
///
/// These values dictate the visual path used to draw a connection between points.
enum ConnectionDrawingType {
  /// Draw a bezier curve with vertical control points.
  bezier,

  /// Draw a simple straight line.
  straightLine,

  /// Draw a path that goes vertically then horizontally.
  verticalThenHorizontal,

  /// Draw a path that goes half horizontally then vertically.
  halfHorizontalThenVertical,

  /// Draw a path that goes half vertically then horizontally.
  halfVerticalThenHorizontal,

  /// Draw a bezier curve that transitions horizontally and then vertically.
  bezierHorizontalThenVertical,
}

/// A custom painter that draws connections between points using various drawing types.
///
/// This painter uses the provided [Manager] to access current connection points and
/// mouse position information. It draws both the actual connections and, if active,
/// an intermediate mouse connection line.
class ConnectionPainter extends CustomPainter {
  /// If true, an additional mouse connection line is rendered.
  final bool mouseLineActive;

  /// The manager containing connection points, connections, and offset data.
  final Manager manager;

  /// The drawing type to use for the connection paths.
  final ConnectionDrawingType drawingType;

  /// The color used when drawing the mouse connection line.
  final Color mouseLineColor;

  /// The thickness (stroke width) of the connection lines.
  final double lineThickness;

  /// The radius of the endpoint circles drawn at connection points.
  final double endpointRadius;

  /// Creates a [ConnectionPainter] with the provided [manager] and customization options.
  ///
  /// The [repaint] parameter is set to the manager's [mousePosition] notifier so that the
  /// painter updates when the mouse moves.
  ConnectionPainter(
      this.manager, {
        this.drawingType = ConnectionDrawingType.bezierHorizontalThenVertical,
        this.mouseLineActive = true,
        this.mouseLineColor = Colors.blue,
        this.lineThickness = 2.0,
        this.endpointRadius = 4.0,
      }) : super(repaint: manager.mousePosition);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all existing connections.
    for (final connection in manager.connections.value) {
      try {
        // Retrieve connection points based on composite identifiers.
        final cpw1 = manager.connectionPoints.value.firstWhere(
              (cpw) => manager.getCompositeId(cpw) == connection.id1,
        );
        final cpw2 = manager.connectionPoints.value.firstWhere(
              (cpw) => manager.getCompositeId(cpw) == connection.id2,
        );

        // Ensure that the callback exists before invoking it.
        if (cpw1.getOffsetCallback == null || cpw2.getOffsetCallback == null) {
          debugPrint('Offset callback is null for one of the connection points.');
          continue;
        }

        // Compute offsets adjusted by the canvas offset.
        final offset1 = cpw1.getOffsetCallback!() - manager.canvasOffset.value;
        final offset2 = cpw2.getOffsetCallback!() - manager.canvasOffset.value;

        // Build the connection path using the specified drawing type.
        final path = _buildPathForType(offset1, offset2);

        // Paint for the connection path.
        final connectionPaint = Paint()
          ..color = connection.color ?? Colors.blue
          ..strokeWidth = lineThickness
          ..style = PaintingStyle.stroke;

        canvas.drawPath(path, connectionPaint);

        // Paint for the endpoint dots.
        final dotPaint = Paint()
          ..color = connection.color ?? Colors.blue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(offset1, endpointRadius, dotPaint);
        canvas.drawCircle(offset2, endpointRadius, dotPaint);
      } catch (e, stackTrace) {
        // Log any errors for debugging, then skip drawing this connection.
        debugPrint('Error drawing connection: $e\n$stackTrace');
        continue;
      }
    }

    // Draw a connection line from the selected point to the current mouse position.
    if (mouseLineActive && manager.currentlySelectedPoint.value != null) {
      final selectedCP = manager.currentlySelectedPoint.value!;
      if (selectedCP.getOffsetCallback == null) {
        debugPrint('Offset callback is null for the selected connection point.');
      } else {
        final startOffset =
            selectedCP.getOffsetCallback!() - manager.canvasOffset.value;
        final mouseOffset = manager.mousePosition.value;

        final path = _buildPathForType(startOffset, mouseOffset);

        final connectionPaint = Paint()
          ..color = mouseLineColor
          ..strokeWidth = lineThickness
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, connectionPaint);

        final dotPaint = Paint()
          ..color = mouseLineColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(startOffset, endpointRadius, dotPaint);
        canvas.drawCircle(mouseOffset, endpointRadius, dotPaint);
      }
    }
  }

  /// Builds a [Path] between [offset1] and [offset2] according to [drawingType].
  ///
  /// Returns a [Path] constructed using one of the predefined path-building methods.
  Path _buildPathForType(Offset offset1, Offset offset2) {
    switch (drawingType) {
      case ConnectionDrawingType.bezier:
        return _buildBezierPath(offset1, offset2);
      case ConnectionDrawingType.straightLine:
        return _buildStraightLinePath(offset1, offset2);
      case ConnectionDrawingType.verticalThenHorizontal:
        return _buildVerticalThenHorizontalPath(offset1, offset2);
      case ConnectionDrawingType.halfHorizontalThenVertical:
        return _buildHalfHorizontalThenVerticalPath(offset1, offset2);
      case ConnectionDrawingType.halfVerticalThenHorizontal:
        return _buildHalfVerticalThenHorizontalPath(offset1, offset2);
      case ConnectionDrawingType.bezierHorizontalThenVertical:
        return _buildBezierHorizontalThenVerticalPath(offset1, offset2);
    }
  }

  /// Constructs a bezier curve using vertical control points.
  ///
  /// The control points are located at the vertical midpoint between [offset1] and [offset2].
  Path _buildBezierPath(Offset offset1, Offset offset2) {
    final midY = (offset1.dy + offset2.dy) / 2;
    return Path()
      ..moveTo(offset1.dx, offset1.dy)
      ..cubicTo(offset1.dx, midY, offset2.dx, midY, offset2.dx, offset2.dy);
  }

  /// Constructs a bezier curve with horizontal control points.
  ///
  /// The control points are calculated based on the horizontal midpoint.
  Path _buildBezierHorizontalThenVerticalPath(Offset offset1, Offset offset2) {
    final midX = (offset1.dx + offset2.dx) / 2;
    return Path()
      ..moveTo(offset1.dx, offset1.dy)
      ..cubicTo(midX, offset1.dy, midX, offset2.dy, offset2.dx, offset2.dy);
  }

  /// Constructs a simple straight line between [offset1] and [offset2].
  Path _buildStraightLinePath(Offset offset1, Offset offset2) {
    return Path()
      ..moveTo(offset1.dx, offset1.dy)
      ..lineTo(offset2.dx, offset2.dy);
  }

  /// Constructs a path that goes vertically first, then horizontally.
  Path _buildVerticalThenHorizontalPath(Offset offset1, Offset offset2) {
    return Path()
      ..moveTo(offset1.dx, offset1.dy)
      ..lineTo(offset1.dx, offset2.dy)
      ..lineTo(offset2.dx, offset2.dy);
  }

  /// Constructs a path that goes half the distance horizontally then vertically.
  Path _buildHalfHorizontalThenVerticalPath(Offset offset1, Offset offset2) {
    final midX = (offset1.dx + offset2.dx) / 2;
    return Path()
      ..moveTo(offset1.dx, offset1.dy)
      ..lineTo(midX, offset1.dy)
      ..lineTo(midX, offset2.dy)
      ..lineTo(offset2.dx, offset2.dy);
  }

  /// Constructs a path that goes half the distance vertically then horizontally.
  Path _buildHalfVerticalThenHorizontalPath(Offset offset1, Offset offset2) {
    final midY = (offset1.dy + offset2.dy) / 2;
    return Path()
      ..moveTo(offset1.dx, offset1.dy)
      ..lineTo(offset1.dx, midY)
      ..lineTo(offset2.dx, midY)
      ..lineTo(offset2.dx, offset2.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
