import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'canvas_configuration.dart';
import 'data_connection_painter.dart';
import 'graph_visualiser.dart';
import 'grid_widget.dart';
import 'node_visual.dart';

/// The main interactive canvas for the node graph.
///
/// Uses an [InteractiveViewer] to handle all panning and zooming natively.
/// Listens to the [GraphVisualiser] to rebuild when visual states or connections change.
class GraphCanvas extends StatefulWidget {
  final GraphVisualiser visualiser;
  final CanvasLayout canvasLayout;

  /// Graph canvas handles the rendering, positioning and marquee selection of the provided [GraphVisualiser].
  /// It requires a [CanvasLayout] to know what style to draw and render in. It listens to its [GraphVisualiser] for events and updates itself
  /// without storing states itself for improved performance. Additionally gives [DataConnectionPainter] its Animation controller for indicator animations.
  const GraphCanvas({
    super.key,
    required this.visualiser,
    required this.canvasLayout,
  });

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas>
    with SingleTickerProviderStateMixin {
  ValueNotifier<bool> canPan = ValueNotifier(true);

  final TransformationController _transformationController =
      TransformationController();

  late AnimationController _dotController;

  Rect _calculateRect(Offset a, Offset b) {
    return Rect.fromLTRB(
      math.min(a.dx, b.dx),
      math.min(a.dy, b.dy),
      math.max(a.dx, b.dx),
      math.max(a.dy, b.dy),
    );
  }

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.visualiser,
      builder: (context, _) {
        return Container(
          color: widget.canvasLayout.gridBackgroundColor,
          child: ValueListenableBuilder(
            valueListenable: canPan,
            builder: (context, pan, child) {
              List<NodeViewState> sortedNodes =
                  widget.visualiser.nodeViewStates.values.toList();
              sortedNodes.sort((NodeViewState a, NodeViewState b) {
                return a.paintOrder.compareTo(b.paintOrder);
              });

              List<Widget> nodeWidgets = [];
              for (int i = 0; i < sortedNodes.length; i++) {
                NodeViewState nodeState = sortedNodes[i];
                Widget nodeWidget = NodeVisual(
                  key: ValueKey(nodeState.model.id),
                  nodeViewState: nodeState,
                  graphVisualizer: widget.visualiser,
                  builder: widget.visualiser
                      .getNodeBuilderByType(nodeState.model.typeName)!,
                );
                nodeWidgets.add(nodeWidget);
              }

              return InteractiveViewer(
                panEnabled: pan,
                transformationController: _transformationController,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(0),
                minScale: widget.canvasLayout.minScale,
                maxScale: widget.canvasLayout.maxScale,
                scaleFactor: widget.canvasLayout.scaleFactor,
                child: Listener(
                  onPointerDown: (details) {
                    if (HardwareKeyboard.instance.isShiftPressed) {
                      widget.visualiser.startMarquee(details.localPosition);
                      canPan.value = false;
                    }
                    if (details.buttons == kSecondaryButton) {
                      widget.visualiser.selectedNodes.value = [];
                    }
                  },
                  onPointerMove: (details) {
                    if (HardwareKeyboard.instance.isShiftPressed) {
                      // currentMarquee internally handles logic and listener notification
                      widget.visualiser.currentMarquee(details.localPosition);
                    }
                  },
                  onPointerUp: (details) {
                    widget.visualiser.endMarquee();
                    canPan.value = true;
                  },
                  child: MouseRegion(
                    onHover: (event) {
                      widget.visualiser
                          .updateMousePosition(event.localPosition);
                    },
                    child: SizedBox(
                      width: widget.canvasLayout.canvasWidth,
                      height: widget.canvasLayout.canvasHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: GridWidget(
                                gridSpacing: widget.canvasLayout.gridSpacing,
                                lineColor: widget.canvasLayout.gridLineColor,
                                backgroundColor:
                                    widget.canvasLayout.gridBackgroundColor,
                                lineWidth: 0.2,
                              ),
                            ),
                          ),

                          // Dynamically build NodeVisuals from the visualiser's state
                          ...nodeWidgets,

                          IgnorePointer(
                            child: CustomPaint(
                              size: Size(widget.canvasLayout.canvasWidth,
                                  widget.canvasLayout.canvasHeight),
                              painter: DataConnectionPainter(
                                widget.visualiser,
                                _dotController,
                                lineColor:
                                    widget.canvasLayout.connectionLineColor,
                                lineColorShadow: widget
                                    .canvasLayout.connectionLineColorShadow,
                                dotColor:
                                    widget.canvasLayout.connectionDotColor,
                                dotColorShadow: widget
                                    .canvasLayout.connectionDotColorShadow,
                                highLightColor:
                                    widget.canvasLayout.highLightColor,
                                enableAnimation: widget
                                    .canvasLayout.connectionEnableAnimation,
                                enableLineGlow: widget
                                    .canvasLayout.connectionEnableLineGlow,
                                enableDotGlow:
                                    widget.canvasLayout.connectionEnableDotGlow,
                                connectionShape:
                                    widget.canvasLayout.connectionShape,
                              ),
                            ),
                          ),

                          if (widget.visualiser.marqueeStartPosition != null &&
                              widget.visualiser.marqueeEndPosition != null)
                            Positioned.fromRect(
                              rect: _calculateRect(
                                  widget.visualiser.marqueeStartPosition!,
                                  widget.visualiser.marqueeEndPosition!),
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: Colors.blueAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
