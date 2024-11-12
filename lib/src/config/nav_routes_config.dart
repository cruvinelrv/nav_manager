import 'package:flutter/material.dart';

abstract class NavRoutesConfig {
  Map<String, Widget Function()> get routes;

  void defineRoutes();

  void registerRoute(String route, Widget Function() pageBuilder) {
    if (!routes.containsKey(route)) {
      routes[route] = pageBuilder;
    }
  }

  Map<String, Widget Function()> getAllRoutes() {
    return routes;
  }
}
