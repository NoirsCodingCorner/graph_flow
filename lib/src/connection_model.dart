
/// Connection between two ports of two nodes.
/// Contains the sources [sourceNodeId]+[sourcePortId] and the targets [targetNodeId]+[targetPortId].
class ConnectionModel {
  String sourceNodeId;
  String sourcePortId;
  String targetNodeId;
  String targetPortId;

  ConnectionModel({required this.sourceNodeId, required this.sourcePortId, required this.targetNodeId, required this.targetPortId});
  
  Map<String, String>toJson(){
    return {
      "sourceNodeId":sourceNodeId,
      "sourcePortId":sourcePortId,
      "targetNodeId":targetNodeId,
      "targetPortId":targetPortId
    };
  }
  factory ConnectionModel.fromJson(Map<String, String>json){
    List<String>mustContain=["sourceNodeId","sourcePortId","targetNodeId","targetPortId"];
    for(String cont in mustContain){
      if(!json.containsKey(cont)){
        throw ArgumentError("Json does not contain required parameter $cont");
      }
    }
    return ConnectionModel(
      sourceNodeId: json["sourceNodeId"]!,
      sourcePortId: json["sourcePortId"]!,
      targetNodeId: json["targetNodeId"]!,
      targetPortId: json["targetPortId"]!,
    );
  }
}