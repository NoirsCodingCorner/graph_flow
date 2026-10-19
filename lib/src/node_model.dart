
import 'port_model.dart';

/// NodeModel represents a node/vertices in a Graph.
///
/// A node is identified by a unique [id], has a [typeName] that tells the UI
/// which kind of node it is (and therefore which builder to use to draw it),
/// and owns a list of [ports] through which data flows in and out.
class NodeModel {
  String id;
  String typeName;
  List<PortModel>ports;

  /// NodeModel represents a node/vertices in a Graph. Every
  /// NodeModel contains a unique global identifier [id], a [typeName] and a List of PortModels [ports] that
  /// govern which information can be transferred to and from the node.
  NodeModel({required this.id, required this.typeName, required this.ports});

  /// Creates a [NodeModel] from a JSON-compatible [json] map.
  ///
  /// The map must contain the keys `"id"` (a [String]), `"typeName"` (a
  /// [String]) and `"ports"` (a list of port JSON maps). Each port is
  /// deserialised with [PortModel.fromJson], using [typeRegistry] to resolve
  /// port type names to their runtime [Type]s.
  ///
  /// Throws an [ArgumentError] if any of the required keys is missing. A
  /// value of the wrong type will cause a cast error.

  factory NodeModel.fromJson(Map<String, Object?> json, Map<String, Type> typeRegistry) {
    List<String> mustContain = ["id", "typeName", "ports"];
    for (int i = 0; i < mustContain.length; i++) {
      String cont = mustContain[i];
      if (!json.containsKey(cont)) {
        throw ArgumentError("Json does not contain required parameter $cont");
      }
    }

    List<Object?> rawPorts = json["ports"] as List<Object?>;
    List<PortModel> loadedPorts = [];

    for (int i = 0; i < rawPorts.length; i++) {
      Map<String, Object?> portJson = rawPorts[i] as Map<String, Object?>;
      loadedPorts.add(PortModel.fromJson(portJson, typeRegistry));
    }

    return NodeModel(
      id: json["id"] as String,
      typeName: json["typeName"] as String,
      ports: loadedPorts,
    );
  }

  /// Serialises this node to a JSON-compatible map.
  ///
  /// The result has the keys `"id"`, `"typeName"` and `"ports"`, where
  /// `"ports"` is the list of each port's own [PortModel.toJson] output. The
  /// map can be passed back to [NodeModel.fromJson] to restore the node.
  Map<String, Object?> toJson() {
    List<Map<String, Object?>> portsJson = [];
    for (int i = 0; i < ports.length; i++) {
      portsJson.add(ports[i].toJson());
    }

    return {
      "id": id,
      "typeName": typeName,
      "ports": portsJson,
    };
  }
}