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
    // Inicializar as rotas corretamente
    _initializeRoutes();
  }

  @override
  List<Page> get pages => List.of(_pages);

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

  // Inicializa as rotas com as páginas
  void _initializeRoutes() {
    // Registra as rotas e garante que a página inicial seja construída
    final routes = _injector.getRoutes(); // Obter todas as rotas registradas
    for (var route in routes) {
      final pageBuilder =
          _injector.resolveRoute(route); // Resolva a função para a rota
      if (pageBuilder != null) {
        _addPage(route, pageBuilder); // Adiciona a página à pilha
      }
    }

    // Se nenhuma rota foi adicionada (isso significa que não há rotas registradas), adiciona a EscapePage
    if (_pages.isEmpty) {
      _addEscapePage();
    }
  }

  void _addPage(String route, Widget Function(NavInjector) pageBuilder) {
    // Gerando uma chave dinâmica para a página
    final dynamicKey =
        ValueKey('$route-${DateTime.now().millisecondsSinceEpoch}');

    // Evita adicionar páginas duplicadas à pilha, com chave dinâmica
    if (!_pages.any((page) => page.key == dynamicKey)) {
      _pages.add(MaterialPage(
        key: dynamicKey, // Usando a chave dinâmica
        child: pageBuilder(_injector),
      ));
    } else {
      print("Página já existe na pilha: $route");
    }
  }

  // Página de Escape para quando a rota não for encontrada
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
      _addEscapePage();
    }

    // Notifica ouvintes após a alteração da pilha
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
    } else {
      _addEscapePage();
      _pages = List.of(_pages);
    }

    // Notifica ouvintes após a alteração da pilha
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
