// example/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:nav_manager/example/lib/app/config/nav_service_context_extension.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Usa a extensão para obter o serviço
    final navService = context.navService;

    // ✅ Usa a extensão para obter um serviço específico
    // final myApiService = context.getService<MyApiService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome Home!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ✅ Usa o serviço de navegação
                navService.pushNamed('/detail');
              },
              child: const Text('Go to Detail'),
            ),
            // ... outros botões
          ],
        ),
      ),
    );
  }
}
