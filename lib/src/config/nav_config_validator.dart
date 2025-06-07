import 'package:nav_manager/nav_manager.dart';
import 'package:nav_manager/src/config/nav_logger.dart';
import 'package:nav_manager/src/config/nav_manager_exception.dart';
import 'package:nav_manager/src/module/nav_module.dart';

class NavConfigValidator {
  final NavLogger logger;

  NavConfigValidator(this.logger);

  // Validação síncrona básica
  void validateBasicConfig({
    required Map<String, dynamic> routes,
    required Map<String, NavModule> localModules,
    required Map<String, NavModule> remoteModules,
  }) {
    if (routes.isEmpty && localModules.isEmpty && remoteModules.isEmpty) {
      throw NavManagerException('NavManagerConfig must have at least one route or module');
    }

    logger.logSuccess('Basic configuration validation passed');
  }

  // Validação final assíncrona
  Future<void> validateFinalConfiguration({
    required NavInjector navInjector,
    required List<String> requiredRoutes,
  }) async {
    logger.logInfo('Performing final validation...');

    try {
      await _validateRequiredRoutes(navInjector, requiredRoutes);
      await _validateInjectorIntegrity(navInjector);

      logger.logSuccess('Final validation passed');
    } catch (e, stackTrace) {
      throw NavManagerException(
        'Final validation failed',
        e,
        stackTrace,
      );
    }
  }

  // Validar rotas obrigatórias
  Future<void> _validateRequiredRoutes(
    NavInjector navInjector,
    List<String> requiredRoutes,
  ) async {
    final registeredRoutes = navInjector.getRegisteredRoutes();
    final missingRoutes = <String>[];

    for (var route in requiredRoutes) {
      if (!registeredRoutes.contains(route)) {
        missingRoutes.add(route);
      }
    }

    if (missingRoutes.isNotEmpty) {
      throw NavManagerException('Required routes not registered: ${missingRoutes.join(', ')}');
    }

    logger.logSuccess('All required routes are registered: ${requiredRoutes.join(', ')}');
  }

  // Validar integridade do injector
  Future<void> _validateInjectorIntegrity(NavInjector navInjector) async {
    final dependencyCount = navInjector.getDependencyCount();
    final routeCount = navInjector.getRouteCount();

    if (routeCount == 0) {
      throw NavManagerException('No routes registered in NavInjector');
    }

    logger.logSuccess(
        'Injector integrity validated - $dependencyCount dependencies, $routeCount routes');
  }
}
