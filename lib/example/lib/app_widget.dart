import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';

// AppWidget agora pode ser um StatelessWidget, pois não gerencia mais o injector ou a key
class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key); // Remove o construtor com injector

  @override
  Widget build(BuildContext context) {
    // Obtenha o NavManagerService usando o context.
    // Este context agora tem um NavManager como ancestral.
    final navService = NavManagerService.getService(context);

    // O NavManagerService agora fornecerá o RouterDelegate e o RouteInformationParser
    // Ele já tem o injector e a navigatorKey que foram passados para o widget NavManager.
    return MaterialApp.router(
      routerDelegate: navService.getRouterDelegate(), // Chame o método sem passar injector/key
      routeInformationParser:
          navService.getRouteInformationParser(), // Chame o método sem passar injector
      // A navigatorKey é gerenciada internamente pelo NavManager ou pelo Delegate/Service
      // Não precisa mais passá-la para o MaterialApp.router key
      // key: _navigatorKey, // REMOVA esta linha

      title: 'Nav Manager Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // O builder também deve ser obtido do service
      builder: navService.getBuilder(), // Chame o método sem passar injector/key
    );
  }
}
