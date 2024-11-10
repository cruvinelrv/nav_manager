import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late List<Page> _pages;

  NavRouter(this._injector) {
    final initialPageBuilder = _injector.resolveRoute('/');
    if (initialPageBuilder != null) {
      _pages = [
        MaterialPage(
          key: ValueKey(DateTime.now()
              .millisecondsSinceEpoch
              .toString()), // Chave única gerada dinamicamente
          child: initialPageBuilder(),
        ),
      ];
    } else {
      _pages = [];
    }
    _printPages();
  }

  // Método para adicionar uma nova página à pilha.
  Future<void> to(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _addPage(route, pageBuilder);
      notifyListeners(); // Notifica a mudança no estado da navegação
      _printPages(); // Adiciona o print para verificar as rotas após adicionar uma nova página
    } else {
      print('Rota não encontrada: $route');
    }
  }

  // Método para adicionar uma nova página à pilha.
  Future<void> navigateTo(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _addPage(route, pageBuilder);
      notifyListeners(); // Notifica a mudança no estado da navegação
      _printPages(); // Adiciona o print para verificar as rotas após adicionar uma nova página
    } else {
      print('Rota não encontrada: $route');
    }
  }

  // Método que retorna a pilha de páginas para o Navigator 2.0.
  @override
  List<Page> get pages => List.of(_pages);

  // Define a navegação e trata a remoção de páginas (quando o botão de voltar for pressionado).
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      onDidRemovePage: (result) {
        pop();
      },
    );
  }

  // Substitui a página atual com uma nova.
  Future<void> replace(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      final newPage = MaterialPage(
        key: ValueKey(route),
        child: pageBuilder(),
      );

      if (_pages.isNotEmpty) {
        _pages.removeLast(); // Remove the current page
        _pages.add(newPage); // Add the new page
      } else {
        _pages.add(newPage); // Add the new page if no current page
      }

      notifyListeners(); // Notifica que a navegação foi substituída
      _printPages(); // Adiciona o print para verificar as rotas após substituir uma página
    } else {
      print('Rota não encontrada: $route');
    }
  }

  // Pop a página da pilha de navegação.
  void pop() {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
      notifyListeners(); // Notifica que uma página foi removida
      _printPages(); // Adiciona o print para verificar as rotas após remover uma página
    }
  }

  // Adiciona uma página à pilha de navegação.
  void _addPage(String route, Widget Function() pageBuilder) {
    _pages.add(MaterialPage(
      key: ValueKey(route),
      child: pageBuilder(),
    ));
  }

  // Configura uma nova rota com base nas informações passadas pela URL.
  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    // Usando o URI para acessar o caminho da rota.
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;

    // Aqui, usamos o route para pegar a página associada a ele
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _pages = [
        MaterialPage(
          key: ValueKey(route),
          child: pageBuilder(),
        ),
      ];
      notifyListeners();
      _printPages(); // Adiciona o print para verificar as rotas após configurar uma nova rota
    } else {
      print('Rota não encontrada: $route');
    }
  }

  // Método para imprimir as rotas atuais na lista de páginas
  void _printPages() {
    print('Rotas atuais na pilha de navegação:');
    for (var page in _pages) {
      print((page.key as ValueKey).value);
    }
  }
}
