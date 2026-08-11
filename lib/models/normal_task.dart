import 'task.dart';
import 'priority.dart';

// A "regular" task. Nothing special, just the base behaviour.
class NormalTask extends Task {
  NormalTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.isDone,
  });

  @override
  String describe() {
    final status = isDone ? '[x]' : '[ ]';
    final deadlineStr = deadline != null
        ? ' (due ${deadline!.toIso8601String().split('T').first})'
        : '';
    return '$status ${priority.emoji} $title$deadlineStr';
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'normal',
        'id': id,
        'title': title,
        'priority': priority.name,
        'deadline': deadline?.toIso8601String(),
        'isDone': isDone,
      };

  factory NormalTask.fromJson(Map<String, dynamic> json) {
    return NormalTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: Priority.values.byName(json['priority'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}
