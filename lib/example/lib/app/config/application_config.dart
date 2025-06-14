import 'package:flutter/widgets.dart';
import 'package:nav_manager/example/lib/app/pages/detail_page.dart';
import 'package:nav_manager/example/lib/app/pages/home_page.dart';
import 'package:nav_manager/example/lib/app/pages/settings_page.dart';
import 'package:nav_manager/nav_manager.dart';
import '../../services/user_service.dart';

class ApplicationConfig {
  static NavDependencyInjectorImpl? _injector;

  // Getter estático público para acessar o injetor
  static NavDependencyInjectorImpl get injector {
    // Garante que o injetor foi configurado antes de ser acessado
    if (_injector == null) {
      // Esta é a linha que lança o StateError se configure() falhou
      throw StateError(
          'Dependency Injector has not been configured. Call ApplicationConfig.configure() first.');
    }
    return _injector!;
  }

  static NavManagerConfig configure() {
    try {
      _injector = NavDependencyInjectorImpl();

      _injector!.register<UserService>(UserService('Config Value'), DependencyScopeEnum.singleton);

      final navConfig = NavManagerConfig(
        routes: {
          'products': NavRoutesInjector(
            routes: {
              '/': NavRoute(builder: (context) => const HomePage()),
              '/products/:id': NavRoute(builder: (context) {
                final id = ModalRoute.of(context)!.settings.arguments as String?;
                return DetailPage(id: id ?? 'Unknown');
              }),
            },
          ),
          'settings': NavRoutesInjector(routes: {
            '/settings': NavRoute(builder: (context) => const SettingsPage()),
          }),
        },
        dependencies: {}, // Não passa mais o injetor aqui
      );
      return navConfig;
    } catch (e, stack) {
      print('-------------------------------------------------------');
      print('FATAL ERROR: Exception occurred during ApplicationConfig.configure()');
      print('Exception: $e');
      print('Stack trace: $stack');
      print('-------------------------------------------------------');

      rethrow;
    }
  }
}
