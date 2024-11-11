import 'package:flutter/material.dart';

abstract class NavRoutesConfig {
  static final Map<String, Widget Function()> _routes = {};

  void defineRoutes();

  void registerRoute(String route, Widget Function() pageBuilder) {
    if (!_routes.containsKey(route)) {
      _routes[route] = pageBuilder;
    }
  }

  Map<String, Widget Function(BuildContext)> getAllRoutes() {
    return Map.fromEntries(
      _routes.entries.map(
        (entry) => MapEntry(entry.key, (context) => entry.value()),
      ),
    );
  }
}
