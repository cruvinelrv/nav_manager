// lib/src/nav_manager_core.dart
import 'package:flutter/material.dart'; // Importa Material para GlobalKey
import 'package:nav_manager/src/config/nav_manager_config.dart';
import 'package:nav_manager/src/nova/nav_dependency_injector.dart';
import 'package:nav_manager/src/nova/nav_routes_injector.dart';

class NavManager {
  static NavManager? _instance;

  final NavManagerConfig config;
  final NavDependencyInjector di;
  final NavRoutesInjector navigator; // Agora mantém o NavRoutesInjector

  // Construtor privado
  NavManager._({
    required this.config,
    required this.di,
    required this.navigator, // Recebe o NavRoutesInjector
  });

  // Método de inicialização assíncrona
  static Future<void> initialize({
    required String configPath, // Caminho para o arquivo de configuração
    // O NavManager agora precisa da chave do Navigator do aplicativo consumidor
    required GlobalKey<NavigatorState> navigatorKey,
    // Rotas adicionais do app consumidor (usando sua nova assinatura de builder)
    Map<String, RouteWidgetBuilder> additionalRoutes = const {},
    // Função para configurar as dependências
    required void Function(NavDependencyInjector injector) registerDependencies,
  }) async {
    if (_instance != null) {
      // Já inicializado
      return;
    }

    // 1. Carregar Configuração
    final config = await NavManagerConfig.loadFromAssets(configPath);

    // 2. Inicializar Injetor de Dependência
    final di = NavDependencyInjector();
    di.registerSingletonInstance<NavManagerConfig>(config);
    di.registerSingletonInstance<NavDependencyInjector>(di);

    // Chamar a função fornecida pelo aplicativo consumidor para registrar suas dependências
    registerDependencies(di);

    // Opcional: Registrar dependências internas do package NavManager (se houver)
    // di.register<SomeInternalService>(...);

    // 3. Inicializar Injetor de Rotas (Seu customizado)
    final navigatorInjector = NavRoutesInjector(navigatorKey, di);

    // Registrar rotas internas do package NavManager (se houver)
    // Exemplo:
    // navigatorInjector.registerRoute(
    //   name: '/package-feature',
    //   builder: (context, di, args) => PackageFeatureScreen(
    //     someDependency: di.get<SomePackageDependency>(),
    //     arguments: args,
    //   ),
    // );
    // navigatorInjector.registerRoutes({...}); // Registrar múltiplas rotas do package

    // Registrar rotas adicionais do aplicativo consumidor
    navigatorInjector.registerRoutes(additionalRoutes);

    // 4. Criar a instância do NavManager
    _instance = NavManager._(
      config: config,
      di: di,
      navigator: navigatorInjector, // Passa o NavRoutesInjector configurado
    );
  }

  // Método para obter a instância (getter)
  static NavManager get instance {
    if (_instance == null) {
      throw Exception("NavManager not initialized. Call NavManager.initialize() first.");
    }
    return _instance!;
  }

  // Métodos de conveniência para acessar os componentes
  static NavManagerConfig get config => instance.config;
  static NavDependencyInjector get di => instance.di;
  // Expõe o seu NavRoutesInjector customizado
  static NavRoutesInjector get navigator => instance.navigator;
}
