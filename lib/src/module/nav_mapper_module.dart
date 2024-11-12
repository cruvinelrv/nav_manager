import 'package:nav_manager/src/module/nav_module.dart';
import 'package:nav_manager/src/navigation/nav_injector.dart';

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

  void configureModules(NavInjector injector) {
    _registerModules(injector, localModules);

    _registerModules(injector, remoteModules);
  }

  void _registerModules(NavInjector injector, List<NavModule> modules) {
    for (var module in modules) {
      module.registerDependencies(injector);
      module.registerRoutes(injector);
    }
  }
}
