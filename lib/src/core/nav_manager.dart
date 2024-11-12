import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

abstract class NavModule {
  void configure(NavInjector injector);
}

/// Widget principal para inicializar a navegação.
class NavManager extends StatefulWidget {
  final NavModule module;
  final Widget child;
  final Widget Function()? escapePageBuilder;

  const NavManager({
    super.key,
    required this.module,
    required this.child,
    this.escapePageBuilder,
  });

  @override
  State<NavManager> createState() => _NavManagerState();

  static late NavRouter _navRouter;

  static NavRouter get router => _navRouter;

  static Future<void> navigateTo(String route) async {
    await _navRouter.to(route);
  }
}

class _NavManagerState extends State<NavManager> {
  late final NavInjector _injector;

  @override
  void initState() {
    super.initState();
    _injector = NavInjector();
    _initializeModule(widget.module);
    NavManager._navRouter = NavRouter(_injector);
  }

  void _initializeModule(NavModule module) {
    module.configure(_injector);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: NavManager._navRouter,
      routeInformationParser: NavRouteInformationParser(),
    );
  }
}
