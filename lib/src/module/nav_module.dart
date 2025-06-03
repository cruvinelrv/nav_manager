// lib/src/module/nav_module.dart
import '../navigation/nav_injector.dart';

abstract class NavModule {
  /// Nome do domínio de negócio
  String get domainName;

  /// Rota base do domínio (ex: /auth, /user, /shop)
  String get baseRoute;

  /// Todas as rotas que pertencem a este domínio
  List<String> get domainRoutes;

  /// Equipe responsável pelo domínio (opcional, para debug/docs)
  String? get teamOwner => null;

  /// Versão do módulo (para compatibilidade)
  String get version => '1.0.0';

  /// Se é um módulo remoto ou local
  bool get isRemote => false;

  /// Dependências externas que este módulo precisa
  List<String> get dependencies => [];

  /// Registrar dependências específicas do domínio
  void registerDependencies(NavInjector injector);

  /// Registrar rotas específicas do domínio
  void registerRoutes(NavInjector injector);

  /// Validar se uma rota pertence a este domínio
  bool isRouteFromDomain(String route) {
    return route.startsWith(baseRoute) || domainRoutes.contains(route);
  }

  /// Validar se todas as rotas declaradas começam com baseRoute
  List<String> validateRouteConsistency() {
    final inconsistentRoutes = <String>[];

    for (var route in domainRoutes) {
      if (!route.startsWith(baseRoute)) {
        inconsistentRoutes.add('Route "$route" does not start with baseRoute "$baseRoute"');
      }
    }

    return inconsistentRoutes;
  }

  /// Informações de debug do módulo
  Map<String, dynamic> getModuleInfo() {
    return {
      'domainName': domainName,
      'baseRoute': baseRoute,
      'teamOwner': teamOwner,
      'version': version,
      'isRemote': isRemote,
      'routeCount': domainRoutes.length,
      'routes': domainRoutes,
      'dependencies': dependencies,
    };
  }
}

/// Implementação base para módulos locais
abstract class LocalModule extends NavModule {
  @override
  bool get isRemote => false;
}

/// Implementação base para módulos remotos
abstract class RemoteModule extends NavModule {
  @override
  bool get isRemote => true;

  /// URL do repositório remoto (para multirepo)
  String? get repositoryUrl => null;

  /// Branch/tag específica
  String? get branch => null;
}
