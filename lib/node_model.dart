
import 'package:graph_flow/port_model.dart';

class NodeModel {
  String id;
  String typeName;
  List<PortModel>ports;

  NodeModel({required this.id, required this.typeName, required this.ports});
}