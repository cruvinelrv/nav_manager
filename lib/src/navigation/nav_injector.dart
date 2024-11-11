import 'package:flutter/material.dart';

class NavInjector {
  final Map<String, dynamic> _dependencies = <String, dynamic>{};
  final Map<String, Widget Function(BuildContext)> _routes = <String,
      Widget Function(BuildContext)>{}; // Mudamos para aceitar BuildContext

  /// Registra uma dependência com a chave correspondente
  void register(String key, dynamic dependency) {
    if (_dependencies.containsKey(key)) {
      throw ArgumentError(
          'A dependência com a chave "$key" já foi registrada.');
    }
    _dependencies[key] = dependency;
  }

  /// Registra uma rota com a chave correspondente
  void registerRoute(String route, Widget Function(BuildContext) pageBuilder) {
    debugPrint('Registrando rota: $route');
    if (_routes.containsKey(route)) {
      throw ArgumentError('A rota "$route" já foi registrada.');
    }
    _routes[route] = pageBuilder;
  }

  /// Resolve uma dependência registrada
  T resolve<T>(String key) {
    final dependency = _dependencies[key];
    if (dependency is T) {
      return dependency;
    }
    throw ArgumentError(
      'Dependência de tipo ${T.toString()} não encontrada para a chave "$key".',
    );
  }

  /// Resolve uma rota registrada e retorna um Widget
  Widget resolveRoute(BuildContext context, String route) {
    final pageBuilder = _routes[route];
    if (pageBuilder != null) {
      // Agora passamos o BuildContext para a função de criação da página
      return pageBuilder(context);
    }
    debugPrint('Rota não encontrada: $route');
    // Se a rota não for encontrada, usamos a rota padrão '/'
    return _routes['/']!(context);
  }

  /// Método para registrar uma rota padrão (caso o usuário não tenha definido)
  void registerDefaultRoute(Widget Function(BuildContext) pageBuilder) {
    if (_routes.containsKey('/')) {
      debugPrint('A rota padrão "/" já foi registrada e será sobrescrita.');
    }
    _routes['/'] = pageBuilder;
  }

  /// Método para obter todas as rotas registradas
  List<String> getRoutes() {
    return _routes.keys.toList();
  }

  /// Método para imprimir todas as rotas registradas
  void printRoutes() {
    print('Rotas registradas na lista:');
    _routes.forEach((key, value) {
      print('Rota: $key');
    });
  }
}
