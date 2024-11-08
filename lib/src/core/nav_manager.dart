import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

abstract class NavModule {
  /// Método que configura rotas e dependências no injetor.
  void configure(NavInjector injector);
}

/// Widget principal para inicializar a navegação.
class NavManager extends StatefulWidget {
  final NavModule module; // Módulo inicial
  final Widget child; // Widget principal da aplicação

  const NavManager({
    super.key,
    required this.module,
    required this.child,
  });

  @override
  State<NavManager> createState() => _NavManagerState();
}

class _NavManagerState extends State<NavManager> {
  late final NavInjector _injector;

  @override
  void initState() {
    super.initState();
    _injector = NavInjector();
    _initializeModule(widget.module);
  }

  void _initializeModule(NavModule module) {
    // Inicializa as rotas e dependências do módulo
    module.configure(_injector);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: NavRouter(_injector),
      routeInformationParser: NavRouteInformationParser(),
    );
  }
}
