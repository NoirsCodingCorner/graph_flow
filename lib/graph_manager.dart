
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:graph_flow/graph_flow.dart';
import 'connection_model.dart';

class GraphModel extends ChangeNotifier {
  List<NodeModel> nodeModels = [];
  List<ConnectionModel> connectionModels = [];

  Map<Type, List<Type>> allowedConnections;

  GraphModel({this.allowedConnections = const {}});

  void addNode(NodeModel model) {
    nodeModels.add(model);
    notifyListeners();
  }

  void removeConnection(ConnectionModel connection) {
    connectionModels.remove(connection);
    notifyListeners();
  }

  bool isDirectionCompatible(PortDirection dirA, PortDirection dirB) {
    if (dirA == PortDirection.inout) { return true; }
    if (dirB == PortDirection.inout) { return true; }
    if (dirA == PortDirection.input && dirB == PortDirection.output) { return true; }
    if (dirA == PortDirection.output && dirB == PortDirection.input) { return true; }
    return false;
  }

  bool canConnect(PortModel source, NodeModel sourceNode, PortModel target, NodeModel targetNode) {
    if (sourceNode.id == targetNode.id) {
      return false;
    }

    bool directionOk = isDirectionCompatible(source.direction, target.direction);
    if (directionOk == false) {
      return false;
    }

    Type outType = source.type;
    Type inType = target.type;

    if (source.direction == PortDirection.input) {
      outType = target.type;
      inType = source.type;
    }

    bool isValidType = false;

    if (source.direction == PortDirection.inout || target.direction == PortDirection.inout) {
      List<Type>? sourceAllowed = allowedConnections[source.type];
      if (sourceAllowed != null) {
        for (int i = 0; i < sourceAllowed.length; i++) {
          if (sourceAllowed[i] == target.type) {
            isValidType = true;
          }
        }
      }
      List<Type>? targetAllowed = allowedConnections[target.type];
      if (targetAllowed != null) {
        for (int i = 0; i < targetAllowed.length; i++) {
          if (targetAllowed[i] == source.type) {
            isValidType = true;
          }
        }
      }
    } else {
      List<Type>? allowedTargets = allowedConnections[outType];
      if (allowedTargets != null) {
        for (int i = 0; i < allowedTargets.length; i++) {
          if (allowedTargets[i] == inType) {
            isValidType = true;
          }
        }
      }
    }

    if (isValidType == false) {
      return false;
    }

    bool exists = false;
    for (int i = 0; i < connectionModels.length; i++) {
      ConnectionModel conn = connectionModels[i];
      if (conn.sourcePortId == source.id && conn.targetPortId == target.id) {
        exists = true;
      }
      if (conn.sourcePortId == target.id && conn.targetPortId == source.id) {
        exists = true;
      }
    }

    if (exists) {
      return false;
    }

    return true;
  }

  bool createConnection(String sourceNodeId, String sourcePortId, String targetNodeId, String targetPortId) {
    NodeModel? sourceNode;
    for (int i = 0; i < nodeModels.length; i++) {
      if (nodeModels[i].id == sourceNodeId) {
        sourceNode = nodeModels[i];
      }
    }

    NodeModel? targetNode;
    for (int i = 0; i < nodeModels.length; i++) {
      if (nodeModels[i].id == targetNodeId) {
        targetNode = nodeModels[i];
      }
    }

    if (sourceNode == null || targetNode == null) {
      return false;
    }

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

    if (sourcePort == null || targetPort == null) {
      return false;
    }

    bool valid = canConnect(sourcePort, sourceNode, targetPort, targetNode);
    if (valid) {
      ConnectionModel newConnection = ConnectionModel(
        sourceNodeId: sourceNodeId,
        sourcePortId: sourcePortId,
        targetNodeId: targetNodeId,
        targetPortId: targetPortId,
      );

      connectionModels.add(newConnection);
      notifyListeners();
      return true;
    }

    return false;
  }

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

    bool connectionsDeleted = connectionModels.length < initialCount;

    if (connectionsDeleted) {
      notifyListeners();
    }

    return connectionsDeleted;
  }

  List<ConnectionModel> getConnectionsOfNode(NodeModel? node) {
    if (node == null) {
      return [];
    }

    List<ConnectionModel> nodeConnections = [];
    for (int i = 0; i < connectionModels.length; i++) {
      ConnectionModel connection = connectionModels[i];
      if (connection.sourceNodeId == node.id || connection.targetNodeId == node.id) {
        nodeConnections.add(connection);
      }
    }
    return nodeConnections;
  }
}

class GraphVisualiser extends ChangeNotifier{
  GraphModel model;
  GraphVisualiser(this.model);
  /// Visual representation of the nodes
  Map<String,NodeViewState> nodeViewStates = {};

  NodeViewState? currentlyHoveredNode;
  PortViewState? currentlySelectedPort;
  /// Temporal UI states representation

  ValueNotifier<List<NodeViewState>>selectedNodes=ValueNotifier([]);

  Offset? mousePosition;
  Offset?marqueeStartPosition;
  Offset?marqueeEndPosition;

  Map<String,Widget Function(BuildContext context, NodeViewState state, Map<String, PortVisual> ports)> nodeBuilders={};
  Map<Type,Widget Function(BuildContext context, PortVisual visual)> portBuilders={};

  Widget Function(BuildContext context, NodeViewState state, Map<String, PortVisual> ports)? getNodeBuilderByType(String typeName){
    return nodeBuilders[typeName]!;
  }
  Widget Function(BuildContext context, PortVisual visual) getPortBuilderByType(Type type){
    return portBuilders[type]!;
  }


  void updateMousePosition(Offset position) {
    mousePosition = position;
    if(currentlySelectedPort!=null){
      notifyListeners();
    }
  }

  void setLastHovered(NodeViewState node){
    currentlyHoveredNode=node;
    notifyListeners();
  }
  void removeHovered(NodeViewState node){
    currentlyHoveredNode=null;
    notifyListeners();
  }

  Offset? getAbsolutePortPosition(String nodeId, String portId) {
    // 1. Find the parent NodeViewState
    NodeViewState? nodeViewState = nodeViewStates[nodeId];
    if (nodeViewState == null) return null;

    // 2. Look up PortViewState directly by portId in the ports map
    PortViewState? portVisual = nodeViewState.ports[portId];
    if (portVisual == null) return null;

    // 3. Extract and verify the local offset
    Offset? localOffset = portVisual.localOffset.value;
    if (localOffset == null) return null;

    // 4. Absolute Position = Node Base Position + Port Local Offset
    return nodeViewState.position.value + localOffset;
  }

  void leftClicked(PortViewState clicked) {
    if (currentlySelectedPort == null) {
      // First click: select the port
      currentlySelectedPort = clicked;
      notifyListeners();
    } else if (currentlySelectedPort != clicked) {
      // Second click: attempt connection
      model.createConnection(
        currentlySelectedPort!.nodeId,
        currentlySelectedPort!.model.id,
        clicked.nodeId,
        clicked.model.id,
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
  void rightClicked(PortViewState clicked){
    currentlySelectedPort=null;
    model.deleteConnectionsOfPortVisual(clicked.model);
    notifyListeners();
  }


  void nodePositionChanged(NodeViewState node, Offset delta ){
    if(!selectedNodes.value.contains(node)){
      selectedNodes.value=[node];
    }
    //node.position.value+=delta;

    for(NodeViewState selNode in selectedNodes.value){
      selNode.position.value+=delta;
    }

    notifyListeners();
  }

  void selectInMarquee(){
    if(marqueeStartPosition!=null&&marqueeEndPosition!=null){
      double lowestX= min(marqueeStartPosition!.dx, marqueeEndPosition!.dx);
      double highestX=max(marqueeStartPosition!.dx, marqueeEndPosition!.dx);
      double lowestY= min(marqueeStartPosition!.dy, marqueeEndPosition!.dy);
      double highestY=max(marqueeStartPosition!.dy, marqueeEndPosition!.dy);

      List<NodeViewState>inside=[];
      for(NodeViewState node in nodeViewStates.values){
        Offset nodePos=node.position.value;


        if(lowestX<nodePos.dx&&nodePos.dx<highestX&&lowestY<nodePos.dy&&nodePos.dy<highestY){
          inside.add(node);
        }
      }
      selectedNodes.value=inside;
      //print("selectedNodes: ${selectedNodes.length} in: $marqueeStartPosition x $marqueeEndPosition");
      notifyListeners();
    }
  }

  void startMarquee(Offset startingPosition){
    marqueeStartPosition=startingPosition;
  }
  void currentMarquee(Offset endPosition){
    marqueeEndPosition=endPosition;
    selectInMarquee();
  }
  void endMarquee(){
    marqueeStartPosition=null;
    marqueeEndPosition=null;
  }

}