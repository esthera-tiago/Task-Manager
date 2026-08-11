import 'json_serializable.dart';
import 'priority.dart';
import 'normal_task.dart';
import 'urgent_task.dart';

// Abstract base class for every task in the app.
// NormalTask and UrgentTask both extend this class (inheritance).
// It also implements two interfaces:
//   - Comparable<Task>  -> so we can use List.sort() directly
//   - JsonSerializable  -> so the repository can save it to disk
abstract class Task implements Comparable<Task>, JsonSerializable {
  final String id;
  String title;
  Priority priority;
  DateTime? deadline;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.isDone = false,
  });

  // Every subclass must describe itself differently
  // (this is where polymorphism happens in the CLI list view).
  String describe();

  @override
  Map<String, dynamic> toJson();

  // Sorting rule used by "List all tasks (sorted by priority)".
  // Higher priority first, and for equal priority the oldest deadline first.
  @override
  int compareTo(Task other) {
    final byPriority = other.priority.index.compareTo(priority.index);
    if (byPriority != 0) return byPriority;

    if (deadline == null && other.deadline == null) return 0;
    if (deadline == null) return 1; // no deadline goes last
    if (other.deadline == null) return -1;
    return deadline!.compareTo(other.deadline!);
  }

  // Factory that reads the "type" field to decide which subclass to build.
  // This is how polymorphism survives the JSON round-trip.
  factory Task.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'normal';
    if (type == 'urgent') {
      return UrgentTask.fromJson(json);
    }
    return NormalTask.fromJson(json);
  }
}
