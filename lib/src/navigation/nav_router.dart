import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;
  final Widget Function()? escapePageBuilder;
  final List<Page> _pages = [];
  final Map<String, ValueKey> _routeKeys = {};

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavRouter(this._injector, {this.escapePageBuilder}) {
    _initializeRoutes();
  }

  @override
  List<Page> get pages => List.unmodifiable(_pages);

  ValueKey _getKeyForRoute(String route) {
    return _routeKeys.putIfAbsent(route, () => ValueKey(route));
  }

  @override
  Widget build(BuildContext context) {
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
    _pages.clear();

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
    final pageKey = _getKeyForRoute(route);

    if (!_pages.any((page) => page.key == pageKey)) {
      _pages.add(
        MaterialPage(
          key: pageKey,
          name: route,
          child: pageBuilder(_injector),
        ),
      );
    }
  }

  void _addEscapePage() {
    final pageKey = _getKeyForRoute('escape');
    _pages.add(
      MaterialPage(
        key: pageKey,
        name: 'escape',
        child: escapePageBuilder?.call() ??
            Scaffold(
              appBar: AppBar(title: const Text('Página não encontrada')),
              body: const Center(
                child: Text('A rota solicitada não foi encontrada.'),
              ),
            ),
      ),
    );
  }

  Future<void> to(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _addPage(route, pageBuilder);
      notifyListeners();
    } else {
      _addEscapePage();
      notifyListeners();
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    final pageBuilder = _injector.resolveRoute(route);

    _pages.clear();

    if (pageBuilder != null) {
      _addPage(route, pageBuilder);
    } else {
      _addEscapePage();
    }

    notifyListeners();
  }

  @override
  Future<bool> popRoute() async {
    if (_pages.length > 1) {
      _pages.removeLast();
      notifyListeners();
      return true;
    }
    return false;
  }
}
