import 'package:material_ui/material_ui.dart';
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

  final TextStyle _nodeTextStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.5,
  );

  // In-memory mock database
  Map<String, dynamic>? savedGraphData;
  Map<String, dynamic>? savedVisualData;

  // The registry required for PortModel.fromJson
  Map<String, Type> typeRegistry = {"int": int, "String": String};

  @override
  void initState() {
    super.initState();
    visualiser = GraphVisualiser(model);
    _registerBuilders();
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
            color: color.withValues(alpha: 0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  void _registerBuilders() {
    visualiser.portBuilders[String] =
        (BuildContext context, PortVisual visual) {
          return _buildPortUI(const Color(0xFF43B581));
        };

    visualiser.portBuilders[int] = (BuildContext context, PortVisual visual) {
      return _buildPortUI(const Color(0xFFFAA61A));
    };

    visualiser.nodeBuilders['OutputNode'] =
        (
          BuildContext context,
          NodeViewState state,
          Map<String, PortVisual> ports,
        ) {
          return _buildNodeUI([
            Text(state.model.id, style: _nodeTextStyle),
            ports.values.first,
          ]);
        };

    visualiser.nodeBuilders['InputNode'] =
        (
          BuildContext context,
          NodeViewState state,
          Map<String, PortVisual> ports,
        ) {
          return _buildNodeUI([
            ports.values.first,
            Text(state.model.id, style: _nodeTextStyle),
          ]);
        };

    visualiser.nodeBuilders['AddInts'] =
        (
          BuildContext context,
          NodeViewState state,
          Map<String, PortVisual> ports,
        ) {
          String nodeId = state.model.id;
          return SizedBox(
            width: 180,
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ports["${nodeId}_in_a"]!,
                      ports["${nodeId}_in_b"]!,
                    ],
                  ),
                  Text(state.model.id, style: _nodeTextStyle),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ports["${nodeId}_out_result"]!],
                  ),
                ],
              ),
            ),
          );
        };
  }

  NodeModel createAddIntsNode(String uniqueId) {
    PortModel inputA = PortModel(
      id: "${uniqueId}_in_a",
      type: int,
      direction: PortDirection.input,
      maxConnections: 1,
    );

    PortModel inputB = PortModel(
      id: "${uniqueId}_in_b",
      type: int,
      direction: PortDirection.input,
      maxConnections: 1,
    );

    PortModel outputResult = PortModel(
      id: "${uniqueId}_out_result",
      type: int,
      direction: PortDirection.output,
      maxConnections: 0,
    );

    return NodeModel(
      id: uniqueId,
      typeName: "AddInts",
      ports: [inputA, inputB, outputResult],
    );
  }

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GraphCanvas(
              visualiser: visualiser,
              canvasLayout: CanvasLayout.darkAnimatedNeonYellow,
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      savedGraphData = model.toJson();
                      savedVisualData = visualiser.toJson();
                      print("Graph Saved.");
                    },
                    child: const Text("Save Graph"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (savedGraphData != null && savedVisualData != null) {
                        model.loadFromJson(savedGraphData!, typeRegistry);
                        // The model loading triggers synch() in Visualiser, creating default (0,0) states.
                        // We must wait for the next frame to let the synch finish, then apply saved positions.
                        visualiser.loadPositions(savedVisualData!);
                      } else {
                        print("No save data found.");
                      }
                    },
                    child: const Text("Load Graph"),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NodeModel addNode = createAddIntsNode("AddNode_$counter");
            model.addNode(addNode);
            counter++;
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
