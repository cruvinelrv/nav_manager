// lib/my_app.dart

import 'package:flutter/material.dart';
import '../../nav_manager.dart';
// Não precisamos importar o injetor aqui, pois ele é acessado estaticamente via ApplicationConfig

// Remova completamente a classe DependencyInjectorProvider InheritedWidget se ela estiver aqui

class MyApp extends StatelessWidget {
  final NavManagerConfig config;
  const MyApp({super.key, required this.config});

  // REMOVA ESTE GETTER _injector que tenta ler de config.dependencies
  /*
  NavDependencyInjectorImpl get _injector {
     final injector = config.dependencies['injector'];
     if (injector is! NavDependencyInjectorImpl) {
        throw StateError('NavDependencyInjectorImpl not found in config.dependencies with key "injector". '
                         'Ensure ApplicationConfig.configure() registers it.');
     }
     return injector;
  }
  */

  @override
  Widget build(BuildContext context) {
    Map<String, WidgetBuilder> appRoutes = {};
    config.routes.forEach((injectorKey, injector) {
      injector.routes.forEach((routePath, navRoute) {
        if (!routePath.contains(':')) {
          appRoutes[routePath] = navRoute.builder;
        }
      });
    });

    // Não envolvemos mais com DependencyInjectorProvider
    return MaterialApp(
      title: 'Nav Manager Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: appRoutes,
      onGenerateRoute: (settings) {
        for (var injector in config.routes.values) {
          for (var entry in injector.routes.entries) {
            final routePath = entry.key;
            final navRoute = entry.value;
            if (routePath.contains(':')) {
              final pathSegmentsConfig = routePath.split('/');
              final pathSegmentsActual = Uri.parse(settings.name ?? '').pathSegments;
              if (pathSegmentsConfig.length == pathSegmentsActual.length) {
                bool matches = true;
                for (int i = 0; i < pathSegmentsConfig.length; i++) {
                  if (pathSegmentsConfig[i].startsWith(':')) {
                    // Parâmetros
                  } else if (pathSegmentsConfig[i] != pathSegmentsActual[i]) {
                    matches = false;
                    break;
                  }
                }
                if (matches) {
                  // O builder (HomePage, DetailPage, SettingsPage)
                  // receberá o BuildContext, mas não precisa dele para o injetor
                  return MaterialPageRoute(builder: navRoute.builder, settings: settings);
                }
              }
            }
          }
        }
        if (appRoutes.containsKey(settings.name)) {
          // O builder também recebe o BuildContext
          return MaterialPageRoute(builder: appRoutes[settings.name]!, settings: settings);
        }
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Erro')),
                body: Center(child: Text('Route not found: ${settings.name}'))));
      },
    );
  }
}
