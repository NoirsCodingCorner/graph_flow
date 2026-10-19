library;

import 'package:graph_flow/src/canvas_configuration.dart';
import 'package:graph_flow/src/graph_canvas.dart';
import 'package:graph_flow/src/graph_model.dart';
import 'package:graph_flow/src/graph_visualiser.dart';
import 'package:graph_flow/src/node_model.dart';
import 'package:graph_flow/src/node_visual.dart';
import 'package:graph_flow/src/port_model.dart';
import 'package:graph_flow/src/port_visual.dart';

/// Graph Flow library consisting of the following components:
/// Graph Elements:
/// - [GraphModel]: Contains NodeModels and ConnectionModels that make up the graph.
/// It manages creation, deletion, loading and saving of the GraphModel.
/// - [NodeModel]: A node in the graph, representing a state or operation.
/// - [PortModel]: The inputs, outputs and inouts of nodes.
///
/// Visual Elements:
/// - [GraphVisualiser]: Visualizes the given Graph and manages the control flow of the user on said Graph.
/// - [GraphCanvas]: Widget to render a given Graph in a Layout style of [CanvasLayout].
/// - [NodeVisual]: Widget that gets drawn by the GraphCanvas, uses the developers provided building method to render Nodes on the canvas.
/// - [PortVisual]: Widget that gets drawn by the GraphCanvas, uses the developers provided building method to render Ports of the nodes.

export 'src/node_model.dart';
export 'src/port_model.dart';
export 'src/connection_model.dart';

export 'src/graph_model.dart';

export 'src/canvas_configuration.dart';
export 'src/data_connection_painter.dart';
export 'src/graph_canvas.dart';
export 'src/graph_visualiser.dart';
export 'src/grid_widget.dart';
export 'src/node_visual.dart';
export 'src/port_visual.dart';
export 'src/position_snapper.dart';
