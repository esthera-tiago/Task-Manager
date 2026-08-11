import 'json_serializable.dart';
import 'normal_task.dart';
import 'priority.dart';
import 'urgent_task.dart';

// Common base for every task in the app.
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

  // Each subclass renders its own one-line description for the CLI list.
  String describe();

  @override
  Map<String, dynamic> toJson();

  // Sort by priority (high first), then by deadline (earliest first).
  // Tasks without a deadline always come last.
  @override
  int compareTo(Task other) {
    final byPriority = other.priority.index.compareTo(priority.index);
    if (byPriority != 0) return byPriority;

    if (deadline == null && other.deadline == null) return 0;
    if (deadline == null) return 1;
    if (other.deadline == null) return -1;
    return deadline!.compareTo(other.deadline!);
  }

  // Rebuilds the right subclass from the "type" field saved in JSON.
  factory Task.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'normal';
    if (type == 'urgent') {
      return UrgentTask.fromJson(json);
    }
    return NormalTask.fromJson(json);
  }
}
