import 'package:nav_manager/src/dependency_injection/dependency_scope_enum.dart';

abstract class NavDependencyInjector {
  void register<T extends Object>(T instance, DependencyScopeEnum scope);
  void registerFactory<T extends Object>(T Function() factory, DependencyScopeEnum scope);
  void registerLazySingleton<T extends Object>(T Function() factory);
  T resolve<T>();
  bool isRegistered<T>();
  void reset();
  void unregister<T>();
  List<Type> getRegisteredTypes();
  DependencyScopeEnum? getScope<T>();
  Map<String, dynamic> getDebugInfo();
}
