import 'package:flutter/material.dart';

class NavInjector {
  final Map<String, Widget Function()> _routes = {};

  void registerRoute(String path, Widget Function() builder) {
    debugPrint('📝 Registering route in NavInjector: $path');
    _routes[path] = builder;
  }

  List<String> getRoutes() {
    debugPrint('📋 Getting list of routes: ${_routes.keys.toList()}');
    return _routes.keys.toList();
  }

  Widget Function()? resolveRoute(String path) {
    final builder = _routes[path];
    if (builder != null) {
      debugPrint('✅ Route found: $path');
    } else {
      debugPrint('❌ Route not found: $path');
    }
    return builder;
  }

  void printRegisteredRoutes() {
    debugPrint('\n📊 Routes registered in NavInjector:');
    for (var route in _routes.keys) {
      debugPrint('  - $route');
    }
    debugPrint('');
  }
}
