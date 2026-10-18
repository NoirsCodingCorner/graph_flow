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
  GraphModel model = GraphModel(
    allowedConnections: {
      String: [String, dynamic],
      int: [int, double, dynamic],
    },
  );
  late GraphVisualiser visualiser;

  TextStyle _nodeTextStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.5,
  );

  @override
  void initState() {
    super.initState();
    visualiser = GraphVisualiser(model);
    _registerBuilders();
    _setupDemoGraph();
  }

  Widget _buildNodeUI(List<Widget> children) {
    return SizedBox(
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

  void _registerBuilders() {
    visualiser.portBuilders[String] = (BuildContext context, PortVisual visual) {
      return _buildPortUI(const Color(0xFF43B581));
    };

    visualiser.portBuilders[int] = (BuildContext context, PortVisual visual) {
      return _buildPortUI(const Color(0xFFFAA61A));
    };

    visualiser.nodeBuilders['OutputNode'] = (BuildContext context, NodeViewState state, Map<String, PortVisual> ports) {
      return _buildNodeUI([
        Text(state.model.id, style: _nodeTextStyle),
        ports.values.first
      ]);
    };

    visualiser.nodeBuilders['InputNode'] = (BuildContext context, NodeViewState state, Map<String, PortVisual> ports) {
      return _buildNodeUI([
        ports.values.first,
        Text(state.model.id, style: _nodeTextStyle)
      ]);
    };
  }

  void _createOutputNode(String nodeId, String portId, Offset position) {
    PortModel portModel = PortModel(id: portId, type: String, direction: PortDirection.output);
    NodeModel nodeModel = NodeModel(id: nodeId, typeName: 'OutputNode', ports: [portModel]);

    model.addNode(nodeModel);
    visualiser.nodeViewStates[nodeId] = NodeViewState(nodeModel, position);
  }

  void _createInputNode(String nodeId, String portId, Offset position) {
    PortModel portModel = PortModel(id: portId, type: String, direction: PortDirection.input);
    NodeModel nodeModel = NodeModel(id: nodeId, typeName: 'InputNode', ports: [portModel]);

    model.addNode(nodeModel);
    visualiser.nodeViewStates[nodeId] = NodeViewState(nodeModel, position);
  }

  void _setupDemoGraph() {
    int input = 25;
    for (int i = 0; i < input; i++) {
      _createInputNode('Layer_0_$i', 'in_$i', Offset(1000, i * 60.0));
    }

    int output = 2;
    for (int o = 0; o < output; o++) {
      _createOutputNode('Layer_1_$o', 'out_$o', Offset(0, o * 60.0));
    }

    for (int i = 0; i < input; i++) {
      for (int o = 0; o < output; o++) {
        model.createConnection('Layer_1_$o', 'out_$o', 'Layer_0_$i', 'in_$i');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GraphCanvas(
          visualiser: visualiser,
          canvasLayout: CanvasLayout.darkDefault,
        ),
      ),
    );
  }
}