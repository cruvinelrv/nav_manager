import 'package:nav_manager/src/dependency_injection/nav_dependency_injector.dart';

import 'dependency_scope_enum.dart';

/// A simple, basic implementation of [NavDependencyInjector].
/// Supports singleton, lazy singleton, factory, and instance scopes
/// based on the provided interface and enum.
class NavDependencyInjectorImpl implements NavDependencyInjector {
  // Internal storage for different registration types
  // _singletons armazena instâncias para escopos singleton e instance
  final Map<Type, dynamic> _singletons = {};
  // _lazySingletonFactories armazena fábricas para escopo lazySingleton
  final Map<Type, Function()> _lazySingletonFactories = {};
  // _factories armazena fábricas para escopo factory
  final Map<Type, Function()> _factories = {};
  // _scopes armazena o escopo registrado para cada tipo
  final Map<Type, DependencyScopeEnum> _scopes = {};

  // Helper para verificar se um tipo já está registrado em qualquer mapa
  // Usamos T sem extends Object para compatibilidade com resolve, isRegistered, etc.
  bool _isTypeRegistered<T>() {
    return _singletons.containsKey(T) ||
        _lazySingletonFactories.containsKey(T) ||
        _factories.containsKey(T);
  }

  // Helper para lançar erro se já registrado
  // Usamos T sem extends Object para compatibilidade com resolve, isRegistered, etc.
  void _checkAlreadyRegistered<T>() {
    if (_isTypeRegistered<T>()) {
      throw StateError('Type $T is already registered.');
    }
  }

  @override
  // Este método na interface tem extends Object
  void register<T extends Object>(T instance, DependencyScopeEnum scope) {
    _checkAlreadyRegistered<T>(); // O helper funciona com T sem extends Object
    switch (scope) {
      case DependencyScopeEnum.singleton:
      case DependencyScopeEnum.instance: // Trata 'instance' como 'singleton' para instância fixa
        _singletons[T] = instance;
        _scopes[T] = scope; // Armazena o escopo exato usado
        break;
      case DependencyScopeEnum.lazySingleton:
      case DependencyScopeEnum.factory:
        // Não faz sentido registrar uma instância fixa com escopo que requer fábrica.
        throw ArgumentError(
            'Cannot register an instance with scope ${scope}. Use registerFactory or registerLazySingleton for factory-based scopes.');
    }
  }

  @override
  // Este método na interface tem extends Object
  void registerFactory<T extends Object>(T Function() factory, DependencyScopeEnum scope) {
    _checkAlreadyRegistered<T>(); // O helper funciona com T sem extends Object
    switch (scope) {
      case DependencyScopeEnum.lazySingleton:
        _lazySingletonFactories[T] = factory;
        _scopes[T] = DependencyScopeEnum.lazySingleton;
        break;
      case DependencyScopeEnum.factory:
        _factories[T] = factory;
        _scopes[T] = DependencyScopeEnum.factory;
        break;
      case DependencyScopeEnum.singleton:
      case DependencyScopeEnum.instance:
        // Não faz sentido registrar uma fábrica com escopo que requer instância fixa.
        throw ArgumentError(
            'Cannot register a factory with scope ${scope}. Use register or registerSingleton for instance-based scopes.');
    }
  }

  @override
  // Este método na interface tem extends Object
  void registerLazySingleton<T extends Object>(T Function() factory) {
    // Este método é um wrapper de conveniência para registerFactory com escopo lazySingleton
    registerFactory<T>(factory, DependencyScopeEnum.lazySingleton);
  }

  @override
  // Este método na interface NÃO tem extends Object
  T resolve<T>() {
    // 1. Verifica instâncias singleton ou instance já criadas/registradas
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    // 2. Verifica fábricas de singleton lazy
    if (_lazySingletonFactories.containsKey(T)) {
      // Cria a instância, armazena como singleton e remove a fábrica
      final instance = _lazySingletonFactories[T]!();
      _singletons[T] = instance; // Armazena a instância criada no mapa de singletons
      _lazySingletonFactories.remove(T); // Remove a fábrica lazy
      // O escopo foi definido para lazySingleton durante o registro
      return instance as T;
    }

    // 3. Verifica funções fábrica (factory)
    if (_factories.containsKey(T)) {
      // Cria uma nova instância usando a fábrica a cada resolução
      // O escopo foi definido para factory durante o registro
      return _factories[T]!() as T;
    }

    // Se não encontrado em nenhum registro
    throw StateError('Type ${T} is not registered in the dependency injector.');
  }

  @override
  // Este método na interface NÃO tem extends Object
  bool isRegistered<T>() {
    return _isTypeRegistered<T>();
  }

  @override
  void reset() {
    _singletons.clear();
    _lazySingletonFactories.clear();
    _factories.clear();
    _scopes.clear();
  }

  @override
  // Este método na interface NÃO tem extends Object
  void unregister<T>() {
    _singletons.remove(T);
    _lazySingletonFactories.remove(T);
    _factories.remove(T);
    _scopes.remove(T);
  }

  @override
  List<Type> getRegisteredTypes() {
    // Combina chaves de todos os mapas de registro
    return (_singletons.keys.toList() +
            _lazySingletonFactories.keys.toList() +
            _factories.keys.toList())
        .toSet()
        .toList();
  }

  @override
  // Este método na interface NÃO tem extends Object
  DependencyScopeEnum? getScope<T>() {
    return _scopes[T];
  }

  @override
  Map<String, dynamic> getDebugInfo() {
    return {
      'singletons (and instances)': _singletons.keys.map((t) => t.toString()).toList(),
      'lazySingletonFactories': _lazySingletonFactories.keys.map((t) => t.toString()).toList(),
      'factories': _factories.keys.map((t) => t.toString()).toList(),
      'scopes': _scopes.map((type, scope) => MapEntry(type.toString(), scope.toString())),
    };
  }
}
