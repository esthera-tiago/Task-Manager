import 'dart:io';

import 'package:task_manager_cli/exceptions/task_exceptions.dart';
import 'package:task_manager_cli/models/normal_task.dart';
import 'package:task_manager_cli/models/priority.dart';
import 'package:task_manager_cli/models/urgent_task.dart';
import 'package:task_manager_cli/repository/task_repository.dart';
import 'package:test/test.dart';

void main() {
  // We use a temporary file for each test so tests never touch
  // the real tasks.json and never depend on each other.
  late String tempPath;
  late TaskRepository repository;

  setUp(() {
    tempPath =
        '${Directory.systemTemp.path}/test_tasks_${DateTime.now().microsecondsSinceEpoch}.json';
    repository = TaskRepository(tempPath);
  });

  tearDown(() {
    final file = File(tempPath);
    if (file.existsSync()) file.deleteSync();
  });

  test('a new repository starts empty', () async {
    final tasks = await repository.getAll();
    expect(tasks, isEmpty);
  });

  test('add() stores a task and it can be found by id', () async {
    final task = NormalTask(id: '1', title: 'Buy milk', priority: Priority.low);

    await repository.add(task);
    final tasks = await repository.getAll();

    expect(tasks.length, 1);
    expect(repository.getById('1').title, 'Buy milk');
  });

  test('add() throws InvalidTaskException for an empty title', () async {
    final task = NormalTask(id: '2', title: '   ', priority: Priority.medium);

    expect(() => repository.add(task), throwsA(isA<InvalidTaskException>()));
  });

  test('delete() removes a task, and throws if the id does not exist',
      () async {
    final task = NormalTask(id: '3', title: 'Clean desk', priority: Priority.medium);
    await repository.add(task);

    await repository.delete('3');
    final tasks = await repository.getAll();
    expect(tasks, isEmpty);

    expect(() => repository.delete('does-not-exist'),
        throwsA(isA<TaskNotFoundException>()));
  });

  test('markDone() sets isDone to true on the right task', () async {
    final task = NormalTask(id: '4', title: 'Write report', priority: Priority.high);
    await repository.add(task);

    await repository.markDone('4');

    expect(repository.getById('4').isDone, isTrue);
  });

  test('sortedByPriority() puts high priority (and UrgentTask) first',
      () async {
    final low = NormalTask(id: '5', title: 'Low task', priority: Priority.low);
    final medium =
        NormalTask(id: '6', title: 'Medium task', priority: Priority.medium);
    final urgent = UrgentTask(
      id: '7',
      title: 'Urgent task',
      deadline: DateTime.now().add(const Duration(days: 1)),
    );

    await repository.add(low);
    await repository.add(medium);
    await repository.add(urgent);

    final sorted = repository.sortedByPriority();

    expect(sorted.first.id, '7'); // UrgentTask is always Priority.high
    expect(sorted.last.id, '5');
  });

  test('data survives a reload from disk (persistence check)', () async {
    final task = NormalTask(id: '8', title: 'Persisted task', priority: Priority.medium);
    await repository.add(task);

    // Simulate the app restarting: create a brand new repository
    // instance pointing at the same file.
    final reloaded = TaskRepository(tempPath);
    final tasks = await reloaded.getAll();

    expect(tasks.length, 1);
    expect(tasks.first.title, 'Persisted task');
  });

  test('update() replaces an existing task', () async {
    final task = NormalTask(id: '9', title: 'Old title', priority: Priority.low);
    await repository.add(task);

    final updated = NormalTask(
      id: '9',
      title: 'New title',
      priority: Priority.high,
    );
    await repository.update(updated);

    final saved = repository.getById('9');
    expect(saved.title, 'New title');
    expect(saved.priority, Priority.high);
  });

  test('add() rejects a duplicate id', () async {
    await repository.add(
      NormalTask(id: '10', title: 'First', priority: Priority.low),
    );

    final duplicate = NormalTask(
      id: '10',
      title: 'Second',
      priority: Priority.low,
    );
    expect(() => repository.add(duplicate),
        throwsA(isA<InvalidTaskException>()));
  });

  test('getById() throws TaskNotFoundException for an unknown id', () async {
    expect(() => repository.getById('missing'),
        throwsA(isA<TaskNotFoundException>()));
  });

  test('sortedByDate() orders by deadline, tasks without one come last',
      () async {
    final noDeadline = NormalTask(
      id: '11',
      title: 'No deadline',
      priority: Priority.medium,
    );
    final later = NormalTask(
      id: '12',
      title: 'Later',
      priority: Priority.medium,
      deadline: DateTime(2030, 12, 31),
    );
    final sooner = NormalTask(
      id: '13',
      title: 'Sooner',
      priority: Priority.medium,
      deadline: DateTime(2030, 1, 1),
    );

    await repository.add(noDeadline);
    await repository.add(later);
    await repository.add(sooner);

    final sorted = repository.sortedByDate();
    expect(sorted[0].id, '13');
    expect(sorted[1].id, '12');
    expect(sorted[2].id, '11');
  });
}
