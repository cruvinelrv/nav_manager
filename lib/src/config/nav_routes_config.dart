import 'package:flutter/material.dart';
import 'package:nav_manager/src/navigation/nav_injector.dart';

abstract class NavRoutesConfig {
  static final Map<String, Widget Function()> _routes = {};

  void defineRoutes();

  void registerRoute(String route, Widget Function() pageBuilder) {
    if (!_routes.containsKey(route)) {
      _routes[route] = pageBuilder;
    }
  }

  Map<String, Widget Function(BuildContext)> getAllRoutes(
      NavInjector navInjector) {
    return Map.fromEntries(
      _routes.entries.map(
        (entry) {
          return MapEntry(
            entry.key,
            (context) {
              final resolvedRoute = navInjector.resolveRoute(entry.key);
              if (resolvedRoute != null) {
                return resolvedRoute();
              } else {
                final routeBuilder = entry.value;
                return routeBuilder();
              }
            },
          );
        },
      ),
    );
  }
}
