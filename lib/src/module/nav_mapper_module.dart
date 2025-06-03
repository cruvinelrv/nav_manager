// lib/src/module/nav_mapper_module.dart
import 'nav_module.dart';
import '../navigation/nav_injector.dart';

class NavMapperModule {
  final String name;
  final String domainName;
  final String? teamOwner;
  final List<NavModule> localModules;
  final List<NavModule> remoteModules;
  final Map<String, dynamic> dependencies;
  final String version;

  NavMapperModule({
    required this.name,
    required this.domainName,
    this.teamOwner,
    this.localModules = const [],
    this.remoteModules = const [],
    this.dependencies = const {},
    this.version = '1.0.0',
  });

  /// Validar consistência do domínio
  DomainValidationResult validateDomain() {
    final errors = <String>[];
    final warnings = <String>[];
    final info = <String>[];

    // 1. Validar se módulos pertencem ao domínio correto
    for (var module in [...localModules, ...remoteModules]) {
      if (module.domainName != domainName) {
        errors.add(
            'Module ${module.runtimeType} domain "${module.domainName}" != mapper domain "$domainName"');
      }

      // Validar consistência interna das rotas do módulo
      final moduleErrors = module.validateRouteConsistency();
      errors.addAll(moduleErrors);
    }

    // 2. Verificar conflitos de rotas entre módulos
    final allRoutes = <String>[];
    final routeConflicts = <String>[];

    for (var module in [...localModules, ...remoteModules]) {
      for (var route in module.domainRoutes) {
        if (allRoutes.contains(route)) {
          routeConflicts.add('Route "$route" is declared in multiple modules');
        } else {
          allRoutes.add(route);
        }
      }
    }
    errors.addAll(routeConflicts);

    // 3. Verificar se há módulos locais e remotos misturados
    if (localModules.isNotEmpty && remoteModules.isNotEmpty) {
      warnings.add(
          'Domain "$domainName" has both local and remote modules. Consider keeping them separate.');
    }

    // 4. Informações gerais
    info.add('Domain "$domainName" has ${allRoutes.length} routes');
    info.add('Local modules: ${localModules.length}');
    info.add('Remote modules: ${remoteModules.length}');

    return DomainValidationResult(
      domainName: domainName,
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      info: info,
      totalRoutes: allRoutes.length,
    );
  }

  /// Obter todas as rotas do domínio
  List<String> getAllDomainRoutes() {
    final routes = <String>[];
    for (var module in [...localModules, ...remoteModules]) {
      routes.addAll(module.domainRoutes);
    }
    return routes.toSet().toList(); // Remove duplicatas
  }

  /// Obter informações detalhadas do mapper
  Map<String, dynamic> getMapperInfo() {
    return {
      'name': name,
      'domainName': domainName,
      'teamOwner': teamOwner,
      'version': version,
      'localModules': localModules.map((m) => m.getModuleInfo()).toList(),
      'remoteModules': remoteModules.map((m) => m.getModuleInfo()).toList(),
      'dependencies': dependencies,
      'totalRoutes': getAllDomainRoutes().length,
      'allRoutes': getAllDomainRoutes(),
    };
  }

  /// Configurar módulos (método existente mantido)
  void configureModules(NavInjector injector) {
    _registerModules(injector, localModules);
    _registerModules(injector, remoteModules);
  }

  void _registerModules(NavInjector injector, List<NavModule> modules) {
    for (var module in modules) {
      module.registerDependencies(injector);
      module.registerRoutes(injector);
    }
  }
}

/// Resultado da validação de domínio
class DomainValidationResult {
  final String domainName;
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final List<String> info;
  final int totalRoutes;

  const DomainValidationResult({
    required this.domainName,
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.info,
    required this.totalRoutes,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Domain Validation: $domainName');
    buffer.writeln('Status: ${isValid ? "✅ VALID" : "❌ INVALID"}');

    if (errors.isNotEmpty) {
      buffer.writeln('Errors:');
      for (var error in errors) {
        buffer.writeln('  ❌ $error');
      }
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('Warnings:');
      for (var warning in warnings) {
        buffer.writeln('  ⚠️  $warning');
      }
    }

    if (info.isNotEmpty) {
      buffer.writeln('Info:');
      for (var infoItem in info) {
        buffer.writeln('  ℹ️  $infoItem');
      }
    }

    return buffer.toString();
  }
}
