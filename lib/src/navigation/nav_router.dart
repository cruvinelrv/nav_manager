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
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _navigateToPage(route, pageBuilder);
      notifyListeners(); // Notifica imediatamente após adicionar a página
      _printPages();
    } else {
      print('Rota não encontrada: $route');
      _navigateToPage('escape', () => _buildEscapePage().child);
      notifyListeners(); // Notifica imediatamente após adicionar a página de escape
    }
  }

  void _navigateToPage(String route, Widget Function() pageBuilder) {
    // Verifica se a rota já está presente na lista de páginas
    final existingPageIndex =
        _pages.indexWhere((page) => (page.key as ValueKey).value == route);
    if (existingPageIndex != -1) {
      // Navega para a página existente
      _pages = _pages.sublist(0, existingPageIndex + 1);
    } else {
      // Adiciona uma nova página
      _pages.add(MaterialPage(
        key: ValueKey(route), // Usa a rota como chave
        child: pageBuilder(),
      ));
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    print('\n🔄 Definindo nova rota: $route');
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      print('✅ Rota encontrada, adicionando página');
      _navigateToPage(route, pageBuilder);
    } else {
      print('❌ Rota não encontrada, adicionando página de escape');
      _navigateToPage('escape', () => _buildEscapePage().child);
    }

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
      _navigateToPage('escape', () => _buildEscapePage().child);
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
    for (var route in routes) {
      if (route != '/') {
        final pageBuilder = _injector.resolveRoute(route);
        if (pageBuilder != null) {
          _navigateToPage(route, pageBuilder);
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
