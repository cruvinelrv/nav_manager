import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

class AppWidget extends StatelessWidget {
  final NavManagerConfig navManagerConfig;
  const AppWidget({super.key, required this.navManagerConfig});

  @override
  Widget build(BuildContext context) {
    navManagerConfig.navInjector.printRegisteredRoutes();
    return MaterialApp.router(
      routeInformationParser: NavRouteInformationParser(),
      routerDelegate: NavRouter((navManagerConfig.navInjector)),
      title: 'App Title',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
