import 'package:flutter/material.dart';
import 'package:nav_manager/example/lib/app/domains/domain_screen.dart';
import 'package:nav_manager/nav_manager.dart';

// Importar dependências específicas deste domínio, se houver
// import '../../services/authservice.dart'; // Exemplo
/// Rotas relacionadas à Autenticação.
class AuthRoutes {
  static const String domain = 'Auth';

  /// Registra as rotas de autenticação (no NavInjector) e dependências (no NavDependencyInjector).
  // ✅ Agora aceita AMBOS os injetores
  static void register(NavInjector navInjector, NavDependencyInjector dependencyInjector) {
    // Registra rotas usando o NavInjector
    navInjector.registerRouteWithDomain(domain, '/login',
        () => DomainScreen(title: 'Login', domain: domain, icon: Icons.login, color: Colors.blue));
    navInjector.registerRouteWithDomain(
        domain,
        '/register',
        () => DomainScreen(
            title: 'Register', domain: domain, icon: Icons.person_add, color: Colors.blue));
// 💉 Se houver dependências específicas de Autenticação para registrar, use o NavDependencyInjector
// ✅ Use dependencyInjector.registerSingleton ou dependencyInjector.registerFactory aqui
// Ex: dependencyInjector.registerSingleton&lt;AuthService&gt;(AuthService());
// Ex: dependencyInjector.registerFactory&lt;AuthRepository&gt;(() =&gt; AuthRepositoryImpl());
  }

  /// Retorna o mapa de rotas de autenticação.
  static Map<String, Widget Function()> getAllRoutes() {
    return {
      '/login': () =>
          DomainScreen(title: 'Login', domain: domain, icon: Icons.login, color: Colors.blue),
      '/register': () => DomainScreen(
          title: 'Register', domain: domain, icon: Icons.person_add, color: Colors.blue),
    };
  }

  /// Retorna rotas públicas de autenticação.
  static List<String> getPublicRoutes() {
    return ['/login', '/register'];
  }

  /// Retorna rotas protegidas de autenticação.
  // Exemplo: Se houver uma tela de "Gerenciar Sessões" que é protegida
  static List<String> getProtectedRoutes() {
    return []; // Ou liste rotas protegidas aqui
  }
}
