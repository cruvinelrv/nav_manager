import 'package:nav_manager/src/dependency_injection/dependency_scope_enum.dart';

// Forward declaration para evitar dependência cíclica se FactoryFunc precisasse de INavDependencyInjector
// e INavDependencyInjector precisasse de FactoryFunc no mesmo arquivo.
// Neste caso, FactoryFunc usa INavDependencyInjector, então está ok.
abstract class INavDependencyInjector {
  void register<T extends Object>(
    FactoryFunc<T> factory, {
    required DependencyScopeEnum scope,
    String? tag,
  });

  void registerInstance<T extends Object>(
    T instance, {
    String? tag,
  });

  T get<T extends Object>({String? tag});
  bool isRegistered<T extends Object>({String? tag});
  bool unregister<T extends Object>({String? tag, bool autoDispose = true});
  void unregisterAll({bool autoDispose = true});
}

// Tipo da função factory para criar dependências.
// O INavDependencyInjector passado permite que as factories resolvam outras dependências.
typedef FactoryFunc<T> = T Function(INavDependencyInjector injector);
