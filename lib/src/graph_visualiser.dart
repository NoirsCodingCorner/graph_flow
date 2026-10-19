
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'graph_model.dart';
import 'node_model.dart';
import 'node_visual.dart';
import 'port_visual.dart';

/// A [GraphVisualiser] sits on top of a [GraphModel] (the data) and keeps
/// track of everything that is purely visual or interactive: where each node
/// is drawn, which nodes are selected or hovered, which port is currently
/// being connected, and the state of the marquee (rubber-band) selection.
///
/// It extends [ChangeNotifier], so widgets can listen to it and rebuild
/// whenever the visual state changes. It also listens to the underlying
/// [GraphModel] and keeps [nodeViewStates] in [synch] with the model's nodes

class GraphVisualiser extends ChangeNotifier{
  GraphModel model;

  /// Visual representation of the nodes
  Map<String,NodeViewState> nodeViewStates = {};

  NodeViewState? currentlyHoveredNode;
  PortViewState? currentlySelectedPort;
  /// Temporal UI states representation

  ValueNotifier<List<NodeViewState>>selectedNodes=ValueNotifier([]);

  Offset? mousePosition;
  Offset?marqueeStartPosition;
  Offset?marqueeEndPosition;

  /// Building method to be used for each Node that gets build.
  Map<String,Widget Function(BuildContext context, NodeViewState state, Map<String, PortVisual> ports)> nodeBuilders={};
  /// Building method to be used for each Port that gets build.
  Map<Type,Widget Function(BuildContext context, PortVisual visual)> portBuilders={};
  Widget Function(BuildContext context, NodeViewState state, Map<String, PortVisual> ports)? getNodeBuilderByType(String typeName){
    return nodeBuilders[typeName]!;
  }
  Widget Function(BuildContext context, PortVisual visual) getPortBuilderByType(Type type){
    return portBuilders[type]!;
  }

  /// GraphVisualiser manages a given Graph by handling the visual and state managing of widgets.
  /// The provided [GraphModel] ([model]) is to be seen as the actual Graph (source of truth) that this visualiser is allowed to interact with.
  /// Updates on the original are reacted upon to allow for changes of the graph without the visual editor (like programmatic updates, Agent additions etc.)
  GraphVisualiser(this.model){
    selectedNodes.addListener(() {
      bringToFront(selectedNodes.value);
      notifyListeners();
    });
    model.addListener(synch);
  }

  /// Method that is assigned to react to changes in the provided [GraphModel] model.
  /// If events such as node or connection creation has occurred the visualizer updates itself to reflect the new Graph state.
  void synch() {
    for (int i = 0; i < model.nodeModels.length; i++) {
      NodeModel nodeModel = model.nodeModels[i];
      bool exists = nodeViewStates.containsKey(nodeModel.id);

      if (exists == false) {
        NodeViewState newState = NodeViewState(nodeModel, const Offset(0, 0));
        nodeViewStates[nodeModel.id] = newState;
      }
    }

    List<String> existingKeys = nodeViewStates.keys.toList();
    for (int i = 0; i < existingKeys.length; i++) {
      String key = existingKeys[i];
      bool foundInModel = false;

      for (int j = 0; j < model.nodeModels.length; j++) {
        NodeModel nodeModel = model.nodeModels[j];
        if (nodeModel.id == key) {
          foundInModel = true;
        }
      }

      if (foundInModel == false) {
        nodeViewStates.remove(key);
      }
    }

    notifyListeners();
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

  void bringToFront(List<NodeViewState> nodes) {
    for(NodeViewState node in nodeViewStates.values){
      node.paintOrder = 0;
    }
    for(NodeViewState node in nodes){
      node.paintOrder = 1;
    }
  }

  /// Serialises the node layout to a Json map.
  ///
  /// The result maps each node id to its position, e.g.
  /// `{"nodeId": {"x": 120.0, "y": 80.5}}`. Only positions are stored; the
  /// graph structure itself belongs to [model]. Use [loadPositions] to restore
  /// the layout.
  ///
  Map<String, Object?> toJson() {
    Map<String, Object?> positions = {};

    List<String> keys = nodeViewStates.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      NodeViewState state = nodeViewStates[key]!;
      Offset pos = state.position.value;

      positions[key] = {
        "x": pos.dx,
        "y": pos.dy,
      };
    }

    return positions;
  }
  /// Restores node positions from a map produced by [toJson].
  ///
  /// Entries whose node id does not exist in [nodeViewStates] are ignored. The
  /// positions are applied in a post-frame callback so that the node view
  /// states created by [synch] exist before they are updated. Listeners are
  /// notified once all positions have been applied.
  ///
  /// Each entry must contain numeric `"x"` and `"y"` values typed as
  /// [double], otherwise the cast will throw.

  void loadPositions(Map<String, dynamic> json) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<String> keys = json.keys.toList();

      for (int i = 0; i < keys.length; i++) {
        String key = keys[i];
        bool exists = nodeViewStates.containsKey(key);

        if (exists) {
          Map<String, Object?> posData = json[key] as Map<String, Object?>;
          double x = posData["x"] as double;
          double y = posData["y"] as double;

          nodeViewStates[key]!.position.value = Offset(x, y);
        }
      }

      notifyListeners();
    });
  }
}