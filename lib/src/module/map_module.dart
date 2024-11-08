// lib/src/map_module.dart

import '../navigation/nav_injector.dart';
import 'module.dart';

class MapModule {
  final String name;
  final List<Module> localModules;
  final List<Module> remoteModules;
  final Map<String, dynamic> dependencies;

  MapModule({
    required this.name,
    required this.localModules,
    required this.remoteModules,
    required this.dependencies,
  });

  // Configura os módulos locais e remotos
  void configureModules(NavInjector injector) {
    // Registrando módulos locais
    _registerModules(injector, localModules);

    // Registrando módulos remotos
    _registerModules(injector, remoteModules);
  }

  // Registra dependências e rotas para os módulos locais e remotos
  void _registerModules(NavInjector injector, List<Module> modules) {
    for (var module in modules) {
      // Passando o injector para os métodos registerDependencies e registerRoutes
      module.registerDependencies(injector);
      module.registerRoutes(injector);
    }
  }
}
