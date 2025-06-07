// lib/nav_manager.dart (Dentro do seu package nav_manager)

import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';
// Importe os componentes específicos do seu package
// Ajuste os caminhos de importação conforme a estrutura real do seu package
import 'package:provider/provider.dart'; // Importe o package provider

/// Widget raiz que configura o sistema de navegação (Router API)
/// e disponibiliza o NavInjector e o NavManagerService via Provider.
class NavManager extends StatefulWidget {
  /// O widget filho que representa o restante da árvore de widgets do aplicativo.
  /// As rotas iniciais e serviços para este child serão configurados aqui.
  /// Note: Ao usar MaterialApp.router, este child não se torna a 'home',
  /// mas define o escopo onde os Providers e outros widgets globais (como Overlays)
  /// podem ser aplicados acima do Navigator gerenciado pelo RouterDelegate.
  final Widget child;

  /// A rota inicial que o Router deve tentar navegar ao iniciar.
  /// Geralmente '/'.
  final String initialRoute;

  /// O NavInjector pré-configurado com as rotas e serviços do aplicativo.
  final NavInjector injector;

  /// O título do aplicativo. Passado para MaterialApp.router.
  final String title;

  /// O tema do aplicativo. Passado para MaterialApp.router.
  final ThemeData theme;

  const NavManager({
    super.key,
    required this.child,
    required this.initialRoute,
    required this.injector,
    this.title = '', // Pode definir um default ou tornar obrigatório
    required this.theme, // O tema geralmente é obrigatório
  });

  @override
  State<NavManager> createState() => _NavManagerState();
}

class _NavManagerState extends State<NavManager> {
  // ✅ Gerencia a GlobalKey para o Navigator.
  // Criada no initState e persistente durante a vida do State.
  late final GlobalKey<NavigatorState> _navigatorKey;

  // ✅ Gerencia a instância do NavRouter.
  // Criada no initState e persistente durante a vida do State.
  late final NavRouter _navRouter;

  // ✅ Gerencia a instância do NavManagerService.
  // Criada no initState e persistente durante a vida do State.
  late final NavManagerService _navManagerService;

  // ✅ Gerencia a instância do NavRouteInformationParser.
  // Criada no initState e persistente durante a vida do State.
  late final NavRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    debugPrint('🛠️ NavManager: Initializing...');

    // 1. Cria a GlobalKey para o Navigator. Criada apenas uma vez no initState.
    _navigatorKey = GlobalKey<NavigatorState>();

    // 2. O NavInjector é recebido no construtor do widget.
    final navInjector = widget.injector;

    // 3. Cria a instância do NavRouter, passando o injector e a key.
    // O NavRouter gerencia a pilha de navegação e usa a key para o Navigator interno.
    _navRouter = NavRouter(navInjector, _navigatorKey);

    // 4. Cria a instância do NavManagerService, passando o router e o injector.
    // Este serviço usará o router (e sua key) para realizar as operações de navegação.
    // Ele também pode usar o injector para acessar outros serviços.
    _navManagerService = NavManagerService(_navRouter, navInjector);

    // 5. Cria a instância do RouteInformationParser.
    // Responsável por converter a URL em um estado de rota e vice-versa.
    _routeInformationParser = NavRouteInformationParser();

    // O Router API (via MaterialApp.router) cuidará de chamar setNewRoutePath
    // com a rota inicial após a primeira construção.
    // Não precisamos chamar _navRouter.setNewRoutePath(...) explicitamente aqui.
  }

  @override
  void dispose() {
    debugPrint('🗑️ NavManager: Disposing...');
    // ✅ Descarta o NavRouter (que deve ser um ChangeNotifier).
    _navRouter.dispose();
    // Se o NavInjector precisar de dispose (por exemplo, se gerenciar streams/controladores),
    // chame dispose nele aqui. Adicione um método dispose() ao NavInjector se necessário.
    // Exemplo: if (widget.injector is Disposable) (widget.injector as Disposable).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ NavManager: Building...');
    // ✅ Usa MultiProvider para fornecer o NavInjector e o NavManagerService
    // ao contexto, tornando-os acessíveis para os widgets abaixo na árvore.
    return MultiProvider(
      providers: [
        // Fornece a instância do NavInjector
        Provider<NavInjector>.value(
          value: widget.injector,
        ),
        // Fornece a instância do NavManagerService
        Provider<NavManagerService>.value(
          value: _navManagerService,
        ),
        // Opcional: Fornecer o NavRouter se você precisar acessá-lo diretamente
        // Provider<NavRouter>.value(
        // value: _navRouter,
        // ),
      ],
      // ✅ Envolve o MaterialApp.router, que é o widget raiz que implementa
      // a Router API e usa o routerDelegate e routeInformationParser.
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false, // Ou defina conforme sua necessidade
        title: widget.title, // ✅ Use o título passado no construtor do NavManager
        theme: widget.theme, // ✅ Use o tema passado no construtor do NavManager

        // Configura o Router API com as instâncias criadas no initState
        routerDelegate: _navRouter,
        routeInformationParser: _routeInformationParser,

        // O widget child original do NavManager (widget.child) não é colocado
        // diretamente aqui como a 'home' ou um child do MaterialApp.router.
        // A Router API gerencia a exibição das telas através do routerDelegate.
        // O MultiProvider envolvendo o MaterialApp.router garante que
        // os Providers estejam disponíveis para todas as telas gerenciadas
        // pelo NavRouter. O 'widget.child' serve principalmente para o escopo
        // dos Providers e para adicionar widgets que devem estar acima do Navigator
        // (como overlays globais), embora Stack seja mais comum para isso dentro do builder.
        // Se você tiver widgets que devem estar *acima* do Navigator (como um LoadingOverlay global),
        // eles iriam no 'builder' do MaterialApp.router, envolvendo o 'navigator'.
        // Exemplo:
        // builder: (context, navigator) {
        //   return Stack(
        //     children: [
        //       navigator!, // O Navigator construído pelo framework
        //       // Seu widget global (ex: LoadingOverlay())
        //     ],
        //   );
        // },
      ),
    );
  }
}
