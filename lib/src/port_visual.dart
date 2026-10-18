import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import 'graph_visualiser.dart';
import 'port_model.dart';

class PortViewState{
  String nodeId;
  final PortModel model;
  final ValueNotifier<Offset?>localOffset= ValueNotifier(null);

  PortViewState(this.model, this.nodeId);
}

/// The Widget for the PortViewState Objects Rendering.
/// Does only contain:
/// - [portViewState]: the state object to render.
/// - [graphVisualizer]: the [GraphVisualiser] that is responsible to render the actual graph.
/// - [builder]: build function for this specific type of port.
class PortVisual extends StatefulWidget {

  final PortViewState portViewState;
  final GraphVisualiser graphVisualizer;

  /// Tracks the port's center coordinate relative to the top-left corner of its parent NodeVisual.

  /// A builder function allowing for complete UI customization of the port.
  final Widget Function(BuildContext context, PortVisual visual) builder;


  /// Constructs a [PortVisual].
  const PortVisual({
    super.key,
    required this.portViewState,
    required this.graphVisualizer,
    required this.builder,
  });

  @override
  State<PortVisual> createState() => _PortVisualState();
}

class _PortVisualState extends State<PortVisual> {
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

      if (widget.portViewState.localOffset.value != calculatedLocalOffset) {
        widget.portViewState.localOffset.value = calculatedLocalOffset;
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
            widget.graphVisualizer.leftClicked(widget.portViewState);
          },
          onSecondaryTap: (){
            widget.graphVisualizer.rightClicked(widget.portViewState);
          },
          // 1. Listen to the manager for state changes
          child: ListenableBuilder(
            listenable: widget.graphVisualizer,
            builder: (context, child) {
              return Container(
                foregroundDecoration: BoxDecoration(
                  color: widget.graphVisualizer.currentlySelectedPort == widget.portViewState
                      ? Colors.black.withValues(alpha: 0.4)
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