// lib/src/config/validators/route_validator.dart
import 'package:nav_manager/src/config/nav_logger.dart';
import 'package:nav_manager/src/config/nav_manager_exception.dart';

class NavRouteValidator {
  final NavLogger logger;

  NavRouteValidator(this.logger);

  // Validar rotas duplicadas
  void validateDuplicateRoutes(Map<String, dynamic> routes) {
    final allRoutes = <String>{};

    // Verificar rotas diretas
    for (var route in routes.keys) {
      if (allRoutes.contains(route)) {
        throw NavManagerException('Duplicate route found in direct routes: $route');
      }
      allRoutes.add(route);
    }

    logger.logSuccess('Route validation passed - no duplicates found');
  }

  // Validar formato das rotas
  void validateRouteFormat(Map<String, dynamic> routes) {
    for (var route in routes.keys) {
      if (!route.startsWith('/')) {
        throw NavManagerException('Route must start with "/": $route');
      }

      if (route.contains('//')) {
        throw NavManagerException('Route cannot contain double slashes: $route');
      }
    }

    logger.logSuccess('Route format validation passed');
  }
}
