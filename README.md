

# GraphFlow
<p align="center">
  <img src=https://github.com/user-attachments/assets/c17583bc-be4e-4b3e-9002-9694068f4b1b?raw=true" alt="Screenshot">
</p>

GraphFlow is a powerful and flexible Flutter package for building interactive node-based editors. It provides a highly customizable canvas with support for grid backgrounds, dynamic node positioning, and a range of connection rendering styles with advanced pan & zoom functionalities. Build flowcharts, diagram editors, visual programming environments, and more – all with ease!

[![Pub Version](https://img.shields.io/pub/v/graph_flow)](https://pub.dev/packages/graph_flow)  
[![Flutter Platform](https://img.shields.io/badge/Flutter-Compatible-brightgreen.svg)](https://flutter.dev)

### Example Usecase:

![graph_flow_pretty](https://github.com/user-attachments/assets/0dc3679e-3451-4f15-b243-e3071b4d5f75?raw=true)

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

## Example of a customized Editor
![Gifshowcase](https://github.com/user-attachments/assets/9eefc701-0c1b-4a32-93d4-1acc1d1f4a9c?raw=true)


## Getting Started

### Installation

Add GraphFlow to your Flutter project's `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  graph_flow: ^0.1.0
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
<h2 style="display: flex; align-items: center; gap: 8px;">
  <img src="https://github.com/user-attachments/assets/8ade4ad5-ea95-491c-95e5-989b572a844a?raw=true" alt="Canvas Icon" width="36" height="36" />
  <span>Customizable Features of CanvasPage</span>
  
</h2>

- **Manager**  
  - The required `Manager` instance controls nodes, connection points, and overall scene state.

- **Custom Connection Painter**  
  - Specify a custom painter via the `connectionPainter` parameter.  
  - If not provided, the default `ConnectionPainter` is used to render connection lines.

- **Mouse Region Callbacks**  
  - `onMouseEnter`: Triggered when the mouse enters the canvas area.  
  - `onMouseHover`: Updates the manager’s mouse position and handles hover events.  
  - `onMouseExit`: Triggered when the mouse leaves the canvas area.

- **Gesture Detector Callbacks**  
  - `onTapDown`, `onTapUp`, `onTap`: Customize how tap events are handled.  
  - `onLongPress`: Customize long-press behavior.  
  - `onPanStart`, `onPanUpdate`, `onPanEnd`: Handle drag (panning) events to move nodes or navigate the canvas.

- **Canvas Dimensions**  
  - `canvasWidth` & `canvasHeight`: Define the size of the canvas.

- **Zoom & Pan Settings**  
  - `maxZoom` & `minZoom`: Control the zooming capabilities of the canvas.  
  - `scaleFactor`: Factor applied to the scaling transformation.

- **Grid Settings**  
  - `gridSpacing`: Specifies the distance between grid lines.  
  - `lineColor`: Defines the color of the grid lines.  
  - `lineWidth`: Sets the stroke width of the grid lines.  
  - `overflowSpacing`: Adds extra spacing beyond the widget’s bounds to ensure complete grid coverage.

 <h2 style="display: flex; align-items: center; gap: 8px;">
  <img src="https://github.com/user-attachments/assets/26ff7125-cf7a-4a6b-8183-367b07cbe63b?raw=true" alt="connectionIcon" width="36" height="36" />
  <span>Customizable Features of ConnectionPainter</span>
</h2>
- **Mouse Line Activation:**  
  Toggle the visibility of a dynamic connection line from the selected connection point to the current mouse position using the `mouseLineActive` flag.

- **Drawing Type:**  
  Choose from a variety of connection drawing styles via the `drawingType` parameter:
  - `bezier` – Draw a bezier curve with vertical control points.
  - `straightLine` – Draw a simple straight line.
  - `verticalThenHorizontal` – Draw a line going vertically then horizontally.
  - `halfHorizontalThenVertical` – Draw a path going half horizontally then vertically.
  - `halfVerticalThenHorizontal` – Draw a path going half vertically then horizontally.
  - `bezierHorizontalThenVertical` – Draw a bezier curve transitioning horizontally then vertically.

- **Mouse Line Color:**  
  Customize the color of the mouse-tracking connection line through the `mouseLineColor` property.

- **Line Thickness:**  
  Adjust the stroke width of the connection lines with the `lineThickness` setting.

- **Endpoint Radius:**  
  Specify the radius for the endpoint dots on connection points using the `endpointRadius`.

Leverage these properties to fine-tune the visual style and interaction behavior of your connection lines for building highly interactive node-based editors.




## Contributing

Contributions are very welcome and will be reviewed in sight!

## License

GraphFlow is licensed under the MIT License. See the [LICENSE](https://github.com/NoirsCodingCorner/graph_flow/blob/master/LICENSE) file for details.

## Outlook

GraphFlow is currently fresh in development.
If you have any comments or wishes for this library feel free to contact me over the github or just leave a note in the flutter discord channel.

Plans: 
- **Data Pipes**: It is planned to add runtime data passing into the connections themselves to allow easier usage during runtime
- **More customizable Events**: Events like creation, deletion and dragging of connections is to be made fully costumizable

Thank you all for using my library <3
