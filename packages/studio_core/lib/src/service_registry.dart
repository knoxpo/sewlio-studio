/// A minimal typed service locator: one instance per type.
///
/// The app shell composes services at startup and hands the registry to
/// whatever needs dependencies; domain code declares what it needs by
/// type. No lifecycle, no scopes.
// ponytail: flat type→instance map — add scoping/lifecycle only if a
// real second scope shows up.
final class ServiceRegistry {
  final Map<Type, Object> _services = {};

  /// Registers [service] as the implementation of [T].
  /// Throws [StateError] if [T] is already registered.
  void register<T extends Object>(T service) {
    if (_services.containsKey(T)) {
      throw StateError('Service already registered: $T');
    }
    _services[T] = service;
  }

  /// Returns the registered [T]. Throws [StateError] if missing.
  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('Service not registered: $T');
    }
    return service as T;
  }

  /// Returns the registered [T], or null if none.
  T? maybeGet<T extends Object>() => _services[T] as T?;
}
