
enum PortDirection{
  input, output
}

class PortModel{
  String id;
  PortDirection direction;
  Type type;

  PortModel({required this.id, required this.direction, required this.type});

}

