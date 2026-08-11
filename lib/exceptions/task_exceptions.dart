// Custom exceptions used across the app.
// I use a base abstract class so every custom error in this app
// shares the same "shape" and can be caught together if needed.

abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when we look for a task by id and it does not exist.
class TaskNotFoundException extends AppException {
  TaskNotFoundException(String id) : super('Task with id "$id" was not found.');
}

/// Thrown when the data given to create/update a task is not valid
/// (empty title, deadline in the past, etc.).
class InvalidTaskException extends AppException {
  InvalidTaskException(String message) : super(message);
}

/// Thrown when something goes wrong while reading/writing the JSON file.
class StorageException extends AppException {
  StorageException(String message) : super(message);
}
