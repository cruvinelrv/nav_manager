import 'package:flutter/material.dart';

abstract class NavRoutesConfig {
  final Map<String, Widget Function()> _routes = {};

  void injectRoutes();

  void registerRoute(String route, Widget Function() pageBuilder) {
    if (!_routes.containsKey(route)) {
      _routes[route] = pageBuilder;
    }
  }

  Map<String, Widget Function()> getAllRoutes() {
    return _routes;
  }
}
