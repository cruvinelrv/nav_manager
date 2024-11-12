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
    print('\n🚀 Iniciando NavRouter');
    _initializeRoutes();
  }

  @override
  List<Page> get pages => List.unmodifiable(_pages);

  ValueKey _getKeyForRoute(String route) {
    final key = _routeKeys.putIfAbsent(route, () => ValueKey(route));
    print('🔑 Chave gerada para rota "$route": $key');
    return key;
  }

  @override
  Widget build(BuildContext context) {
    print('\n🏗️ Construindo Navigator');
    print('📄 Páginas atuais: ${_pages.map((p) => p.name).toList()}');
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onDidRemovePage: (result) {
        print('🗑️ Página removida');
        popRoute();
      },
    );
  }

  void _initializeRoutes() {
    print('\n🔄 Inicializando rotas');
    final routes = _injector.getRoutes();
    print('📋 Rotas disponíveis: $routes');
    _pages.clear();

    for (var route in routes) {
      final pageBuilder = _injector.resolveRoute(route);
      if (pageBuilder != null) {
        print('✅ Rota encontrada: $route');
        _addPage(route, pageBuilder);
      } else {
        print('❌ Rota não resolvida: $route');
      }
    }

    if (_pages.isEmpty) {
      print('⚠️ Nenhuma página encontrada, adicionando página de escape');
      _addEscapePage();
    }

    print('📚 Total de páginas após inicialização: ${_pages.length}');
  }

  void _addPage(String route, Widget Function(NavInjector) pageBuilder) {
    print('\n➕ Tentando adicionar página: $route');
    final pageKey = _getKeyForRoute(route);

    if (!_pages.any((page) => page.key == pageKey)) {
      _pages.add(
        MaterialPage(
          key: pageKey,
          name: route,
          child: pageBuilder(_injector),
        ),
      );
      print('✅ Página adicionada com sucesso: $route');
    } else {
      print('⚠️ Página já existe: $route');
    }
    print('📚 Total de páginas atual: ${_pages.length}');
  }

  void _addEscapePage() {
    print('\n🚨 Adicionando página de escape');
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
    print('✅ Página de escape adicionada');
  }

  Future<void> to(String route) async {
    print('\n🔄 Navegando para: $route');
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      print('✅ Rota encontrada, adicionando página');
      _addPage(route, pageBuilder);
      notifyListeners();
    } else {
      print('❌ Rota não encontrada, redirecionando para página de escape');
      _addEscapePage();
      notifyListeners();
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    // final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    // print('\n🔄 Definindo nova rota: $route');
    // final pageBuilder = _injector.resolveRoute(route);

    // print('🗑️ Limpando páginas existentes');
    // _pages.clear();

    // if (pageBuilder != null) {
    //   print('✅ Rota encontrada, adicionando página');
    //   _addPage(route, pageBuilder);
    // } else {
    //   print('❌ Rota não encontrada, adicionando página de escape');
    //   _addEscapePage();
    // }

    // print('🔔 Notificando listeners');
    // notifyListeners();
  }

  @override
  Future<bool> popRoute() async {
    if (_pages.length > 1) {
      print('\n⬅️ Removendo última página');
      final removedPage = _pages.removeLast();
      print('✅ Página removida: ${removedPage.name}');
      print('📚 Total de páginas restantes: ${_pages.length}');
      notifyListeners();
      return true;
    }
    print('\n⚠️ Não é possível remover a última página');
    return false;
  }
}
