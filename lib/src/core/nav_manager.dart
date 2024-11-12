import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

abstract class NavModule {
  void configure(NavInjector injector);
}

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
      routerDelegate: NavRouter(_injector),
      routeInformationParser: NavRouteInformationParser(),
    );
  }
}
