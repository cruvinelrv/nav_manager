import 'package:flutter/material.dart';
import 'package:nav_manager/src/dependency_injection/dependency_injector.dart';
import 'package:nav_manager/src/dependency_injection/dependency_scope_enum.dart';
import 'package:nav_manager/src/module/nav_module.dart';
import 'package:nav_manager/src/navigation/nav_injector.dart';

class NavManagerConfig {
  final bool isMultRepo;
  final Map<String, NavModule> localModules;
  final Map<String, String> remoteModules;
  final Map<String, Widget Function(BuildContext)> routes;
  final DependencyScopeEnum dependencyScope;
  final DependencyInjector? injectorType;

  NavManagerConfig({
    this.isMultRepo = false,
    this.localModules = const {},
    this.remoteModules = const {},
    required this.routes,
    this.dependencyScope = DependencyScopeEnum.singleton,
    this.injectorType,
  });

  /// Método para configurar e registrar módulos.
  void configureModules(NavInjector injector) {
    // Configurar módulos locais
    for (var module in localModules.values) {
      module.registerDependencies(injector);
      module.registerRoutes(injector);
    }

    // Configurar módulos remotos se for multirepo
    if (isMultRepo) {
      for (var entry in remoteModules.entries) {
        print('Verificando módulo remoto: ${entry.key} de ${entry.value}');
      }
    }
  }

  /// Método de fábrica para criar uma configuração padrão.
  static NavManagerConfig createDefaultConfig({
    required DependencyInjector injector,
  }) {
    return NavManagerConfig(
      isMultRepo: false,
      localModules: {},
      remoteModules: {},
      routes: {},
      dependencyScope: DependencyScopeEnum.singleton,
      injectorType: injector,
    );
  }
}
