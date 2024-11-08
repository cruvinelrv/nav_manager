import 'package:flutter/material.dart';

class NavInjector {
  final Map<String, dynamic> _dependencies = <String, dynamic>{};
  final Map<String, Widget Function()> _routes = <String, Widget Function()>{};

  /// Registra uma dependência com a chave correspondente
  void register(String key, dynamic dependency) {
    if (_dependencies.containsKey(key)) {
      throw ArgumentError(
          'A dependência com a chave "$key" já foi registrada.');
    }
    _dependencies[key] = dependency;
  }

  /// Registra uma rota com a chave correspondente
  void registerRoute(String route, Widget Function() pageBuilder) {
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

  /// Resolve uma rota registrada
  Widget Function()? resolveRoute(String route) {
    final pageBuilder = _routes[route];
    if (pageBuilder != null) {
      return pageBuilder;
    }
    debugPrint('Rota não encontrada: $route');
    return _routes['/']; // Retorna a rota padrão se não encontrada
  }

  /// Método para registrar uma rota padrão (caso o usuário não tenha definido)
  void registerDefaultRoute(Widget Function() pageBuilder) {
    if (_routes.containsKey('/')) {
      debugPrint('A rota padrão "/" já foi registrada e será sobrescrita.');
    }
    _routes['/'] = pageBuilder;
  }
}
// import 'package:flutter/material.dart';

// class NavInjector {
//   final Map<String, dynamic> _dependencies = {};
//   final Map<String, Widget Function()> _routes = {};

//   /// Registra uma dependência com a chave correspondente
//   void register(String key, dynamic dependency) {
//     _dependencies[key] = dependency;
//   }

//   /// Registra uma rota com a chave correspondente
//   void registerRoute(String route, Widget Function() pageBuilder) {
//     _routes[route] = pageBuilder;
//   }

//   /// Resolve uma dependência registrada
//   T resolve<T>(String key) {
//     final dependency = _dependencies[key];
//     if (dependency is T) {
//       return dependency;
//     }
//     throw ArgumentError(
//         'Dependência de tipo ${T.toString()} não encontrada para a chave $key');
//   }

//   /// Resolve uma rota registrada
//   Widget Function()? resolveRoute(String route) {
//     final pageBuilder = _routes[route];
//     if (pageBuilder != null) {
//       return pageBuilder;
//     }
//     print('Rota não encontrada: $route');
//     return _routes['/']; // Página padrão ou de erro
//   }

//   /// Método para registrar uma rota padrão (caso o usuário não tenha definido)
//   void registerDefaultRoute(Widget Function() pageBuilder) {
//     _routes['/'] = pageBuilder;
//   }
// }
