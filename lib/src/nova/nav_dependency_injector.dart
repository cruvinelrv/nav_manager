// Define uma classe base para as estratégias de registro
import 'package:nav_manager/src/dependency_injection/dependency_scope_enum.dart';

abstract class _Registration {
  dynamic getInstance(NavDependencyInjector injector);
}

// Estratégia para Factory: cria uma nova instância a cada solicitação
class _FactoryRegistration<T extends Object> implements _Registration {
  // A função factory recebe o próprio injetor, permitindo resolver sub-dependências
  final T Function(NavDependencyInjector injector) factoryFunc;

  _FactoryRegistration(this.factoryFunc);

  @override
  T getInstance(NavDependencyInjector injector) {
    return factoryFunc(injector);
  }
}

// Estratégia para Singleton (e Lazy Singleton): cria uma única instância na primeira solicitação e a reutiliza
class _SingletonRegistration<T extends Object> implements _Registration {
  T? _instance;
  // A função factory recebe o próprio injetor
  final T Function(NavDependencyInjector injector) factoryFunc;

  _SingletonRegistration(this.factoryFunc);

  @override
  T getInstance(NavDependencyInjector injector) {
    _instance ??= factoryFunc(injector);
    return _instance!;
  }
}

/// Gerenciador de Injeção de Dependência customizado para o NavManager.
/// Permite registrar e resolver dependências (serviços, repositórios, etc.)
/// com diferentes escopos de ciclo de vida definidos por [DependencyScopeEnum].
class NavDependencyInjector {
  // Mapa para armazenar os registros. A chave é o Tipo, o valor é a estratégia de registro.
  final Map<Type, _Registration> _registrations = {};

  /// Registra uma dependência com um escopo especificado.
  ///
  /// [scope]: O escopo de ciclo de vida da dependência ([DependencyScopeEnum.singleton],
  ///   [DependencyScopeEnum.lazySingleton], ou [DependencyScopeEnum.factory]).
  /// [factoryFunc]: Uma função que cria a instância da dependência. Esta função
  ///   recebe o próprio injetor como argumento, permitindo resolver dependências aninhadas.
  ///   Não use este método para [DependencyScopeEnum.instance]; use [registerSingletonInstance]
  ///   para registrar instâncias pré-existentes.
  void register<T extends Object>({
    required DependencyScopeEnum scope,
    required T Function(NavDependencyInjector injector) factoryFunc,
  }) {
    if (scope == DependencyScopeEnum.instance) {
      throw ArgumentError("Use registerSingletonInstance for DependencyScopeEnum.instance");
    }

    if (_registrations.containsKey(T)) {
      // Opcional: lançar erro ou logar aviso se já registrado
      print("Warning: Type $T already registered. Overwriting.");
    }

    switch (scope) {
      case DependencyScopeEnum.factory:
        _registrations[T] = _FactoryRegistration<T>(factoryFunc);
        break;
      case DependencyScopeEnum.singleton:
      case DependencyScopeEnum.lazySingleton:
        // Nossa implementação de Singleton já é lazy por padrão, então ambos mapeiam aqui.
        _registrations[T] = _SingletonRegistration<T>(factoryFunc);
        break;
      case DependencyScopeEnum.instance:
        // Este caso nunca deve ser alcançado devido à verificação no início do método.
        break;
    }
  }

  /// Registra uma instância existente como um Singleton.
  /// Útil para registrar objetos que são inicializados antes da configuração do injetor,
  /// como a própria configuração ou o injetor.
  void registerSingletonInstance<T extends Object>(T instance) {
    if (_registrations.containsKey(T)) {
      print("Warning: Type $T already registered. Overwriting.");
    }
    // Cria um Singleton registration cuja factory apenas retorna a instância fornecida
    _registrations[T] = _SingletonRegistration<T>((_) => instance);
  }

  /// Obtém uma instância da dependência registrada para o tipo [T].
  /// Lança uma exceção [Exception] se o tipo [T] não estiver registrado.
  T get<T extends Object>() {
    final registration = _registrations[T];
    if (registration == null) {
      throw Exception(
          "Dependency not registered: $T. Make sure it was registered before calling get().");
    }
    // Usa a estratégia de registro para obter a instância
    return registration.getInstance(this) as T;
  }

  /// Verifica se uma dependência do tipo [T] está registrada.
  bool isRegistered<T extends Object>() {
    return _registrations.containsKey(T);
  }

  /// Remove todas as dependências registradas. Útil para testes.
  void reset() {
    _registrations.clear();
  }

  // Opcional: Método para registrar módulos inteiros de dependências
  // abstract class NavDependencyModule {
  //   void register(NavDependencyInjector injector);
  // }
  // void registerModule(NavDependencyModule module) {
  //   module.register(this);
  // }
}
