import 'package:flutter/material.dart';
import '../src/conneciton_point.dart';
import '../src/standart_connection_point.dart';
import 'manager.dart';
import 'node_card.dart';

/// A top-level builder function for [ExampleNode].
///
/// This function builds the node's UI using a [ConnectionPoint]. It locates
/// the nearest [ExampleNode] ancestor via [BuildContext] so that it can pass
/// the node as the owner to the [ConnectionPoint].
Widget exampleNodeBuilder(BuildContext context, NodeCard nodeCard) {
  return Container(
    width: 100,
    height: 70,
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      border: Border.all(
        color: Colors.cyanAccent,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: ConnectionPoint(
          owner: nodeCard,
          id: nodeCard.id.value,
          manager: nodeCard.manager,
          // When selected, display a red square; otherwise, a blue square.
          builder: (isSelected) => StandardConnectionPoint(isSelected),
        ),
      ),
    ),
  );
}

/// A simple example node that wraps the normal [NodeCard] implementation.
///
/// This node uses a builder callback (defined outside) to define its UI.
/// It registers with the [Manager] for position updates and gesture handling,
/// and provides a default [toJson] method for serialization.
class ExampleNode extends NodeCard {
  /// Creates an [ExampleNode] instance.
  ///
  /// [manager] is the Manager responsible for this node.
  /// [id] must be a unique identifier.
  /// [initialPosition] sets the starting canvas position (defaults to Offset.zero).
  ExampleNode({
    Key? key,
    required Manager manager,
    required String id,
    Offset initialPosition = Offset.zero,
  }) : super(
    key: key,
    manager: manager,
    id: id,
    initialPosition: initialPosition,
    builder: (context, nodeCard) => exampleNodeBuilder(context, nodeCard),
  );

  /// Factory constructor to create an [ExampleNode] from a JSON map.
  ///
  /// The [json] map is expected to contain an 'id' and a 'position'
  /// map with 'dx' and 'dy' values.
  factory ExampleNode.fromJson(Map<String, dynamic> json, Manager manager) {
    return ExampleNode(
      manager: manager,
      id: json['id'] as String,
      initialPosition: Offset(
        (json['position']['dx'] as num).toDouble(),
        (json['position']['dy'] as num).toDouble(),
      ),
    );
  }

  /// Serializes the node to a JSON map.
  ///
  /// Overrides the base [toJson] to include a type field specific to this node.
  @override
  Map<String, dynamic> toJson() {
    final jsonMap = super.toJson();
    jsonMap['type'] = 'ExampleNode';
    return jsonMap;
  }
}
