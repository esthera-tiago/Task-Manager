import 'priority.dart';
import 'task.dart';

class UrgentTask extends Task {
  final int escalateAfterHours;

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
    final status = isDone ? 'done' : 'pending';
    final date = deadline!.toIso8601String().split('T').first;
    return '[$status] [urgent] $title (due $date, escalates after '
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
