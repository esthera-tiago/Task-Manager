// Task priority levels. Declaration order matters: it is used when
// sorting tasks by priority (high first).
enum Priority { low, medium, high }

extension PriorityLabel on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  // Parses the shortcut used in the CLI prompt ("l", "m", "h"
  // or the full word). Throws if the input is not recognized.
  static Priority fromShortcut(String input) {
    switch (input.trim().toLowerCase()) {
      case 'l':
      case 'low':
        return Priority.low;
      case 'm':
      case 'medium':
        return Priority.medium;
      case 'h':
      case 'high':
        return Priority.high;
      default:
        throw ArgumentError('Unknown priority shortcut: $input');
    }
  }
}
