import 'package:flutter/widgets.dart';
import 'connection_model.dart';
import 'node_model.dart';
import 'port_model.dart';

/// GraphModel represents a standard directed Graph.
/// It contains Nodes ([nodeModels]) and their Connections ([connectionModels]).
/// Every Node in this Graph is an element of [NodeModel] containing a unique Id and several [PortModel] to indicate
/// what type of information to receive or transmit.
/// Methods for the addition of Nodes, connecting Ports etc are provided in this class.
class GraphModel extends ChangeNotifier {
  List<NodeModel> nodeModels = [];
  List<ConnectionModel> connectionModels = [];

  Map<Type, List<Type>> allowedConnections;

  GraphModel({this.allowedConnections = const {}});

  /// Adds a [NodeModel] to the graph and notifies listeners.
  void addNode(NodeModel model) {
    nodeModels.add(model);
    notifyListeners();
  }

  /// Removes a specific [ConnectionModel] from the graph and notifies listeners.
  void removeConnection(ConnectionModel connection) {
    connectionModels.remove(connection);
    notifyListeners();
  }

  /// Checks if two [PortDirection] values are compatible for a connection.
  bool isDirectionCompatible(PortDirection dirA, PortDirection dirB) {
    if (dirA == PortDirection.inout || dirB == PortDirection.inout) return true;
    if (dirA == PortDirection.input && dirB == PortDirection.output) {
      return true;
    }
    if (dirA == PortDirection.output && dirB == PortDirection.input) {
      return true;
    }
    return false;
  }

  /// Validates whether a connection can be successfully established between two ports.
  bool canConnect(PortModel source, NodeModel sourceNode, PortModel target,
      NodeModel targetNode) {
    if (sourceNode.id == targetNode.id) {
      return false;
    }

    if (isDirectionCompatible(source.direction, target.direction) == false) {
      return false;
    }

    PortModel actualOutput = source;
    PortModel actualInput = target;

    if (source.direction == PortDirection.input ||
        target.direction == PortDirection.output) {
      actualOutput = target;
      actualInput = source;
    }

    Type outType = actualOutput.type;
    Type inType = actualInput.type;
    bool isValidType = false;

    if (actualOutput.direction == PortDirection.inout ||
        actualInput.direction == PortDirection.inout) {
      List<Type>? sourceAllowed = allowedConnections[actualOutput.type];
      if (sourceAllowed != null) {
        for (int i = 0; i < sourceAllowed.length; i++) {
          if (sourceAllowed[i] == actualInput.type) isValidType = true;
        }
      }
      List<Type>? targetAllowed = allowedConnections[actualInput.type];
      if (targetAllowed != null) {
        for (int i = 0; i < targetAllowed.length; i++) {
          if (targetAllowed[i] == actualOutput.type) isValidType = true;
        }
      }
    } else {
      List<Type>? allowedTargets = allowedConnections[outType];
      if (allowedTargets != null) {
        for (int i = 0; i < allowedTargets.length; i++) {
          if (allowedTargets[i] == inType) isValidType = true;
        }
      }
    }

    if (isValidType == false) {
      return false;
    }

    for (int i = 0; i < connectionModels.length; i++) {
      ConnectionModel conn = connectionModels[i];
      if (conn.sourcePortId == actualOutput.id &&
          conn.targetPortId == actualInput.id) {
        return false;
      }
    }

    int currentConnections = getConnectionsInto(actualInput).length;
    if (actualInput.maxConnections > 0 &&
        currentConnections >= actualInput.maxConnections) {
      return false;
    }

    return true;
  }

  /// Attempts to create a connection between two ports using their respective IDs and node IDs.
  /// Does check if connection is allowed via [canConnect].
  bool createConnection(String sourceNodeId, String sourcePortId,
      String targetNodeId, String targetPortId) {
    NodeModel? sourceNode;
    for (int i = 0; i < nodeModels.length; i++) {
      if (nodeModels[i].id == sourceNodeId) sourceNode = nodeModels[i];
    }

    NodeModel? targetNode;
    for (int i = 0; i < nodeModels.length; i++) {
      if (nodeModels[i].id == targetNodeId) targetNode = nodeModels[i];
    }

    if (sourceNode == null || targetNode == null) return false;

    PortModel? sourcePort;
    for (int i = 0; i < sourceNode.ports.length; i++) {
      if (sourceNode.ports[i].id == sourcePortId) {
        sourcePort = sourceNode.ports[i];
      }
    }

    PortModel? targetPort;
    for (int i = 0; i < targetNode.ports.length; i++) {
      if (targetNode.ports[i].id == targetPortId) {
        targetPort = targetNode.ports[i];
      }
    }

    if (sourcePort == null || targetPort == null) return false;

    if (canConnect(sourcePort, sourceNode, targetPort, targetNode)) {
      String flowSourceNodeId = sourceNodeId;
      String flowSourcePortId = sourcePortId;
      String flowTargetNodeId = targetNodeId;
      String flowTargetPortId = targetPortId;

      if (sourcePort.direction == PortDirection.input ||
          targetPort.direction == PortDirection.output) {
        flowSourceNodeId = targetNodeId;
        flowSourcePortId = targetPortId;
        flowTargetNodeId = sourceNodeId;
        flowTargetPortId = sourcePortId;
      }

      ConnectionModel newConnection = ConnectionModel(
        sourceNodeId: flowSourceNodeId,
        sourcePortId: flowSourcePortId,
        targetNodeId: flowTargetNodeId,
        targetPortId: flowTargetPortId,
      );

      connectionModels.add(newConnection);
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Deletes all connections that are attached to the given [PortModel].
  bool deleteConnectionsOfPortVisual(PortModel port) {
    int initialCount = connectionModels.length;
    List<ConnectionModel> toKeep = [];

    for (int i = 0; i < connectionModels.length; i++) {
      ConnectionModel model = connectionModels[i];
      if (model.sourcePortId != port.id && model.targetPortId != port.id) {
        toKeep.add(model);
      }
    }
    connectionModels = toKeep;

    if (connectionModels.length < initialCount) {
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Returns a list of all [ConnectionModel] instances going into the given [PortModel].
  List<ConnectionModel> getConnectionsInto(PortModel port) {
    List<ConnectionModel> into = [];
    for (int i = 0; i < connectionModels.length; i++) {
      ConnectionModel connection = connectionModels[i];
      if (connection.targetPortId == port.id) {
        into.add(connection);
      }
    }
    return into;
  }

  /// Returns a list of all [ConnectionModel] instances attached to any port of the given [NodeModel] input, output or inout.
  List<ConnectionModel> getConnectionsOfNode(NodeModel? node) {
    if (node == null) return [];

    List<ConnectionModel> nodeConnections = [];
    for (int i = 0; i < connectionModels.length; i++) {
      ConnectionModel connection = connectionModels[i];
      if (connection.sourceNodeId == node.id ||
          connection.targetNodeId == node.id) {
        nodeConnections.add(connection);
      }
    }
    return nodeConnections;
  }

  /// Generates and returns a unique node ID string using the provided [baseName].
  String getUniqueNodeId(String baseName) {
    int counter = 0;
    bool isUnique = false;
    String newId = "";

    while (isUnique == false) {
      newId = "${baseName}_$counter";
      bool found = false;

      for (int i = 0; i < nodeModels.length; i++) {
        if (nodeModels[i].id == newId) {
          found = true;
        }
      }

      if (found == false) {
        isUnique = true;
      } else {
        counter++;
      }
    }

    return newId;
  }

  /// Generates and returns a unique port ID string using the provided [baseName].
  String getUniquePortId(String baseName) {
    int counter = 0;
    bool isUnique = false;
    String newId = "";

    while (isUnique == false) {
      newId = "${baseName}_$counter";
      bool found = false;

      for (int i = 0; i < nodeModels.length; i++) {
        NodeModel node = nodeModels[i];
        for (int j = 0; j < node.ports.length; j++) {
          if (node.ports[j].id == newId) {
            found = true;
          }
        }
      }

      if (found == false) {
        isUnique = true;
      } else {
        counter++;
      }
    }

    return newId;
  }

  /// Serializes the graph's nodes and connections into a JSON map. Can be stored outside and loaded via [loadFromJson] to retrieve all of the graph again.
  Map<String, dynamic> toJson() {
    List<Map<String, Object?>> nodesJson = [];
    for (int i = 0; i < nodeModels.length; i++) {
      nodesJson.add(nodeModels[i].toJson());
    }

    List<Map<String, String>> connectionsJson = [];
    for (int i = 0; i < connectionModels.length; i++) {
      connectionsJson.add(connectionModels[i].toJson());
    }

    return {
      "nodes": nodesJson,
      "connections": connectionsJson,
    };
  }

  /// Populates the graph's nodes and connections from a JSON map, utilizing a [typeRegistry] to know what to convert types to.
  /// The json representation of the Graph can be retrieved via [toJson].
  void loadFromJson(Map<String, dynamic> json, Map<String, Type> typeRegistry) {
    nodeModels = [];
    connectionModels = [];

    List<Object?> rawNodes = json["nodes"] as List<Object?>;
    for (int i = 0; i < rawNodes.length; i++) {
      Map<String, Object?> nodeJson = rawNodes[i] as Map<String, Object?>;
      nodeModels.add(NodeModel.fromJson(nodeJson, typeRegistry));
    }

    List<Object?> rawConnections = json["connections"] as List<Object?>;
    for (int i = 0; i < rawConnections.length; i++) {
      Map<String, Object?> rawConn = rawConnections[i] as Map<String, Object?>;
      Map<String, String> stringMap = {};

      List<String> keys = rawConn.keys.toList();
      for (int k = 0; k < keys.length; k++) {
        String key = keys[k];
        stringMap[key] = rawConn[key] as String;
      }
      connectionModels.add(ConnectionModel.fromJson(stringMap));
    }

    notifyListeners();
  }
}
