import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../src/connection_painter.dart';
import '../src/grid_widget.dart';
import '../src/manager.dart';

import 'node_card.dart';

/// A widget representing the main canvas area on which nodes and connections are rendered.
///
/// This canvas supports panning and zooming via an [InteractiveViewer] and includes the grid,
/// node cards, and connection lines (rendered via a custom painter). Mouse events and gesture
/// callbacks can be provided to handle user interaction.
class CanvasPage extends StatelessWidget {
  /// The [Manager] controlling nodes, connections, and related state.
  final Manager manager;

  /// Optional custom painter for drawing connections.
  /// If not provided, the default [ConnectionPainter] will be used.
  final CustomPainter? connectionPainter;

  // Optional mouse region callbacks.
  final PointerEnterEventListener? onMouseEnter;
  final PointerHoverEventListener? onMouseHover;
  final PointerExitEventListener? onMouseExit;

  // Optional gesture detector callbacks.
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  /// The width of the canvas.
  final double canvasWidth;

  /// The height of the canvas.
  final double canvasHeight;

  /// The maximum scale factor (zoom in) for the canvas.
  final double maxZoom;

  /// The minimum scale factor (zoom out) for the canvas.
  final double minZoom;

  /// Factor applied to the scale transformation.
  final double scaleFactor;

  /// Spacing between grid lines.
  final double gridSpacing;

  /// Color of the grid lines.
  final Color lineColor;

  /// Stroke width of the grid lines.
  final double lineWidth;

  /// The extra spacing applied beyond the widget's bounds to draw the grid.
  final double overflowSpacing;

  /// Creates a [CanvasPage] with the provided parameters.
  ///
  /// Required parameters include the [manager]. Optional gesture or mouse callbacks can be
  /// provided to extend interactivity.
  CanvasPage({
    super.key,
    this.canvasWidth = 10000,
    this.canvasHeight = 10000,
    this.maxZoom = 10.0,
    this.minZoom = 0.1,
    this.scaleFactor = 10000,
    this.gridSpacing = 100,
    this.lineColor = Colors.grey,
    this.lineWidth = 0.2,
    this.overflowSpacing = 10000,
    required this.manager,
    this.connectionPainter,
    this.onMouseEnter,
    this.onMouseHover,
    this.onMouseExit,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onLongPress,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  /// A GlobalKey used to locate the widget's position in the widget tree.
  final GlobalKey _key = GlobalKey();

  /// Controls the transformation (pan and zoom) of the canvas.
  final TransformationController _transformationController =
  TransformationController();

  @override
  Widget build(BuildContext context) {
    // Schedule a post-frame callback to update the canvas offset in the manager.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
      _key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        // Calculate the global offset of the canvas container.
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        manager.canvasOffset.value = offset;
      }
    });

    return MouseRegion(
      onEnter: (PointerEnterEvent event) => onMouseEnter?.call(event),
      onHover: (PointerHoverEvent event) {
        // Update the manager's mouse position.
        manager.mousePosition.value = event.localPosition;
        onMouseHover?.call(event);
      },
      onExit: (PointerExitEvent event) => onMouseExit?.call(event),
      child: GestureDetector(
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTap: onTap,
        onLongPress: onLongPress,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: Container(
          key: _key,
          child: Stack(
            children: [
              // Layer 1: Grid and Node Cards.
              SizedBox(
                width: canvasWidth,
                height: canvasHeight,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  constrained: false,
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.hardEdge,
                  minScale: minZoom,
                  maxScale: maxZoom,
                  scaleFactor: scaleFactor,
                  child: ValueListenableBuilder(
                    valueListenable: manager.nodes,
                    builder: (context, List<NodeCard> cards, _) {
                      return SizedBox(
                        width: canvasWidth,
                        height: canvasHeight,
                        child: Stack(
                          children: [
                            // Display the grid in the background.
                            IgnorePointer(
                              child: GridWidget(
                                gridSpacing: gridSpacing,
                                lineColor: lineColor,
                                lineWidth: lineWidth,
                                overflowSpacing: overflowSpacing,
                              ),
                            ),
                            // Position each node based on its current position.
                            ...cards.map((card) {
                              return ValueListenableBuilder<Offset>(
                                valueListenable: card.position,
                                builder: (context, offset, _) => Positioned(
                                  left: offset.dx,
                                  top: offset.dy,
                                  child: card,
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Layer 2: Connection lines drawn on top of the nodes.
              IgnorePointer(
                child: ValueListenableBuilder(
                  valueListenable: manager.connections,
                  builder: (context, dynamic connections, _) => CustomPaint(
                    // Use the provided custom painter or default to ConnectionPainter.
                    painter: connectionPainter ?? ConnectionPainter(manager),
                    size: Size.infinite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
