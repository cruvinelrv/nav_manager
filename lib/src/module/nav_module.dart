import 'package:nav_manager/nav_manager.dart';

abstract class NavModule {
  void registerDependencies(NavInjector injector);
  void registerRoutes(NavInjector injector);
}

class LocalModule implements NavModule {
  @override
  void registerDependencies(NavInjector injector) {}

  @override
  void registerRoutes(NavInjector injector) {}
}

class RemoteModule implements NavModule {
  @override
  void registerDependencies(NavInjector injector) {}

  @override
  void registerRoutes(NavInjector injector) {}
}
