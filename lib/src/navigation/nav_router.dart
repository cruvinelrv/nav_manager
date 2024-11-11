import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;
  final Widget Function()? escapePageBuilder;
  List<Page> _pages = [];

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavRouter(this._injector, {this.escapePageBuilder}) {
    _initializeRoutes();
  }

  @override
  List<Page> get pages {
    // Log para mostrar as chaves das páginas
    for (var page in _pages) {
      print('Página: ${page.key}');
    }
    return List.of(_pages);
  }

  @override
  Widget build(BuildContext context) {
    // Log para mostrar a chave do Navigator
    print('Chave do Navigator: ${navigatorKey}');
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onDidRemovePage: (result) {
        popRoute();
      },
    );
  }

  void _initializeRoutes() {
    final routes = _injector.getRoutes();
    for (var route in routes) {
      final pageBuilder = _injector.resolveRoute(route);
      if (pageBuilder != null) {
        _addPage(route, pageBuilder);
      }
    }

    if (_pages.isEmpty) {
      _addEscapePage();
    }
  }

  void _addPage(String route, Widget Function(NavInjector) pageBuilder) {
    final pageKey = ValueKey('$route-${DateTime.now().millisecondsSinceEpoch}');
    if (!_pages.any((page) => page.key == pageKey)) {
      _pages.add(MaterialPage(
        key: pageKey,
        child: pageBuilder(_injector),
      ));
      // Log para mostrar a chave da página adicionada
      print('Página adicionada: ${pageKey}');
    }
  }

  void _addEscapePage() {
    _pages.add(MaterialPage(
      key: const ValueKey('escape'),
      child: escapePageBuilder != null
          ? escapePageBuilder!()
          : Scaffold(
              appBar: AppBar(title: const Text('Página não encontrada')),
              body: const Center(
                  child: Text('A rota solicitada não foi encontrada.')),
            ),
    ));
    print('Página de escape adicionada com chave: escape');
  }

  Future<void> to(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      if (!_pages.any((page) => page.key == ValueKey(route))) {
        _addPage(route, pageBuilder);
      }
    } else {
      print('Rota não encontrada: $route');
      _addEscapePage();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
      print('Nova rota definida: $route com chave ${ValueKey(route)}');
    } else {
      _addEscapePage();
      _pages = List.of(_pages);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
