import 'package:flutter/material.dart';

class NavInjector {
  final Map<String, Widget Function()> _routes = {};

  // NOVOS: Gestão de dependências
  final Map<String, dynamic Function()> _services = {};
  final Map<String, dynamic> _singletonInstances = {};

  // NOVOS: Gestão por domínios
  final Map<String, String> _routeDomains = {}; // rota -> domínio
  final Map<String, List<String>> _domainRoutes = {}; // domínio -> [rotas]

  // NOVOS: Gestão de módulos
  final Map<String, ModuleInfo> _registeredModules = {};

  // ========== MÉTODOS EXISTENTES ==========

  void registerRoute(String path, Widget Function() builder) {
    debugPrint('📝 Registering route in NavInjector: $path');
    _routes[path] = builder;
  }

  List<String> getRoutes() {
    debugPrint('📋 Getting list of routes: ${_routes.keys.toList()}');
    return _routes.keys.toList();
  }

  Widget Function()? resolveRoute(String path) {
    final builder = _routes[path];
    if (builder != null) {
      debugPrint('✅ Route found: $path');
    } else {
      debugPrint('❌ Route not found: $path');
    }
    return builder;
  }

  void printRegisteredRoutes() {
    debugPrint('\n📊 Routes registered in NavInjector:');
    for (var route in _routes.keys) {
      debugPrint(' - $route');
    }
    debugPrint('');
  }

  // ========== MÉTODOS NECESSÁRIOS PARA O VALIDATOR ==========

  List<String> getRegisteredRoutes() {
    debugPrint('📋 Getting registered routes: ${_routes.keys.toList()}');
    return _routes.keys.toList();
  }

  int getDependencyCount() {
    debugPrint('📊 Getting dependency count: ${_services.length}');
    return _services.length;
  }

  int getRouteCount() {
    debugPrint('📊 Getting route count: ${_routes.length}');
    return _routes.length;
  }

  // ========== NOVOS MÉTODOS PARA DOMÍNIOS ==========

  // --- Gestão de Dependências ---

  void registerService<T>(String key, T Function() factory) {
    debugPrint('🔧 Registering service in NavInjector: $key');
    _services[key] = factory;
  }

  T getService<T>(String key) {
    if (_singletonInstances.containsKey(key)) {
      debugPrint('✅ Service found (cached): $key');
      return _singletonInstances[key] as T;
    }

    if (_services.containsKey(key)) {
      debugPrint('✅ Service found (creating instance): $key');
      final instance = _services[key]!() as T;
      _singletonInstances[key] = instance;
      return instance;
    }

    debugPrint('❌ Service not found: $key');
    throw Exception('Service not found: $key');
  }

  bool hasService(String key) {
    final exists = _services.containsKey(key);
    debugPrint('🔍 Checking service "$key": ${exists ? "exists" : "not found"}');
    return exists;
  }

  void removeService(String key) {
    _services.remove(key);
    _singletonInstances.remove(key);
    debugPrint('🗑️ Removed service: $key');
  }

  List<String> getRegisteredServices() {
    debugPrint('📋 Getting registered services: ${_services.keys.toList()}');
    return _services.keys.toList();
  }

  // --- Gestão por Domínios ---

  void registerRouteWithDomain(String domain, String path, Widget Function() builder) {
    debugPrint('📝 Registering route $path for domain $domain');

    // Registrar a rota (usando método existente)
    _routes[path] = builder;

    // Mapear rota -> domínio
    _routeDomains[path] = domain;

    // Mapear domínio -> rotas
    _domainRoutes.putIfAbsent(domain, () => []).add(path);
  }

  List<String> getRoutesByDomain(String domain) {
    final routes = _domainRoutes[domain] ?? [];
    debugPrint('📋 Getting routes for domain "$domain": $routes');
    return routes;
  }

  Map<String, List<String>> getAllDomains() {
    debugPrint('📋 Getting all domains: ${_domainRoutes.keys.toList()}');
    return Map.from(_domainRoutes);
  }

  bool hasDomain(String domain) {
    final exists = _domainRoutes.containsKey(domain);
    debugPrint('🔍 Checking domain "$domain": ${exists ? "exists" : "not found"}');
    return exists;
  }

  String? getDomainForRoute(String route) {
    final domain = _routeDomains[route];
    debugPrint('🔍 Domain for route "$route": ${domain ?? "none"}');
    return domain;
  }

  // --- Gestão de Módulos ---

  void registerModule(
    String moduleName,
    String domain,
    List<String> routes, {
    String? teamOwner,
    String? version,
    bool isRemote = false,
  }) {
    _registeredModules[moduleName] = ModuleInfo(
      name: moduleName,
      domain: domain,
      routes: routes,
      teamOwner: teamOwner,
      version: version,
      isRemote: isRemote,
      registeredAt: DateTime.now(),
    );

    debugPrint('📦 Registered module: $moduleName ($domain) - ${routes.length} routes');
  }

  List<String> getRegisteredModules() {
    debugPrint('📋 Getting registered modules: ${_registeredModules.keys.toList()}');
    return _registeredModules.keys.toList();
  }

  ModuleInfo? getModuleInfo(String moduleName) {
    final info = _registeredModules[moduleName];
    debugPrint('🔍 Module info for "$moduleName": ${info != null ? "found" : "not found"}');
    return info;
  }

  // --- Validações e Debug ---

  List<String> getConflictingRoutes() {
    final conflicts = <String>[];
    final seenRoutes = <String>{};

    for (var route in _routes.keys) {
      if (seenRoutes.contains(route)) {
        conflicts.add(route);
      } else {
        seenRoutes.add(route);
      }
    }

    if (conflicts.isNotEmpty) {
      debugPrint('⚠️ Found conflicting routes: $conflicts');
    }

    return conflicts;
  }

  Map<String, String> getRouteOwnership() {
    debugPrint('📋 Getting route ownership mapping');
    return Map.from(_routeDomains);
  }

  bool validateDomainConsistency(String domain, List<String> expectedRoutes) {
    final actualRoutes = getRoutesByDomain(domain).toSet();
    final expectedRoutesSet = expectedRoutes.toSet();

    final isConsistent =
        actualRoutes.containsAll(expectedRoutesSet) && expectedRoutesSet.containsAll(actualRoutes);

    debugPrint('🔍 Domain "$domain" consistency: ${isConsistent ? "✅ valid" : "❌ invalid"}');

    return isConsistent;
  }

  void printDomainInfo() {
    debugPrint('\n🏗️ Domain Information:');

    if (_domainRoutes.isEmpty) {
      debugPrint(' - No domains registered');
      return;
    }

    for (var entry in _domainRoutes.entries) {
      final domain = entry.key;
      final routes = entry.value;

      debugPrint(' 📁 $domain (${routes.length} routes):');
      for (var route in routes) {
        debugPrint('   🛣️  $route');
      }
    }

    if (_registeredModules.isNotEmpty) {
      debugPrint('\n📦 Registered Modules:');
      for (var module in _registeredModules.values) {
        debugPrint(' 📦 ${module.name} (${module.domain})');
        if (module.teamOwner != null) {
          debugPrint('   👥 ${module.teamOwner}');
        }
        if (module.version != null) {
          debugPrint('   🏷️  v${module.version}');
        }
        debugPrint('   📊 ${module.routes.length} routes');
      }
    }

    debugPrint('');
  }

  // --- Métodos de Limpeza ---

  void removeRoute(String path) {
    _routes.remove(path);

    // Limpar também dos domínios
    final domain = _routeDomains.remove(path);
    if (domain != null) {
      _domainRoutes[domain]?.remove(path);
      if (_domainRoutes[domain]?.isEmpty == true) {
        _domainRoutes.remove(domain);
      }
    }

    debugPrint('🗑️ Removed route: $path');
  }

  void clearAll() {
    _routes.clear();
    _services.clear();
    _singletonInstances.clear();
    _routeDomains.clear();
    _domainRoutes.clear();
    _registeredModules.clear();
    debugPrint('🧹 Cleared all NavInjector data');
  }

  // --- Método de Debug Expandido ---

  void printFullStatus() {
    debugPrint('\n📊 NavInjector Full Status:');
    debugPrint('Routes: ${_routes.length}');
    debugPrint('Services: ${_services.length}');
    debugPrint('Domains: ${_domainRoutes.length}');
    debugPrint('Modules: ${_registeredModules.length}');

    printRegisteredRoutes();
    printDomainInfo();
  }
}

// ========== CLASSE ModuleInfo ==========

class ModuleInfo {
  final String name;
  final String domain;
  final List<String> routes;
  final String? teamOwner;
  final String? version;
  final bool isRemote;
  final DateTime registeredAt;

  const ModuleInfo({
    required this.name,
    required this.domain,
    required this.routes,
    this.teamOwner,
    this.version,
    this.isRemote = false,
    required this.registeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'domain': domain,
      'routes': routes,
      'teamOwner': teamOwner,
      'version': version,
      'isRemote': isRemote,
      'registeredAt': registeredAt.toIso8601String(),
      'routeCount': routes.length,
    };
  }

  @override
  String toString() {
    return 'ModuleInfo(name: $name, domain: $domain, routes: ${routes.length})';
  }
}
