import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:graph_flow/graph_flow.dart';
import 'package:material_ui/material_ui.dart';
import 'port_model.dart';

/// A visual representation of a PortModel that tracks its local position within a NodeVisual.
class PortVisual extends StatefulWidget {
  /// The pure data model defining the port's logic, direction, and data type.
  final PortModel portModel;

  /// Tracks the port's center coordinate relative to the top-left corner of its parent NodeVisual.
  final ValueNotifier<Offset> localOffset;

  /// A builder function allowing for complete UI customization of the port.
  final Widget Function(BuildContext context, PortVisual visual) builder;

  final GraphManager graphManager;
  String parentNodeID;

  /// Constructs a [PortVisual].
  PortVisual({
    super.key,
    required this.portModel,
    required this.builder,
    Offset initialLocalOffset = Offset.zero,
    required this.graphManager,
    required this.parentNodeID
  }) : localOffset = ValueNotifier<Offset>(initialLocalOffset);

  @override
  State<PortVisual> createState() => _PortVisualState();
}

class _PortVisualState extends State<PortVisual> {
  // Key used to measure the physical location and size of the port widget.
  final GlobalKey _portKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Schedule a measurement pass immediately after the first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLocalOffset());
  }

  /// Calculates the exact center of this port relative to the parent NodeVisual.
  void _updateLocalOffset() {
    final renderBox = _portKey.currentContext?.findRenderObject() as RenderBox?;

    // CHANGE HERE: Target the RenderRepaintBoundary specifically, skipping over
    // all the intermediate Padding and Row RenderBoxes.
    final parentNodeBox = context.findAncestorRenderObjectOfType<RenderRepaintBoundary>();

    if (renderBox != null && parentNodeBox != null) {
      final centerOfPort = renderBox.size.center(Offset.zero);

      final calculatedLocalOffset = renderBox.localToGlobal(
        centerOfPort,
        ancestor: parentNodeBox, // This is now mathematically locked to the Node's root
      );

      if (widget.localOffset.value != calculatedLocalOffset) {
        widget.localOffset.value = calculatedLocalOffset;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateLocalOffset());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: GestureDetector(
          onTap: () {
            widget.graphManager.leftClicked(widget);
          },
          onSecondaryTap: (){
            widget.graphManager.rightClicked(widget);
          },
          // 1. Listen to the manager for state changes
          child: ListenableBuilder(
            listenable: widget.graphManager,
            builder: (context, child) {
              return Container(
                foregroundDecoration: BoxDecoration(
                  color: widget.graphManager.currentlySelectedPort == widget
                      ? Colors.black.withOpacity(0.4)
                      : Colors.transparent,
                ),
                // 3. Render the cached child (the port UI) underneath the overlay
                child: child,
              );
            },
            // 2. Cache the expensive custom builder content so it doesn't rebuild on every selection change
            child: Container(
              key: _portKey,
              child: widget.builder(context, widget),
            ),
          ),
        ),
      ),
    );
  }
}