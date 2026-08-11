// Contract for objects that can be serialized to a JSON map.
abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}
