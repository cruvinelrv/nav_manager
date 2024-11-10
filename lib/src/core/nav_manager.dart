import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

abstract class NavModule {
  void configure(NavInjector injector);
}

/// Widget principal para inicializar a navegação.
class NavManager extends StatefulWidget {
  final NavModule module;
  final Widget child;
  final Widget Function()?
      escapePageBuilder; // Nova propriedade para definir a página de escape

  const NavManager({
    super.key,
    required this.module,
    required this.child,
    this.escapePageBuilder, // Passa a página de escape customizável
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
    module.configure(_injector);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: NavRouter(
        _injector,
        escapePageBuilder: widget.escapePageBuilder,
      ),
      routeInformationParser: NavRouteInformationParser(),
    );
  }
}
