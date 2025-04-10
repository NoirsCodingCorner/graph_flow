import 'package:flutter/material.dart';
import '../src/conneciton_point.dart';
import '../src/connection.dart';
import '../src/node_card.dart';

/// A manager class that coordinates nodes, connection points, and connections in the scene.
///
/// This manager is responsible for tracking the state of the nodes and connections, generating
/// composite IDs to uniquely identify connection points, as well as saving and loading scenes
/// from JSON. It uses [ValueNotifier]s to notify listeners of state changes, allowing for dynamic
/// updates in the UI.
class Manager {
  /// A function used to generate new unique IDs.
  final String Function()? getNewID;

  /// A map associating node types (as strings) with factory functions to create nodes.
  ///
  /// Each factory function accepts a JSON map and a reference to this [Manager],
  /// returning a new [NodeCard] instance.
  final Map<String, Function(Map<String, dynamic>, Manager)> nodeFactories;

  /// Default color for newly created connections.
  final Color? connectionColor;

  /// Creates a [Manager] with the provided ID generator, connection color, and node factories.
  ///
  /// The [getNewID] function is required for ID generation. If [nodeFactories] is not provided,
  /// it defaults to an empty map.
  Manager({
    required this.getNewID,
    this.connectionColor,
    Map<String, Function(Map<String, dynamic>, Manager)>? nodeFactories,
  }) : nodeFactories = nodeFactories ?? {};

  /// A notifier holding the list of nodes in the scene.
  ValueNotifier<List<NodeCard>> nodes = ValueNotifier<List<NodeCard>>([]);

  /// A notifier holding the list of connection points.
  ValueNotifier<List<ConnectionPoint>> connectionPoints =
  ValueNotifier<List<ConnectionPoint>>([]);

  /// A notifier holding the list of connections between nodes.
  ValueNotifier<List<Connection>> connections = ValueNotifier<List<Connection>>([]);

  /// A notifier for the mouse position in the scene.
  ValueNotifier<Offset> mousePosition = ValueNotifier<Offset>(Offset.zero);

  /// The offset of the canvas (for panning or scrolling).
  ValueNotifier<Offset> canvasOffset = ValueNotifier<Offset>(Offset.zero);

  /// The currently selected connection point, if any.
  ValueNotifier<ConnectionPoint?> currentlySelectedPoint =
  ValueNotifier<ConnectionPoint?>(null);

  //////////////////////////////////////////////////////////////////////////////
  //                          ID-RELATED FUNCTIONS                          //
  //////////////////////////////////////////////////////////////////////////////

  /// Generates a composite ID for a given [point].
  ///
  /// The composite ID is created by joining the [NodeCard]'s ID (accessible via [point.owner.id.value])
  /// and the connection point's own ID. This ensures that each connection point is uniquely
  /// associated with its parent node.
  ///
  /// Example: `"nodeId_pointId"`.
  String getCompositeId(ConnectionPoint point) {
    return '${point.owner.id.value}_${point.id}';
  }

  //////////////////////////////////////////////////////////////////////////////
  //                         NODE-RELATED FUNCTIONS                           //
  //////////////////////////////////////////////////////////////////////////////

  /// Adds a [node] to the manager.
  ///
  /// If the node is already present, it is first removed and then re-added.
  /// This method notifies listeners of changes in the node list.
  void addNode(NodeCard node) {
    if (nodes.value.contains(node)) {
      removeNode(node);
    }
    nodes.value.add(node);
    nodes.notifyListeners();
  }

  /// Removes the specified [node] from the manager.
  ///
  /// Notifies listeners after removal.
  void removeNode(NodeCard node) {
    nodes.value.remove(node);
    nodes.notifyListeners();
  }

  /// Creates a new [NodeCard] instance from a JSON object.
  ///
  /// The JSON must include a `type` field used to determine the proper factory function.
  /// If the type is not found in [nodeFactories], an exception is thrown.
  ///
  /// Throws an [Exception] if the node type is unknown.
  NodeCard loadNodeFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final factory = nodeFactories[type];
    if (factory != null) {
      return factory(json, this);
    }
    throw Exception('Unknown NodeCard type: $type');
  }

  //////////////////////////////////////////////////////////////////////////////
  //                    CONNECTION POINT-RELATED FUNCTIONS                    //
  //////////////////////////////////////////////////////////////////////////////

  /// Adds a [connectionPoint] to the manager.
  ///
  /// Notifies listeners after the addition.
  void addConnectionPoint(ConnectionPoint connectionPoint) {
    connectionPoints.value.add(connectionPoint);
    connectionPoints.notifyListeners();
  }

  /// Removes a [connectionPoint] from the manager.
  ///
  /// Notifies listeners after the removal.
  void removeConnectionPoint(ConnectionPoint connectionPoint) {
    connectionPoints.value.remove(connectionPoint);
    connectionPoints.notifyListeners();
  }

  /// Removes all connections associated with the provided [point].
  ///
  /// This is determined by comparing each connection's composite IDs with that of the given [point].
  void removeConnectionsOfPoint(ConnectionPoint point) {
    String compositeId = getCompositeId(point);
    List<Connection> currentConnections = connections.value;
    currentConnections.removeWhere((connection) =>
    connection.id1 == compositeId || connection.id2 == compositeId);
    connections.value = List.from(currentConnections);
  }

  /// Retrieves the parent node's ID for the connection point identified by [pointCompositeId].
  ///
  /// Looks up the connection point and returns its parent's (node's) ID.
  /// Returns `null` if no matching point is found.
  ValueNotifier? getParentIdOfPoint(String pointCompositeId) {
    try {
      final point = connectionPoints.value.firstWhere(
            (point) => getCompositeId(point) == pointCompositeId,
      );
      return point.owner.id;
    } catch (e) {
      return null;
    }
  }

  /// Returns a list of card IDs that are connected to the [self] connection point.
  ///
  /// Iterates through related connections and extracts the parent node IDs of the connected points.
  /// Duplicate IDs are removed by using a [Set].
  List<String> getCardIdsOfPoint(ConnectionPoint self) {
    List<Connection> relConnections = getConnectionsOfPoint(self);
    Set<String> ids = {};

    for (final connection in relConnections) {
      // Helper function to retrieve the partner's parent card ID.
      String getPartnerCardId(String partnerCompositeId) {
        final matchingPoints = connectionPoints.value.where(
              (point) => getCompositeId(point) == partnerCompositeId,
        );
        if (matchingPoints.isNotEmpty) {
          return matchingPoints.first.owner.id.value;
        }
        return '';
      }

      String compositeSelf = getCompositeId(self);

      if (compositeSelf == connection.id1) {
        final partnerCardId = getPartnerCardId(connection.id2);
        if (partnerCardId.isNotEmpty) {
          ids.add(partnerCardId);
        }
      }
      if (compositeSelf == connection.id2) {
        final partnerCardId = getPartnerCardId(connection.id1);
        if (partnerCardId.isNotEmpty) {
          ids.add(partnerCardId);
        }
      }
    }

    return ids.toList();
  }

  //////////////////////////////////////////////////////////////////////////////
  //                         CONNECTION-RELATED FUNCTIONS                     //
  //////////////////////////////////////////////////////////////////////////////

  /// Adds a [connection] between two connection points.
  ///
  /// Notifies listeners after adding the connection.
  void addConnection(Connection connection) {
    connections.value.add(connection);
    connections.notifyListeners();
  }

  /// Removes a [connection] from the manager.
  ///
  /// Notifies listeners after removal.
  void removeConnection(Connection connection) {
    connections.value.remove(connection);
    connections.notifyListeners();
  }

  /// Creates a connection between two connection points [point1] and [point2].
  ///
  /// This method checks to ensure the two points are not identical and that a connection does
  /// not already exist between them. If valid, it creates a new [Connection] with generated
  /// composite IDs and adds it to the manager.
  void createConnection(ConnectionPoint point1, ConnectionPoint point2) {
    final compositeId1 = getCompositeId(point1);
    final compositeId2 = getCompositeId(point2);

    // Prevent connecting a point to itself.
    if (compositeId1 == compositeId2) return;

    // Check if a connection between these points already exists.
    final connectionExists = connections.value.any((connection) =>
    (connection.id1 == compositeId1 && connection.id2 == compositeId2) ||
        (connection.id1 == compositeId2 && connection.id2 == compositeId1));
    if (connectionExists) return;

    // Create and add the new connection.
    final connection = Connection(compositeId1, compositeId2, connectionColor);
    connections.value.add(connection);
    connections.notifyListeners();
  }

  /// Retrieves a list of all connections that involve the given [point].
  List<Connection> getConnectionsOfPoint(ConnectionPoint point) {
    String compositeId = getCompositeId(point);
    return connections.value
        .where((connection) =>
    connection.id1 == compositeId || connection.id2 == compositeId)
        .toList();
  }

  //////////////////////////////////////////////////////////////////////////////
  //                           SCENE-RELATED FUNCTIONS                        //
  //////////////////////////////////////////////////////////////////////////////

  /// Loads a scene from a JSON map by clearing existing data and repopulating it
  /// with nodes and connections.
  ///
  /// The JSON should have the following structure:
  /// ```json
  /// {
  ///   "canvasOffset": {"dx": number, "dy": number},
  ///   "nodes": [ { "id": string, "type": string, ... }, ... ],
  ///   "connections": [ { "id1": "cardId_pointName", "id2": "cardId_pointName", ... }, ... ]
  /// }
  /// ```
  ///
  /// - The `canvasOffset` (if present) updates the manager's canvas offset.
  /// - Each node in `nodes` is created using [loadNodeFromJson] and added via [addNode].
  /// - A temporary node ID mapping is used for reconstructing connection composite IDs.
  void loadSceneFromJson(Map<String, dynamic> sceneJson) {
    // Clear existing data.
    nodes.value.clear();
    connectionPoints.value.clear();
    connections.value.clear();

    // Update canvas offset if provided.
    if (sceneJson.containsKey('canvasOffset')) {
      final offset = sceneJson['canvasOffset'];
      if (offset is Map) {
        canvasOffset.value = Offset(
          (offset['dx'] as num?)?.toDouble() ?? 0.0,
          (offset['dy'] as num?)?.toDouble() ?? 0.0,
        );
      }
    }

    // Mapping of old node IDs to new node IDs (if needed).
    final Map<String, String> nodeIdMapping = {};

    // Load nodes from JSON.
    final List<dynamic> nodesJson = sceneJson['nodes'] as List<dynamic>? ?? [];
    for (final dynamic nodeData in nodesJson) {
      if (nodeData is Map<String, dynamic>) {
        final String? oldId = nodeData['id'] as String?;
        if (oldId == null) continue;
        final NodeCard node = loadNodeFromJson(nodeData);
        // In this example, node IDs remain unchanged.
        nodeIdMapping[oldId] = oldId;
        addNode(node);
      }
    }

    // Load connections from JSON.
    final List<Connection> loadedConnections = [];
    final List<dynamic> connectionsJson = sceneJson['connections'] as List<dynamic>? ?? [];
    for (final dynamic connectionData in connectionsJson) {
      if (connectionData is Map<String, dynamic>) {
        final String? oldCompositeId1 = connectionData['id1'] as String?;
        final String? oldCompositeId2 = connectionData['id2'] as String?;
        if (oldCompositeId1 == null || oldCompositeId2 == null) continue;

        // Each composite ID should be in the form "cardId_pointName".
        final List<String> parts1 = oldCompositeId1.split("_");
        final List<String> parts2 = oldCompositeId2.split("_");
        if (parts1.length != 2 || parts2.length != 2) continue;

        final String oldCardId1 = parts1[0];
        final String pointName1 = parts1[1];
        final String oldCardId2 = parts2[0];
        final String pointName2 = parts2[1];

        // Map old card IDs using nodeIdMapping.
        final String cardId1 = nodeIdMapping[oldCardId1] ?? oldCardId1;
        final String cardId2 = nodeIdMapping[oldCardId2] ?? oldCardId2;

        final String newCompositeId1 = '${cardId1}_$pointName1';
        final String newCompositeId2 = '${cardId2}_$pointName2';

        loadedConnections.add(Connection(newCompositeId1, newCompositeId2, connectionColor));
      }
    }
    // Update the connections notifier once to trigger listeners.
    connections.value = loadedConnections;
  }

  /// Saves the current scene to a JSON map.
  ///
  /// The returned JSON contains the current [canvasOffset], a list of nodes, and a list of connections.
  /// Nodes and connections are assumed to have their own [toJson] methods.
  Map<String, dynamic> saveSceneToJson() {
    final Map<String, dynamic> sceneJson = {
      "canvasOffset": {
        "dx": canvasOffset.value.dx,
        "dy": canvasOffset.value.dy,
      },
      "nodes": nodes.value.map((card) => card.toJson()).toList(),
      "connections": connections.value.map((connection) => connection.toJson()).toList(),
    };
    return sceneJson;
  }

  //////////////////////////////////////////////////////////////////////////////
  //                         AREA CALCULATION FUNCTIONS                       //
  //////////////////////////////////////////////////////////////////////////////

  /// Returns a list of rectangular areas ([Rect]) covered by the widgets associated with the given list of [GlobalKey]s.
  ///
  /// For each [GlobalKey], this method attempts to find its [RenderBox] via the widget's context.
  /// If found, it calculates the widget's global offset and size, returning a [Rect] that represents
  /// the area covered by that widget.
  ///
  /// Keys with invalid or unmounted render objects are skipped.
  List<Rect> getAreasFromKeys(List<GlobalKey> keys) {
    final List<Rect> areas = [];
    for (GlobalKey key in keys) {
      final RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject is RenderBox) {
        final Offset offset = renderObject.localToGlobal(Offset.zero);
        final Rect rect = offset & renderObject.size;
        areas.add(rect);
      }
    }
    return areas;
  }

  /// Returns a list of [Rect] objects that represent all the areas covered by the nodes.
  ///
  /// This method extracts the [GlobalKey]s from each [NodeCard] and calculates the corresponding
  /// rectangular areas using [getAreasFromKeys].
  List<Rect> getAllCoveredAreas() {
    final List<GlobalKey> keys = nodes.value.map((card) => card.globalKey).toList();
    return getAreasFromKeys(keys);
  }
}
