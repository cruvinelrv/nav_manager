import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  final NavInjector _injector;
  final Widget Function()? escapePageBuilder;
  final List<Page> _pages =
      []; // Aqui vamos garantir que as páginas sejam dinâmicas.

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavRouter(this._injector, {this.escapePageBuilder}) {
    // As rotas serão registradas fora do construtor do NavRouter.
    _initializeRoutes();
  }

  @override
  List<Page> get pages => List.of(_pages);

  @override
  Widget build(BuildContext context) {
    debugPrint('NavRouter build chamado');
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      onDidRemovePage: (result) {
        debugPrint('onDidRemovePage chamado');
        popRoute();
      },
    );
  }

  // Inicializar as rotas
  void _initializeRoutes() {
    // Adicionar a página inicial na pilha
    _pages.add(_buildInitialPage('/')); // Rota padrão "/"

    // Adicionar a EscapePage como última página, caso necessário.
    _pages.add(_buildEscapePage());
  }

  // Método para navegar para a rota
  Future<void> to(String route) async {
    debugPrint('Tentando navegar para a rota: $route');
    final pageBuilder = _injector.resolveRoute(route);

    if (pageBuilder != null) {
      // Verifica se a rota já existe na pilha
      if (!_pages.any((page) => page.key == ValueKey(route))) {
        _addPage(route, pageBuilder);
        debugPrint('Rota $route adicionada à pilha');
      } else {
        debugPrint('Rota $route já está na pilha');
      }
    } else {
      debugPrint('Rota não encontrada: $route');
      _pages.add(_buildEscapePage());
    }

    // Notifica ouvintes após a alteração da pilha
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Adiciona uma nova página à pilha
  void _addPage(String route, Widget Function(NavInjector) pageBuilder) {
    _pages.add(MaterialPage(
      key: ValueKey(route),
      child: pageBuilder(_injector),
    ));
  }

  // Página inicial
  MaterialPage _buildInitialPage(String route) {
    debugPrint('Construindo a página inicial para a rota: $route');
    return MaterialPage(
      key: ValueKey('$route-${DateTime.now().millisecondsSinceEpoch}'),
      child: _injector.resolveRoute(route)?.call(_injector) ??
          const SizedBox.shrink(),
    );
  }

  // Página de erro/escape para rotas não encontradas
  MaterialPage _buildEscapePage() {
    debugPrint('Construindo a EscapePage');
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

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) {
    throw UnimplementedError();
  }

  // @override
  // Future<void> setNewRoutePath(RouteInformation configuration) async {
  //   final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
  //   debugPrint('setNewRoutePath chamado para a rota: $route');
  //   final pageBuilder = _injector.resolveRoute(route);

  //   if (pageBuilder != null) {
  //     _pages = [
  //       MaterialPage(
  //         key: ValueKey(route),
  //         child: pageBuilder(_injector),
  //       ),
  //     ];
  //     debugPrint('Rota $route carregada com sucesso');
  //   } else {
  //     _pages = [_buildEscapePage()];
  //     debugPrint('Rota $route não encontrada. Redirecionando para a EscapePage');
  //   }

  //   // Notifica ouvintes após a alteração da pilha
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     notifyListeners();
  //   });
  // }
}
