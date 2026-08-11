import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/normal_task.dart';
import '../models/priority.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import '../repository/task_repository.dart';

// Small class that owns the terminal menu and talks to the repository.
// Kept separate from main.dart so the logic is a bit easier to read/test.
class CliApp {
  final TaskRepository repository;

  CliApp(String storagePath) : repository = TaskRepository(storagePath);

  Future<void> run() async {
    print('=== Task Manager CLI - Next Flutter FFSC ===');
    var running = true;

    while (running) {
      _printMenu();
      final choice = stdin.readLineSync();

      // EOF (e.g. piped stdin closed): stop instead of looping forever.
      if (choice == null) {
        print('Thanks for using Task Manager. Bye!');
        break;
      }

      try {
        switch (choice) {
          case '1':
            await _addTask();
            break;
          case '2':
            _listTasks();
            break;
          case '3':
            await _markDone();
            break;
          case '4':
            await _deleteTask();
            break;
          case '5':
            running = false;
            print('Thanks for using Task Manager. Bye!');
            break;
          default:
            print('Invalid choice, please pick a number from 1 to 5.\n');
        }
      } on AppException catch (e) {
        // Catch our own custom exceptions so the app never crashes,
        // it just shows a clean error message and loops back to the menu.
        print(' Error: $e\n');
      }
    }
  }

  void _printMenu() {
    print('''
------------------------------
1. Add a task
2. List tasks
3. Mark a task as done
4. Delete a task
5. Exit
------------------------------''');
    stdout.write('Choose an option: ');
  }

  Future<void> _addTask() async {
    stdout.write('Title: ');
    final title = stdin.readLineSync() ?? '';

    stdout.write('Priority (l = low, m = medium, h = high): ');
    final priorityInput = stdin.readLineSync() ?? '';

    stdout.write('Is this task urgent? (y/n): ');
    final isUrgent = (stdin.readLineSync() ?? 'n').trim().toLowerCase() == 'y';

    stdout.write(
        'Deadline (YYYY-MM-DD, press Enter to skip${isUrgent ? ' - required for urgent tasks' : ''}): ');
    final deadlineInput = (stdin.readLineSync() ?? '').trim();

    DateTime? deadline;
    if (deadlineInput.isNotEmpty) {
      try {
        deadline = DateTime.parse(deadlineInput);
      } catch (_) {
        throw InvalidTaskException(
            'Deadline "$deadlineInput" is not a valid date (expected YYYY-MM-DD).');
      }
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final Task task;
    if (isUrgent) {
      if (deadline == null) {
        throw InvalidTaskException('An urgent task must have a deadline.');
      }
      task = UrgentTask(id: id, title: title, deadline: deadline);
    } else {
      final priority = PriorityLabel.fromShortcut(
        priorityInput.isEmpty ? 'medium' : priorityInput,
      );
      task = NormalTask(
        id: id,
        title: title,
        priority: priority,
        deadline: deadline,
      );
    }

    await repository.add(task);
    print('Task added.\n');
  }

  void _listTasks() {
    if (repository.tasks.isEmpty) {
      print('No tasks yet.\n');
      return;
    }

    stdout.write('Sort by (p = priority, d = date): ');
    final sortChoice = (stdin.readLineSync() ?? 'p').trim().toLowerCase();

    final tasks =
        sortChoice == 'd' ? repository.sortedByDate() : repository.sortedByPriority();

    print('\n--- Tasks ---');
    for (final task in tasks) {
      // Polymorphism: describe() prints differently for NormalTask/UrgentTask.
      print('${task.id} -> ${task.describe()}');
    }
    print('');
  }

  Future<void> _markDone() async {
    stdout.write('Task id to mark as done: ');
    final id = (stdin.readLineSync() ?? '').trim();
    await repository.markDone(id);
    print('Task marked as done.\n');
  }

  Future<void> _deleteTask() async {
    stdout.write('Task id to delete: ');
    final id = (stdin.readLineSync() ?? '').trim();
    await repository.delete(id);
    print('Task deleted.\n');
  }
}
