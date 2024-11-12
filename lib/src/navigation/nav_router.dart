import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late List<Page> _pages;
  int _pageKeyCounter = 0; // Contador para gerar chaves únicas

  NavRouter(this._injector) {
    _pages = [];

    _initializeRoutes(); // Inicializa as rotas

    // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
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
      onDidRemovePage: (result) {
        print('🗑️ Página removida');
        popRoute();
      },
    );
  }

  Future<void> to(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _addPage(route, pageBuilder);
      // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
        _printPages();
      });
    } else {
      print('Rota não encontrada: $route');
      _addPage('escape', () => _buildEscapePage().child);
      // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void pop() {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
      // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
        _printPages();
      });
    }
  }

  void _addPage(String route, Widget Function() pageBuilder) {
    _pages.add(MaterialPage(
      key: ValueKey(
          '$route-${_pageKeyCounter++}'), // Gera uma chave única para cada página
      child: pageBuilder(),
    ));
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    print('\n🔄 Definindo nova rota: $route');
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      print('✅ Rota encontrada, adicionando página');
      _addPage(route, pageBuilder);
    } else {
      print('❌ Rota não encontrada, adicionando página de escape');
      _addEscapePage();
    }

    print('🔔 Notificando listeners');
    notifyListeners();
  }

  // Inicializa as rotas
  void _initializeRoutes() {
    final initialRoute = '/'; // Define a rota inicial
    final initialPageBuilder = _injector.resolveRoute(initialRoute);

    if (initialPageBuilder != null) {
      _pages.add(MaterialPage(
        key: ValueKey('$initialRoute-${_pageKeyCounter++}'),
        child: initialPageBuilder(),
      ));
    } else {
      _addEscapePage();
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

  void _addEscapePage() {
    _pages.add(_buildEscapePage());
  }

  // Injeta as novas rotas a partir do AppModule
  void _injectRoutesFromModule() {
    final routes = _injector.getRoutes();
    for (var route in routes) {
      if (route != '/') {
        _addPage(route, _injector.resolveRoute(route)!);
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
