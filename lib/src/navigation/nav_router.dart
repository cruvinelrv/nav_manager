import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;
  final Widget Function()?
      escapePageBuilder; // Callback para a página de escape customizável

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late List<Page> _pages;

  NavRouter(this._injector, {this.escapePageBuilder}) {
    // Inicializa com a EscapePage caso não tenha rota válida
    _pages = [
      _buildEscapePage(), // Página de escape por padrão
    ];

    _printPages();
  }

  @override
  List<Page> get pages => List.of(_pages);

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

  Future<void> to(String route) async {
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      _addPage(route, pageBuilder);
      notifyListeners();
      _printPages();
    } else {
      print('Rota não encontrada: $route');
      _addPage('escape', () => _buildEscapePage().child);
      notifyListeners();
    }
  }

  void pop() {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
      notifyListeners();
      _printPages();
    }
  }

  void _addPage(String route, Widget Function() pageBuilder) {
    _pages.add(MaterialPage(
      key: ValueKey(route),
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
      notifyListeners();
      _printPages();
    } else {
      print('Rota não encontrada: $route');
      _pages = [
        _buildEscapePage(), // Usa a página de escape quando a rota não é encontrada
      ];
      notifyListeners();
    }
  }

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

  void _printPages() {
    print('Rotas atuais na pilha de navegação:');
    for (var page in _pages) {
      print((page.key as ValueKey).value);
    }
  }
}
