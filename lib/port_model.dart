enum PortDirection {
  input,
  output,
  inout
}

class PortModel{
  String id;
  Type type;
  PortDirection direction;
  PortModel({required this.id, required this.type,required this.direction});

}

