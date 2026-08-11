// Generic repository interface.
// This lets us write "Repository<Task>" but the same contract could be
// reused later for another type (Repository<User> for example),
// that's the point of generics here.
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
  Future<void> save();
}
