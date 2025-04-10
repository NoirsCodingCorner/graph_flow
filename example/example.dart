import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graph_flow/graph_flow.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static int _uniqueCounter = 0;
  static String generateUniqueId() {
    print("generateUniqueId: ${DateTime.now().millisecondsSinceEpoch}-$_uniqueCounter");
    _uniqueCounter++; // Increment the counter each time the method is called.
    final id = '${DateTime.now().millisecondsSinceEpoch}-$_uniqueCounter';
    return id;
  }
  const MyApp({super.key});
  String getNewID() => generateUniqueId();

  @override
  Widget build(BuildContext context) {
    Manager manager = Manager(getNewID: getNewID);
    manager.nodeFactories['ExampleNode'] = ExampleNode.fromJson;
    manager.addNode(ExampleNode(manager: manager, id: getNewID()));
    manager.addNode(ExampleNode(manager: manager, id: getNewID()));


    return MaterialApp(
      title: 'Falling Icon with Transformations',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            CanvasPage(manager: manager, gridSpacing: 10, connectionPainter: ConnectionPainter(manager, drawingType: ConnectionDrawingType.bezier, ),),
            Align(
              alignment: Alignment.bottomRight,
              child: Builder(
                builder:
                    (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Map<String, dynamic> json =
                        manager.saveSceneToJson();
                        print(
                          const JsonEncoder.withIndent('  ').convert(json),
                        );
                      },
                      icon: const Icon(Icons.print),
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
                                  onPressed:
                                      () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final inputJson = jsonDecode(
                                      controller.text,
                                    );
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
                      icon: const Icon(Icons.input),
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
