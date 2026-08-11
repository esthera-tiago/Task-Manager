// Base class shared by all exceptions raised by the app.
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class TaskNotFoundException extends AppException {
  TaskNotFoundException(String id) : super('Task with id "$id" was not found.');
}

class InvalidTaskException extends AppException {
  InvalidTaskException(String message) : super(message);
}

class StorageException extends AppException {
  StorageException(String message) : super(message);
}
