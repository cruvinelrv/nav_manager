import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late List<Page> _pages;

  NavRouter(this._injector) {
    _pages = [];

    _initializeRoutes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _printPages();
    });
  }

  @override
  List<Page> get pages => List.of(_pages);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onDidRemovePage: (route) {
        print('🗑️ Página removida');
        // Não remove a página da lista
      },
    );
  }

  Future<void> to(String route) async {
    _recoverRoutes(); // Recupera as rotas antes de navegar
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _navigateToPage(route);
      notifyListeners(); // Notifica imediatamente após navegar para a página
      _printPages();
    } else {
      print('Rota não encontrada: $route');
      _navigateToPage('escape');
      notifyListeners(); // Notifica imediatamente após navegar para a página de escape
    }
  }

  void _navigateToPage(String route) {
    // Verifica se a rota já está presente na lista de páginas
    final existingPageIndex =
        _pages.indexWhere((page) => (page.key as ValueKey).value == route);
    if (existingPageIndex != -1) {
      // Navega para a página existente
      _pages = _pages.sublist(0, existingPageIndex + 1);
    } else {
      // Adiciona uma nova página
      final pageBuilder = _injector.resolveRoute(route);
      if (pageBuilder != null) {
        _pages.add(MaterialPage(
          key: ValueKey(route), // Usa a rota como chave
          child: pageBuilder(),
        ));
      }
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    _recoverRoutes(); // Recupera as rotas antes de definir a nova rota
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    print('\n🔄 Definindo nova rota: $route');
    _navigateToPage(route);

    notifyListeners(); // Notifica imediatamente após definir a nova rota
    _printPages();
  }

  // Inicializa as rotas
  void _initializeRoutes() {
    final initialRoute = '/'; // Define a rota inicial
    final initialPageBuilder = _injector.resolveRoute(initialRoute);

    if (initialPageBuilder != null) {
      _pages.add(MaterialPage(
        key: ValueKey(initialRoute),
        child: initialPageBuilder(),
      ));
    } else {
      _pages.add(_buildEscapePage());
    }

    _injectRoutesFromModule(); // Injeta as novas rotas a partir do AppModule
  }

  // Construir a página de escape
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

  // Injeta as novas rotas a partir do AppModule
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

  // Recupera as rotas a partir do NavInjector
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
