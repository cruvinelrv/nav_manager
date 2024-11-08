// lib/src/map_module.dart

import '../navigation/nav_injector.dart';
import 'nav_module.dart';

class NavMapperModule {
  final String name;
  final List<NavModule> localModules;
  final List<NavModule> remoteModules;
  final Map<String, dynamic> dependencies;

  NavMapperModule({
    required this.name,
    this.localModules = const [],
    this.remoteModules = const [],
    this.dependencies = const {},
  });

  // Configura os módulos locais e remotos
  void configureModules(NavInjector injector) {
    // Registrando módulos locais
    _registerModules(injector, localModules);

    // Registrando módulos remotos
    _registerModules(injector, remoteModules);
  }

  // Registra dependências e rotas para os módulos locais e remotos
  void _registerModules(NavInjector injector, List<NavModule> modules) {
    for (var module in modules) {
      // Passando o injector para os métodos registerDependencies e registerRoutes
      module.registerDependencies(injector);
      module.registerRoutes(injector);
    }
  }
}
