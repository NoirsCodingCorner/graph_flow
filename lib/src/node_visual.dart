import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'graph_visualiser.dart';
import 'node_model.dart';
import 'port_model.dart';
import 'port_visual.dart';
import 'position_snapper.dart';

/// The state of a visual node element. The NodeVisual uses this to render and react to changes
/// properly. Contains a reference to [model], [position], [size] and the PortViewStates of [ports].
/// If [paintOrder] is 0 it is considered standard node. With paintOrder 1 it will be drawn above the other nodes.
class NodeViewState {
  final NodeModel model;
  final ValueNotifier<Offset> position;
  final ValueNotifier<Size> size = ValueNotifier(Size.zero);
  final Map<String, PortViewState> ports;
  int paintOrder = 0;

  NodeViewState(this.model, Offset start)
      : position = ValueNotifier(start),
        ports = {
          for (PortModel p in model.ports) p.id: PortViewState(p, model.id)
        };
}

/// The Widget to render a NodeViewState.
/// Does only contain:
/// - [nodeViewState]: the state object to render.
/// - [graphVisualizer]: the [GraphVisualiser] that is responsible to render the actual graph.
/// - [builder]: build function for the specified type of node.
class NodeVisual extends StatefulWidget {
  final NodeViewState nodeViewState;
  final GraphVisualiser graphVisualizer;

  /// A builder function allowing for complete UI customization.
  final Widget Function(BuildContext context, NodeViewState state,
      Map<String, PortVisual> ports) builder;

  /// Constructs a [NodeVisual].
  const NodeVisual({
    super.key,
    required this.nodeViewState, // NodeViewState, created by the visualiser
    required this.graphVisualizer,
    required this.builder,
  });

  @override
  State<NodeVisual> createState() => _NodeVisualState();
}

class _NodeVisualState extends State<NodeVisual> {
  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
  }

  /// Calculates the bounding box of the widget and updates the size notifier.
  void _updateSize() {
    final renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newSize = renderBox.size;
      if (widget.nodeViewState.size.value != newSize) {
        widget.nodeViewState.size.value = newSize;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ports = {
      for (final p in widget.nodeViewState.ports.values)
        p.model.id: PortVisual(
          key: ValueKey(p.model.id),
          portViewState: p,
          graphVisualizer: widget.graphVisualizer,
          builder: widget.graphVisualizer.getPortBuilderByType(p.model.type),
        ),
    };
    // 1. ValueListenableBuilder isolates position updates.
    // Dragging updates the notifier, skipping a full widget rebuild.
    return ValueListenableBuilder<Offset>(
      valueListenable: widget.nodeViewState.position,
      builder: (context, position, child) {
        Offset snappedPosition = PositionSnapper.snapOffset(position)!;
        return Positioned(
          left: snappedPosition.dx,
          top: snappedPosition.dy,
          child: child!,
        );
      },
      // 2. RepaintBoundary caches the complex custom UI as a static texture.
      // During pans/drags, Flutter merely shifts the image instead of redrawing shadows/shapes.
      child: RepaintBoundary(
        child: MouseRegion(
          onEnter: (details) {
            widget.graphVisualizer.setLastHovered(widget.nodeViewState);
          },
          onExit: (details) {
            widget.graphVisualizer.removeHovered(widget.nodeViewState);
          },
          child: GestureDetector(
            onTap: () {
              if (HardwareKeyboard.instance.isShiftPressed) {
                if (widget.graphVisualizer.selectedNodes.value
                    .contains(widget.nodeViewState)) {
                  widget.graphVisualizer.selectedNodes.value
                      .remove(widget.nodeViewState);
                  widget.graphVisualizer.selectedNodes.value = [
                    ...widget.graphVisualizer.selectedNodes.value
                  ];
                } else {
                  widget.graphVisualizer.selectedNodes.value = [
                    ...widget.graphVisualizer.selectedNodes.value,
                    widget.nodeViewState
                  ];
                }
              } else {
                widget.graphVisualizer.selectedNodes.value = [widget.nodeViewState];
              }
            },
            onPanUpdate: (details) {
              // Instantly update the node's local position state
              widget.graphVisualizer
                  .nodePositionChanged(widget.nodeViewState, details.delta);
            },
            // 3. Automatically triggers an update if the custom builder content resizes dynamically.
            child: NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (notification) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _updateSize());
                return true;
              },
              child: SizeChangedLayoutNotifier(
                child: ValueListenableBuilder(
                    valueListenable: widget.graphVisualizer.selectedNodes,
                    builder: (context, value, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2D31),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: value.contains(widget.nodeViewState)
                                  ? Colors.white
                                  : Colors.white12,
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        key: _widgetKey,
                        child: widget.builder(
                            context, widget.nodeViewState, ports),
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
