# GraphFlow

GraphFlow is a powerful and flexible Flutter package for building interactive node-based editors. It provides a highly customizable canvas with support for grid backgrounds, dynamic node positioning, and a range of connection rendering styles with advanced pan & zoom functionalities. Build flowcharts, diagram editors, visual programming environments, and more – all with ease!

[![Pub Version](https://img.shields.io/pub/v/graph_flow)](https://pub.dev/packages/graph_flow)  
[![Flutter Platform](https://img.shields.io/badge/Flutter-Compatible-brightgreen.svg)](https://flutter.dev)

## Features

- **Interactive Node Editor:**  
  Add, remove, and reposition node cards on a highly interactive canvas.
- **Dynamic Connections:**  
  Draw connections between nodes using customizable styles such as Bezier curves, straight lines, and more.
- **Advanced Pan & Zoom:**  
  Navigate your canvas easily using built-in support for panning and zooming with `InteractiveViewer`.
- **Customizable Grid Background:**  
  Configure grid spacing, colors, and line widths to suit your visual style.
- **Scene Persistence:**  
  Save and load entire scenes—including nodes, connections, and canvas offsets—via JSON for easy sharing and persistence.
- **Flexible Event Handling:**  
  Customize interactions with support for mouse and gesture callbacks.
- **Easy Integration:**  
  Extend the package with custom painters and node factories for bespoke node behaviors.

## Screenshots

Place your images in an `images/` folder at the root of your package. Use the sample paths below to showcase GraphFlow's capabilities:

![GraphFlow Overview](images/graphflow_overview.png)  
*An overview of GraphFlow showing the grid, nodes, and connection lines.*

![GraphFlow Editing Mode](images/graphflow_editing.png)  
*The editor in action with pan, zoom, and interactive node manipulation.*

## Getting Started

### Installation

Add GraphFlow to your Flutter project's `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  graph_flow: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Basic Usage

Below is a simple example that demonstrates how to integrate GraphFlow into your Flutter app. This sample creates a manager, adds two nodes, and displays the canvas with a grid and connection layer.

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graph_flow/graph_flow.dart'; // Use your package's public API.
import 'package:graph_flow/src/connection_painter.dart';
import 'package:graph_flow/src/example_node.dart';
import 'package:graph_flow/src/manager.dart';
import 'package:graph_flow/src/node_canvas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static int _uniqueCounter = 0;
  
  static String generateUniqueId() {
    _uniqueCounter++; 
    // Create a unique id combining a timestamp and counter.
    return '${DateTime.now().millisecondsSinceEpoch}-$_uniqueCounter';
  }
  
  const MyApp({Key? key}) : super(key: key);
  
  String getNewID() => generateUniqueId();
  
  @override
  Widget build(BuildContext context) {
    Manager manager = Manager(getNewID: getNewID);
    // Register a node type factory.
    manager.nodeFactories['ExampleNode'] = ExampleNode.fromJson;
    // Add example nodes to the manager.
    manager.addNode(ExampleNode(manager: manager, id: getNewID()));
    manager.addNode(ExampleNode(manager: manager, id: getNewID()));
    
    return MaterialApp(
      title: 'GraphFlow Demo',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Main canvas with grid and nodes.
            CanvasPage(
              manager: manager, 
              gridSpacing: 10, 
              connectionPainter: ConnectionPainter(
                manager, 
                drawingType: ConnectionDrawingType.bezier,
              ),
            ),
            // UI controls to print or input JSON.
            Align(
              alignment: Alignment.bottomRight,
              child: Builder(
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Map<String, dynamic> json = manager.saveSceneToJson();
                        print(
                          const JsonEncoder.withIndent('  ').convert(json),
                        );
                      },
                      icon: const Icon(Icons.print, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        final TextEditingController controller =
                            TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Input JSON'),
                              content: TextField(
                                controller: controller,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: 'Enter JSON here',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final inputJson = jsonDecode(controller.text);
                                    manager.loadSceneFromJson(inputJson);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.input, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Advanced Usage

GraphFlow is fully extensible. You can provide your own custom connection painters, override default callbacks for mouse and gesture events, or extend node card functionalities. For example, to use a custom connection painter:

```dart
class MyCustomPainter extends CustomPainter {
  final Manager manager;

  MyCustomPainter(this.manager);

  @override
  void paint(Canvas canvas, Size size) {
    // Your custom connection rendering logic.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Usage in CanvasPage:
CanvasPage(
  manager: manager,
  connectionPainter: MyCustomPainter(manager),
);
```

## Documentation

For detailed API documentation, visit the [API Docs](https://pub.dev/documentation/graph_flow/latest/).

## Keywords

GraphFlow, Flutter, Node Editor, Diagram Editor, Interactive Canvas, Flowchart, Visual Programming, Custom Editor, Pan, Zoom

## Contributing

Contributions are welcome! Please see our [contributing guidelines](CONTRIBUTING.md) for more information on how to get involved and submit pull requests.

## License

GraphFlow is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

---

### Where to Place Images

- **Images Folder:** Create an `images/` folder in the root of your package repository.  
- **Image Links:** Update the image paths in the README (e.g., `images/graphflow_overview.png`) to match your folder structure.  
- **Optimization:** Compress images appropriately for faster loading on pub.dev.

---

This README is designed to clearly communicate your package's capabilities, implementation details, and usage instructions while including visual examples and search keywords to optimize pub.dev visibility.
