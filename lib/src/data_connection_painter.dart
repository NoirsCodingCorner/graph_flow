import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'connection_model.dart';
import 'graph_visualiser.dart';

/// Defines the drawing type of the connection. Either [bezier] or [direct] supported.
enum ConnectionShape { direct, bezier }

/// A high-performance painter that draws connections and animated dots.
/// Uses the Visualizer to determine selected and highlighting aspects of its connections.
/// The [animation] uses one global instance to allow performant animation of all connection indicators.
class DataConnectionPainter extends CustomPainter {
  final GraphVisualiser visualiser;
  final Animation<double> animation;

  final Color lineColor;
  final Color lineColorShadow;
  final Color dotColor;
  final Color dotColorShadow;
  final Color highLightColor;

  final bool enableAnimation;
  final bool enableLineGlow;
  final bool enableDotGlow;
  final ConnectionShape connectionShape;

  // Cache Paint objects so they are only created once, not 60 times a second
  late final Paint _linePaint;
  late final Paint _lineHighlightPaint;

  late final Paint _endpointPaint;
  late final Paint _dotPaint;
  late final Paint _glowPaintOuter;
  late final Paint _glowPaintInner;
  late final Paint _dotGlowPaintOuter;
  late final Paint _dotGlowPaintInner;

  // Conditionally bind the animation. If false, the canvas only repaints when nodes move/connect.
  DataConnectionPainter(
    this.visualiser,
    this.animation, {
    required this.lineColor,
    this.lineColorShadow = Colors.black,
    this.dotColor = Colors.white,
    this.dotColorShadow = Colors.black,
    this.highLightColor = Colors.black,
    this.enableAnimation = true,
    this.enableLineGlow = true,
    this.enableDotGlow = true,
    this.connectionShape = ConnectionShape.bezier,
  }) : super(
            repaint: enableAnimation
                ? Listenable.merge([visualiser, animation])
                : visualiser) {
    // Initialize core paints
    _linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    _lineHighlightPaint = Paint()
      ..color = highLightColor
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    _endpointPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    _dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    // Only initialize expensive blur filters if glowing is enabled
    if (enableLineGlow) {
      _glowPaintOuter = Paint()
        ..color = lineColorShadow.withValues(alpha: 0.15) // Lighter opacity
        ..strokeWidth = 12.0 // Wider stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      _glowPaintInner = Paint()
        ..color = lineColorShadow.withValues(alpha: 0.3) // Darker opacity
        ..strokeWidth = 7.0 // Narrower stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    }

    if (enableDotGlow) {
      _dotGlowPaintOuter = Paint()
        ..color = dotColorShadow.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;

      _dotGlowPaintInner = Paint()
        ..color = dotColorShadow.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // --- 1. Draw established connections ---
    List<ConnectionModel> hoveredConnections = visualiser.model
        .getConnectionsOfNode(visualiser.currentlyHoveredNode?.model);
    for (ConnectionModel connection in visualiser.model.connectionModels) {
      Offset? startOffset = visualiser.getAbsolutePortPosition(
          connection.sourceNodeId, connection.sourcePortId);

      Offset? endOffset = visualiser.getAbsolutePortPosition(
          connection.targetNodeId, connection.targetPortId);

      if (startOffset != null &&
          endOffset != null &&
          !hoveredConnections.contains(connection)) {
        _drawConnectionPath(canvas, startOffset, endOffset, true, false);
      }
    }
    for (final connection in hoveredConnections) {
      Offset? startOffset = visualiser.getAbsolutePortPosition(
          connection.sourceNodeId, connection.sourcePortId);

      Offset? endOffset = visualiser.getAbsolutePortPosition(
          connection.targetNodeId, connection.targetPortId);

      if (startOffset != null && endOffset != null) {
        _drawConnectionPath(canvas, startOffset, endOffset, true, true);
      }
    }

    // --- 2. Draw live preview connection ---
    if (visualiser.currentlySelectedPort != null &&
        visualiser.mousePosition != null) {
      Offset? startOffset = visualiser.getAbsolutePortPosition(
          visualiser.currentlySelectedPort!.nodeId,
          visualiser.currentlySelectedPort!.model.id);

      if (startOffset != null) {
        // Draw the path using the mouse position as the end target.
        // We set drawDots to false so the preview line is just a solid beam.
        _drawConnectionPath(
            canvas, startOffset, visualiser.mousePosition!, false, true);
      }
    }
  }

  /// Helper method to keep the paint function clean
  void _drawConnectionPath(Canvas canvas, Offset startOffset, Offset endOffset,
      bool drawDots, bool highlight) {
    // FIX: Prevent zero-dimension bounding boxes which cause Flutter to drop blur filters.
    double safeEndX = endOffset.dx;
    double safeEndY = endOffset.dy;

    if ((safeEndY - startOffset.dy).abs() < 0.01) safeEndY += 0.01;
    if ((safeEndX - startOffset.dx).abs() < 0.01) safeEndX += 0.01;

    Path path = Path();
    path.moveTo(startOffset.dx, startOffset.dy);

    if (connectionShape == ConnectionShape.bezier) {
      double midX = (startOffset.dx + safeEndX) / 2;
      path.cubicTo(midX, startOffset.dy, midX, safeEndY, safeEndX, safeEndY);
    } else if (connectionShape == ConnectionShape.direct) {
      path.lineTo(safeEndX, safeEndY);
    }

    if (enableLineGlow) {
      // Draw outer glow then inner glow to create a gradient-like falloff
      canvas.drawPath(path, _glowPaintOuter);
      canvas.drawPath(path, _glowPaintInner);
    }

    if (highlight) {
      canvas.drawPath(path, _lineHighlightPaint);
    } else {
      canvas.drawPath(path, _linePaint);
    }

    // We can still use the exact original offsets for the circles
    canvas.drawCircle(startOffset, 4.0, _endpointPaint);
    canvas.drawCircle(endOffset, 4.0, _endpointPaint);

    if (enableAnimation && drawDots) {
      final PathMetrics pathMetrics = path.computeMetrics();

      for (final PathMetric metric in pathMetrics) {
        final double pathLength = metric.length;
        const int dotCount = 3;

        for (int i = 0; i < dotCount; i++) {
          double dotProgress = (animation.value + (i / dotCount)) % 1.0;
          double distanceAlongPath = dotProgress * pathLength;

          final Tangent? tangent =
              metric.getTangentForOffset(distanceAlongPath);
          if (tangent != null) {
            if (enableDotGlow) {
              // Draw layered circles instead of blurred circles
              canvas.drawCircle(tangent.position, 9.0, _dotGlowPaintOuter);
              canvas.drawCircle(tangent.position, 6.0, _dotGlowPaintInner);
            }
            canvas.drawCircle(tangent.position, 3.5, _dotPaint);
          }
        }
        break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DataConnectionPainter oldDelegate) {
    return oldDelegate.enableAnimation != enableAnimation ||
        oldDelegate.enableLineGlow != enableLineGlow ||
        oldDelegate.enableDotGlow != enableDotGlow ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.connectionShape != connectionShape;
  }
}
