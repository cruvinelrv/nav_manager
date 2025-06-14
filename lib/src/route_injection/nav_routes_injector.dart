import 'package:nav_manager/src/route_injection/nav_route.dart';

class NavRoutesInjector {
  final Map<String, NavRoute> routes;
  const NavRoutesInjector({
    this.routes = const {},
  });
  @override
  String toString() {
    return 'NavRoutesInjector(routes: $routes)';
  }
}
