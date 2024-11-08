import 'package:flutter/material.dart';
import 'package:nav_manager/src/navigation/nav_injector.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Lista de páginas atuais na pilha de navegação.
  List<Page> _pages = [];

  NavRouter(this._injector);

  // Método para adicionar uma nova página à pilha.
  Future<void> to(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _addPage(pageBuilder);
      notifyListeners(); // Notifica a mudança no estado da navegação
    } else {
      print('Rota não encontrada: $route');
    }
  }

  // Substitui a página atual com uma nova.
  Future<void> replace(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _pages = [
        MaterialPage(
          key: ValueKey(route),
          child: pageBuilder(),
        ),
      ];
      notifyListeners(); // Notifica que a navegação foi substituída
    } else {
      print('Rota não encontrada: $route');
    }
  }

  // Pop a página da pilha de navegação.
  void pop() {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
      notifyListeners(); // Notifica que uma página foi removida
    }
  }

  // Adiciona uma página à pilha de navegação.
  void _addPage(Widget Function() pageBuilder) {
    _pages.add(MaterialPage(
      key: ValueKey(pageBuilder),
      child: pageBuilder(),
    ));
  }

  // Configura uma nova rota com base nas informações passadas pela URL.
  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    // Aqui podemos processar as informações da URL, caso necessário.
    // Para simplificação, podemos usar uma única página de exemplo.
  }

  // Método que retorna a pilha de páginas para o Navigator 2.0.
  List<Page> get pages {
    if (_pages.isEmpty) {
      print(
          'A pilha de navegação está vazia. Certifique-se de que uma página inicial foi configurada.');
    }
    return _pages;
  }

  // Define a navegação e trata a remoção de páginas (quando o botão de voltar for pressionado).
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onDidRemovePage: (route) {
        pop(); // Remove a página quando ela é removida
      },
    );
  }
}
