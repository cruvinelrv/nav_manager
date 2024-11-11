import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;
  final Widget Function()? escapePageBuilder;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late List<Page> _pages;

  NavRouter(this._injector, {this.escapePageBuilder}) {
    _pages = [
      _buildEscapePage(),
    ];
  }

  @override
  List<Page> get pages => List.of(_pages);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      onDidRemovePage: (result) {
        popRoute();
      },
    );
  }

  // Método para navegar para a rota
  Future<void> to(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      // Verifica se a rota já existe na pilha
      if (!_pages.any((page) => page.key == ValueKey(route))) {
        _addPage(route, pageBuilder);
      }
    } else {
      print('Rota não encontrada: $route');
      _pages.add(_buildEscapePage());
    }

    // Notifica ouvintes após a alteração da pilha
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Adiciona uma nova página à pilha
  void _addPage(String route, Widget Function(NavInjector) pageBuilder) {
    _pages.add(MaterialPage(
      key: ValueKey(route),
      child: pageBuilder(_injector),
    ));
  }

  // Página de erro/escape para rotas não encontradas
  MaterialPage _buildEscapePage() {
    return MaterialPage(
      key: const ValueKey('escape'),
      child: escapePageBuilder != null
          ? escapePageBuilder!()
          : Scaffold(
              appBar: AppBar(title: const Text('Página não encontrada')),
              body: const Center(
                  child: Text('A rota solicitada não foi encontrada.')),
            ),
    );
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _pages = [
        MaterialPage(
          key: ValueKey(route),
          child: pageBuilder(_injector),
        ),
      ];
    } else {
      _pages = [_buildEscapePage()];
    }

    // Notifica ouvintes após a alteração da pilha
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}


// import 'package:flutter/material.dart';
// import 'package:nav_manager/src/navigation/nav_injector.dart';

// class NavRouter extends RouterDelegate<RouteInformation>
//     with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
//   final NavInjector injector;
//   final List<Page> _pages = [];
//   final Widget Function()? escapePageBuilder;

//   NavRouter(this.injector, this.escapePageBuilder);

//   // Configura as rotas com base no NavInjector
//   void configureRoutes() {
//     _pages.clear();

//     // Adiciona todas as rotas registradas no NavInjector
//     for (var route in injector.getRoutes()) {
//       _pages.add(MaterialPage(
//         key: ValueKey(route),
//         child: injector.resolveRoute(route)!(),
//       ));
//     }
//   }

//   // Método de navegação para mover entre páginas
//   Future<void> to(String route) async {
//     final pageBuilder = injector.resolveRoute(route);
//     if (pageBuilder != null) {
//       _pages.add(MaterialPage(
//         key: ValueKey(route),
//         child: pageBuilder(),
//       ));
//     } else {
//       debugPrint('Rota não encontrada para: $route');
//     }

//     // Usando addPostFrameCallback para evitar modificações durante o ciclo de construção
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });
//   }

//   // Obter as páginas atuais
//   List<Page> get pages => List.unmodifiable(_pages);

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }

//   @override
//   // TODO: implement navigatorKey
//   GlobalKey<NavigatorState>? get navigatorKey => throw UnimplementedError();

//   @override
//   Future<void> setNewRoutePath(RouteInformation configuration) {
//     // TODO: implement setNewRoutePath
//     throw UnimplementedError();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:nav_manager/nav_manager.dart';

// class NavRouter extends RouterDelegate<RouteInformation>
//     with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
//   final NavInjector _injector;
//   final Widget Function()? escapePageBuilder;

//   @override
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//   late List<Page> _pages;

//   NavRouter(this._injector, {this.escapePageBuilder}) {
//     _pages = [
//       _buildInitialPage('/'), // Rota padrão "/"
//       _buildEscapePage(), // Rota de escape
//     ];

//     _injectRoutesFromModule(); // Injeta as novas rotas a partir do AppModule

//     // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _printPages();
//     });
//   }

//   @override
//   List<Page> get pages => List.of(_pages);

//   @override
//   Widget build(BuildContext context) {
//     return Navigator(
//       key: navigatorKey,
//       pages: List.of(_pages),
//       onPopPage: (route, result) {
//         if (!route.didPop(result)) {
//           return false;
//         }
//         pop();
//         return true;
//       },
//     );
//   }

//   Future<void> to(String route) async {
//     final pageBuilder = _injector.resolveRoute(route);

//     if (pageBuilder != null) {
//       // Verifica se a rota já existe na pilha de páginas
//       if (!_pages.any((page) => page.key == ValueKey(route))) {
//         _addPage(route, pageBuilder);

//         // Usando addPostFrameCallback para garantir que as mudanças de estado ocorram após a construção
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           notifyListeners();
//         });
//       }
//     } else {
//       print('Rota não encontrada: $route');
//       _addPage('escape', () => _buildEscapePage().child);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         notifyListeners();
//       });
//     }
//   }

//   void pop() {
//     if (_pages.isNotEmpty) {
//       _pages.removeLast();
//       // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         notifyListeners();
//         _printPages();
//       });
//     }
//   }

//   void _addPage(String route, Widget Function() pageBuilder) {
//     _pages.add(MaterialPage(
//       key: ValueKey(route),
//       child: pageBuilder(),
//     ));
//   }

//   @override
//   Future<void> setNewRoutePath(RouteInformation configuration) async {
//     final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
//     final pageBuilder = _injector.resolveRoute(route);

//     if (pageBuilder != null) {
//       _pages = [
//         MaterialPage(
//           key: ValueKey(route),
//           child: pageBuilder(),
//         ),
//       ];
//       // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         notifyListeners();
//         _printPages();
//       });
//     } else {
//       print('Rota não encontrada: $route');
//       _pages = [
//         _buildEscapePage(), // Usa a página de escape quando a rota não é encontrada
//       ];
//       // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         notifyListeners();
//       });
//     }
//   }

//   // Construir a rota inicial "/"
//   MaterialPage _buildInitialPage(String route) {
//     return MaterialPage(
//       key: ValueKey(
//           '$route-${DateTime.now().millisecondsSinceEpoch}'), // Key única para evitar conflitos
//       child: _injector.resolveRoute(route)?.call() ??
//           const SizedBox
//               .shrink(), // Garante que o widget está vindo do AppModule
//     );
//   }

//   // Construir a página de escape
//   MaterialPage _buildEscapePage() {
//     return MaterialPage(
//       key: const ValueKey('escape'),
//       child: escapePageBuilder != null
//           ? escapePageBuilder!()
//           : Scaffold(
//               appBar: AppBar(title: const Text('Página não encontrada')),
//               body: const Center(
//                   child: Text('A rota solicitada não foi encontrada.')),
//             ),
//     );
//   }

//   // Injeta as novas rotas a partir do AppModule
//   void _injectRoutesFromModule() {
//     final routes = _injector.getRoutes();
//     for (var route in routes) {
//       _pages.add(MaterialPage(
//         key: ValueKey(route),
//         child: _injector.resolveRoute(route)?.call() ?? const SizedBox(),
//       ));
//     }
//   }

//   void _printPages() {
//     print('Rotas atuais na pilha de navegação:');
//     for (var page in _pages) {
//       print((page.key as ValueKey).value);
//     }
//   }
// }
