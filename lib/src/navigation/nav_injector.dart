import 'package:flutter/material.dart';

class NavInjector {
  final Map<String, Widget Function()> _routes = {};

  void registerRoute(String path, Widget Function() builder) {
    print('📝 Registrando rota no NavInjector: $path');
    _routes[path] = builder;
  }

  List<String> getRoutes() {
    print('📋 Obtendo lista de rotas: ${_routes.keys.toList()}');
    return _routes.keys.toList();
  }

  Widget Function()? resolveRoute(String path) {
    print('🔍 Resolvendo rota: $path');
    final builder = _routes[path];
    if (builder != null) {
      print('✅ Builder encontrado para: $path');
    } else {
      print('❌ Builder não encontrado para: $path');
    }
    return builder;
  }

  void printRegisteredRoutes() {
    print('\n📊 Rotas registradas no NavInjector:');
    for (var route in _routes.keys) {
      print('  - $route');
    }
    print('');
  }
}
