// lib/nav_manager_service.dart
import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart'; // Importe NavRouter e NavInjector
import 'package:provider/provider.dart'; // Importe o package provider

/// Serviço responsável por orquestrar a navegação e o acesso ao injector.
/// Esta classe é fornecida via Provider e acessada através de BuildContext.
class NavManagerService {
  final NavRouter _router;

  /// Construtor que recebe as instâncias de NavRouter e NavInjector.
  NavManagerService(this._router) {
    // Registra o NavInjector no NavRouter
  }

  /// Navega para uma rota nomeada, adicionando-a à pilha.
  Future<void> pushNamed(String routeName) async {
    await _router.push(routeName);
  }

  /// Substitui a rota atual na pilha por uma nova rota nomeada.
  Future<void> replaceNamed(String routeName) async {
    await _router.replace(routeName);
  }

  /// Remove a rota atual do topo da pilha.
  void pop() {
    _router.pop();
  }

  /// Remove rotas da pilha até encontrar a rota nomeada especificada.
  void popUntilNamed(String routeName) {
    _router.popUntil(routeName);
  }

  /// Helper estático para obter a instância do NavManagerService via Provider.
  /// Use listen: false pois a instância do serviço não muda.
  static NavManagerService of(BuildContext context) {
    try {
      return Provider.of<NavManagerService>(context, listen: false);
    } catch (e) {
      throw FlutterError(
        'NavManagerService.of() called with a context that does not contain a NavManagerService.\n'
        'Ensure that a NavManager widget is an ancestor of the widget calling NavManagerService.of().',
      );
    }
  }

  /// Helper estático para obter a instância do NavInjector via Provider.
  /// Use listen: false pois a instância do injector não muda.
  static NavInjector injectorOf(BuildContext context) {
    try {
      return Provider.of<NavInjector>(context, listen: false);
    } catch (e) {
      throw FlutterError(
        'NavManagerService.injectorOf() called with a context that does not contain a NavInjector.\n'
        'Ensure that a NavManager widget is an ancestor of the widget calling NavManagerService.injectorOf().',
      );
    }
  }

  /// Helper estático genérico para obter um serviço específico do NavInjector via Provider.
  /// Resolve a dependência do NavInjector e depois chama getService nele.
  static T getService<T>(BuildContext context) {
    final injector = injectorOf(context); // Obtém o injector usando o helper estático
    return injector.getService<T>(); // Chama o método getService na instância do injector
  }

  /// Helper estático para obter um construtor de rota específico do NavInjector via Provider.
  /// (Opcional, se precisar construir uma tela manualmente em algum lugar)
  static Widget Function() getRouteBuilder(BuildContext context, String routeName) {
    final injector = injectorOf(context);
    final builder = injector.resolveRoute(routeName);
    if (builder == null) {
      throw Exception('Route builder not found for route: $routeName');
    }
    return builder;
  }
}
