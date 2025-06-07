// import 'package:flutter/material.dart'; // Import necessário para Widget Function()
// import 'package:nav_manager/example/lib/app/config/routes/auth_routes.dart';
// import 'package:nav_manager/example/lib/app/config/routes/main_routes.dart';
// import 'package:nav_manager/nav_manager.dart';

// // Importar os arquivos de rota por domínio com os caminhos corretos
// /// Orquestrador de todas as rotas e dependências da aplicação.
// /// Este arquivo centraliza a chamada para o registro de rotas e dependências de cada domínio.
// class AppRoutes {
//   /// Registra todas as rotas (no NavInjector) e dependências de domínio (no NavDependencyInjector).
//   ///
//   /// Este método itera sobre cada domínio e chama o método register
//   /// correspondente, passando as instâncias de NavInjector e NavDependencyInjector.
//   // ✅ Agora aceita AMBOS os injetores
//   static void registerAll(NavInjector navInjector, NavDependencyInjector dependencyInjector) {
//     print('🗺️ AppRoutes: Starting route and domain dependency registration…');
// // Registra rotas e dependências de cada domínio
// // Cada classe de rota de domínio é responsável por chamar
// // navInjector.registerRoute e dependencyInjector.registerSingleton/Factory
//     MainRoutes.register(navInjector, dependencyInjector); // ✅ Passa ambos
//     AuthRoutes.register(navInjector, dependencyInjector); // ✅ Passa ambos

// // Assumindo que NavInjector tem um método para contar rotas registradas
//     final totalRoutes = navInjector.getRegisteredRoutes().length;
// // ✅ Usa o DependencyInjector para contar as dependências registradas
// // Usando getRegisteredTypes() que você mostrou na sua implementação
//     final totalServices = dependencyInjector.getRegisteredTypes().length;
//     print(
//         '✅ AppRoutes: $totalRoutes total routes and $totalServices total dependencies registered successfully!');
//   }

//   static Map<String, Widget Function()> getAllRoutesMap() {
//     return {
//       // ✅ Use TRÊS PONTOS (...)
//       ...MainRoutes.getAllRoutes(),
//       ...AuthRoutes.getAllRoutes(),
//     };
//   }

//   /// Lista todos os paths de rota da aplicação.
//   /// Combina as listas de paths de cada domínio.
//   static List<String> getAllRoutePaths() {
//     // Usamos .keys.toList() pois getAllRoutesMap() retorna um Map
//     return getAllRoutesMap().keys.toList();
//   }

//   /// Obtém rotas agrupadas por domínio.
//   /// Retorna um mapa onde a chave é o nome do domínio e o valor é uma lista de paths.
//   static Map<String, List<String>> getRoutesByDomain() {
//     return {
//       MainRoutes.domain: MainRoutes.getAllRoutes().keys.toList(),
//       AuthRoutes.domain: AuthRoutes.getAllRoutes().keys.toList(),
//     };
//   }

//   /// Lista rotas públicas (não precisam de autenticação).
//   /// Combina as listas de rotas públicas de cada domínio.
//   static List<String> getPublicRoutes() {
//     return [
//       // ✅ Usando o operador spread (…) corretamente
//       ...MainRoutes.getPublicRoutesPath(),
//       ...AuthRoutes.getPublicRoutes(),
//     ];
//   }

//   /// Lista rotas protegidas (precisam de autenticação).
//   /// Combina as listas de rotas protegidas de cada domínio.
//   static List<String> getProtectedRoutesPaths() {
//     return [
//       // ✅ Usando o operador spread (…) corretamente
//       ...MainRoutes.getProtectedRoutesPaths()
//     ];
//   }
// }
