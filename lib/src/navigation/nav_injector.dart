import 'package:flutter/material.dart';

class NavInjector {
  final Map<String, dynamic> _dependencies = {};
  final Map<String, Widget Function()> _routes = {};

  /// Registra uma dependência com a chave correspondente
  void register(String key, dynamic dependency) {
    _dependencies[key] = dependency;
  }

  /// Registra uma rota com a chave correspondente
  void registerRoute(String route, Widget Function() pageBuilder) {
    _routes[route] = pageBuilder;
  }

  /// Resolve uma dependência registrada
  T resolve<T>(String key) {
    return _dependencies[key] as T;
  }

  /// Resolve uma rota registrada
  Widget Function()? resolveRoute(String route) {
    return _routes[
        route]; // Retorna a função de construção da página (widget builder)
  }
}
