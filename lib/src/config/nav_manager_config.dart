import 'package:flutter/material.dart';
import 'package:nav_manager/src/dependency_injection/dependency_scope_enum.dart';
import 'package:nav_manager/src/module/nav_module.dart';
import 'package:nav_manager/src/navigation/nav_injector.dart';

class NavManagerConfig {
  final bool isMultRepo;
  final Map<String, NavModule> localModules;
  final Map<String, NavModule> remoteModules;
  final Map<String, Widget Function()> routes;
  final DependencyScopeEnum dependencyScope;
  final NavInjector navInjector;

  NavManagerConfig({
    this.isMultRepo = false,
    this.localModules = const {},
    this.remoteModules = const {},
    required this.routes,
    this.dependencyScope = DependencyScopeEnum.singleton,
    required this.navInjector,
  });

  void configureModules() {
    for (var module in localModules.values) {
      module.registerDependencies(navInjector);
      module.registerRoutes(navInjector);
    }

    if (isMultRepo) {
      for (var module in remoteModules.values) {
        module.registerDependencies(navInjector);
        module.registerRoutes(navInjector);
      }
    }

    configureRoutes();
  }

  void configureRoutes() {
    for (var entry in routes.entries) {
      final routeBuilder = entry.value;
      navInjector.registerRoute(entry.key, routeBuilder);
    }
  }

  static NavManagerConfig createDefaultConfig({
    required NavInjector navInjector,
  }) {
    return NavManagerConfig(
      isMultRepo: false,
      localModules: {},
      remoteModules: {},
      routes: {},
      dependencyScope: DependencyScopeEnum.singleton,
      navInjector: navInjector,
    );
  }
}
