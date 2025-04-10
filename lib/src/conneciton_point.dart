import 'package:flutter/material.dart';
import '../src/node_card.dart';
import 'manager.dart';

/// A universally usable connection point that allows connecting to another point of its kind.
///
/// This widget registers itself with a [Manager] and uses callbacks to provide its absolute
/// center offset in the global coordinate system. It also responds to tap events to select or
/// delete connections.
class ConnectionPoint extends StatefulWidget {
  /// The owner of the connection point.
  final NodeCard owner;

  /// The unique identifier for this connection point.
  final String id;

  /// Builder function that creates a widget based on whether the connection point is selected.
  final Widget Function(bool isSelected)? builder;

  /// Manager handling the collection of connection points and connections.
  final Manager manager;

  /// Callback to retrieve the absolute center offset of this connection point widget.
  /// This callback is set internally.
  Offset Function()? getOffsetCallback;

  /// Creates a [ConnectionPoint] with the required parameters.
  ConnectionPoint({
    super.key,
    required this.owner,
    required this.id,
    this.builder,
    this.getOffsetCallback,
    required this.manager,
  });

  @override
  State<ConnectionPoint> createState() => _ConnectionPointState();
}

class _ConnectionPointState extends State<ConnectionPoint> {
  final GlobalKey _key = GlobalKey();

  /// Calculates and returns the absolute center offset of this widget.
  ///
  /// It retrieves the [RenderBox] of the widget, computes the local center, and translates
  /// it to global coordinates. Returns [Offset.zero] if the calculation cannot be performed.
  Offset getAbsoluteCenterOffset() {
    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final localCenter = renderObject.size.center(Offset.zero);
      return renderObject.localToGlobal(localCenter);
    }
    return Offset.zero;
  }

  @override
  void initState() {
    super.initState();
    // Set the callback for retrieving this widget's absolute center.
    widget.getOffsetCallback = getAbsoluteCenterOffset;
    // Register this connection point with the manager.
    widget.manager.addConnectionPoint(widget);
  }

  @override
  void dispose() {
    // Unregister this connection point from the manager.
    widget.manager.removeConnectionPoint(widget);
    super.dispose();
  }

  /// Handles the left-click action on this connection point.
  ///
  /// - If no point is selected, this point becomes selected.
  /// - If another point is already selected, it creates a connection between that point and this one.
  /// - If this point is already selected, it deselects it.
  void isLeftClicked() {
    debugPrint("Left clicked: ${widget.id}");
    if (widget.manager.currentlySelectedPoint.value == null) {
      debugPrint("Selected: ${widget.id}");
      widget.manager.currentlySelectedPoint.value = widget;
    } else if (widget.manager.currentlySelectedPoint.value != widget) {
      debugPrint("Created connection with: ${widget.id}");
      widget.manager.createConnection(widget.manager.currentlySelectedPoint.value!, widget);
      // Log current connections for debugging.
      for (var connection in widget.manager.connections.value) {
        debugPrint("Connection: ${connection.id1}, ${connection.id2}");
      }
      widget.manager.currentlySelectedPoint.value = null;
    } else {
      debugPrint("Deselected: ${widget.id}");
      widget.manager.currentlySelectedPoint.value = null;
    }
  }

  /// Handles the right-click action on this connection point.
  ///
  /// Prompts the user with a confirmation dialog to delete all connections associated with this point.
  void isRightClicked() {
    debugPrint("Right clicked: ${widget.id}");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Connections"),
        content: const Text("Do you want to delete all connections of this node?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Confirm"),
            onPressed: () {
              Navigator.of(context).pop();
              // Log connections before removal.
              for (var connection in widget.manager.connections.value) {
                debugPrint("Before deletion, connection: ${connection.id1}, ${connection.id2}");
              }
              widget.manager.removeConnectionsOfPoint(widget);
              // Log connections after removal.
              for (var connection in widget.manager.connections.value) {
                debugPrint("After deletion, connection: ${connection.id1}, ${connection.id2}");
              }
              widget.manager.currentlySelectedPoint.value = null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: isLeftClicked,
      onSecondaryTap: isRightClicked,
      child: ValueListenableBuilder(
        valueListenable: widget.manager.currentlySelectedPoint,
        builder: (context, selectedPoint, child) {
          // Use the custom builder if available; otherwise, fall back to an empty Container.
          return widget.builder?.call(selectedPoint == widget) ?? Container();
        },
      ),
    );
  }
}
