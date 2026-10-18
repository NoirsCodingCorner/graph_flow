
import 'port_model.dart';

class NodeModel {
  String id;
  String typeName;
  List<PortModel>ports;

  NodeModel({required this.id, required this.typeName, required this.ports});

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