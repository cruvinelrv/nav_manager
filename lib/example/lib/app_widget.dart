// lib/app/app_widget.dart (ou onde seu AppWidget estiver)

import 'package:flutter/material.dart';
import 'package:nav_manager/nav_manager.dart';
// Importe o NavManager do seu package
// Importe o NavInjector do seu package

// Mude para StatefulWidget
class AppWidget extends StatefulWidget {
  // O injector ainda é passado para cá, mas será usado no State
  final NavInjector injector;
  const AppWidget({Key? key, required this.injector}) : super(key: key);

  @override
  _AppWidgetState createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  // ✅ Crie a GlobalKey<NavigatorState> aqui no State
  // Ela será persistente durante a vida útil do State
  late final GlobalKey<NavigatorState> _navigatorKey;

  @override
  void initState() {
    super.initState();
    // Inicialize a chave no initState
    _navigatorKey = GlobalKey<NavigatorState>();

    // O injector já foi criado em main e passado para o widget,
    // podemos acessá-lo via widget.injector
    // Não precisamos criar o injector aqui novamente.
  }

  @override
  Widget build(BuildContext context) {
    // NavManager configura o MaterialApp.router e os Providers
    // Passe o injector e a chave persistentes para o NavManager
    return NavManager(
      injector: widget.injector, // ✅ Use o injector passado para o widget
      key: _navigatorKey, // ✅ Passe a chave persistente
      initialRoute: '/',
      // ✅ Remova o MaterialApp aninhado!
      // O NavManager deve estar fornecendo o MaterialApp.router.
      // Se o NavManager permite configurar title e theme, faça aqui:
      title: 'Nav Manager Example App', // Exemplo: se NavManager aceita title
      theme: ThemeData(
        // ✅ Passe o tema aqui
        primarySwatch: Colors.blue,
        // Configure seu tema aqui (cores, fontes, etc.)
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      child: Container(), // Ou null, dependendo da implementação do NavManager
    );
  }

  // Opcional: Limpar o injector se necessário (em dispose)
  // @override
  // void dispose() {
  //   widget.injector.clearAll(); // Exemplo: se você precisa limpar
  //   super.dispose();
  // }
}
