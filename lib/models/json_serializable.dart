// This is the "interface" required by the project instructions.
// In Dart, any class is a valid interface. We keep this one very small
// on purpose: a single contract that says "I can turn myself into JSON".
// Task implements this interface (see task.dart).
abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}
