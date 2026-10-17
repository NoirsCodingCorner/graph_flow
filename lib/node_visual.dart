import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graph_flow/graph_flow.dart';
import 'package:graph_flow/port_visual.dart';
import 'node_model.dart';


class NodeViewState{
  final NodeModel model;
  final ValueNotifier<Offset>position;
  final ValueNotifier<Size> size=ValueNotifier(Size.zero);
  final Map<String, PortViewState>ports;

  NodeViewState(this.model, Offset start): position = ValueNotifier(start), ports = {for (final p in model.ports) p.id: PortViewState(p)};
}


/// A visual representation of a NodeModel that manages its own position, size, and layout.
class NodeVisual extends StatefulWidget {
  /// The pure data model defining the node's logic.
  final NodeModel nodeModel;

  /// Tracks the node's absolute position on the canvas layer.
  final ValueNotifier<Offset> position;

  /// Tracks the actual rendered dimensions of the node widget.
  final ValueNotifier<Size> size;

  /// The visual representations of the ports belonging to this node.
  final List<PortVisual> portVisuals;


  final GraphModel graphManager;

  /// A builder function allowing for complete UI customization.
  final Widget Function(BuildContext context, NodeVisual visual, List<PortVisual> portVisuals, GraphModel manager) builder;

  /// Constructs a [NodeVisual].
  NodeVisual({
    super.key,
    required this.nodeModel,
    required Offset initialPosition,
    required this.builder,
    List<PortVisual>? portVisuals,
    required this.graphManager,
  })  : position = ValueNotifier<Offset>(initialPosition),
        size = ValueNotifier<Size>(Size.zero),
        this.portVisuals = portVisuals ?? [];

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
    final renderBox = _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newSize = renderBox.size;
      if (widget.size.value != newSize) {
        widget.size.value = newSize;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. ValueListenableBuilder isolates position updates.
    // Dragging updates the notifier, skipping a full widget rebuild.
    return ValueListenableBuilder<Offset>(
      valueListenable: widget.position,
      builder: (context, position, child) {
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: child!,
        );
      },
      // 2. RepaintBoundary caches the complex custom UI as a static texture.
      // During pans/drags, Flutter merely shifts the image instead of redrawing shadows/shapes.
      child: RepaintBoundary(
        child: MouseRegion(
          onEnter: (details){widget.graphManager.setLastHovered(widget);},
          onExit: (details){widget.graphManager.removeHovered(widget);},
          child: GestureDetector(
            onTap: (){
              widget.graphManager.setLastNode(widget);
              widget.graphManager.selectedNodes.value=[widget];
            },
            onPanUpdate: (details) {
              // Instantly update the node's local position state
              widget.graphManager.nodePositionChanged(widget, details.delta);
              },
            // 3. Automatically triggers an update if the custom builder content resizes dynamically.
            child: NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (notification) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
                return true;
              },
              child: SizeChangedLayoutNotifier(
                child: ValueListenableBuilder(
                  valueListenable: widget.graphManager.selectedNodes,
                  builder: (context, value, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2D31),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: value.contains(widget)?Colors.white:Colors.white12, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      key: _widgetKey,
                      // 4. Defer entirely to your custom builder to dictate the look.
                      child: widget.builder(context, widget, widget.portVisuals, widget.graphManager),
                    );
                  }
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}