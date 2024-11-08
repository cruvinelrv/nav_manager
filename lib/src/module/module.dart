// lib/src/navigation/module.dart

import '../navigation/nav_injector.dart';

abstract class Module {
  void registerDependencies(NavInjector injector);
  void registerRoutes(NavInjector injector);
}

class LocalModule implements Module {
  @override
  void registerDependencies(NavInjector injector) {
    // Registrar dependências locais
    // injector.register('someKey', someDependency());
  }

  @override
  void registerRoutes(NavInjector injector) {
    // Registrar rotas locais
    // injector.registerRoute('/local', () => LocalPage());
  }
}

class RemoteModule implements Module {
  @override
  void registerDependencies(NavInjector injector) {
    // Registrar dependências remotas
    // injector.register('someRemoteService', someRemoteService());
  }

  @override
  void registerRoutes(NavInjector injector) {
    // Registrar rotas remotas
    // injector.registerRoute('/remote', () => RemotePage());
  }
}
