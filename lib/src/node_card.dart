import 'package:flutter/material.dart';
import 'manager.dart';

/// A universally usable node card that represents a draggable widget on a canvas.
///
/// This implementation now accepts a builder callback that returns the node's visual
/// representation instead of a fixed child widget. It also includes:
/// - A [manager] that manages the node.
/// - A builder callback [builder] for constructing the node's UI.
/// - A [position] notifier tracking the node's canvas position.
/// - A [id] notifier holding the node's unique identifier.
/// - A default [toJson] method that serializes the node's id and position.
///
/// The node registers itself with the manager on initialization and removes itself on dispose.
class NodeCard extends StatefulWidget {
  /// Manager that handles this node.
  final Manager manager;

  /// A builder callback that returns the visual representation of the node.
  final Widget Function(BuildContext, NodeCard) builder;

  /// Notifier for the node's position on the canvas.
  final ValueNotifier<Offset> position;

  /// Notifier for the node's unique identifier.
  final ValueNotifier<String> id;

  /// Internal key used to find the widget in the tree.
  final GlobalKey globalKey = GlobalKey();

  /// Creates a [NodeCard].
  ///
  /// [manager] is required to manage this node.
  /// [builder] is a callback that builds the visual representation.
  /// [id] must be unique.
  /// [initialPosition] sets the starting position on the canvas.
  NodeCard({
    Key? key,
    required this.manager,
    required this.builder,
    required String id,
    Offset initialPosition = Offset.zero,
  })  : position = ValueNotifier<Offset>(initialPosition),
        id = ValueNotifier<String>(id),
        super(key: key);

  /// Factory constructor that creates a [NodeCard] from a JSON map.
  ///
  /// The [json] map must contain an 'id' and a 'position' with 'dx' and 'dy' values.
  factory NodeCard.fromJson({
    required Manager manager,
    required Widget Function(BuildContext, NodeCard) builder,
    required Map<String, dynamic> json,
  }) {
    return NodeCard(
      manager: manager,
      builder: builder,
      id: json['id'] as String,
      initialPosition: Offset(
        (json['position']['dx'] as num).toDouble(),
        (json['position']['dy'] as num).toDouble(),
      ),
    );
  }

  /// Serializes the node into a JSON-compatible map.
  ///
  /// The default implementation returns the node's unique id and its current position.
  Map<String, dynamic> toJson() {
    return {
      'type': 'NodeCard', // Default type identifier; override in subclasses if needed.
      'id': id.value,
      'position': {
        'dx': position.value.dx,
        'dy': position.value.dy,
      },
    };
  }

  @override
  State<NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard> {
  /// Registers the node with the manager when the widget is initialized.
  @override
  void initState() {
    super.initState();
  }

  /// Removes the node from the manager when the widget is disposed.
  @override
  void dispose() {
    widget.manager.removeNode(widget);
    super.dispose();
  }

  /// Builds the widget by wrapping the built child in a [GestureDetector]
  /// that updates the node's position based on pan updates.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.globalKey,
      child: widget.builder(context, widget),
      onPanUpdate: (details) {
        widget.position.value += details.delta;
      },
    );
  }
}
