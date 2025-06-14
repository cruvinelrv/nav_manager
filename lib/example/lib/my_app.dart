import 'package:flutter/material.dart';
import '../../nav_manager.dart';

class MyApp extends StatelessWidget {
  final NavManagerConfig config;
  const MyApp({super.key, required this.config});
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
    return MaterialApp(
      title: 'Nav Manager Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/products',
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
                Map<String, String> parameters = {};
                for (int i = 0; i < pathSegmentsConfig.length; i++) {
                  if (pathSegmentsConfig[i].startsWith(':')) {
                    parameters[pathSegmentsConfig[i].substring(1)] = pathSegmentsActual[i];
                  } else if (pathSegmentsConfig[i] != pathSegmentsActual[i]) {
                    matches = false;
                    break;
                  }
                }
                if (matches) {
                  return MaterialPageRoute(builder: navRoute.builder, settings: settings);
                }
              }
            }
          }
        }
        if (appRoutes.containsKey(settings.name)) {
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
