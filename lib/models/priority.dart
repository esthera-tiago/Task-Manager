// Priority level for a task.
// The order low -> medium -> high matters because we use the enum
// index to sort tasks by priority (high first).
enum Priority { low, medium, high }

// Small extension to get a nice printable label + an emoji.
// (extension on enum, just like the exercise we did on int before)
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

  String get emoji {
    switch (this) {
      case Priority.low:
        return '🟢';
      case Priority.medium:
        return '🟡';
      case Priority.high:
        return '🔴';
    }
  }

  // Helper to convert a string coming from user input ("l", "m", "h")
  // into a Priority value. Throws if the input is not recognized.
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
