// lib/src/routing/nav_routes_injector.dart
import 'package:flutter/material.dart';
import 'package:nav_manager/src/nova/nav_dependency_injector.dart';

// Define a assinatura para a função construtora da tela/widget
// Ela recebe o BuildContext, o injetor de dependência e os argumentos da rota.
typedef RouteWidgetBuilder = Widget Function(
  BuildContext context,
  NavDependencyInjector di,
  Object? arguments,
);

// Classe interna para armazenar a definição de uma rota
class _RouteDefinition {
  final String name;
  final RouteWidgetBuilder builder;

  _RouteDefinition({required this.name, required this.builder});
}

/// Gerenciador de Rotas customizado para o NavManager.
/// Responsável por registrar rotas e executar operações de navegação.
class NavRoutesInjector {
  // Chave global para acessar o NavigatorState de qualquer lugar
  final GlobalKey<NavigatorState> _navigatorKey;
  final NavDependencyInjector _di;

  // Mapa para armazenar as definições de rota. A chave é o nome da rota.
  final Map<String, _RouteDefinition> _routes = {};

  /// Construtor do NavRoutesInjector.
  /// Recebe a chave do Navigator e o injetor de dependência.
  NavRoutesInjector(this._navigatorKey, this._di);

  /// Registra uma rota com um nome e uma função construtora.
  ///
  /// [name]: O nome único da rota (ex: '/home', '/details/:id').
  /// [builder]: A função que constrói o widget da tela para esta rota.
  ///   Esta função recebe o BuildContext, o NavDependencyInjector e os argumentos da rota.
  void registerRoute({
    required String name,
    required RouteWidgetBuilder builder,
  }) {
    if (_routes.containsKey(name)) {
      print("Warning: Route '$name' already registered. Overwriting.");
    }
    _routes[name] = _RouteDefinition(name: name, builder: builder);
  }

  /// Registra múltiplas rotas de uma vez.
  void registerRoutes(Map<String, RouteWidgetBuilder> routes) {
    routes.forEach((name, builder) {
      registerRoute(name: name, builder: builder);
    });
  }

  /// Método usado pelo MaterialApp.onGenerateRoute para construir a rota.
  /// Não deve ser chamado diretamente pelo aplicativo consumidor.
  Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeDefinition = _routes[settings.name];

    if (routeDefinition == null) {
      // Rota não encontrada, retornar null para que o Navigator tente onUnknownRoute
      // ou mostrar uma tela de erro padrão.
      print("Error: Route '${settings.name}' not found.");
      return null; // Ou RouteNotFoundPage()
    }

    // Usa a função construtora registrada para criar o widget da tela
    final widget = routeDefinition.builder(
      _navigatorKey.currentContext!, // Passa o BuildContext do Navigator
      _di, // Passa o injetor de dependência
      settings.arguments, // Passa os argumentos da rota
    );

    // Retorna um MaterialPageRoute (ou CupertinoPageRoute, etc.)
    return MaterialPageRoute(
      settings: settings, // Mantém as configurações da rota
      builder: (context) => widget,
    );
  }

  // --- Métodos de Navegação ---

  /// Navega para uma rota pelo nome, adicionando-a à pilha.
  /// Retorna um Future que completa quando a rota é removida da pilha.
  Future<T?> pushNamed<T extends Object?>(String name, {Object? arguments}) {
    if (!_routes.containsKey(name)) {
      print("Error: Cannot push route '$name'. Not registered.");
      // Opcional: Lançar erro ou navegar para tela de erro
      // throw Exception("Route '$name' not registered.");
      // Ou: return _navigatorKey.currentState!.pushReplacementNamed('/error', arguments: 'Route $name not found');
      return Future.value(null); // Retorna um futuro nulo se a rota não existe
    }
    return _navigatorKey.currentState!.pushNamed<T>(name, arguments: arguments);
  }

  /// Navega para uma rota pelo nome, substituindo a rota atual na pilha.
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String name, {
    TO? result,
    Object? arguments,
  }) {
    if (!_routes.containsKey(name)) {
      print("Error: Cannot push replacement route '$name'. Not registered.");
      return Future.value(null);
    }
    return _navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      name,
      result: result,
      arguments: arguments,
    );
  }

  /// Remove todas as rotas até que a rota com o nome especificado seja alcançada,
  /// e então navega para a nova rota, substituindo a rota alcançada.
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    if (!_routes.containsKey(newRouteName)) {
      print("Error: Cannot push and remove until route '$newRouteName'. Not registered.");
      return Future.value(null);
    }
    return _navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  /// Remove a rota atual da pilha.
  void pop<T extends Object?>([T? result]) {
    return _navigatorKey.currentState!.pop<T>(result);
  }

  /// Remove todas as rotas da pilha até que a rota com o nome especificado seja alcançada.
  void popUntil(RoutePredicate predicate) {
    _navigatorKey.currentState!.popUntil(predicate);
  }

  /// Verifica se é possível remover a rota atual da pilha.
  bool canPop() {
    return _navigatorKey.currentState!.canPop();
  }

  // Métodos adicionais como `goNamed` (que geralmente envolve popUntil + pushReplacementNamed)
  // podem ser adicionados aqui para replicar comportamentos de routers mais complexos.
  // Exemplo simples de 'go' (substitui toda a pilha):
  void goNamed(String name, {Object? arguments}) {
    if (!_routes.containsKey(name)) {
      print("Error: Cannot go to route '$name'. Not registered.");
      return;
    }
    // Remove todas as rotas e adiciona a nova
    _navigatorKey.currentState!.pushNamedAndRemoveUntil(
      name,
      (Route<dynamic> route) => false, // Remove todas as rotas
      arguments: arguments,
    );
  }

  // Opcional: Método para obter o BuildContext atual do Navigator
  BuildContext? get navigatorContext => _navigatorKey.currentContext;

  // Opcional: Método para obter a rota atual
  // String? get currentRouteName => _navigatorKey.currentState?.currentRoute?.settings.name;
  // Nota: Acesso à rota atual pode ser mais complexo dependendo da implementação.
}
