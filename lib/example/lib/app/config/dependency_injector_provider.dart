
    // import 'package:flutter/material.dart';
    // import '../../../../nav_manager.dart';
    // class DependencyInjectorProvider extends InheritedWidget {
    //   const DependencyInjectorProvider({
    //     super.key,
    //     required this.injector,
    //     required super.child,
    //   });

    //   final NavDependencyInjectorImpl injector;

    //   // Método para obter o injetor a partir do BuildContext
    //   static NavDependencyInjectorImpl of(BuildContext context) {
    //     final DependencyInjectorProvider? result = context.dependOnInheritedWidgetOfExactType<DependencyInjectorProvider>();
    //     assert(result != null, 'No DependencyInjectorProvider found in context');
    //     return result!.injector;
    //   }

    //   @override
    //   bool updateShouldNotify(DependencyInjectorProvider oldWidget) {
    //     return false; // A instância do injetor não muda
    //   }
    // }


    // class MyApp extends StatelessWidget {
    //   final NavManagerConfig config;
    //   const MyApp({super.key, required this.config});

    //   // Obtenha o injetor do config
    //   NavDependencyInjectorImpl get _injector {
    //      final injector = config.dependencies['injector'];
    //      if (injector is! NavDependencyInjectorImpl) {
    //         // Trate o erro se o injetor não foi configurado corretamente
    //         throw StateError('NavDependencyInjectorImpl not found in config.dependencies with key "injector". '
    //                          'Ensure ApplicationConfig.configure() registers it.');
    //      }
    //      return injector;
    //   }

    //   @override
    //   Widget build(BuildContext context) {
    //     Map<String, WidgetBuilder> appRoutes = {};
    //     config.routes.forEach((injectorKey, injector) {
    //       injector.routes.forEach((routePath, navRoute) {
    //         if (!routePath.contains(':')) {
    //           appRoutes[routePath] = navRoute.builder;
    //         }
    //       });
    //     });

    //     // --- 4. Envolva o MaterialApp com o DependencyInjectorProvider ---
    //     return DependencyInjectorProvider(
    //       injector: _injector, // Passa a instância do injetor extraída do config
    //       child: MaterialApp(
    //         title: 'Nav Manager Example',
    //         theme: ThemeData(
    //           primarySwatch: Colors.blue,
    //           visualDensity: VisualDensity.adaptivePlatformDensity,
    //         ),
    //         initialRoute: '/products',
    //         routes: appRoutes,
    //         onGenerateRoute: (settings) {
    //           for (var injector in config.routes.values) {
    //             for (var entry in injector.routes.entries) {
    //               final routePath = entry.key;
    //               final navRoute = entry.value;
    //               if (routePath.contains(':')) {
    //                 final pathSegmentsConfig = routePath.split('/');
    //                 final pathSegmentsActual = Uri.parse(settings.name ?? '').pathSegments;
    //                 if (pathSegmentsConfig.length == pathSegmentsActual.length) {
    //                   bool matches = true;
    //                   for (int i = 0; i < pathSegmentsConfig.length; i++) {
    //                     if (pathSegmentsConfig[i].startsWith(':')) {
    //                       // Parâmetros
    //                     } else if (pathSegmentsConfig[i] != pathSegmentsActual[i]) {
    //                       matches = false;
    //                       break;
    //                     }
    //                   }
    //                   if (matches) {
    //                     // O builder (HomePage, DetailPage, SettingsPage)
    //                     // receberá o BuildContext que está abaixo do InheritedWidget
    //                     return MaterialPageRoute(builder: navRoute.builder, settings: settings);
    //                   }
    //                 }
    //               }
    //             }
    //           }
    //           if (appRoutes.containsKey(settings.name)) {
    //              // O builder também receberá o BuildContext correto
    //             return MaterialPageRoute(builder: appRoutes[settings.name]!, settings: settings);
    //           }
    //           return MaterialPageRoute(
    //               builder: (context) => Scaffold(
    //                   appBar: AppBar(title: const Text('Erro')),
    //                   body: Center(child: Text('Route not found: ${settings.name}'))));
    //         },
    //       ),
    //     );
    //   }
    // }
