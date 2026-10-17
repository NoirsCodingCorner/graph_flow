import 'package:flutter/material.dart';
import 'package:graph_flow/canvas_configuration.dart';
import 'package:graph_flow/graph_flow.dart';

void main() {
  runApp(const GraphEditorApp());
}

class GraphEditorApp extends StatefulWidget {
  const GraphEditorApp({super.key});

  @override
  State<GraphEditorApp> createState() => _GraphEditorAppState();
}

class _GraphEditorAppState extends State<GraphEditorApp> {
  GraphManager manager = GraphManager();

  @override
  void initState() {
    super.initState();
    _setupDemoGraph();
  }

// 1. Shared UI Builders for styling
  final TextStyle _nodeTextStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.5,
  );

  Widget _buildNodeUI(List<Widget> children, GraphManager manager) {
    return ValueListenableBuilder(
      valueListenable: manager.selectedNodes,
      builder: (context, value, child) {
        return Container(
          width: 140,
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          ),
        );
      }
    );
  }

  Widget _buildPortUI(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

// 2. Factory Methods for Inputs and Outputs
  void _createOutputNode(String nodeId, String nodeName, String portId, Offset position) {
    PortModel portModel = PortModel(id: portId, direction: PortDirection.output, type: String);
    NodeModel nodeModel = NodeModel(id: nodeId, typeName: nodeName, ports: [portModel]);

    NodeVisual nodeVisual = NodeVisual(
      nodeModel: nodeModel,
      initialPosition: position,
      builder: (BuildContext context, NodeVisual visual, List<PortVisual> ports, GraphManager manager) {
        // Output nodes put the text on the left and the port on the right
        return _buildNodeUI([Text(nodeName, style: _nodeTextStyle), ports[0]],manager);
      },
      graphManager: manager,
    );

    PortVisual portVisual = PortVisual(
      portModel: portModel,
      builder: (context, visual) => _buildPortUI(const Color(0xFF43B581)), // Soft green
      graphManager: manager,
      parentNodeID: nodeModel.id,
    );

    nodeVisual.portVisuals.add(portVisual);
    manager.addNode(nodeModel, nodeVisual);
  }

  void _createInputNode(String nodeId, String nodeName, String portId, Offset position) {
    PortModel portModel = PortModel(id: portId, direction: PortDirection.input, type: String);
    NodeModel nodeModel = NodeModel(id: nodeId, typeName: nodeName, ports: [portModel]);

    NodeVisual nodeVisual = NodeVisual(
      nodeModel: nodeModel,
      initialPosition: position,
      builder: (BuildContext context, NodeVisual visual, List<PortVisual> ports, GraphManager manager) {
        // Input nodes put the port on the left and the text on the right
        return _buildNodeUI([ports[0], Text(nodeName, style: _nodeTextStyle)], manager);
      },
      graphManager: manager,
    );

    PortVisual portVisual = PortVisual(
      portModel: portModel,
      builder: (context, visual) => _buildPortUI(const Color(0xFFFAA61A)), // Soft orange
      graphManager: manager,
      parentNodeID: nodeModel.id,
    );

    nodeVisual.portVisuals.add(portVisual);
    manager.addNode(nodeModel, nodeVisual);
  }

// 3. Clean Setup Execution
  void _setupDemoGraph() {
    int input=25;
    for(int i=0;i<input;i++){
      _createInputNode('node_B$i', 'Layer_0_$i', 'in_$i', Offset(1000, i*60));
    }

    int output=25;
    for(int o=0;o<output;o++){
      _createOutputNode('node_A$o', 'Layer_1_$o', 'out_$o', Offset(0, o*60));
    }

    for(int i=0;i<input;i++){
      for(int o=0;o<output;o++){
        manager.createConnection('node_A$o', 'out_$o', 'node_B$i', 'in_$i');
      }
    }


  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GraphCanvas(manager: manager, canvasLayout: CanvasLayout.darkAnimatedNeonCyan,),
      ),
    );
  }
}