// import 'package:flutter/material.dart'; // Para Container e Widget
// import 'package:flutter_test/flutter_test.dart';
// import 'package:nav_manager/src/config/nav_manager_exception.dart';
// import 'package:nav_manager/src/nova/inav_routes_injector.dart';
// import 'package:nav_manager/src/nova/nav_dependency_injector.dart';
// import 'package:nav_manager/src/nova/nav_routes_injector.dart'; // Ajuste o caminho

// // Uma função builder de widget simples para usar nos testes
// Widget _testScreenBuilder() => Container(key: const Key('testScreen'));
// Widget _anotherTestScreenBuilder() => Container(key: const Key('anotherTestScreen'));

// void main() {
//   group('NavRoutesInjector Tests', () {
//     late INavRoutesInjector routesInjector;

//     setUp(() {
//       routesInjector = NavRoutesInjector(
//         GlobalKey<NavigatorState>(), // Usando uma chave global para o Navigator
//         NavDependencyInjector(), // Injetor de dependência vazio para os testes
//       );
//     });

//     test('should register a route successfully', () {
//       routesInjector.registerRoute('/home', _testScreenBuilder);
//       expect(routesInjector.hasRoute('/home'), isTrue);
//     });

//     test('should throw NavManagerException when registering an empty path', () {
//       expect(
//         () => routesInjector.registerRoute('', _testScreenBuilder),
//         throwsA(isA<NavManagerException>()
//             .having((e) => e.message, 'message', 'Route path cannot be empty.')),
//       );
//     });

//     test('should throw NavManagerException when registering a duplicate route path', () {
//       routesInjector.registerRoute('/home', _testScreenBuilder);
//       expect(
//         () => routesInjector.registerRoute('/home', _anotherTestScreenBuilder),
//         throwsA(isA<NavManagerException>().having((e) => e.message, 'message',
//             "Route for path '/home' is already registered. Duplicate route paths are not allowed.")),
//       );
//     });

//     test('should get a registered route builder', () {
//       routesInjector.registerRoute('/profile', _testScreenBuilder);
//       final builder = routesInjector.getRouteOrThrow('/profile');
//       expect(builder, _testScreenBuilder);
//       // Verificando se o builder retorna o widget esperado
//       expect(builder().key, const Key('testScreen'));
//     });

//     test('should throw NavManagerException when getting a non-existent route', () {
//       expect(
//         () => routesInjector.getRouteOrThrow('/nonexistent'),
//         throwsA(isA<NavManagerException>().having((e) => e.message, 'message',
//             "No route registered for path '/nonexistent'. Ensure the route is defined and registered.")),
//       );
//     });

//     test('should return all registered routes', () {
//       routesInjector.registerRoute('/home', _testScreenBuilder);
//       routesInjector.registerRoute('/settings', _anotherTestScreenBuilder);

//       final allRoutes = routesInjector.getAllRegisteredRoutes();
//       expect(allRoutes.length, 2);
//       expect(allRoutes['/home'], _testScreenBuilder);
//       expect(allRoutes['/settings'], _anotherTestScreenBuilder);
//     });

//     test('getAllRegisteredRoutes should return an unmodifiable map', () {
//       routesInjector.registerRoute('/home', _testScreenBuilder);
//       final allRoutes = routesInjector.getAllRegisteredRoutes();
//       expect(() => allRoutes['/new'] = _testScreenBuilder, throwsUnsupportedError);
//     });

//     test('hasRoute should return true for registered route and false otherwise', () {
//       routesInjector.registerRoute('/about', _testScreenBuilder);
//       expect(routesInjector.hasRoute('/about'), isTrue);
//       expect(routesInjector.hasRoute('/contact'), isFalse);
//     });

//     test('clearAllRoutes should remove all registered routes', () {
//       routesInjector.registerRoute('/home', _testScreenBuilder);
//       routesInjector.registerRoute('/settings', _anotherTestScreenBuilder);
//       expect(routesInjector.getAllRegisteredRoutes().isNotEmpty, isTrue);

//       routesInjector.clearAllRoutes();
//       expect(routesInjector.getAllRegisteredRoutes().isEmpty, isTrue);
//       expect(routesInjector.hasRoute('/home'), isFalse);
//     });
//   });
// }
