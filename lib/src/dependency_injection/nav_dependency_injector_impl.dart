// src/dependency_injection/simple_dependency_injector.dart
import 'nav_dependency_injector.dart';
import 'dependency_scope_enum.dart';

/// Default implementation of [NavDependencyInjector]
///
/// A lightweight, in-memory dependency injection container
/// supporting singleton, lazySingleton, factory, and instance scopes.
class NavDependencyInjectorImpl extends NavDependencyInjector {
  final Map<Type, dynamic> _instances = {};
  final Map<Type, DependencyScopeEnum> _scopes = {};
  final Map<Type, Function> _factories = {};

  @override
  void register<T extends Object>(T instance, DependencyScopeEnum scope) {
    switch (scope) {
      case DependencyScopeEnum.singleton:
        _instances[T] = instance;
        _scopes[T] = scope;
        break;

      case DependencyScopeEnum.lazySingleton:
        // For lazy singleton, we store as factory but with singleton behavior
        _factories[T] = () => instance;
        _scopes[T] = scope;
        break;

      case DependencyScopeEnum.factory:
        // For factory, we need a function - this might be a limitation
        // User should use registerFactory instead
        _factories[T] = () => instance;
        _scopes[T] = scope;
        break;

      case DependencyScopeEnum.instance:
        _instances[T] = instance;
        _scopes[T] = scope;
        break;
    }
  }

  /// Registers a factory function
  void registerFactory<T extends Object>(
    T Function() factory,
    DependencyScopeEnum scope,
  ) {
    _factories[T] = factory;
    _scopes[T] = scope;
  }

  /// Convenient method to register a singleton (immediate creation)
  void registerSingleton<T extends Object>(T instance) {
    register<T>(instance, DependencyScopeEnum.singleton);
  }

  /// Convenient method to register a lazy singleton
  void registerLazySingleton<T extends Object>(T Function() factory) {
    registerFactory<T>(factory, DependencyScopeEnum.lazySingleton);
  }

  /// Convenient method to register a factory
  void registerFactoryFunction<T extends Object>(T Function() factory) {
    registerFactory<T>(factory, DependencyScopeEnum.factory);
  }

  /// Convenient method to register an instance
  void registerInstance<T extends Object>(T instance) {
    register<T>(instance, DependencyScopeEnum.instance);
  }

  @override
  T resolve<T>() {
    final scope = _scopes[T];

    if (scope == null) {
      throw Exception('Type $T is not registered');
    }

    switch (scope) {
      case DependencyScopeEnum.singleton:
        return _resolveSingleton<T>();

      case DependencyScopeEnum.lazySingleton:
        return _resolveLazySingleton<T>();

      case DependencyScopeEnum.factory:
        return _resolveFactory<T>();

      case DependencyScopeEnum.instance:
        return _resolveInstance<T>();

      default:
        throw Exception('Unsupported scope: $scope');
    }
  }

  T _resolveSingleton<T>() {
    if (_instances.containsKey(T)) {
      return _instances[T] as T;
    }
    throw Exception('Singleton instance not found for type $T');
  }

  T _resolveLazySingleton<T>() {
    // Check if already created and cached
    if (_instances.containsKey(T)) {
      return _instances[T] as T;
    }

    // Create from factory and cache it
    if (_factories.containsKey(T)) {
      final factory = _factories[T] as T Function();
      final instance = factory();
      _instances[T] = instance; // Cache for future calls
      return instance;
    }

    throw Exception('Lazy singleton factory not found for type $T');
  }

  T _resolveFactory<T>() {
    // Always create new instance
    if (_factories.containsKey(T)) {
      final factory = _factories[T] as T Function();
      return factory();
    }
    throw Exception('Factory not found for type $T');
  }

  T _resolveInstance<T>() {
    if (_instances.containsKey(T)) {
      return _instances[T] as T;
    }
    throw Exception('Instance not found for type $T');
  }

  @override
  bool isRegistered<T>() {
    return _scopes.containsKey(T);
  }

  @override
  void reset() {
    _instances.clear();
    _scopes.clear();
    _factories.clear();
  }

  /// Unregisters a specific type
  void unregister<T>() {
    _instances.remove(T);
    _scopes.remove(T);
    _factories.remove(T);
  }

  /// Gets all registered types
  List<Type> getRegisteredTypes() {
    return _scopes.keys.toList();
  }

  /// Gets the scope of a registered type
  DependencyScopeEnum? getScope<T>() {
    return _scopes[T];
  }

  /// Gets debug information about current registrations
  Map<String, dynamic> getDebugInfo() {
    return {
      'total_registrations': _scopes.length,
      'singletons': _scopes.entries.where((e) => e.value == DependencyScopeEnum.singleton).length,
      'lazy_singletons':
          _scopes.entries.where((e) => e.value == DependencyScopeEnum.lazySingleton).length,
      'factories': _scopes.entries.where((e) => e.value == DependencyScopeEnum.factory).length,
      'instances': _scopes.entries.where((e) => e.value == DependencyScopeEnum.instance).length,
      'cached_instances': _instances.length,
      'registered_factories': _factories.length,
      'types': _scopes.keys.map((e) => e.toString()).toList(),
    };
  }
}
