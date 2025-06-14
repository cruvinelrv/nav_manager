// lib/nav_injector.dart

import 'package:flutter/material.dart'; // Para debugPrint
import 'dart:core'; // Para Type

class NavInjector {
  // Rotas continuam usando String como chave (nome da rota)
  final Map<String, Widget Function()> _routes = {};

  // ✅ MUDANÇA: Gestão de dependências agora usa Type como chave
  final Map<Type, dynamic Function()> _serviceFactories = {}; // Fábricas para criar serviços
  final Map<Type, dynamic> _singletonInstances = {}; // Instâncias de singletons já criadas

  // Gestão por domínios (continua usando String)
  final Map<String, String> _routeDomains = {}; // rota -> domínio
  final Map<String, List<String>> _domainRoutes = {}; // domínio -> [rotas]

  // Gestão de módulos (continua usando String)
  final Map<String, ModuleInfo> _registeredModules = {};

  // ========== MÉTODOS EXISTENTES (Sem alteração para rotas) ==========

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

  // ========== MÉTODOS NECESSÁRIOS PARA O VALIDATOR (Ajustados para serviços) ==========

  List<String> getRegisteredRoutes() {
    debugPrint('📋 Getting registered routes: ${_routes.keys.toList()}');
    return _routes.keys.toList();
  }

  // ✅ MUDANÇA: Conta as fábricas de serviço registradas por Type
  int getDependencyCount() {
    debugPrint('📊 Getting dependency count: ${_serviceFactories.length}');
    return _serviceFactories.length;
  }

  int getRouteCount() {
    debugPrint('📊 Getting route count: ${_routes.length}');
    return _routes.length;
  }

  // ========== NOVOS MÉTODOS PARA DOMÍNIOS (Sem alteração) ==========

  // --- Gestão de Dependências (MODIFICADA) ---

  /// Registra uma fábrica para criar uma instância de serviço do tipo T.
  /// ✅ Usa Type como chave.
  void registerService<T>(T Function() factory) {
    final key = T; // O tipo T é a chave
    if (_serviceFactories.containsKey(key)) {
      debugPrint('⚠️ Service factory already registered for type $T. Overwriting.');
    }
    _serviceFactories[key] = factory;
    // Remova a instância singleton cacheada se houver, para garantir que a nova fábrica seja usada
    _singletonInstances.remove(key);
    debugPrint('🔧 Registered service factory for type: $key');
  }

  /// Resolve e retorna uma instância do serviço registrado para o tipo [T].
  /// ✅ Não espera parâmetro String key. Usa o tipo T para buscar.
  T getService<T>() {
    final key = T; // O tipo T é a chave para buscar

    // 1. Verifica se já existe uma instância singleton cacheada
    if (_singletonInstances.containsKey(key)) {
      debugPrint('✅ Service found (cached): $key');
      return _singletonInstances[key] as T;
    }

    // 2. Verifica se existe uma fábrica registrada para este tipo
    if (_serviceFactories.containsKey(key)) {
      debugPrint('✅ Service factory found (creating instance): $key');
      final factory = _serviceFactories[key]!;
      // Chama a fábrica para criar a instância
      final instance = factory() as T; // A fábrica não recebe parâmetros aqui

      // Cacheia a instância como singleton
      _singletonInstances[key] = instance;
      debugPrint('✅ Created and cached instance for type: $key');

      return instance;
    }

    // 3. Serviço não encontrado
    debugPrint('❌ Service factory not found for type: $key');
    throw Exception('Service factory not found for type $T');
  }

  /// Verifica se um serviço do tipo T está registrado.
  /// ✅ Usa Type como chave.
  bool hasService<T>() {
    final key = T;
    final exists = _serviceFactories.containsKey(key);
    debugPrint('🔍 Checking service factory for type "$key": ${exists ? "exists" : "not found"}');
    return exists;
  }

  /// Remove a fábrica e a instância singleton de um serviço do tipo T.
  /// ✅ Usa Type como chave.
  void removeService<T>() {
    final key = T;
    _serviceFactories.remove(key);
    _singletonInstances.remove(key);
    debugPrint('🗑️ Removed service factory and instance for type: $key');
  }

  /// Retorna uma lista das representações em String dos tipos de serviços registrados.
  /// ✅ Retorna String, mas representa os Types.
  List<String> getRegisteredServices() {
    final types = _serviceFactories.keys.map((type) => type.toString()).toList();
    debugPrint('📋 Getting registered service types: $types');
    return types;
  }

  // --- Gestão por Domínios (Sem alteração) ---

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

  // --- Gestão de Módulos (Sem alteração) ---

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

  // --- Validações e Debug (Sem alteração, exceto onde chamam métodos de serviço) ---

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
        debugPrint(' 🛣️ $route');
      }
    }

    if (_registeredModules.isNotEmpty) {
      debugPrint('\n📦 Registered Modules:');
      for (var module in _registeredModules.values) {
        debugPrint(' 📦 ${module.name} (${module.domain})');
        if (module.teamOwner != null) {
          debugPrint(' 👥 ${module.teamOwner}');
        }
        if (module.version != null) {
          debugPrint(' 🏷️ v${module.version}');
        }
        debugPrint(' 📊 ${module.routes.length} routes');
      }
    }

    debugPrint('');
  }

  // --- Métodos de Limpeza (Ajustados para serviços) ---

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

  // ✅ MUDANÇA: Limpa também os mapas de serviço baseados em Type
  void clearAll() {
    _routes.clear();
    _serviceFactories.clear(); // ✅ Limpa fábricas (Map<Type, ...>)
    _singletonInstances.clear(); // ✅ Limpa singletons (Map<Type, ...>)
    _routeDomains.clear();
    _domainRoutes.clear();
    _registeredModules.clear();
    debugPrint('🧹 Cleared all NavInjector data');
  }

  // --- Método de Debug Expandido (Ajustado para serviços) ---

  void printFullStatus() {
    debugPrint('\n📊 NavInjector Full Status:');
    debugPrint('Routes: ${_routes.length}');
    debugPrint('Services: ${_serviceFactories.length}'); // ✅ Conta fábricas por Type
    debugPrint('Domains: ${_domainRoutes.length}');
    debugPrint('Modules: ${_registeredModules.length}');

    printRegisteredRoutes();
    printDomainInfo();
    // Opcional: Adicionar printRegisteredServices() aqui
  }
}

// ========== CLASSE ModuleInfo (Sem alteração) ==========

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
