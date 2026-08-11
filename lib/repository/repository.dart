// Generic contract for a data store.
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
  Future<void> save();
}
