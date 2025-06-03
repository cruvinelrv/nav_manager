import 'package:nav_manager/nav_manager.dart';

abstract class NavDependencyInjector {
  void register<T extends Object>(T instance, DependencyScopeEnum scope);
  void registerFactory<T extends Object>(T Function() factory, DependencyScopeEnum scope);
  void registerSingleton<T extends Object>(T instance);
  void registerLazySingleton<T extends Object>(T Function() factory);
  void registerInstance<T extends Object>(T instance);
  T resolve<T>();
  bool isRegistered<T>();
  void reset();
  void unregister<T>();
  List<Type> getRegisteredTypes();
  DependencyScopeEnum? getScope<T>();
  Map<String, dynamic> getDebugInfo();
}
