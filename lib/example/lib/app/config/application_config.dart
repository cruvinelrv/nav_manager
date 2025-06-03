import 'package:flutter/material.dart';
import 'package:nav_manager/example/lib/app/domains/domain_screen.dart';
import 'package:nav_manager/example/lib/app/domains/example_home.dart';
import 'package:nav_manager/nav_manager.dart';

/// Configuração principal da aplicação
class ApplicationConfig {
  static NavManagerConfig? _cachedConfig;
  static NavInjector? _cachedNavInjector;
  static NavDependencyInjector? _cachedDependencyInjector;

  static NavManagerConfig configureApp() {
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    print('🚀 ApplicationConfig: Starting app configuration...');

    // 🗺️ Setup do NavInjector (para rotas)
    final navInjector = NavInjector();
    _cachedNavInjector = navInjector;

    // 💉 Setup do DependencyInjector (para dependências)
    final dependencyInjector = DependencyInjectorFactory.createDefault();
    _cachedDependencyInjector = dependencyInjector;

    // 💉 Registra dependências básicas
    _registerDependencies(dependencyInjector);

    // 🗂️ Define as rotas como Map
    final routes = <String, Widget Function()>{
      '/': () => ExampleHome(),
      '/login': () => DomainScreen(
            title: 'Login',
            domain: 'Auth',
            icon: Icons.login,
            color: Colors.blue,
          ),
      '/register': () => DomainScreen(
            title: 'Register',
            domain: 'Auth',
            icon: Icons.person_add,
            color: Colors.blue,
          ),
      '/profile': () => DomainScreen(
            title: 'Profile',
            domain: 'User',
            icon: Icons.person,
            color: Colors.green,
          ),
      '/settings': () => DomainScreen(
            title: 'Settings',
            domain: 'User',
            icon: Icons.settings,
            color: Colors.green,
          ),
      '/products': () => DomainScreen(
            title: 'Products',
            domain: 'Shop',
            icon: Icons.shopping_bag,
            color: Colors.orange,
          ),
      '/cart': () => DomainScreen(
            title: 'Cart',
            domain: 'Shop',
            icon: Icons.shopping_cart,
            color: Colors.orange,
          ),
    };

    // ⚙️ Cria a configuração
    _cachedConfig = NavManagerConfig(
      routes: routes,
      navInjector: navInjector,
    );

    // 🔧 Configura módulos e rotas
    _cachedConfig!.configureModules();

    print('✅ ApplicationConfig: App configured successfully!');
    return _cachedConfig!;
  }

  /// Registra dependências básicas no DependencyInjector
  static void _registerDependencies(NavDependencyInjector dependencyInjector) {
    // ✅ Agora usa o NavDependencyInjector correto
    dependencyInjector.registerSingleton<String>('NavManager Example v1.0');
    dependencyInjector.registerSingleton<int>(42);
    dependencyInjector.registerFactory<DateTime>(() => DateTime.now(), DependencyScopeEnum.factory);
  }

  /// Obtém o NavInjector configurado (para rotas)
  static NavInjector getNavInjector() {
    if (_cachedNavInjector == null) {
      configureApp(); // Força configuração se não existir
    }
    return _cachedNavInjector!;
  }

  /// Obtém o DependencyInjector configurado (para dependências)
  static NavDependencyInjector getDependencyInjector() {
    if (_cachedDependencyInjector == null) {
      configureApp(); // Força configuração se não existir
    }
    return _cachedDependencyInjector!;
  }
}
