import 'package:nav_manager/src/config/repo_type_enum.dart';
import 'package:nav_manager/src/dependency_injection/dependency_scope_enum.dart';
import 'package:nav_manager/src/route_injection/nav_routes_injector.dart';

class NavManagerConfig {
  final RepoTypeEnum typeRepo;
  final List<String> domains;
  final List<String> localModules;
  final List<String> remoteModules;
  final Map<String, NavRoutesInjector> routes;
  final Map<Type, dynamic Function()> dependencies;
  final DependencyScopeEnum dependencyScope;

  NavManagerConfig({
    this.typeRepo = RepoTypeEnum.monoRepo,
    this.domains = const [],
    this.localModules = const [],
    this.remoteModules = const [],
    this.routes = const {},
    this.dependencies = const {},
    this.dependencyScope = DependencyScopeEnum.singleton,
  });
}
