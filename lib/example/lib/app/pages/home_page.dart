// lib/app/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:nav_manager/example/lib/services/user_service.dart';
// Importe a classe da sua dependência
// Importe o ApplicationConfig para acessar o injetor estático
import '../config/application_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variável de estado para armazenar a instância do UserService
  // Inicializamos como null e resolvemos em initState
  UserService? _userService;
  String _configValue = 'Carregando...'; // Estado para exibir o valor de config

  @override
  void initState() {
    super.initState();
    // --- 1. Acesse o injetor estaticamente ---
    final injector = ApplicationConfig.injector;

    try {
      // --- 2. Resolva a dependência do UserService ---
      _userService = injector.resolve<UserService>();

      // --- 3. Use a dependência para obter o valor de configuração ---
      // Atualiza o estado para exibir o valor na UI
      _configValue = _userService!.getConfigValue();
    } catch (e) {
      // Em caso de erro na resolução, atualize o estado para mostrar o erro
      _configValue = 'Erro ao carregar UserService: $e';
      print('Erro ao resolver UserService em initState: $e');
    }

    // Atualiza a UI com o valor de configuração (ou erro)
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // O _userService já foi resolvido e armazenado no estado em initState

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Bem-vindo à Home Page!'),
            const SizedBox(height: 20),

            // Exiba o valor de configuração obtido do UserService (do estado)
            Text('Valor de Configuração do UserService: $_configValue'),

            const SizedBox(height: 20),

            // Botão para imprimir o hashCode no console para verificar se é a mesma instância
            ElevatedButton(
              onPressed: () {
                if (_userService != null) {
                  // Resolva a dependência novamente para comparação
                  final anotherUserServiceInstance =
                      ApplicationConfig.injector.resolve<UserService>();

                  print('HashCode da instância armazenada no estado: ${_userService.hashCode}');
                  print(
                      'HashCode da nova instância resolvida: ${anotherUserServiceInstance.hashCode}');
                  // Se forem iguais, a injeção Singleton funcionou corretamente
                  print(
                      'As instâncias são as mesmas? ${_userService.hashCode == anotherUserServiceInstance.hashCode}');

                  // Opcional: Chamar outro método do UserService
                  // print('Nome do usuário: ${_userService!.getUserName()}');
                } else {
                  print('UserService não foi resolvido.');
                }
              },
              child: const Text('Verificar Instância (Console)'),
            ),

            // ... seus outros widgets e botões ...
          ],
        ),
      ),
    );
  }

  // Opcional: Limpar recursos se necessário (embora para Singletons geralmente não seja preciso)
  // @override
  // void dispose() {
  //   // _userService?.dispose(); // Se UserService tiver um método dispose
  //   super.dispose();
  // }
}

// Assumindo que seu UserService tem algo assim:
/*
class UserService {
  final String configValue;
  UserService(this.configValue);

  String getUserName() {
    return 'Vinicius (Config: $configValue)';
  }

  String getConfigValue() {
    return configValue;
  }
}
*/
