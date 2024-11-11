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
      _buildInitialPage('/'), // Rota padrão "/"
      _buildEscapePage(), // Rota de escape
    ];

    _injectRoutesFromModule(); // Injeta as novas rotas a partir do AppModule

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
      pages: List.of(_pages),
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        pop();
        return true;
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
    final key = route == '/'
        ? ValueKey(
            '$route-${DateTime.now().millisecondsSinceEpoch}') // Gera uma nova key para a rota inicial
        : ValueKey(route);

    _pages.add(MaterialPage(
      key: key,
      child: pageBuilder(),
    ));
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _pages = [
        MaterialPage(
          key: ValueKey(route),
          child: pageBuilder(),
        ),
      ];
      // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
        _printPages();
      });
    } else {
      print('Rota não encontrada: $route');
      _pages = [
        _buildEscapePage(), // Usa a página de escape quando a rota não é encontrada
      ];
      // Usa addPostFrameCallback para evitar chamada de notifyListeners no ciclo de construção
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Construir a rota inicial "/"
  MaterialPage _buildInitialPage(String route) {
    return MaterialPage(
      key: const ValueKey('/'),
      child: _injector.resolveRoute(route)?.call() ??
          const Scaffold(
              body: Center(child: Text('Página inicial não encontrada.'))),
    );
  }

  // Construir a página de escape
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

  // Injeta as novas rotas a partir do AppModule
  void _injectRoutesFromModule() {
    final routes = _injector.getRoutes();
    for (var route in routes) {
      _pages.add(MaterialPage(
        key: ValueKey(route),
        child: _injector.resolveRoute(route)?.call() ?? const SizedBox(),
      ));
    }
  }

  void _printPages() {
    print('Rotas atuais na pilha de navegação:');
    for (var page in _pages) {
      print((page.key as ValueKey).value);
    }
  }
}
