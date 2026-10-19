enum PortDirection { input, output, inout }

/// PortModel represents a point of connection for a Node.
/// Ports can either be input, output or inout.
/// Stores the Properties:
/// - [id]: Unique identifier of the Port.
/// - [type]: The runtime type of the Port data.
/// - [direction]: [PortDirection] showcasing which way a port transports data.
class PortModel {
  int maxConnections;
  String id;
  Type type;
  PortDirection direction;
  PortModel(
      {required this.id,
      required this.type,
      required this.direction,
      this.maxConnections = 1});

  factory PortModel.fromJson(
      Map<String, Object?> json, Map<String, Type> typeRegistry) {
    List<String> mustContain = ["id", "direction", "type"];
    for (int i = 0; i < mustContain.length; i++) {
      String cont = mustContain[i];
      if (!json.containsKey(cont)) {
        throw ArgumentError("Json does not contain required parameter $cont");
      }
    }

    String typeString = json["type"] as String;
    Type resolvedType = typeRegistry[typeString]!;

    PortDirection parsedDirection = PortDirection.input;
    for (int i = 0; i < PortDirection.values.length; i++) {
      if (PortDirection.values[i].name == json["direction"]) {
        parsedDirection = PortDirection.values[i];
      }
    }

    int parsedMaxConnections = 1;
    if (json.containsKey("maxConnections")) {
      parsedMaxConnections = json["maxConnections"] as int;
    }

    return PortModel(
      id: json["id"] as String,
      type: resolvedType,
      direction: parsedDirection,
      maxConnections: parsedMaxConnections,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "type": type.toString(),
      "direction": direction.name,
      "maxConnections": maxConnections
    };
  }
}
