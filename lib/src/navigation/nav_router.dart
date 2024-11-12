import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late List<Page> _pages;

  static NavRouter? _instance;

  NavRouter(this._injector) {
    _pages = [];
    _initializeRoutes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _printPages();
    });
    _instance = this;
  }

  static NavRouter get instance {
    if (_instance == null) {
      throw Exception('NavRouter has not been initialized.');
    }
    return _instance!;
  }

  static Future<void> navigateTo(String route) async {
    await instance.to(route);
  }

  @override
  List<Page> get pages => List.of(_pages);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onDidRemovePage: (route) {},
    );
  }

  Future<void> to(String route) async {
    _recoverRoutes();
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _navigateToPage(route);
      notifyListeners();
      _printPages();
    } else {
      print('Rota não encontrada: $route');
      _navigateToPage('escape');
      notifyListeners();
    }
  }

  void _navigateToPage(String route) {
    final existingPageIndex =
        _pages.indexWhere((page) => (page.key as ValueKey).value == route);
    if (existingPageIndex != -1) {
      _pages = _pages.sublist(0, existingPageIndex + 1);
    } else {
      final pageBuilder = _injector.resolveRoute(route);
      if (pageBuilder != null) {
        _pages.add(MaterialPage(
          key: ValueKey(route),
          child: pageBuilder(),
        ));
      }
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    _recoverRoutes();
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    print('\n🔄 Definindo nova rota: $route');
    _navigateToPage(route);

    notifyListeners();
    _printPages();
  }

  void _initializeRoutes() {
    final initialRoute = '/';
    final initialPageBuilder = _injector.resolveRoute(initialRoute);

    if (initialPageBuilder != null) {
      _pages.add(MaterialPage(
        key: ValueKey(initialRoute),
        child: initialPageBuilder(),
      ));
    } else {
      _pages.add(_buildEscapePage());
    }

    _injectRoutesFromModule();
  }

  MaterialPage _buildEscapePage() {
    return MaterialPage(
      key: const ValueKey('escape'),
      child: Scaffold(
        appBar: AppBar(title: const Text('Página não encontrada')),
        body:
            const Center(child: Text('A rota solicitada não foi encontrada.')),
      ),
    );
  }

  void _injectRoutesFromModule() {
    final routes = _injector.getRoutes();
    print('📋 Rotas obtidas do NavInjector:');
    for (var route in routes) {
      print('🔄 Processando rota: $route');
      if (route != '/') {
        final pageBuilder = _injector.resolveRoute(route);
        if (pageBuilder != null) {
          print('✅ Injetando rota: $route');
          _pages.add(MaterialPage(
            key: ValueKey(route),
            child: pageBuilder(),
          ));
        }
      }
    }
  }

  void _recoverRoutes() {
    final routes = _injector.getRoutes();
    print('📋 Recuperando rotas do NavInjector:');
    for (var route in routes) {
      print('🔄 Rota: $route');
      if (route != '/' &&
          !_pages.any((page) => (page.key as ValueKey).value == route)) {
        final pageBuilder = _injector.resolveRoute(route);
        if (pageBuilder != null) {
          print('✅ Injetando rota: $route');
          _pages.add(MaterialPage(
            key: ValueKey(route),
            child: pageBuilder(),
          ));
        }
      }
    }
  }

  void _printPages() {
    print('Rotas atuais na pilha de navegação:');
    for (var page in _pages) {
      print((page.key as ValueKey).value);
    }
  }

  @override
  RouteInformation? get currentConfiguration {
    if (_pages.isEmpty) {
      return null;
    }
    final route = _pages.last.key as ValueKey<String>;
    return RouteInformation(uri: Uri.parse(route.value));
  }
}
