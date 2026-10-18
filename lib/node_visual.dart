import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:graph_flow/graph_flow.dart';
import 'package:graph_flow/port_visual.dart';
import 'package:graph_flow/position_snapper.dart';
import 'node_model.dart';

class NodeViewState {
  final NodeModel model;
  final ValueNotifier<Offset> position;
  final ValueNotifier<Size> size = ValueNotifier(Size.zero);
  final Map<String, PortViewState> ports;

  NodeViewState(this.model, Offset start)
      : position = ValueNotifier(start),
        ports = {
          for (PortModel p in model.ports) p.id: PortViewState(p, model.id)
        };
}

/// A visual representation of a NodeModel that manages its own position, size, and layout.
class NodeVisual extends StatefulWidget {
  final NodeViewState nodeViewState;
  final GraphVisualiser visualiser;

  /// A builder function allowing for complete UI customization.
  final Widget Function(BuildContext context, NodeViewState state,
      Map<String, PortVisual> ports) builder;

  /// Constructs a [NodeVisual].
  NodeVisual({
    super.key,
    required this.nodeViewState, // NodeViewState, created by the visualiser
    required this.visualiser,
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
          graphVisualizer: widget.visualiser,
          builder: widget.visualiser.getPortBuilderByType(p.model.type),
        ),
    };
    // 1. ValueListenableBuilder isolates position updates.
    // Dragging updates the notifier, skipping a full widget rebuild.
    return ValueListenableBuilder<Offset>(
      valueListenable: widget.nodeViewState.position,
      builder: (context, position, child) {
        Offset snappedPosition = PositionSnapper.snapOffset(position);
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
            widget.visualiser.setLastHovered(widget.nodeViewState);
          },
          onExit: (details) {
            widget.visualiser.removeHovered(widget.nodeViewState);
          },
          child: GestureDetector(
            onTap: () {
              if (HardwareKeyboard.instance.isShiftPressed) {
                if (widget.visualiser.selectedNodes.value
                    .contains(widget.nodeViewState)) {
                  widget.visualiser.selectedNodes.value
                      .remove(widget.nodeViewState);
                  widget.visualiser.selectedNodes.value = [
                    ...widget.visualiser.selectedNodes.value
                  ];
                } else {
                  widget.visualiser.selectedNodes.value = [
                    ...widget.visualiser.selectedNodes.value,
                    widget.nodeViewState
                  ];
                }
              } else {
                widget.visualiser.selectedNodes.value = [widget.nodeViewState];
              }
              print(widget.visualiser.selectedNodes.value.length);
            },
            onPanUpdate: (details) {
              // Instantly update the node's local position state
              widget.visualiser
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
                    valueListenable: widget.visualiser.selectedNodes,
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
                              color: Colors.black.withOpacity(0.3),
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
