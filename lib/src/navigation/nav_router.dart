// lib/nav_router.dart
import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart'; // Importe NavInjector, NavRouteInformationParser

class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  // ✅ Recebido no construtor, não criado aqui
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  // ✅ Instância do NavInjector recebida no construtor
  final NavInjector _injector;

  // Lista de páginas que representa a pilha de navegação
  late List<Page> _pages;

  // ❌ Removido: static NavRouter? _instance;
  // ❌ Removido: static NavRouter get instance {...}
  // ❌ Removido: static Future<void> navigateTo(String route) async {...}

  // ✅ Construtor: Recebe o NavInjector e a GlobalKey
  NavRouter(this._injector, this.navigatorKey) {
    _pages = [];
    // ❌ Removido: _initializeRoutes(); (A rota inicial será definida pelo NavManager ou setNewRoutePath)
    // ❌ Removido: WidgetsBinding.instance.addPostFrameCallback((_) {...});
    // ❌ Removido: _instance = this;
  }

  // ❌ Removido: List<Page> get pages => List.of(_pages); (Expor a lista diretamente não é ideal)

  @override
  Widget build(BuildContext context) {
    // ✅ O Navigator usa a GlobalKey recebida
    return Navigator(
      key: navigatorKey,
      // ✅ Use uma cópia imutável para evitar modificações externas acidentais
      pages: List.unmodifiable(_pages),
      // ✅ Implemente a lógica para lidar com o pop via gesto ou back button
      onPopPage: _handlePopPage,
      // ❌ Removido: onDidRemovePage (onPopPage é o handler correto para pops)
    );
  }

  // ✅ Handler para pops (gesto de voltar, back button)
  bool _handlePopPage(Route<dynamic> route, result) {
    // Verifica se a rota realmente foi "poppada" (ex: gesto concluído)
    if (!route.didPop(result)) {
      return false;
    }
    // Remove a página do topo da pilha se não for a última
    if (_pages.length > 1) {
      _pages.removeLast();
      notifyListeners(); // Notifica os listeners (o Router) que a configuração mudou
      _printPages(); // Para debug
      return true; // Indica que o pop foi tratado
    }
    // Se for a última página, não permite o pop via gesto/back button padrão do Navigator
    // (a menos que você queira fechar o app, o que geralmente é tratado em outro lugar,
    // como no WillPopScope do Scaffold da página inicial, se necessário)
    debugPrint('⚠️ NavRouter: Cannot pop the last page via Navigator handler.');
    return false; // Indica que o pop não foi tratado por este handler
  }

  // ✅ Método para 'push' (renomeado de 'to' e simplificado)
  // Será chamado pelo NavManagerService
  Future<void> push(String routeName) async {
    debugPrint('➡️ NavRouter: Attempting to push route: $routeName');
    // ✅ Usa o injector recebido para resolver a rota
    final pageBuilder = _injector.resolveRoute(routeName);

    if (pageBuilder != null) {
      // Adiciona a nova página ao topo da pilha
      _pages.add(MaterialPage(
        key: ValueKey(routeName), // Use ValueKey com o nome da rota para identificação
        child: pageBuilder(),
      ));
      notifyListeners(); // Notifica os listeners
      _printPages(); // Para debug
    } else {
      debugPrint('❌ NavRouter: Route not found for push: $routeName');
      // Lógica para rota não encontrada - pode redirecionar para a página de escape
      final escapePageBuilder =
          _injector.resolveRoute('escape'); // Assumindo que 'escape' é a rota da página de erro
      if (escapePageBuilder != null) {
        _pages.add(MaterialPage(
          key: const ValueKey('escape'), // Use uma chave consistente para a página de escape
          child: escapePageBuilder(),
        ));
        notifyListeners();
        _printPages(); // Para debug
      } else {
        debugPrint('❌ NavRouter: Escape route "escape" not found either.');
        // Opcional: Adicionar uma página de erro fallback simples se 'escape' não estiver registrado
        _pages.add(MaterialPage(
          key: const ValueKey('fallback_error'),
          child: Scaffold(
              appBar: AppBar(title: const Text('Navigation Error')),
              body: const Center(child: Text('Could not navigate to route or escape page.'))),
        ));
        notifyListeners();
        _printPages(); // Para debug
      }
    }
  }

  // ✅ Método para 'replace' (adicionado para substituir a página atual)
  // Será chamado pelo NavManagerService
  Future<void> replace(String routeName) async {
    debugPrint('🔄 NavRouter: Attempting to replace route with: $routeName');
    final pageBuilder = _injector.resolveRoute(routeName);

    if (pageBuilder != null) {
      // Remove a página atual se houver
      if (_pages.isNotEmpty) {
        _pages.removeLast();
      }
      // Adiciona a nova página
      _pages.add(MaterialPage(
        key: ValueKey(routeName),
        child: pageBuilder(),
      ));
      notifyListeners();
      _printPages(); // Para debug
    } else {
      debugPrint('❌ NavRouter: Route not found for replace: $routeName');
      // Lógica para rota não encontrada - pode redirecionar para a página de escape
      final escapePageBuilder = _injector.resolveRoute('escape');
      if (escapePageBuilder != null) {
        if (_pages.isNotEmpty) {
          _pages.removeLast(); // Remove a página atual antes de adicionar a de escape
        }
        _pages.add(MaterialPage(
          key: const ValueKey('escape'),
          child: escapePageBuilder(),
        ));
        notifyListeners();
        _printPages(); // Para debug
      } else {
        debugPrint('❌ NavRouter: Escape route "escape" not found either.');
        // Fallback para uma página de erro simples
        if (_pages.isNotEmpty) {
          _pages.removeLast();
        }
        _pages.add(MaterialPage(
          key: const ValueKey('fallback_error'),
          child: Scaffold(
              appBar: AppBar(title: const Text('Navigation Error')),
              body: const Center(child: Text('Could not replace route or find escape page.'))),
        ));
        notifyListeners();
        _printPages(); // Para debug
      }
    }
  }

  // ✅ Método para 'pop' (adicionado para remover a página do topo explicitamente)
  // Será chamado pelo NavManagerService
  void pop() {
    debugPrint('⬅️ NavRouter: Attempting to pop route.');
    if (_pages.length > 1) {
      // Garante que não remove a última página
      _pages.removeLast();
      notifyListeners();
      _printPages(); // Para debug
    } else {
      debugPrint('⚠️ NavRouter: Cannot pop the last page explicitly.');
      // Opcional: Chamar SystemNavigator.pop() para fechar o app se for a última página
      // SystemNavigator.pop();
    }
  }

  // ✅ Método para 'popUntil' (adicionado para remover rotas até uma específica)
  // Será chamado pelo NavManagerService
  void popUntil(String routeName) {
    debugPrint('⬆️ NavRouter: Attempting to pop until route: $routeName');
    // Encontra o índice da página de destino na pilha
    final existingPageIndex =
        _pages.indexWhere((page) => (page.key as ValueKey).value == routeName);

    if (existingPageIndex != -1) {
      // Mantém apenas as páginas até a página de destino (inclusive)
      _pages = _pages.sublist(0, existingPageIndex + 1);
      notifyListeners();
      _printPages(); // Para debug
    } else {
      debugPrint('⚠️ NavRouter: Route "$routeName" not found in stack for popUntil.');
      // Opcional: Lidar com a rota não encontrada na pilha (ex: erro, ou pop até a raiz '/')
      // popUntilNamed('/'); // Exemplo: pop até a raiz se a rota não for encontrada
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    // Este método é chamado pelo Router quando a configuração da rota muda externamente
    // (ex: deep links, URL na web).
    final route = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    debugPrint('\n🔄 NavRouter: Setting new route path: $route');

    // Geralmente, ao definir um novo caminho de rota, limpamos a pilha existente
    // e navegamos para a nova rota.
    _pages.clear(); // Limpa a pilha existente

    // ✅ Usa o injector para resolver a nova rota
    final pageBuilder = _injector.resolveRoute(route);
    if (pageBuilder != null) {
      _pages.add(MaterialPage(
        key: ValueKey(route),
        child: pageBuilder(),
      ));
    } else {
      debugPrint('❌ NavRouter: Route "$route" not found in injector for deep link.');
      // Lidar com rota não encontrada (usar página de escape)
      final escapePageBuilder = _injector.resolveRoute('escape');
      if (escapePageBuilder != null) {
        _pages.add(MaterialPage(
          key: const ValueKey('escape'),
          child: escapePageBuilder(),
        ));
      } else {
        debugPrint('❌ NavRouter: Escape route "escape" not found either. Adding fallback.');
        // Fallback para uma página de erro simples se 'escape' não estiver registrado
        _pages.add(MaterialPage(
          key: const ValueKey('fallback_error'),
          child: Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Could not handle route.'))),
        ));
      }
    }

    notifyListeners(); // Notifica os listeners que a pilha de páginas mudou
    _printPages(); // Para debug
  }

  // ❌ Removido: _navigateToPage (Lógica incorporada em push/replace/setNewRoutePath)
  // ❌ Removido: _initializeRoutes (Inicialização feita pelo NavManager/setNewRoutePath)
  // ❌ Removido: _buildEscapePage (Página de escape deve ser registrada no Injector)
  // ❌ Removido: _injectRoutesFromModule (O Router não deve gerenciar todas as rotas disponíveis)
  // ❌ Removido: _recoverRoutes (O Router gerencia a pilha ATUAL, não todas as rotas registradas)

  void _printPages() {
    debugPrint('Current navigation stack:');
    if (_pages.isEmpty) {
      debugPrint(' - Stack is empty');
      return;
    }
    for (var page in _pages) {
      // ✅ Acessa o valor da ValueKey de forma segura
      final key = page.key;
      if (key is ValueKey) {
        debugPrint(' - ${key.value}');
      } else {
        debugPrint(' - Page with unknown key type: ${key.runtimeType}');
      }
    }
    debugPrint('---'); // Separador para clareza
  }

  @override
  RouteInformation? get currentConfiguration {
    // Informa a rota atual para o RouteInformationParser (útil para web, deep links)
    // Retorna a rota da página no topo da pilha
    if (_pages.isEmpty) {
      return null;
    }
    // ✅ Acessa o valor da ValueKey da página no topo
    final pageKey = _pages.last.key;
    if (pageKey is ValueKey<String>) {
      debugPrint('⬅️ NavRouter: Reporting current configuration: ${pageKey.value}');
      return RouteInformation(uri: Uri.parse(pageKey.value));
    }
    debugPrint(
        '⬅️ NavRouter: Cannot report current configuration for page with key type: ${pageKey.runtimeType}');
    return null; // Não pode determinar a rota se a chave não for ValueKey<String>
  }

  // ✅ Implemente dispose para limpar recursos se necessário
  @override
  void dispose() {
    debugPrint('🗑️ NavRouter: Disposing...');
    // Se o NavInjector ou outros objetos geridos pelo Router precisarem de dispose, chame aqui.
    // No seu caso, o NavManager (widget) provavelmente fará o dispose do Injector.
    super.dispose(); // Chama o dispose da mixin e ChangeNotifier
  }
}
