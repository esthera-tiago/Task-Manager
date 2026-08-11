import 'task.dart';
import 'priority.dart';

// UrgentTask is a special kind of Task:
// - it is ALWAYS "high" priority (forced in the constructor)
// - it always needs a deadline
// - it has one extra field: escalateAfterHours
// This shows real inheritance: same base fields + extra behaviour.
class UrgentTask extends Task {
  final int escalateAfterHours;

  // Note: we can't mix "super.id" shorthand with an explicit super(...)
  // call in the same constructor, so here everything is passed explicitly.
  UrgentTask({
    required String id,
    required String title,
    required DateTime deadline,
    bool isDone = false,
    this.escalateAfterHours = 24,
  }) : super(
          id: id,
          title: title,
          priority: Priority.high,
          deadline: deadline,
          isDone: isDone,
        );

  @override
  String describe() {
    final status = isDone ? '[x]' : '[ ]';
    final deadlineStr = deadline!.toIso8601String().split('T').first;
    return '$status 🚨 URGENT: $title (due $deadlineStr, escalates after '
        '$escalateAfterHours h)';
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'urgent',
        'id': id,
        'title': title,
        'priority': priority.name,
        'deadline': deadline?.toIso8601String(),
        'isDone': isDone,
        'escalateAfterHours': escalateAfterHours,
      };

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      isDone: json['isDone'] as bool? ?? false,
      escalateAfterHours: json['escalateAfterHours'] as int? ?? 24,
    );
  }
}
