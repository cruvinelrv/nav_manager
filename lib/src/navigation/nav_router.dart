// lib/nav_router.dart
import 'package:flutter/foundation.dart'; // Importe para kDebugMode
import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart'; // Importe NavInjector, NavRouteInformationParser

/// Implementa o RouterDelegate para gerenciar a pilha de navegação usando Pages.
class NavRouter extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  // ✅ Recebido no construtor, não criado aqui
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  // ✅ Instância do NavInjector recebida no construtor
  final NavInjector _injector;

  // Lista de páginas que representa a pilha de navegação
  final List<Page> _pages = []; // Inicializa a lista aqui

  /// Construtor: Recebe o NavInjector e a GlobalKey
  NavRouter(this._injector, this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    // ✅ O Navigator usa a GlobalKey recebida
    return Navigator(
      key: navigatorKey,
      // ✅ Use uma cópia imutável para evitar modificações externas acidentais
      pages: List.unmodifiable(_pages),
      // ✅ Implemente a lógica para lidar com o pop via gesto ou back button
      onPopPage: _handlePopPage,
    );
  }

  /// Handler para pops (gesto de voltar, back button)
  bool _handlePopPage(Route<dynamic> route, result) {
    debugPrint(
        '⬅️ NavRouter: _handlePopPage called for route: ${route.settings.name ?? route.settings.runtimeType}');

    // Verifica se a rota realmente foi "poppada" (ex: gesto concluído)
    if (!route.didPop(result)) {
      debugPrint(
          '⚠️ NavRouter: Pop was not successful for route: ${route.settings.name ?? route.settings.runtimeType}');
      return false; // Pop não foi concluído, não alteramos a lista
    }

    // Se o pop foi bem-sucedido, remove a última página da nossa lista _pages.
    // Assumimos que a rota que foi poppada pelo Navigator corresponde à última
    // página que adicionamos à nossa lista.
    if (_pages.isNotEmpty) {
      debugPrint('⬅️ NavRouter: Pop successful. Removing last page from stack.');
      _pages.removeLast();
      notifyListeners(); // Notifica os listeners (o Router) que a configuração mudou
      _printPages(); // Para debug
      return true; // Indica que tratamos o pop
    } else {
      // Isso não deveria acontecer em um fluxo normal se a lista _pages
      // estiver sincronizada com o Navigator, mas é uma salvaguarda.
      debugPrint('⚠️ NavRouter: Pop successful, but stack is empty. Cannot remove page.');
      return false; // Indica que não tratamos o pop (nada para remover)
    }
  }

  /// Constrói uma Page para um determinado path usando o NavInjector.
  /// Inclui lógica para lidar com rotas não encontradas.
  Page _buildPage(String path) {
    debugPrint('🛠️ NavRouter: Building page for path: $path');
    // Usa o injector recebido para resolver a rota
    final pageBuilder = _injector.resolveRoute(path);

    if (pageBuilder != null) {
      // Rota encontrada, constrói a página
      return MaterialPage(
        key: ValueKey(path), // Use ValueKey com o nome da rota para identificação
        child: pageBuilder(),
        name: path, // Armazena o nome da rota na página (útil para debug/popUntil)
      );
    } else {
      // Rota não encontrada, tenta construir a página de escape
      debugPrint('❌ NavRouter: Route "$path" not found in injector. Attempting "escape" route.');
      final escapePageBuilder =
          _injector.resolveRoute('escape'); // Assumindo 'escape' é a rota da página de erro

      if (escapePageBuilder != null) {
        // Página de escape encontrada
        return MaterialPage(
          key: const ValueKey('escape'), // Use uma chave consistente para a página de escape
          child: escapePageBuilder(),
          name: 'escape', // Nome da rota de escape
        );
      } else {
        // Página de escape não encontrada, cria uma página de erro fallback simples
        debugPrint(
            '❌ NavRouter: Escape route "escape" not found either. Creating fallback error page.');
        return MaterialPage(
          key: const ValueKey('fallback_error'),
          child: Scaffold(
            appBar: AppBar(title: const Text('Navigation Error')),
            body: const Center(child: Text('Could not navigate to route or escape page.')),
          ),
          name: 'fallback_error', // Nome para a página de erro fallback
        );
      }
    }
  }

  // Métodos de navegação que o NavManagerService irá chamar

  /// Adiciona uma nova rota à pilha.
  Future<void> push(String routeName) async {
    debugPrint('➡️ NavRouter: Attempting to push route: $routeName');
    final newPage = _buildPage(routeName);
    _pages.add(newPage);
    notifyListeners(); // Notifica os listeners
    _printPages(); // Para debug
  }

  /// Substitui a rota atual por uma nova.
  Future<void> replace(String routeName) async {
    debugPrint('🔄 NavRouter: Attempting to replace route with: $routeName');
    final newPage = _buildPage(routeName);

    // Remove a página atual se houver
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    // Adiciona a nova página
    _pages.add(newPage);
    notifyListeners();
    _printPages(); // Para debug
  }

  /// Remove a última rota da pilha.
  void pop() {
    debugPrint('⬅️ NavRouter: Attempting to pop route.');
    // Usa a navigatorKey para chamar o pop do Navigator.
    // Isso acionará o _handlePopPage se o pop for bem-sucedido.
    // A lógica de remoção da lista _pages está no _handlePopPage.
    navigatorKey.currentState?.pop();
    // Note: não chamamos notifyListeners() aqui diretamente, pois _handlePopPage
    // já o fará após o Navigator confirmar o pop.
  }

  /// Remove rotas da pilha até encontrar a rota com o nome especificado.
  /// Se a rota não for encontrada, a pilha não é alterada.
  void popUntil(String routeName) {
    debugPrint('⬆️ NavRouter: Attempting to pop until route: $routeName');

    // Encontra o índice da página de destino na pilha
    // Usamos page.name (definido em _buildPage) para encontrar a rota.
    final existingPageIndex = _pages.indexWhere((page) => page.name == routeName);

    if (existingPageIndex != -1) {
      // Mantém apenas as páginas até a página de destino (inclusive)
      // Remove todas as páginas após a página de destino
      _pages.removeRange(existingPageIndex + 1, _pages.length);
      notifyListeners();
      _printPages(); // Para debug
    } else {
      debugPrint(
          '⚠️ NavRouter: Route "$routeName" not found in stack for popUntil. Stack unchanged.');
      // Opcional: Lidar com a rota não encontrada na pilha (ex: erro, ou pop até a raiz '/')
      // popUntil('/'); // Exemplo: pop até a raiz se a rota não for encontrada
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    // Este método é chamado pelo Router quando a configuração da rota muda externamente
    // (ex: deep links, URL na web).
    final path = configuration.uri.path.isEmpty ? '/' : configuration.uri.path;
    debugPrint('\n🔄 NavRouter: Setting new route path: $path');

    // Geralmente, ao definir um novo caminho de rota, limpamos a pilha existente
    // e navegamos para a nova rota.
    _pages.clear(); // Limpa a pilha existente

    // Adiciona a página correspondente ao novo path
    final newPage = _buildPage(path);
    _pages.add(newPage);

    notifyListeners(); // Notifica os listeners que a pilha de páginas mudou
    _printPages(); // Para debug
  }

  /// Implementação obrigatória do PopNavigatorRouterDelegateMixin.
  /// Chamado pelo sistema para lidar com o botão "voltar" do hardware.
  @override
  Future<bool> popRoute() {
    debugPrint('⬅️ NavRouter: popRoute called by system.');
    // Delega a operação de pop para o Navigator subjacente usando a chave.
    // Isso aciona o _handlePopPage.
    return navigatorKey.currentState!.maybePop();
  }

  @override
  RouteInformation? get currentConfiguration {
    // Informa a rota atual para o RouteInformationParser (útil para web, deep links)
    // Retorna a rota da página no topo da pilha
    if (_pages.isEmpty) {
      return null;
    }
    // Retorna a URI da página no topo da pilha, usando o 'name' ou a key.
    // Usar o 'name' (se definido) é geralmente mais direto, mas a key é mais garantida.
    // Se você definir o 'name' da Page com o path da rota, pode usar page.name.
    // Caso contrário, acesse o valor da ValueKey.
    final lastPage = _pages.last;
    if (lastPage.name != null && lastPage.name!.isNotEmpty) {
      debugPrint('⬅️ NavRouter: Reporting current configuration: ${lastPage.name}');
      return RouteInformation(uri: Uri.parse(lastPage.name!));
    } else if (lastPage.key is ValueKey<String>) {
      final pageKey = lastPage.key as ValueKey<String>;
      debugPrint('⬅️ NavRouter: Reporting current configuration from key: ${pageKey.value}');
      return RouteInformation(uri: Uri.parse(pageKey.value));
    }

    debugPrint(
        '⬅️ NavRouter: Cannot report current configuration for page with key type: ${lastPage.key.runtimeType} and no name.');
    return null; // Não pode determinar a rota se a chave/nome não forem adequados
  }

  void _printPages() {
    if (!kDebugMode) return; // Só imprime em debug
    debugPrint('Current navigation stack:');
    if (_pages.isEmpty) {
      debugPrint(' - Stack is empty');
      return;
    }
    for (var i = 0; i < _pages.length; i++) {
      final page = _pages[i];
      // Tenta usar o nome da página primeiro, depois a chave
      final pageIdentifier =
          page.name ?? (page.key is ValueKey ? (page.key as ValueKey).value : page.key.runtimeType);
      debugPrint(' - [$i] $pageIdentifier');
    }
    debugPrint('---'); // Separador para clareza
  }

  // ✅ Implemente dispose para limpar recursos se necessário
  @override
  void dispose() {
    debugPrint('🗑️ NavRouter: Disposing NavRouter...');
    // Se o NavInjector ou outros objetos geridos pelo Router precisarem de dispose, chame aqui.
    // No seu caso, o NavManager (widget) provavelmente fará o dispose do Injector.
    super.dispose(); // Chama o dispose da mixin e ChangeNotifier
  }
}
