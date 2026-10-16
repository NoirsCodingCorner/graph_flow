
import 'package:flutter/widgets.dart';
import 'package:graph_flow/graph_flow.dart';
import 'connection_model.dart';

/// The central source of truth for the graph's state and validation logic.
class GraphManager extends ChangeNotifier {

  List<NodeModel> nodeModels = [];
  List<NodeVisual> nodeVisuals = [];
  List<ConnectionModel> connectionModels = [];

  NodeVisual? currentlyHoveredNode;
  PortVisual? currentlySelectedPort;
  Offset? mousePosition;

  void updateMousePosition(Offset position) {
    mousePosition = position;
    notifyListeners();
  }

  /// Registers a node and its visual representation into the graph.
  void addNode(NodeModel model, NodeVisual visual) {
    nodeModels.add(model);
    nodeVisuals.add(visual);
    notifyListeners();
  }

  /// Removes a node, its visual, and destroys any associated connections.
  void removeNode(String nodeId) {
    nodeModels.removeWhere((node) => node.id == nodeId);
    nodeVisuals.removeWhere((visual) => visual.nodeModel.id == nodeId);

    connectionModels.removeWhere((conn) =>
    conn.sourceNodeId == nodeId || conn.targetNodeId == nodeId
    );

    notifyListeners();
  }

  void setLastNode(NodeVisual node){
    int index=nodeVisuals.indexOf(node);

    if(index==-1){
      return;
    }
    nodeVisuals.removeAt(index);
    nodeVisuals.add(node);
    notifyListeners();
  }
  void setLastHovered(NodeVisual node){
    currentlyHoveredNode=node;
  }
  void removeHovered(NodeVisual node){
    currentlyHoveredNode=null;
  }

  List<ConnectionModel> connectionsOfNode(NodeModel? node){
    if(node==null){return [];}
    List<ConnectionModel> nodeConnections=[];
    // Iterate over all connections
    for(ConnectionModel connection in connectionModels){
      if(connection.sourceNodeId==node.id || connection.targetNodeId==node.id){
        nodeConnections.add(connection);
      }
    }
    return nodeConnections;
  }

  /// Validates whether two ports can logically connect based on strict rules.
  bool canConnect(PortModel source, NodeModel sourceNode, PortModel target, NodeModel targetNode) {
    if (sourceNode.id == targetNode.id) return false;
    if (source.direction == target.direction) return false;
    if (source.type != target.type) return false;

    bool exists = connectionModels.any((conn) =>
    (conn.sourcePortId == source.id && conn.targetPortId == target.id) ||
        (conn.sourcePortId == target.id && conn.targetPortId == source.id));

    if (exists) return false;

    return true;
  }

  /// Attempts to connect two ports. Returns true if successful.
  bool createConnection(String sourceNodeId, String sourcePortId, String targetNodeId, String targetPortId) {
    NodeModel? sourceNode = nodeModels.where((n) => n.id == sourceNodeId).firstOrNull;
    NodeModel? targetNode = nodeModels.where((n) => n.id == targetNodeId).firstOrNull;

    if (sourceNode == null || targetNode == null) return false;

    PortModel? sourcePort = sourceNode.ports.where((p) => p.id == sourcePortId).firstOrNull;
    PortModel? targetPort = targetNode.ports.where((p) => p.id == targetPortId).firstOrNull;

    if (sourcePort == null || targetPort == null) return false;

    // Validate connection
    if (canConnect(sourcePort, sourceNode, targetPort, targetNode)) {
      ConnectionModel newConnection = ConnectionModel(
        sourceNodeId: sourceNodeId,
        sourcePortId: sourcePortId,
        targetNodeId: targetNodeId,
        targetPortId: targetPortId,
      );

      connectionModels.add(newConnection);
      notifyListeners(); // Trigger the CustomPainter to draw the new line
      return true;
    }

    return false;
  }

  /// Removes an existing connection from the graph.
  void removeConnection(ConnectionModel connection) {
    connectionModels.remove(connection);
    notifyListeners();
  }

  /// Calculates the absolute canvas coordinates for a specific port.
  /// This requires zero widget-tree lookups, relying purely on the layout values
  /// cached in the Visual layers.
  Offset? getAbsolutePortPosition(String nodeId, String portId) {
    // 1. Find the parent NodeVisual
    NodeVisual? nodeVisual = nodeVisuals.where((v) => v.nodeModel.id == nodeId).firstOrNull;
    if (nodeVisual == null) return null;

    // 2. Find the specific PortVisual within the parent
    PortVisual? portVisual = nodeVisual.portVisuals.where((pv) => pv.portModel.id == portId).firstOrNull;
    if (portVisual == null) return null;

    // 3. Absolute Position = Node Base Position + Port Local Offset
    return nodeVisual.position.value + portVisual.localOffset.value;
  }

  NodeVisual? findNode(PortVisual port){
    for(NodeVisual node in nodeVisuals){
      if(node.portVisuals.contains(port)){
        return node;
      }
    }
    return null;
  }

  void leftClicked(PortVisual clicked) {
    if (currentlySelectedPort == null) {
      // First click: select the port
      currentlySelectedPort = clicked;
      notifyListeners();
    } else if (currentlySelectedPort != clicked) {
      // Second click: attempt connection
      createConnection(
        currentlySelectedPort!.parentNodeID,
        currentlySelectedPort!.portModel.id,
        clicked.parentNodeID,
        clicked.portModel.id,
      );

      // FIX: Clear BOTH the selection and the stale mouse position
      currentlySelectedPort = null;
      mousePosition = null;

      notifyListeners();
    } else {
      // Clicked the same port twice: deselect it
      currentlySelectedPort = null;
      mousePosition = null; // FIX
      notifyListeners();
    }
  }
  bool deleteConnectionsOfPortVisual(PortVisual port) {
    int initialCount = connectionModels.length;

    connectionModels.removeWhere((model) =>
    model.sourcePortId == port.portModel.id ||
        model.targetPortId == port.portModel.id
    );

    bool connectionsDeleted = connectionModels.length < initialCount;

    if (connectionsDeleted) {
      notifyListeners();
    }

    return connectionsDeleted;
  }


  void rightClicked(PortVisual clicked){
    currentlySelectedPort=null;
    deleteConnectionsOfPortVisual(clicked);
    notifyListeners();
  }
}