import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import 'repository.dart';

// Repository backed by a local JSON file (dart:io + dart:convert only).
class TaskRepository implements Repository<Task> {
  final File _file;
  List<Task> _tasks = [];

  TaskRepository(String path) : _file = File(path) {
    _loadSync();
  }

  // Read-only view so callers cannot mutate the internal list directly.
  List<Task> get tasks => List.unmodifiable(_tasks);

  void _loadSync() {
    try {
      if (!_file.existsSync()) {
        _file.createSync(recursive: true);
        _file.writeAsStringSync('[]');
      }
      final content = _file.readAsStringSync();
      if (content.trim().isEmpty) {
        _tasks = [];
        return;
      }
      final decoded = jsonDecode(content) as List<dynamic>;
      _tasks = decoded
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException('Could not load tasks from ${_file.path}: $e');
    }
  }

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(_tasks);

  @override
  Future<void> add(Task item) async {
    if (item.title.trim().isEmpty) {
      throw InvalidTaskException('Task title cannot be empty.');
    }
    if (_tasks.any((t) => t.id == item.id)) {
      throw InvalidTaskException('A task with id "${item.id}" already exists.');
    }
    _tasks.add(item);
    await save();
  }

  @override
  Future<void> update(Task item) async {
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) throw TaskNotFoundException(item.id);
    _tasks[index] = item;
    await save();
  }

  @override
  Future<void> delete(String id) async {
    final existed = _tasks.any((t) => t.id == id);
    if (!existed) throw TaskNotFoundException(id);
    _tasks.removeWhere((t) => t.id == id);
    await save();
  }

  @override
  Future<void> save() async {
    try {
      final jsonList = _tasks.map((t) => t.toJson()).toList();
      await _file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      throw StorageException('Could not save tasks to ${_file.path}: $e');
    }
  }

  Task getById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    throw TaskNotFoundException(id);
  }

  Future<void> markDone(String id) async {
    final task = getById(id);
    task.isDone = true;
    await save();
  }

  // High priority first (uses Task.compareTo).
  List<Task> sortedByPriority() {
    final copy = List<Task>.from(_tasks);
    copy.sort();
    return copy;
  }

  // Earliest deadline first; tasks without a deadline come last.
  List<Task> sortedByDate() {
    final copy = List<Task>.from(_tasks);
    copy.sort((a, b) {
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });
    return copy;
  }
}
