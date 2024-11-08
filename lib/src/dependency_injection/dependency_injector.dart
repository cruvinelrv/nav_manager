import 'package:nav_manager/src/dependency_injection/dependency_scope_enum.dart';

abstract class DependencyInjector {
  void register<T extends Object>(T instance, DependencyScopeEnum scope);
  T resolve<T>();
  void reset();
  bool isRegistered<T>();
}
