import 'package:flutter/material.dart';
import 'package:nav_manager/src/navigation/nav_injector.dart';

abstract class NavRoutesConfig {
  Map<String, Widget Function(NavInjector)> get routes;

  void defineRoutes();

  void registerRoute(String route, Widget Function(NavInjector) pageBuilder) {
    if (!routes.containsKey(route)) {
      routes[route] = pageBuilder;
    }
  }

  Map<String, Widget Function(NavInjector)> getAllRoutes() {
    return routes;
  }
}
