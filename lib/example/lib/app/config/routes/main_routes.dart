// // example/lib/app/config/routes/main_routes.dart
// import 'package:flutter/material.dart';
// import 'package:nav_manager/example/lib/app/domains/example_home.dart';
// import 'package:nav_manager/nav_manager.dart'; // Se usar algo do nav_manager aqui
// // Importar as telas correspondentes
// // import '../../../screens/alguma_outra_tela.dart'; // Se houver outras telas

// class MainRoutes {
//   static const String domain = 'Main';

//   /// Registra as rotas principais (no NavInjector) e dependências (no NavDependencyInjector).
//   static void register(NavInjector navInjector, NavDependencyInjector dependencyInjector) {
//     print('  -> Registering $domain routes and dependencies...');
//     // Registra rotas usando o NavInjector
//     navInjector.registerRouteWithDomain(domain, '/', () => ExampleHome());
//     // navInjector.registerRouteWithDomain(domain, '/alguma_outra_rota', () => AlgumaOutraTela()); // Exemplo

//     // 💉 Registra dependências específicas de Main, se houver
//     // dependencyInjector.registerSingleton<AlgumServico>(AlgumServico()); // Exemplo

//     print('  -> $domain routes and dependencies registered.');
//   }

//   /// Retorna o mapa de rotas principais.
//   // ✅ VERIFIQUE ESTE MÉTODO!
//   static Map<String, Widget Function()> getAllRoutes() {
//     // ✅ DEVE RETORNAR UM MAPA {}
//     return {
//       '/': () => ExampleHome(),
//       // '/alguma_outra_rota': () => AlgumaOutraTela(), // Se houver outras rotas
//     };
//   }

//   /// Retorna rotas públicas principais.
//   static List<String> getPublicRoutesPath() {
//     return ['/']; // Liste rotas públicas aqui
//   }

//   /// Retorna rotas protegidas principais.
//   static List<String> getProtectedRoutesPaths() {
//     return []; // Liste rotas protegidas aqui
//   }
// }
